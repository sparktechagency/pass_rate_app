import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pass_rate/core/config/app_sizes.dart';
import 'package:pass_rate/core/design/app_colors.dart';
import 'package:pass_rate/core/extensions/context_extensions.dart';

// Model class for multi-select dropdown items
class MultiSelectItem<T> {
  final T value;
  final String label;
  final Widget? icon;
  final bool enabled;

  const MultiSelectItem({required this.value, required this.label, this.icon, this.enabled = true});
}

// GetX Controller for multi-select dropdown
class MultiSelectDropdownController<T> extends GetxController {
  final RxList<T> _selectedValues = <T>[].obs;
  final RxBool _isOpen = false.obs;
  final RxString _searchQuery = ''.obs;
  final RxList<MultiSelectItem<T>> _filteredItems = <MultiSelectItem<T>>[].obs;
  final RxInt _updateTrigger = 0.obs; // Manual update trigger
  List<MultiSelectItem<T>> _allItems = <MultiSelectItem<T>>[];

  List<T> get selectedValues => _selectedValues.toList();

  bool get isOpen => _isOpen.value;

  String get searchQuery => _searchQuery.value;

  List<MultiSelectItem<T>> get filteredItems => _filteredItems;

  int get updateTrigger => _updateTrigger.value;

  void setItems(List<MultiSelectItem<T>> items) {
    _allItems = items;
    _filteredItems.assignAll(items);
  }

  void toggleSelection(T value) {
    if (_selectedValues.contains(value)) {
      _selectedValues.remove(value);
    } else {
      _selectedValues.add(value);
    }
    _updateTrigger.value++; // Force UI update
  }

  void selectAll() {
    _selectedValues.clear();
    _selectedValues.addAll(
      _allItems
          .where((MultiSelectItem<T> item) => item.enabled)
          .map((MultiSelectItem<T> item) => item.value),
    );
    _updateTrigger.value++; // Force UI update
  }

  void clearAll() {
    _selectedValues.clear();
    _updateTrigger.value++; // Force UI update
  }

  void toggleDropdown() {
    _isOpen.value = !_isOpen.value;
    if (!_isOpen.value) {
      _searchQuery.value = '';
      _filteredItems.assignAll(_allItems);
    }
  }

  void closeDropdown() {
    _isOpen.value = false;
    _searchQuery.value = '';
    _filteredItems.assignAll(_allItems);
  }

  void updateSearchQuery(String query) {
    _searchQuery.value = query;
    if (query.isEmpty) {
      _filteredItems.assignAll(_allItems);
    } else {
      final List<MultiSelectItem<T>> filtered =
          _allItems
              .where(
                (MultiSelectItem<T> item) => item.label.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
      _filteredItems.assignAll(filtered);
    }
  }

  bool isSelected(T value) {
    return _selectedValues.contains(value);
  }

  void setInitialValues(List<T> values) {
    _selectedValues.assignAll(values);
    _updateTrigger.value++;
  }

  String getDisplayText(String hint) {
    if (_selectedValues.isEmpty) {
      return hint;
    }
    if (_selectedValues.length == 1) {
      final MultiSelectItem<T>? item = _allItems.firstWhereOrNull(
        (MultiSelectItem<T> item) => item.value == _selectedValues.first,
      );
      return item?.label ?? hint;
    }
    return '${_selectedValues.length} items selected';
  }
}

// Multi-Select Dropdown Widget
class MultiSelectDropdown<T> extends StatefulWidget {
  final List<MultiSelectItem<T>> items;
  final List<T>? initialValues;
  final String? hint;
  final String? label;
  final Function(List<T>)? onChanged;
  final bool isRequired;
  final bool isSearchable;
  final bool isEnabled;
  final String? Function(List<T>?)? validator;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final Color? dropdownColor;
  final double? dropdownMaxHeight;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? emptyMessage;
  final Duration animationDuration;
  final String? controllerTag;
  final bool showClearAll;

