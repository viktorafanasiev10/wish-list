import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/wishlist_service.dart';
import 'widgets/wishlist_form.dart';
import 'wishlist_page.dart';

class WishlistListPage extends StatelessWidget {
  const WishlistListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final svc = WishlistService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlists'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
        stream: svc.myWishlistsStream(uid),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!;
          if (docs.isEmpty) {
            return const Center(
              child: Text('No wishlists yet. Create your first!'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final d = docs[i].data();
              final id = docs[i].id;
              final name = (d['name'] as String?) ?? '(no name)';
              final desc = d['description'] as String?;
              final isOwner = d['ownerId'] == uid;
              return Card(
                elevation: 0.5,
                child: ListTile(
                  leading: CircleAvatar(child: Text(name[0].toUpperCase())),
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(desc ?? (isOwner ? 'Owner' : 'Member')),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (_) => WishlistPage(
                              listId: id,
                              listName: name,
                              currentUserEmail:
                                  FirebaseAuth.instance.currentUser!.email,
                            ),
                      ),
                    );
                  },
                  trailing:
                      isOwner
                          ? IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              final saved = await showModalBottomSheet<bool>(
                                context: context,
                                isScrollControlled: true,
                                builder:
                                    (_) => WishlistForm(
                                      id: id,
                                      initialName: name,
                                      initialDescription: desc,
                                    ),
                              );
                              if (saved == true && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Wishlist updated'),
                                  ),
                                );
                              }
                            },
                          )
                          : null,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            builder: (_) => const WishlistForm(),
          );
          if (created == true && context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Wishlist created')));
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('New list'),
      ),
    );
  }
}
