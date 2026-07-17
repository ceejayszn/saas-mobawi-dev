import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class GlobalHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;

  const GlobalHeader({
    super.key,
    this.title = 'Copy App',
    this.showBackButton = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Exit Application?',
            style: TextStyle(
              fontFamily: 'Helvetica',
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          content: const Text(
            'Are you sure you want to close the application?',
            style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Helvetica',
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                SystemNavigator.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F), // Red exit button
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Exit',
                style: TextStyle(
                  fontFamily: 'Helvetica',
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              if (showBackButton && Navigator.canPop(context))
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                )
              else
                const SizedBox(width: 8),

              // Rounded logo container
              Container(
                width: 42,
                height: 42,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Image.asset('assets/logo.png', fit: BoxFit.contain),
              ),
              const SizedBox(width: 14),

              // Title
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Helvetica',
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        letterSpacing: 0.8,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Official Corporate Terminal',
                      style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                        letterSpacing: 0.5,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
              ),

              // Logout/Exit button
              IconButton(
                icon: const Icon(
                  Icons.power_settings_new_rounded,
                  color: Colors.white,
                  size: 26,
                ),
                tooltip: 'Exit Application',
                onPressed: () => _showExitConfirmation(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
