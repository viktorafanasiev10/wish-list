import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'add_wishlist_item_page.dart';
import 'widgets/wishlist_form.dart';
import 'widgets/invite_form.dart';

class WishlistPage extends StatelessWidget {
  final String listId;
  final String? listName; // optional hint from caller
  final String? currentUserEmail; // optional, not used yet

  const WishlistPage({
    super.key,
    required this.listId,
    this.listName,
    this.currentUserEmail,
  });

  DocumentReference<Map<String, dynamic>> get _doc =>
      FirebaseFirestore.instance.collection('wishlists').doc(listId);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _doc.snapshots(),
      builder: (context, snap) {
        // Basic loading/error states
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snap.hasData || !snap.data!.exists) {
          return Scaffold(
            appBar: AppBar(title: Text(listName ?? 'Wishlist')),
            body: const Center(child: Text('Wishlist not found')),
          );
        }

        final data = snap.data!.data()!;
        final name = (data['name'] as String?) ?? listName ?? 'Wishlist';
        final desc = data['description'] as String?;
        final ownerId = data['ownerId'] as String?;
        final memberIds =
            (data['memberIds'] as List?)?.cast<String>() ?? const <String>[];
        final isOwner = ownerId == uid;

        return Scaffold(
          appBar: AppBar(
            title: Text(name),
            actions: [
              if (isOwner)
                IconButton(
                  tooltip: 'Edit wishlist',
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final saved = await showModalBottomSheet<bool>(
                      context: context,
                      isScrollControlled: true,
                      builder:
                          (_) => WishlistForm(
                            id: listId,
                            initialName: name,
                            initialDescription: desc,
                          ),
                    );
                    if (saved == true && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Wishlist updated')),
                      );
                    }
                  },
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (desc != null && desc.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(desc, style: const TextStyle(fontSize: 16)),
                ),

              // Meta: owner/member counts
              Row(
                children: [
                  _MetaChip(
                    icon: Icons.person,
                    label: isOwner ? 'You are the owner' : 'Owner',
                  ),
                  const SizedBox(width: 8),
                  _MetaChip(
                    icon: Icons.group,
                    label: '${memberIds.length + 1} members',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Placeholder for items section (coming next)
              const Text(
                'Items',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream:
                    FirebaseFirestore.instance
                        .collection('wishlists')
                        .doc(listId)
                        .collection('items')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (!snap.hasData || snap.data!.docs.isEmpty) {
                    return Card(
                      elevation: 0.5,
                      child: ListTile(
                        leading: const Icon(Icons.inventory_2_outlined),
                        title: const Text('No items yet'),
                        subtitle: const Text(
                          'Add items to start building this wishlist.',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        AddWishlistItemPage(wishlistId: listId),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }

                  final docs = snap.data!.docs;
                  return ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final d = docs[i].data();
                      final name = (d['name'] as String?) ?? '(no name)';
                      final desc = d['description'] as String?;
                      final reservedBy = d['reservedBy'] as String?;
                      final youReserved = reservedBy == uid;
                      final imageUrl = d['imageUrl'] as String?;
                      final productUrl = d['url'] as String?;

                      return Card(
                        elevation: 0.5,
                        child: ListTile(
                          leading:
                              (imageUrl == null || imageUrl.isEmpty)
                                  ? const CircleAvatar(
                                    child: Icon(Icons.card_giftcard),
                                  )
                                  : CircleAvatar(
                                    backgroundImage: CachedNetworkImageProvider(
                                      imageUrl,
                                    ),
                                    onBackgroundImageError: (_, __) {},
                                  ),
                          title: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (desc != null && desc.trim().isNotEmpty)
                                Text(desc),
                              const SizedBox(height: 4),
                              // reservation label — hidden identity: only the reserver sees it
                              if (youReserved)
                                const Text(
                                  'You reserved this',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                          trailing:
                              isOwner
                                  ? null // owner controls coming later
                                  : (youReserved
                                      ? const Icon(Icons.check_circle_outline)
                                      : const Icon(Icons.lock_open)),
                          onTap: () {
                            // TODO: open item details (and reserve/unreserve) in next iteration
                          },
                        ),
                      );
                    },
                  );
                },
              ),

          if (isOwner) ...[
            const SizedBox(height: 24),

            const Text(
              'Invite',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.person_add),
              label: const Text('Invite by email'),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => InviteForm(wishlistId: listId),
                );
              },
            ),
          ],
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddWishlistItemPage(wishlistId: listId),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add item'),
          ),
        );
      },
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
