import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/category.dart';
import '../../services/category_repository.dart';
import '../../l10n/app_localizations.dart';

enum SaveState { saved, saving, error, unsaved }

class CategoryManagerSheet extends StatefulWidget {
  final String restaurantId;
  final CategoryLiveState initialState;

  const CategoryManagerSheet({
    super.key,
    required this.restaurantId,
    required this.initialState,
  });

  static Future<void> show(
      BuildContext context, String restaurantId, CategoryLiveState state) {
    if (MediaQuery.of(context).size.width > 768) {
      // Desktop - Dialog centré
      return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720, maxHeight: 680),
            child: CategoryManagerSheet(
              restaurantId: restaurantId,
              initialState: state,
            ),
          ),
        ),
      );
    } else {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          final h =
              (MediaQuery.sizeOf(context).height * 0.90).floorToDouble() - 1;
          return SizedBox(
            height: h,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Material(
                color: Colors.white,
                child: CategoryManagerSheet(
                  restaurantId: restaurantId,
                  initialState: state,
                ),
              ),
            ),
          );
        },
      );
    }
  }

  @override
  State<CategoryManagerSheet> createState() => _CategoryManagerSheetState();
}

class _CategoryManagerSheetState extends State<CategoryManagerSheet> {
  late StreamSubscription _stateSubscription;
  late List<String> _categoriesOrder;
  late Set<String> _categoriesHidden;
  late Map<String, int> _counts;

  SaveState _saveState = SaveState.saved;
  DateTime? _lastSaved;
  Timer? _autoSaveTimer;
  String? _editingCategory;
  final TextEditingController _editController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _categoriesOrder = List.from(widget.initialState.order);
    _categoriesHidden = Set.from(widget.initialState.hidden);
    _counts = Map.from(widget.initialState.counts);

