import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/monument.dart';
import '../services/ssh_service.dart';

class MonumentDetailScreen extends StatefulWidget {
  final Monument monument;
  final SSHService sshService;

  const MonumentDetailScreen({
    super.key,
    required this.monument,
    required this.sshService,
  });

  @override
  State<MonumentDetailScreen> createState() => _MonumentDetailScreenState();
}

class _MonumentDetailScreenState extends State<MonumentDetailScreen> {
  bool _isOrbiting = false;
  Timer? _orbitTimer;
  double _currentHeading = 0;

  @override
  void initState() {
    super.initState();
    _flyToMonument();
  }

  @override
  void dispose() {
    _stopOrbit();
    super.dispose();
  }

  Future<void> _flyToMonument() async {
    if (!widget.sshService.isConnected) return;
    await widget.sshService.flyToMonument(
      name: widget.monument.name,
      latitude: widget.monument.latitude,
      longitude: widget.monument.longitude,
      altitude: widget.monument.altitude,
      heading: widget.monument.heading,
      tilt: widget.monument.tilt,
      range: widget.monument.range,
      country: widget.monument.country,
      year: widget.monument.yearOfInscription,
      category: widget.monument.category,
      description: widget.monument.description,
    );
  }

  void _startOrbit() {
    if (!widget.sshService.isConnected) return;
    setState(() => _isOrbiting = true);
    _currentHeading = 0;

    _orbitTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      _currentHeading = (_currentHeading + 2) % 360;
      widget.sshService.flyTo(
        widget.monument.latitude,
        widget.monument.longitude,
        widget.monument.altitude,
        _currentHeading,
        widget.monument.tilt,
        widget.monument.range,
      );
    });
  }

  void _stopOrbit() {
    _orbitTimer?.cancel();
    _orbitTimer = null;
    if (mounted) {
      setState(() => _isOrbiting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final monument = widget.monument;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1A2E),
      body: Stack(
        children: [
          // Full-screen monument image
          Positioned.fill(
            child: Image.asset(
              monument.imagePath,
              fit: BoxFit.cover,
            ),
          ),
          // Gradient overlay from bottom
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    const Color(0xFF0A1A2E).withValues(alpha: 0.7),
                    const Color(0xFF0A1A2E).withValues(alpha: 0.95),
                    const Color(0xFF0A1A2E),
                  ],
                  stops: const [0.0, 0.35, 0.55, 0.75, 1.0],
                ),
              ),
            ),
          ),
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () {
                _stopOrbit();
                Navigator.pop(context);
              },
            ),
          ),
          // Content at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Globe icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.public,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Monument name
                    Text(
                      monument.name,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Info rows
                    Text(
                      'Country: ${monument.country}',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Year of Inscription: ${monument.yearOfInscription}',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Category: ${monument.category}',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Start/Stop Orbit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isOrbiting ? _stopOrbit : _startOrbit,
                        icon: Icon(
                          _isOrbiting ? Icons.stop : Icons.play_arrow,
                          size: 24,
                        ),
                        label: Text(
                          _isOrbiting ? 'Stop Orbit' : 'Start Orbit',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isOrbiting
                              ? const Color(0xFFD32F2F)
                              : const Color(0xFF1E88E5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
