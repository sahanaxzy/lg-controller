import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/monument.dart';
import '../services/ssh_service.dart';
import 'monument_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final SSHService sshService;

  const HomeScreen({super.key, required this.sshService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isFlying = false;
  int? _flyingIndex;

  @override
  Widget build(BuildContext context) {
    final isConnected = widget.sshService.isConnected;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(),
            // Connection Status Banner
            _buildConnectionBanner(isConnected),
            // Monument Grid
            Expanded(
              child: _buildMonumentGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          // LG Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C3FB5), Color(0xFF4A7DFF)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.rocket_launch, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Liquid Galaxy Control',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          // WiFi indicator
          Icon(
            widget.sshService.isConnected ? Icons.wifi : Icons.wifi_off,
            color: widget.sshService.isConnected
                ? const Color(0xFF4CAF50)
                : Colors.white54,
            size: 24,
          ),
          const SizedBox(width: 8),
          // Clear overlays button
          if (widget.sshService.isConnected)
            GestureDetector(
              onTap: () async {
                await widget.sshService.clearKML();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Overlays cleared', style: GoogleFonts.poppins()),
                      backgroundColor: const Color(0xFF2E7D32),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              },
              child: const Icon(Icons.layers_clear, color: Colors.white70, size: 22),
            ),
          const SizedBox(width: 8),
          // Settings button
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SettingsScreen(sshService: widget.sshService),
                ),
              );
              setState(() {}); // Refresh connection status
            },
            child: const Icon(Icons.settings, color: Colors.white70, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionBanner(bool isConnected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
            isConnected ? Icons.check_circle : Icons.warning_amber_rounded,
            color: isConnected ? const Color(0xFF81C784) : const Color(0xFFEF9A9A),
            size: 22,
          ),
          const SizedBox(width: 10),
          Text(
            isConnected
                ? 'Connected to Liquid Galaxy'
                : 'Not Connected to Liquid Galaxy',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonumentGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.78,
        ),
        itemCount: Monument.monuments.length,
        itemBuilder: (context, index) {
          return _buildMonumentCard(Monument.monuments[index], index);
        },
      ),
    );
  }

  Widget _buildMonumentCard(Monument monument, int index) {
    final isCurrentlyFlying = _isFlying && _flyingIndex == index;

    return GestureDetector(
      onTap: () => _onMonumentTap(monument, index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A3A5C),
              const Color(0xFF0F2840),
            ],
          ),
          border: Border.all(
            color: isCurrentlyFlying
                ? const Color(0xFF4CAF50)
                : Colors.white.withValues(alpha: 0.1),
            width: isCurrentlyFlying ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isCurrentlyFlying
                  ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.4),
              blurRadius: isCurrentlyFlying ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Monument Image
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      monument.imagePath,
                      fit: BoxFit.cover,
                    ),
                    // Gradient overlay at bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              const Color(0xFF0F2840).withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Flying indicator
                    if (isCurrentlyFlying)
                      Container(
                        color: Colors.black.withValues(alpha: 0.3),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF4CAF50),
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Monument Name
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'FLY to',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF81C784),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        monument.name,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onMonumentTap(Monument monument, int index) async {
    if (!widget.sshService.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please connect to Liquid Galaxy first',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFF991B1B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          action: SnackBarAction(
            label: 'Settings',
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SettingsScreen(sshService: widget.sshService),
                ),
              ).then((_) => setState(() {}));
            },
          ),
        ),
      );
      return;
    }

    // Navigate to detail screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MonumentDetailScreen(
          monument: monument,
          sshService: widget.sshService,
        ),
      ),
    );
  }
}
