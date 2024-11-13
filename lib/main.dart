import 'package:dock/state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int dragElementIndex = -1;
  Offset dockPosition = const Offset(0, 370);

  final items = Get.put(Controller());
  int isHover = -1;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Center(
              child: Dock(
                items: items.items,
                builder: (e) {
                  return DragTarget(
                    builder: (context, candidate, reject) {
                      return Obx(() => Draggable(
                          data: items.items.indexOf(e),
                          feedback: Container(
                            constraints: const BoxConstraints(minWidth: 48),
                            height: 48,
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.primaries[
                                  e.hashCode % Colors.primaries.length],
                            ),
                            child: Center(child: Icon(e)),
                          ),
                          childWhenDragging: dragElementIndex == -1
                              ? Container(
                                  constraints:
                                      const BoxConstraints(minWidth: 48),
                                  height: 48,
                                  margin: const EdgeInsets.all(8),
                                )
                              : const SizedBox.shrink(),
                          onDragStarted: () {},
                          maxSimultaneousDrags: 1,
                          affinity: Axis.horizontal,
                          // get the position of the dragged item
                          onDragUpdate: (details) {
                            Offset dragPosition = details.globalPosition;

                            if (dragPosition.dy < 350 || dragPosition.dx > 0) {
                              setState(() {
                                dragElementIndex = items.items.indexOf(e);
                              });
                            }
                          },
                          onDragEnd: (details) {
                            setState(() {
                              dragElementIndex = -1;
                              isHover = -1;
                            });
                          },
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            onHover: (event) {
                              setState(() {
                                isHover = items.items.indexOf(e);
                              });
                            },
                            onExit: (event) {
                              setState(() {
                                isHover = -1;
                              });
                            },
                            child: AnimatedScale(
                              scale: isHover == items.items.indexOf(e)
                                  ? 1.13
                                  : 1.0,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              child: Transform.translate(
                                offset: Offset(0,
                                    isHover == items.items.indexOf(e) ? -2 : 0),
                                child: Container(
                                  constraints:
                                      const BoxConstraints(minWidth: 48),
                                  height: 48,
                                  margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.primaries[
                                        e.hashCode % Colors.primaries.length],
                                  ),
                                  child: Center(child: Icon(e)),
                                ),
                              ),
                            ),
                          )));
                    },
                    onWillAcceptWithDetails: (data) {
                      return true;
                    },
                    onAcceptWithDetails: (data) {
                      items.onAcceptWithDetails(data, e);
                      setState(() {
                        dragElementIndex = -1;
                      });
                    },
                  );
                },
              ),
            );
          },
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
  final List<T> items;

  /// Builder building the provided [T] item.
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T> extends State<Dock<T>> {
  /// [T] items being manipulated.
  // late List<T> _items = widget.items.toList();

  @override
  Widget build(BuildContext context) {
    List<IconData> _items = Get.put(Controller()).items.value;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _items.map((e) => widget.builder(e as T)).toList(),
      ),
    );
  }
}
