import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class CustomNotificationService {
  static void show(
    BuildContext context,
    String message, {
    bool persistent = false,
    VoidCallback? onClose,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 60,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFCD34D), // Jaune (accent)
                  Color(0xFFF97316), // Orange (secondary)
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color.fromRGBO(255, 255, 255, 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: persistent
                ? Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10, right: 30),
                        child: Text(
                          message,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 17.6,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            overlayEntry.remove();
                            if (onClose != null) {
                              onClose();
                            }
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: AppColors.accent,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Text(
                    message,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 17.6,
                    ),
                  ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto-suppression seulement si pas persistant
    if (!persistent) {
      Future.delayed(const Duration(seconds: 3), () {
        if (overlayEntry.mounted) {
          overlayEntry.remove();
        }
      });
    }
  }
}
