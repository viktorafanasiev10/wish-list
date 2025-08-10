import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AddWishlistItemPage extends StatefulWidget {
  final String wishlistId;
  const AddWishlistItemPage({super.key, required this.wishlistId});

  @override
  State<AddWishlistItemPage> createState() => _AddWishlistItemPageState();
}

class _AddWishlistItemPageState extends State<AddWishlistItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _productUrlController = TextEditingController();

  XFile? _picked;
  double _uploadProgress = 0.0;
  bool _isSaving = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() => _picked = picked);
    }
  }

  Future<String?> _uploadImage({required String listId, required String itemId}) async {
    if (_picked == null) return null;
    final ext = _picked!.name.split('.').last.toLowerCase();
    final path = 'wishlists/$listId/$itemId.$ext';

    final ref = FirebaseStorage.instance.ref(path);
    final task = ref.putFile(
      File(_picked!.path),
      SettableMetadata(contentType: ext == 'png' ? 'image/png' : 'image/jpeg'),
    );

    task.snapshotEvents.listen((snap) {
      if (snap.totalBytes > 0) {
        setState(() => _uploadProgress = snap.bytesTransferred / snap.totalBytes);
      }
    });

    await task.whenComplete(() {});
    return await ref.getDownloadURL();
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isSaving = true; _uploadProgress = 0; });

    final itemId = const Uuid().v4();
    final user = FirebaseAuth.instance.currentUser;
    String? imageUrl;

    try {
      // Upload image first (if any)
      imageUrl = await _uploadImage(listId: widget.wishlistId, itemId: itemId);

      // Save Firestore doc
      await FirebaseFirestore.instance
          .collection('wishlists')
          .doc(widget.wishlistId)
          .collection('items')
          .doc(itemId)
          .set({
        'id': itemId,
        'name': _nameController.text.trim(),
        'description': _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        'url': _productUrlController.text.trim().isEmpty ? null : _productUrlController.text.trim(), // product page
        'imageUrl': imageUrl, // direct image (may be null)
        'reservedBy': null,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': user?.uid,
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save item: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _picked != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Item')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Image picker + preview
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 96, height: 96,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: hasImage
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(File(_picked!.path), width: 96, height: 96, fit: BoxFit.cover),
                    )
                        : const Icon(Icons.image, size: 36),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        OutlinedButton.icon(
                          onPressed: _isSaving ? null : _pickImage,
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Upload image'),
                        ),
                        if (_isSaving && _uploadProgress > 0 && _uploadProgress < 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: LinearProgressIndicator(value: _uploadProgress),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Item name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _productUrlController,
                decoration: const InputDecoration(labelText: 'Product page URL (optional)'),
                keyboardType: TextInputType.url,
              ),

              const SizedBox(height: 20),
              _isSaving
                  ? const CircularProgressIndicator()
                  : FilledButton.icon(
                onPressed: _saveItem,
                icon: const Icon(Icons.save),
                label: const Text('Save item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}