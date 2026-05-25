import 'package:flutter/material.dart';

class CustomNavigationRailDestination {
  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final bool? disabled;

  CustomNavigationRailDestination({
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.disabled,
  });
}

class CustomNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final List<CustomNavigationRailDestination> destinations;

  const CustomNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: destinations.asMap().entries.map((entry) {
        return _CustomNavigationRailItem(
          index: entry.key,
          destination: entry.value,
          isSelected: entry.key == selectedIndex,
          onDestinationSelected: onDestinationSelected,
        );
      }).toList(),
    );
  }
}

class _CustomNavigationRailItem extends StatefulWidget {
  final int index;
  final CustomNavigationRailDestination destination;
  final bool isSelected;
  final Function(int) onDestinationSelected;

  const _CustomNavigationRailItem({
    required this.index,
    required this.destination,
    required this.isSelected,
    required this.onDestinationSelected,
  });

  @override
  State<_CustomNavigationRailItem> createState() =>
      _CustomNavigationRailItemState();
}

class _CustomNavigationRailItemState extends State<_CustomNavigationRailItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final bool isDisabled = widget.destination.disabled ?? false;
    final bool isActive = widget.isSelected || _isHovered;
    final Color activeColor = colorScheme.primary.withValues(alpha: 0.12);
    final Color selectedColor = colorScheme.primary;
    final Color defaultColor = colorScheme.onSurface;
    final Color disabledColor = colorScheme.onSurface.withValues(alpha: 0.38);

    return MouseRegion(
      cursor: isDisabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: isDisabled
          ? null
          : (_) {
              setState(() {
                _isHovered = true;
              });
            },
      onExit: isDisabled
          ? null
          : (_) {
              setState(() {
                _isHovered = false;
              });
            },
      child: InkWell(
        onTap: isDisabled
            ? null
            : () => widget.onDestinationSelected(widget.index),
        child: AnimatedContainer(
          width: double.infinity,
          alignment: Alignment.centerLeft,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          color: isActive ? activeColor : Colors.transparent,
          child: Row(
            children: [
              Icon(
                widget.isSelected && widget.destination.selectedIcon != null
                    ? widget.destination.selectedIcon
                    : widget.destination.icon,
                color: isDisabled
                    ? disabledColor
                    : widget.isSelected
                    ? selectedColor
                    : defaultColor,
              ),
              const SizedBox(width: 8.0),
              Text(
                widget.destination.label,
                style: TextStyle(
                  color: isDisabled
                      ? disabledColor
                      : widget.isSelected
                      ? selectedColor
                      : defaultColor,
                  fontWeight: widget.isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
