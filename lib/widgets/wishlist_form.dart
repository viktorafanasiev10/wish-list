import 'package:flutter/material.dart';
import '../services/wishlist_service.dart';

class WishlistForm extends StatefulWidget {
  final String? id; // null = create, else update
  final String? initialName;
  final String? initialDescription;
  const WishlistForm({
    super.key,
    this.id,
    this.initialName,
    this.initialDescription,
  });

  @override
  State<WishlistForm> createState() => _WishlistFormState();
}

class _WishlistFormState extends State<WishlistForm> {
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _svc = WishlistService();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name.text = widget.initialName ?? '';
    _desc.text = widget.initialDescription ?? '';
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name is required')));
      return;
    }
    setState(() => _saving = true);
    try {
      if (widget.id == null) {
        await _svc.createWishlist(name: _name.text, description: _desc.text);
      } else {
        await _svc.updateWishlist(
          id: widget.id!,
          name: _name.text,
          description: _desc.text,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.id == null ? 'Create wishlist' : 'Edit wishlist',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: _desc,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _saving ? null : _submit,
            child: Text(_saving ? 'Saving…' : 'Save'),
          ),
        ],
      ),
    );
  }
}