    // Listen to live changes
    _stateSubscription = CategoryManager.getLiveState(widget.restaurantId)
        .listen(_handleLiveStateUpdate);
  }

  void _handleLiveStateUpdate(CategoryLiveState state) {
    if (mounted) {
      setState(() {
        _counts = state.counts;
        // Only update if we're not currently editing
        if (_saveState != SaveState.saving) {
          _categoriesOrder = List.from(state.order);
          _categoriesHidden = Set.from(state.hidden);
        }
      });
    }
  }

  void _markUnsaved() {
    setState(() => _saveState = SaveState.unsaved);
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), _autoSave);
  }

  Future<void> _autoSave() async {
    if (_saveState == SaveState.unsaved) {
      await _saveChanges();
    }
  }

  Future<void> _saveChanges() async {
    final l10n = AppLocalizations.of(context)!;

    setState(() => _saveState = SaveState.saving);

    try {
      await CategoryManager.reorderCategories(
          widget.restaurantId, _categoriesOrder);
      setState(() {
        _saveState = SaveState.saved;
        _lastSaved = DateTime.now();
      });
    } catch (e) {
      setState(() => _saveState = SaveState.error);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.adminCategoryManagerSaveError(e.toString())),
            backgroundColor: Colors.red[600],
            action: SnackBarAction(
              label: l10n.adminCategoryManagerRetry,
              textColor: Colors.white,
              onPressed: _saveChanges,
            ),
          ),
        );
      }
    }
  }

  void _reorderCategories(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex--;

    setState(() {
      final category = _categoriesOrder.removeAt(oldIndex);
      _categoriesOrder.insert(newIndex, category);
    });

    HapticFeedback.lightImpact();
    _markUnsaved();
  }

  Future<void> _toggleVisibility(String category) async {
    final wasHidden = _categoriesHidden.contains(category);

    // Optimistic update
    setState(() {
      if (wasHidden) {
        _categoriesHidden.remove(category);
      } else {
        _categoriesHidden.add(category);
      }
    });

    try {
      await CategoryManager.toggleCategoryVisibility(
          widget.restaurantId, category);
    } catch (e) {
      // Rollback on error
      setState(() {
        if (wasHidden) {
          _categoriesHidden.add(category);
        } else {
          _categoriesHidden.remove(category);
        }
      });
      rethrow;
    }
  }

  void _startRename(String category) {
    setState(() {
      _editingCategory = category;
      _editController.text = category;
    });
  }

  Future<void> _confirmRename() async {
    final oldName = _editingCategory!;
    final newName = _editController.text.trim();

    if (newName.isEmpty || newName == oldName) {
      _cancelRename();
      return;
    }

    _cancelRename();

    // Show confirmation dialog with progress
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _RenameConfirmationDialog(
        oldName: oldName,
        newName: newName,
        itemCount: _counts[oldName] ?? 0,
        onConfirm: () => _performRename(oldName, newName),
      ),
    );

    if (confirmed == true) {
      // Rename was completed in dialog
    }
  }

  Future<bool> _performRename(String oldName, String newName) async {
    // optimistic (maj order + hidden set)
    final wasHidden = _categoriesHidden.remove(oldName);
    final i = _categoriesOrder.indexOf(oldName);
    if (i != -1) _categoriesOrder[i] = newName;
    if (wasHidden) _categoriesHidden.add(newName);
    setState(() {}); // évite le “glitch” visuel

    // APRÈS :
    try {
      await CategoryManager.renameCategory(
          widget.restaurantId, oldName, newName);
      return true; // Succès
    } catch (e) {
      // rollback
      final j = _categoriesOrder.indexOf(newName);
      if (j != -1) _categoriesOrder[j] = oldName;
      _categoriesHidden.remove(newName);
      if (wasHidden) _categoriesHidden.add(oldName);
      setState(() {});
      return false; // Échec
    }
  }

  void _cancelRename() {
    setState(() {
      _editingCategory = null;
      _editController.clear();
    });
  }

  String _uniqueNewName([String? base]) {
    final l10n = AppLocalizations.of(context)!;
    base ??= l10n.adminCategoryManagerDefaultName;
    var name = base;
    var n = 2;
    while (_categoriesOrder.contains(name)) {
      name = '$base $n';
      n++;
    }
    return name;
  }

  Future<void> _addCategory() async {
    final newName = _uniqueNewName();
    setState(() => _categoriesOrder.add(newName));
    _startRename(newName);

    try {
      await CategoryManager.addCategory(widget.restaurantId, newName);
    } catch (_) {
      setState(() => _categoriesOrder.remove(newName));
      rethrow;
    }
  }

  Future<void> _deleteCategory(String category) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.adminCategoryManagerDeleteTitle),
          content: Text(l10n.adminCategoryManagerDeleteMessage(category)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.adminCategoryManagerDeleteAction),
            )
          ],
        );
      },
    );
    if (ok != true) return;
    // optimistic
    final idx = _categoriesOrder.indexOf(category);
    if (idx != -1) setState(() => _categoriesOrder.removeAt(idx));
    try {
      await CategoryManager.deleteCategory(widget.restaurantId, category);
    } catch (_) {
      // rollback
      setState(() => _categoriesOrder.insert(idx, category));
      rethrow;
    }
  }

  @override
  void dispose() {
    _stateSubscription.cancel();
    _autoSaveTimer?.cancel();
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 768;

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobile ? 16 : 12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildHeader(),
          Expanded(child: _buildCategoriesList()),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final isSmallScreen = MediaQuery.of(context).size.width < 420;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: isSmallScreen
          ? Column(
              // Mobile : empilement vertical
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.reorder,
                        size: 20,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Builder(
                            builder: (context) => Text(
                              AppLocalizations.of(context)!
                                  .adminCategoryManagerTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                          Builder(
                            builder: (context) => Text(
                              AppLocalizations.of(context)!
                                  .adminCategoryManagerSubtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: const Color(0xFF6B7280),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SaveIndicator(state: _saveState, lastSaved: _lastSaved),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: _addCategory,
                      icon: const Icon(Icons.add, size: 16),
                      label: Builder(
                        builder: (context) => Text(AppLocalizations.of(context)!
                            .adminCategoryManagerNew),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              // Desktop : ton Row existant
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.reorder,
                    size: 20,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Builder(
                        builder: (context) => Text(
                          AppLocalizations.of(context)!
                              .adminCategoryManagerTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Builder(
                        builder: (context) => Text(
                          AppLocalizations.of(context)!
                              .adminCategoryManagerSubtitleFull,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SaveIndicator(state: _saveState, lastSaved: _lastSaved),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: _addCategory,
                  icon: const Icon(Icons.add, size: 16),
                  label: Builder(
                    builder: (context) => Text(
                        AppLocalizations.of(context)!.adminCategoryManagerNew),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  color: const Color(0xFF6B7280),
                ),
              ],
            ),
    );
  }

  Widget _buildCategoriesList() {
    return ReorderableListView.builder(
      padding: EdgeInsets.fromLTRB(16, 16, 16,
          72 + (MediaQuery.viewInsetsOf(context).bottom > 0 ? 8 : 0)),
      physics: const ClampingScrollPhysics(),
      itemCount: _categoriesOrder.length,
      onReorder: _reorderCategories,
      buildDefaultDragHandles: false,
      itemBuilder: (context, index) {
        final category = _categoriesOrder[index];
        return CategoryTile(
          key: ValueKey(category),
          index: index, // Garde l'index pour le drag
          category: category,
          count: _counts[category] ?? 0,
          isHidden: _categoriesHidden.contains(category),
          isEditing: _editingCategory == category,
          editController: _editController,
          onToggleVisibility: () => _toggleVisibility(category),
          onStartRename: () => _startRename(category),
          onConfirmRename: _confirmRename,
          onCancelRename: _cancelRename,
          onDelete: () => _deleteCategory(category),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.touch_app, size: 16, color: Color(0xFF6B7280)),
                const SizedBox(width: 8),
                Flexible(
                  child: Builder(
                    builder: (context) => Text(
                      AppLocalizations.of(context)!
                          .adminCategoryManagerDragHint,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF6B7280)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Compteur seulement si assez large
          if (MediaQuery.sizeOf(context).width >= 420)
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4F46E5),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Builder(
                  builder: (context) => Text(
                    AppLocalizations.of(context)!
                        .adminCategoryManagerCount(_categoriesOrder.length),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// Save Indicator Widget
class SaveIndicator extends StatelessWidget {
  final SaveState state;
  final DateTime? lastSaved;

  const SaveIndicator({
    super.key,
    required this.state,
    this.lastSaved,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    switch (state) {
      case SaveState.unsaved:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.circle, size: 8, color: Color(0xFFF59E0B)),
            const SizedBox(width: 6),
            Text(
              l10n.adminCategoryManagerUnsaved,
              style: const TextStyle(fontSize: 12, color: Color(0xFFF59E0B)),
            ),
          ],
        );
      case SaveState.saving:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Color(0xFF3B82F6)),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              l10n.adminCategoryManagerSaving,
              style: const TextStyle(fontSize: 12, color: Color(0xFF3B82F6)),
            ),
          ],
        );
      case SaveState.saved:
        final timeAgo = lastSaved != null
            ? '${DateTime.now().difference(lastSaved!).inSeconds}s'
            : '';
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check, size: 12, color: Color(0xFF10B981)),
            const SizedBox(width: 6),
            Text(
              timeAgo.isNotEmpty
                  ? l10n.adminCategoryManagerSavedAgo(timeAgo)
                  : l10n.adminCategoryManagerSaved,
              style: const TextStyle(fontSize: 12, color: Color(0xFF10B981)),
            ),
          ],
        );
      case SaveState.error:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 12, color: Color(0xFFEF4444)),
            const SizedBox(width: 6),
            Text(
              l10n.adminCategoryManagerError,
              style: const TextStyle(fontSize: 12, color: Color(0xFFEF4444)),
            ),
          ],
        );
    }
  }
}

// Category Tile Widget
class CategoryTile extends StatefulWidget {
  final int index;
  final String category;
  final int count;
  final bool isHidden;
  final bool isEditing;
  final TextEditingController editController;
  final VoidCallback onToggleVisibility;
  final VoidCallback onStartRename;
  final VoidCallback onConfirmRename;
  final VoidCallback onCancelRename;
  final VoidCallback onDelete;

  const CategoryTile({
    super.key,
    required this.index,
    required this.category,
    required this.count,
    required this.isHidden,
    required this.isEditing,
    required this.editController,
    required this.onToggleVisibility,
    required this.onStartRename,
    required this.onConfirmRename,
    required this.onCancelRename,
    required this.onDelete,
  });

  @override
  State<CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.fastOutSlowIn),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: Container(
          height: 60,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: _scaleAnimation.value > 1.0
                  ? const Color(0xFF4F46E5)
                  : const Color(0xFFE5E7EB),
              width: _scaleAnimation.value > 1.0 ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: _scaleAnimation.value > 1.0
                ? [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              _buildDragHandle(),
              Expanded(child: _buildContent()),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return ReorderableDragStartListener(
      index: widget.index,
      child: GestureDetector(
        onTapDown: (_) => _scaleController.forward(),
        onTapUp: (_) => _scaleController.reverse(),
        onTapCancel: () => _scaleController.reverse(),
        child: Container(
          width: 44,
          height: 44,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.drag_indicator,
            size: 18,
            color: Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.isEditing) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: TextField(
          controller: widget.editController,
          onSubmitted: (_) => widget.onConfirmRename(),
          onTapOutside: (_) => widget.onCancelRename(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF4F46E5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          autofocus: true,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.category,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                    decoration:
                        widget.isHidden ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.isHidden) ...[
                  const SizedBox(height: 2),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Builder(
                      builder: (context) => Text(
                        AppLocalizations.of(context)!
                            .adminCategoryManagerHiddenBadge,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${widget.count}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Visibility toggle
          Builder(builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Semantics(
              label: widget.isHidden
                  ? l10n.adminCategoryManagerShowSemantic(widget.category)
                  : l10n.adminCategoryManagerHideSemantic(widget.category),
              child: IconButton(
                onPressed: widget.onToggleVisibility,
                icon: Icon(
                  widget.isHidden ? Icons.visibility : Icons.visibility_off,
                  size: 18,
                ),
                color: widget.isHidden
                    ? const Color(0xFF10B981)
                    : const Color(0xFF6B7280),
                tooltip: widget.isHidden
                    ? l10n.adminCategoryManagerShowAction
                    : l10n.adminCategoryManagerHideAction,
              ),
            );
          }),

          // Edit
          Builder(builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Semantics(
              label: l10n.adminCategoryManagerRenameSemantic(widget.category),
              child: IconButton(
                onPressed: widget.onStartRename,
                icon: const Icon(Icons.edit, size: 18),
                color: const Color(0xFF6B7280),
                tooltip: l10n.adminCategoryManagerRenameAction,
              ),
            );
          }),

          // Delete
          if (widget.count == 0)
            Builder(builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Semantics(
                label: l10n.adminCategoryManagerDeleteSemantic(widget.category),
                child: IconButton(
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete, size: 18),
                  color: const Color(0xFFEF4444),
                  tooltip: l10n.adminCategoryManagerDeleteAction,
                ),
              );
            }),
        ],
      ),
    );
  }
}