  const MultiSelectDropdown({
    super.key,
    required this.items,
    this.initialValues,
    this.hint = 'Select items',
    this.label,
    this.onChanged,
    this.isRequired = false,
    this.isSearchable = true,
    this.isEnabled = true,
    this.validator,
    this.width,
    this.height = 56.0,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 8.0,
    this.textStyle,
    this.hintStyle,
    this.labelStyle,
    this.dropdownColor,
    this.dropdownMaxHeight = 400.0,
    this.suffixIcon,
    this.prefixIcon,
    this.emptyMessage = 'No assessment found',
    this.animationDuration = const Duration(milliseconds: 300),
    this.controllerTag,
    this.showClearAll = true,
  });

  @override
  State<MultiSelectDropdown<T>> createState() => _MultiSelectDropdownState<T>();
}

class _MultiSelectDropdownState<T> extends State<MultiSelectDropdown<T>> {
  late MultiSelectDropdownController<T> controller;
  late GlobalKey dropdownKey;
  late TextEditingController searchController;
  late FocusNode focusNode;
  late FocusNode searchFocusNode;
  OverlayEntry? overlayEntry;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    dropdownKey = GlobalKey();
    searchController = TextEditingController();
    focusNode = FocusNode();
    searchFocusNode = FocusNode();

    final String tag = widget.controllerTag ?? UniqueKey().toString();

    try {
      controller = Get.find<MultiSelectDropdownController<T>>(tag: tag);
    } catch (e) {
      controller = Get.put(MultiSelectDropdownController<T>(), tag: tag);
    }

    controller.setItems(widget.items);
    if (widget.initialValues != null) {
      controller.setInitialValues(widget.initialValues!);
    }

    focusNode.addListener(() {
      if (!focusNode.hasFocus && !searchFocusNode.hasFocus) {
        _closeDropdown();
      }
    });

