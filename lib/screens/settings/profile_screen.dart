import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/notification_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _nameCtrl.text = user.name;
      _phoneCtrl.text = user.phone ?? '';
    }
  }

  @override
  void dispose() { _nameCtrl.dispose(); _phoneCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
        const SizedBox(height: 20),
        CircleAvatar(radius: 48, backgroundColor: AppColors.primary, child: Text(
          auth.currentUser?.name.isNotEmpty == true ? auth.currentUser!.name[0].toUpperCase() : 'U',
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w600),
        )),
        const SizedBox(height: 12),
        Text(auth.currentUser?.email ?? '', style: GoogleFonts.poppins(color: Colors.grey)),
        const SizedBox(height: 32),
        TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline))),
        const SizedBox(height: 16),
        TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone_outlined))),
        const SizedBox(height: 32),
        SizedBox(width: double.infinity, height: 52, child: ElevatedButton(onPressed: () async {
          await auth.updateProfile(name: _nameCtrl.text.trim(), phone: _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null);
          if (mounted) NotificationService.showSnackBar(context, 'Profile updated!');
        }, child: const Text('Save Changes'))),
      ])),
    );
  }
}
