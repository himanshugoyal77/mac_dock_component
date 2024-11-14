import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(e, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<IconData> items;

  /// Builder building the provided [T] item.
  final Widget Function(IconData) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T> extends State<Dock<T>> {
  /// [T] items being manipulated.
  late final List<IconData> _items = widget.items.toList();

  /// List of icon labels and associated icons. Used for tooltips.
  final List<String> _itemsString = const [
    "Icons.person",
    "Icons.message",
    "Icons.call",
    "Icons.camera",
    "Icons.photo",
  ];

  /// List of open apps to display an indicator
  List<IconData> openApps = [Icons.person];

  /// The item that is currently being dragged, if any
  IconData? _draggingItem;

  /// Tracks the hover state by index for highlighting.
  int hoveredItem = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _items
            .asMap()
            .entries
            .map((entry) => _buildDraggableIcon(entry))
            .toList(),
      ),
    );
  }

  /// Builds a draggable icon widget for a specific entry in [_items].
  ///
  /// This method sets up each icon as draggable and determines spacing between neighboring icons.
  /// The item widget will display differently when it’s near a dragged item to provide visual feedback.
  Widget _buildDraggableIcon(MapEntry<int, IconData> entry) {
    final int index = entry.key;
    final IconData item = entry.value;
    final bool isNeighbor = _draggingItem != null &&
        (_items.indexOf(_draggingItem!) == index - 1 ||
            _items.indexOf(_draggingItem!) == index + 1);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInToLinear,
      margin: EdgeInsets.symmetric(horizontal: isNeighbor ? 4.0 : 6.0),
      child: Draggable<IconData>(
        data: item,
        maxSimultaneousDrags: 1,
        feedback: widget.builder(item),
        childWhenDragging: FutureBuilder<void>(
          future: _shrinkAfterDelay(item),
          builder: (context, snapshot) {
            return snapshot.connectionState == ConnectionState.done
                ? const SizedBox.shrink()
                : widget.builder(item);
          },
        ),
        onDragStarted: () => setState(() => _draggingItem = item),
        onDragCompleted: () => setState(() => _draggingItem = null),
        onDraggableCanceled: (_, __) => setState(() {
          _draggingItem = null;
          hoveredItem = -1;
        }),
        child: _buildDragTarget(item, index),
      ),
    );
  }

  /// Builds a `DragTarget` for each item, enabling it to accept dragged items.
  ///
  /// When a new item is accepted, the dock updates the list order and redraws the items.
  Widget _buildDragTarget(IconData item, int index) {
    return DragTarget<IconData>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (data) {
        setState(() {
          int fromIndex = _items.indexOf(data.data);
          _items.removeAt(fromIndex);
          _items.insert(index, data.data);
          _draggingItem = null;
        });
      },
      builder: (context, candidateData, rejectedData) {
        return _buildTooltipItem(item, index);
      },
    );
  }

  /// Builds a widget with a tooltip and hover effect.
  ///
  /// Adds a tooltip to each item and animates its size on hover.
  Widget _buildTooltipItem(IconData item, int index) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onHover: (_) => setState(() => hoveredItem = _items.indexOf(item)),
      onExit: (_) => setState(() => hoveredItem = -1),
      child: Tooltip(
        message: _itemsString[_items.indexOf(item)],
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(5),
        ),
        textStyle: const TextStyle(color: Colors.white),
        waitDuration: const Duration(milliseconds: 200),
        showDuration: const Duration(seconds: 2),
        preferBelow: false,
        margin: const EdgeInsets.only(bottom: 12),
        child: _buildIconColumn(item),
      ),
    );
  }

  /// Creates an animated column for the icon, with scaling for hover effects.
  ///
  /// The column also displays an indicator when the item is active in [openApps].
  Widget _buildIconColumn(IconData item) {
    return AnimatedScale(
      scale: hoveredItem == _items.indexOf(item) ? 1.1 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.linear,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 5),
          GestureDetector(
            onTap: () {
              setState(() {
                openApps.contains(item)
                    ? openApps.remove(item)
                    : openApps.add(item);
              });
            },
            child: widget.builder(item),
          ),
          const SizedBox(height: 5),
          Icon(
            Icons.circle,
            size: 5,
            color: openApps.contains(item) ? Colors.white : Colors.transparent,
          ),
        ],
      ),
    );
  }

  /// Delays shrinking when dragging starts.
  Future<void> _shrinkAfterDelay(IconData item) async {
    if (_draggingItem == item) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }
}