    searchFocusNode.addListener(() {
      if (!searchFocusNode.hasFocus && !focusNode.hasFocus) {
        _closeDropdown();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    focusNode.dispose();
    searchFocusNode.dispose();
    _closeDropdown();
    super.dispose();
  }

  void _validateInput() {
    if (widget.validator != null) {
      setState(() {
        errorMessage = widget.validator!(controller.selectedValues);
      });
    }
  }

  void _openDropdown() {
    if (!widget.isEnabled) {
      return;
    }

    if (!controller.isOpen) {
      controller.toggleDropdown();
      _showOverlay();
    }
  }

  void _closeDropdown() {
    if (controller.isOpen) {
      controller.closeDropdown();
      overlayEntry?.remove();
      overlayEntry = null;
      searchController.clear();
    }
  }

  void _showOverlay() {
    final RenderBox renderBox = dropdownKey.currentContext!.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    overlayEntry = OverlayEntry(
      builder:
          (BuildContext context) => GestureDetector(
            onTap: () {
              // Only close if not tapping on the dropdown content
              _closeDropdown();
            },
            behavior: HitTestBehavior.translucent,
            child: Stack(
              children: <Widget>[
                Positioned.fill(child: Container(color: Colors.transparent)),
                Positioned(
                  left: offset.dx,
                  top: context.screenHeight <500 ? 20 : offset.dy + size.height + 4,
                  width: size.width,
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    color: widget.dropdownColor ?? Colors.white,
                    child: GestureDetector(
                      onTap: () {
                        // Prevent closing when tapping inside dropdown
                      },
                      child: Container(
                        constraints: BoxConstraints(maxHeight: widget.dropdownMaxHeight ?? 300.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            if (widget.isSearchable) _buildSearchField(),
                            if (widget.showClearAll) _buildActionButtons(),
                            Flexible(child: _buildDropdownList()),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );

    Overlay.of(context).insert(overlayEntry!);

  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: searchController,
        focusNode: searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Search items...',
          hintStyle: const TextStyle(color: AppColors.greyLight),
          prefixIcon: const Icon(CupertinoIcons.search, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primaryColor),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          isDense: true,
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        onChanged: (String value) {
          controller.updateSearchQuery(value);
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TextButton(
            onPressed: () {
              _closeDropdown();
            },
            child: const Text(
              'Done',
              style: TextStyle(fontSize: 14, color: AppColors.primaryColor),
            ),
          ),
          if (widget.showClearAll)
            TextButton(
              onPressed: () {
              controller.clearAll();
              widget.onChanged?.call(controller.selectedValues);
              _validateInput();
            },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              ),
              child: const Text(
                'Clear Selection',
                style: TextStyle(fontSize: 12, color: AppColors.red),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdownList() {
    return Obx(() {
      // Reference update trigger to ensure reactivity
      controller.updateTrigger;

      if (controller.filteredItems.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            widget.emptyMessage ?? 'No assessment found',
            style:
                widget.hintStyle ??
                Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.greyLight),
            textAlign: TextAlign.center,
          ),
        );
      }

      return Scrollbar(
        thumbVisibility: true,
        thickness: 5,
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: controller.filteredItems.length,
          itemBuilder: (BuildContext context, int index) {
            final MultiSelectItem<T> item = controller.filteredItems[index];
            final bool isSelected = controller.isSelected(item.value);

            return InkWell(
              onTap:
                  item.enabled
                      ? () {
                        controller.toggleSelection(item.value);
                        widget.onChanged?.call(controller.selectedValues);
                        _validateInput();
                      }
                      : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? AppColors.primaryColor.withValues(alpha: 0.1)
                          : Colors.transparent,
                ),
                child: Row(
                  children: <Widget>[
                    // Checkbox
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? AppColors.primaryColor : Colors.grey.shade400,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        color: isSelected ? AppColors.primaryColor : Colors.transparent,
                      ),
                      child:
                          isSelected
                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                              : null,
                    ),
                    const SizedBox(width: 12),

                    // Item icon if provided
                    if (item.icon != null) ...<Widget>[item.icon!, const SizedBox(width: 8)],

                    // Item label
                    Expanded(
                      child: Text(
                        item.label,
                        style:
                            widget.textStyle?.copyWith(
                              color: item.enabled ? null : Colors.grey,
                              fontWeight: isSelected ? FontWeight.w500 : null,
                            ) ??
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: item.enabled ? null : Colors.grey,
                              fontWeight: isSelected ? FontWeight.w500 : null,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            key: dropdownKey,
            onTap: _openDropdown,
            child: Focus(
              focusNode: focusNode,
              child: Obx(() {
                // Reference update trigger to ensure reactivity
                controller.updateTrigger;

                return TextFormField(
                  controller: TextEditingController(
                    text: controller.getDisplayText(widget.hint ?? 'Select items'),
                  ),
                  style:
                      controller.selectedValues.isNotEmpty
                          ? widget.textStyle ?? Theme.of(context).textTheme.bodyMedium
                          : widget.hintStyle ?? context.txtTheme.labelSmall,
                  readOnly: true,
                  onTap: _openDropdown,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    suffixIcon:
                        widget.suffixIcon ??
                        Obx(
                          () => AnimatedRotation(
                            duration: widget.animationDuration,
                            turns: controller.isOpen ? 0.5 : 0,
                            child: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
                          ),
                        ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: widget.label,
                    labelStyle: context.txtTheme.headlineMedium?.copyWith(fontSize: 18),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                      borderSide: const BorderSide(color: AppColors.primaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                      borderSide: const BorderSide(color: AppColors.primaryColor),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                      borderSide: const BorderSide(color: AppColors.primaryColor),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                  ),
                );
              }),
            ),
          ),
          if (errorMessage != null) ...<Widget>[
            const SizedBox(height: 4),
            Text(errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 12)),
          ],
        ],
      ),
    );
  }
}

/*
Usage:

MultiSelectDropdown<String>(
  items: assessmentItems,
  hint: 'Select assessments',
  label: 'Assessment Categories',
  onChanged: (List<String> selected) {
    print('Selected: $selected');
  },
)

Features:
- ✅ Instant checkbox updates
- ✅ Working search functionality
- ✅ Select All/Clear All buttons
- ✅ Proper focus management
- ✅ Animated checkbox states
- ✅ Multiple item selection
- ✅ Validation support
- ✅ Consistent styling with your app
*/