// Rename Confirmation Dialog with Progress
class _RenameConfirmationDialog extends StatefulWidget {
  final String oldName;
  final String newName;
  final int itemCount;
  final Future<bool> Function() onConfirm;

  const _RenameConfirmationDialog({
    required this.oldName,
    required this.newName,
    required this.itemCount,
    required this.onConfirm,
  });

  @override
  State<_RenameConfirmationDialog> createState() =>
      _RenameConfirmationDialogState();
}

class _RenameConfirmationDialogState extends State<_RenameConfirmationDialog> {
  bool _isProcessing = false;
  double _progress = 0.0;

  Future<void> _handleConfirm() async {
    setState(() => _isProcessing = true);

    // Simulate progress for batch update
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) setState(() => _progress = i / 100);
    }

    final success = await widget.onConfirm();

    if (mounted) {
      Navigator.of(context).pop(success);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Builder(
        builder: (context) =>
            Text(AppLocalizations.of(context)!.adminCategoryManagerRenameTitle),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(
            builder: (context) => Text(
              AppLocalizations.of(context)!.adminCategoryManagerRenameMessage(
                widget.oldName,
                widget.newName,
                widget.itemCount,
              ),
              style: const TextStyle(color: Color(0xFF374151)),
            ),
          ),
          if (_isProcessing) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF4F46E5)),
            ),
            const SizedBox(height: 8),
            Builder(
              builder: (context) => Text(
                AppLocalizations.of(context)!
                    .adminCategoryManagerRenameProgress(
                  (_progress * 100).toInt(),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (!_isProcessing) ...[
          Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.commonCancel),
            ),
          ),
          Builder(
            builder: (context) => FilledButton(
              onPressed: _handleConfirm,
              child: Text(
                  AppLocalizations.of(context)!.adminCategoryManagerConfirm),
            ),
          ),
        ],
      ],
    );
  }
}
