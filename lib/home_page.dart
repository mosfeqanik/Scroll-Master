import 'package:flutter/material.dart';

import 'bottom_center.dart';
import 'main.dart';
import 'section_descripion.dart';

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
  void dispose() {
    _scroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scrolling Master"),
      ),
      body: CustomScrollView(
        controller: _scroller,
        key: const PageStorageKey('editorial'),
        slivers: [
          SliverAppBar(
            pinned: true,
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
                      child: SectionDescription(
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
                            widget.sectionIndex.value = currentIndex;

                            final targetContext =
                                widget.keys[currentIndex].currentContext;
                            if (targetContext != null) {
                              Scrollable.ensureVisible(
                                targetContext,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              final sectionPosition =
                                  currentIndex * 300.0; // Adjust as needed
                              widget.controller.animateTo(
                                sectionPosition,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            }
                          }
                        },
                        child: Text(widget.sections[currentIndex].value));
                  })),
            ),
          );
        },
      ),
    );
  }
}
