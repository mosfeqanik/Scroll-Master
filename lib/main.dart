import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';


final class Sections {
  final String value;

  Sections({required this.value});
}

final sections = [
  Sections(value: "one"),
  Sections(value: "two"),
  Sections(value: "three"),
  Sections(value: "four"),
  Sections(value: "five"),
];

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});
  @override
  State<MainApp> createState() => _MainApp();
}

class _MainApp extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ScrollController _scroller = ScrollController()
    ..addListener(_handleScrollChanged);
  void _handleScrollChanged() {
    _scrollPos.value = _scroller.position.pixels;
  }

  final _scrollPos = ValueNotifier(0.0);
  final _sectionIndex = ValueNotifier(0);
  final currentContext = ValueNotifier<BuildContext?>(null);
  final List<GlobalKey> myKeys = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scrolling Master"),
      ),
      body: CustomScrollView(
        controller: _scroller,
        // scrollBehavior: ScrollConfiguration.of(context).copyWith(),
        key: const PageStorageKey('editorial'),
        slivers: [
          SliverAppBar(
            pinned: true,
            // floating: true,
            // collapsedHeight: 80,
            toolbarHeight: 80,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: _AppBar(
              sectionIndex: _sectionIndex,
              keys: myKeys,
              sections: sections,
              controller: _scroller,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  currentContext.value = context;
                  return Container(
                      height: 300,
                      key: myKeys[index],
                      margin: const EdgeInsets.all(17),
                      color: Colors.purple.shade100,
                      child: SectionDivider(
                        scrollNotifier: _scrollPos,
                        sectionNotifier: _sectionIndex,
                        index: index,
                        values: sections[index].value,
                      ));
                },
                childCount: sections.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 400,
            ),
          )
        ],
      ),
    );
  }
}

class _AppBar extends StatefulWidget {
  const _AppBar(
      {Key? key,
      required this.sectionIndex,
      required this.keys,
      required this.controller,
      required this.sections})
      : super(key: key);
  final ValueNotifier<int> sectionIndex;
  final List<GlobalKey> keys;
  final List<Sections> sections;
  final ScrollController controller;
  @override
  State<_AppBar> createState() => _AppBarState();
}

class _AppBarState extends State<_AppBar> {
  @override
  Widget build(BuildContext context) {
    return BottomCenter(
      child: ValueListenableBuilder<int>(
        valueListenable: widget.sectionIndex,
        builder: (_, value, __) {
          double barSize = 100; // the actual size of this widget

          return Transform.translate(
            offset: const Offset(0, 1),
            child: SizedBox(
              height: barSize,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.sections.length,
                  itemBuilder: ((context, currentIndex) {
                    return TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: value == currentIndex
                                ? Colors.purple
                                : Colors.black,
                            splashFactory: InkSparkle.splashFactory,
                            shape: const StadiumBorder()),
                        onPressed: () {
                          if (widget.sectionIndex.value != currentIndex) {
                            log(currentIndex.toString(), name: "TAPPED INDEX");
                            widget.sectionIndex.value = currentIndex;
                            log("${widget.sectionIndex.value}",
                                name: "SELECTION INDEX");
                            final targetContext =
                                widget.keys[currentIndex].currentContext;
                            if (targetContext != null) {
                              log(currentIndex.toString(),
                                  name: "Calling value");
                              Scrollable.ensureVisible(
                                targetContext,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                              // ScrollController().createScrollPosition(physics, context, oldPosition)
                            } else {
                              final sectionPosition =
                                  currentIndex * 300.0; // Adjust as needed
                              widget.controller.animateTo(
                                sectionPosition,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                              log(targetContext.toString(),
                                  name: "Context AVAILABLE $currentIndex");
                            }
                          }
                        },
                        child: Text(widget.sections[currentIndex].value)
                            .animate(key: ValueKey(currentIndex))
                            .fade()
                            .scale(
                                begin: .5,
                                end: 1,
                                curve: Curves.easeOutBack,
                                duration: 400.ms));
                  })),
            ),
          );
        },
      ),
    );
  }
}

class BottomCenter extends Align {
  const BottomCenter(
      {Key? key, double? widthFactor, double? heightFactor, Widget? child})
      : super(
            key: key,
            widthFactor: widthFactor,
            heightFactor: heightFactor,
            child: child,
            alignment: Alignment.bottomCenter);
}
class SectionDivider extends StatefulWidget {
  const SectionDivider(
      {Key? key,
      required this.index,
      required this.scrollNotifier,
      required this.sectionNotifier,
      required this.values})
      : super(key: key);
  final int index;
  final ValueNotifier<double> scrollNotifier;
  final ValueNotifier<int> sectionNotifier;
  final String values;

  @override
  State<SectionDivider> createState() => SectionDividerState();
}

class SectionDividerState extends State<SectionDivider>
    with SingleTickerProviderStateMixin {
  final _isActivated = ValueNotifier(false);

  double _getSwitchPt(BuildContext c) => MediaQuery.of(c).size.height * 0.5;

  void _checkPosition(BuildContext context) {
    final yPos = ContextUtils.getGlobalPos(context)?.dy;

    if (yPos == null || yPos < 0) return;
    // Only allow headers to switch if it's above the switch pt
    bool activated = yPos < _getSwitchPt(context);
    if (activated != _isActivated.value) {
      scheduleMicrotask(() {
        // When activated, set our index as active. When de-activated, set it to the index before ours (index - 1).
        int newIndex = activated ? widget.index : widget.index - 1;
        widget.sectionNotifier.value = newIndex;
      });
      _isActivated.value = activated;
    }
  }

  @override
  Widget build(BuildContext context) {
    // When scroll position changes, the divider needs to check whether it should mark itself as the active index
    return ValueListenableBuilder<double>(
      valueListenable: widget.scrollNotifier,
      builder: (context, value, _) {
        _checkPosition(context);
        return ValueListenableBuilder<bool>(
          valueListenable: _isActivated,
          builder: (_, value, __) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(widget.values),
          ),
        );
      },
    );
  }
}

class ContextUtils {
  static Offset? getGlobalPos(BuildContext context,
      [Offset offset = Offset.zero]) {
    final rb = context.findRenderObject() as RenderBox?;
    if (rb?.hasSize == true) {
      return rb?.localToGlobal(offset);
    }
    return null;
  }

  static Size? getSize(BuildContext context) {
    final rb = context.findRenderObject() as RenderBox?;
    if (rb?.hasSize == true) {
      return rb?.size;
    }
    return null;
  }
}