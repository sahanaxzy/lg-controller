import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ssh_service.dart';

class SettingsScreen extends StatefulWidget {
  final SSHService sshService;

  const SettingsScreen({super.key, required this.sshService});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _ipController = TextEditingController(text: '192.168.239.3');
  final _portController = TextEditingController(text: '22');
  final _usernameController = TextEditingController(text: 'lg');
  final _passwordController = TextEditingController(text: 'sahanakb2!');
  bool _obscurePassword = true;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ipController.text = prefs.getString('lg_ip') ?? '192.168.239.3';
      _portController.text = prefs.getString('lg_port') ?? '22';
      _usernameController.text = prefs.getString('lg_username') ?? 'lg';
      _passwordController.text =
          prefs.getString('lg_password') ?? 'sahanakb2!';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lg_ip', _ipController.text);
    await prefs.setString('lg_port', _portController.text);
    await prefs.setString('lg_username', _usernameController.text);
    await prefs.setString('lg_password', _passwordController.text);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Settings saved successfully!',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _connect() async {
    setState(() => _isConnecting = true);

    final success = await widget.sshService.connect(
      host: _ipController.text.trim(),
      port: int.tryParse(_portController.text.trim()) ?? 22,
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isConnecting = false);

    if (mounted) {
      final errorMsg = widget.sshService.lastError ?? 'Unknown error';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Connected to Liquid Galaxy! ✅'
                : 'Failed to connect: $errorMsg',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor:
              success ? const Color(0xFF2E7D32) : const Color(0xFF991B1B),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _disconnect() async {
    await widget.sshService.disconnect();
    setState(() {});

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Disconnected from Liquid Galaxy',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFF7F1D1D),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = widget.sshService.isConnected;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            _buildAppBar(),
            // Connection banner
            _buildConnectionBanner(isConnected),
            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildForm(),
              ),
            ),
            // Action buttons
            _buildActionButtons(isConnected),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2840),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'LG Connection Settings',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const Icon(Icons.settings, color: Colors.white54, size: 22),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildConnectionBanner(bool isConnected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isConnected
              ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
              : [const Color(0xFF7F1D1D), const Color(0xFF991B1B)],
        ),
      ),
      child: Row(
        children: [
          Icon(
            isConnected
                ? Icons.check_circle
                : Icons.warning_amber_rounded,
            color: isConnected
                ? const Color(0xFF81C784)
                : const Color(0xFFEF9A9A),
            size: 28,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isConnected ? 'Connected to Liquid Galaxy' : 'Not Connected',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              if (!isConnected)
                Text(
                  'Disconnected',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF162D4A).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            label: 'LG Master IP',
            controller: _ipController,
            icon: Icons.computer,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'SSH Port',
            controller: _portController,
            icon: Icons.tag,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Username',
            controller: _usernameController,
            icon: Icons.person,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Password',
            controller: _passwordController,
            icon: Icons.lock,
            isPassword: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white54,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword && _obscurePassword,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white54, size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white54,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFF0F2840),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isConnected) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Connect / Disconnect button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isConnecting
                  ? null
                  : (isConnected ? _disconnect : _connect),
              icon: _isConnecting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      isConnected ? Icons.link_off : Icons.wifi,
                      size: 20,
                    ),
              label: Text(
                _isConnecting
                    ? 'Connecting...'
                    : (isConnected ? 'Disconnect' : 'Connect'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isConnected
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Save button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _saveSettings,
              icon: const Icon(Icons.save, size: 20),
              label: const Text('Save'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4CAF50),
                side: const BorderSide(color: Color(0xFF4CAF50), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
