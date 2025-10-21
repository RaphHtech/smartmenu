import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/design/client_tokens.dart';
import '../../core/constants/colors.dart';

enum ToastVariant { success, info, warning, error }

class _ToastEntry {
  OverlayEntry? entry;
  late final AnimationController controller;
  _ToastEntry(this.entry, this.controller);
}

class TopToast {
  static _ToastEntry? _current;

  static Future<void> show(
    BuildContext context, {
    required String message,
    String? subtitle,
    ToastVariant variant = ToastVariant.info,
    Duration duration = const Duration(seconds: 3),
    bool haptic = true,
  }) async {
    // Haptic feedback selon le type
    if (haptic) {
      switch (variant) {
        case ToastVariant.success:
          HapticFeedback.lightImpact();
          break;
        case ToastVariant.error:
          HapticFeedback.heavyImpact();
          break;
        default:
          HapticFeedback.selectionClick();
      }
    }

    // Fermer le toast précédent
    await dismiss();

    await Future.delayed(const Duration(milliseconds: 100));
    if (!context.mounted) return;
    final overlay = Overlay.of(context);
    final theme = Theme.of(context);

    Color getAccentColor(ToastVariant v) {
      switch (v) {
        case ToastVariant.success:
          return AppColors.success;
        case ToastVariant.info:
          return AppColors.info;
        case ToastVariant.warning:
          return AppColors.warning;
        case ToastVariant.error:
          return AppColors.error;
      }
    }

    IconData getIcon(ToastVariant v) {
      switch (v) {
        case ToastVariant.success:
          return Icons.check_circle_rounded;
        case ToastVariant.info:
          return Icons.info_rounded;
        case ToastVariant.warning:
          return Icons.warning_amber_rounded;
        case ToastVariant.error:
          return Icons.error_rounded;
      }
    }

    final accentColor = getAccentColor(variant);
    const backgroundColor = AppColors.surface; // Blanc au lieu de noir
    const textColor = AppColors.textPrimary; // Texte foncé
    final controller = AnimationController(
      duration: ClientTokens.durationNormal,
      reverseDuration: ClientTokens.durationFast,
      vsync: Navigator.of(context),
    );

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    ));

    final fadeAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    );

    final entry = OverlayEntry(
      builder: (context) {
        final topPadding = MediaQuery.of(context).padding.top;

        return Positioned(
          top: topPadding + ClientTokens.space16,
          left: ClientTokens.space16,
          right: ClientTokens.space16,
          child: SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: IgnorePointer(
                ignoring: false, // Permettre interaction pour dismiss
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Material(
                      color: backgroundColor,
                      elevation: ClientTokens.elevationModal,
                      borderRadius:
                          BorderRadius.circular(ClientTokens.radius16),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: dismiss, // Tap pour fermer
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: accentColor,
                                width: 4,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(ClientTokens.space16),
                            child: Row(
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.all(ClientTokens.space8),
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    getIcon(variant),
                                    color: accentColor,
                                    size: 20,
                                  ),
                                ),

                                const SizedBox(width: ClientTokens.space12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        message,
                                        style:
                                            theme.textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: textColor,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (subtitle != null) ...[
                                        const SizedBox(
                                            height: ClientTokens.space4),
                                        Text(
                                          subtitle,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: textColor.withValues(
                                                alpha: 0.8),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                // Indicateur dismiss subtil
                                Icon(
                                  Icons.close,
                                  size: 16,
                                  color: textColor.withValues(alpha: 0.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);
    _current = _ToastEntry(entry, controller);

    await controller.forward();

    // Auto-dismiss après la durée spécifiée
    Future.delayed(duration, dismiss);
  }

  static Future<void> dismiss() async {
    final current = _current;
    if (current == null) return;

    _current = null;
    await current.controller.reverse();
    current.entry?.remove();
    current.controller.dispose();
  }
}
