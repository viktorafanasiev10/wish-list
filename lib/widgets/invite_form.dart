import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../services/invitation_service.dart';

class InviteForm extends StatefulWidget {
  final String wishlistId;
  const InviteForm({super.key, required this.wishlistId});

  @override
  State<InviteForm> createState() => _InviteFormState();
}

class _InviteFormState extends State<InviteForm> {
  final _email = TextEditingController();
  final _svc = InvitationService();
  bool _sending = false;
  final _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  Future<void> _submit() async {
    final email = _email.text.trim();
    if (!_emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email')),
      );
      return;
    }
    setState(() => _sending = true);
    try {
      final link = await _svc.createInvitation(
        email: email,
        wishlistId: widget.wishlistId,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      await Share.share(link, subject: 'Join my wishlist');
    } finally {
      if (mounted) setState(() => _sending = false);
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
          const Text(
            'Invite member',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _sending ? null : _submit,
            child: Text(_sending ? 'Sending…' : 'Send invite'),
          ),
        ],
      ),
    );
  }
}

