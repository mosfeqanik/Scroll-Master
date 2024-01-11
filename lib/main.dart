// import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scroll_master/scroll_common.dart';
import 'package:scroll_master/scroll_listener.dart';

import 'scroll_content.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ScrollController _scroller = ScrollController()
    ..addListener(_handleScrollChanged);
  void _handleScrollChanged() {
    _scrollPos.value = _scroller.position.pixels;
  }

  final _scrollPos = ValueNotifier(0.0);
  final _sectionIndex = ValueNotifier(0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      body: LayoutBuilder(builder: (context, constraints) {
        bool shortMode = constraints.biggest.height < 700;
        double minAppBarHeight = shortMode ? 80 : 150;
        // double maxAppBarHeight =
        //     min(MediaQuery.of(context).size.width, 800) * 1.2;

        return PopRouterOnOverScroll(
            controller: _scroller,
            child: TopCenter(
              child: FocusTraversalGroup(
                child: FullscreenKeyboardListScroller(
                  scrollController: _scroller,
                  child: CustomScrollView(
                    controller: _scroller,
                    // scrollBehavior: ScrollConfiguration.of(context).copyWith(),
                    key: const PageStorageKey('editorial'),
                    slivers: [
                      SliverAppBar(
                        pinned: true,
                        // floating: true,
                        title: Text("Scrolling Master"),
                        collapsedHeight: minAppBarHeight,
                        toolbarHeight: minAppBarHeight,
                        backgroundColor: Colors.white,
                        elevation: 0,
                        flexibleSpace: SizedBox.expand(
                          child: _AppBar(
                            sectionIndex: _sectionIndex,
                          ),
                        ),
                      ),

                      /// Editorial content (text and images)
                      ScrollingContent(
                          scrollPos: _scrollPos,
                          sectionNotifier: _sectionIndex),
                    ],
                  ),
                ),
              ),
            ));
      }),
    );
  }
}

class TopCenter extends Align {
  const TopCenter(
      {Key? key, double? widthFactor, double? heightFactor, Widget? child})
      : super(
            key: key,
            widthFactor: widthFactor,
            heightFactor: heightFactor,
            child: child,
            alignment: Alignment.topCenter);
}

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

class _AppBar extends StatelessWidget {
  const _AppBar({
    Key? key,
    required this.sectionIndex,
  }) : super(key: key);
  final ValueNotifier<int> sectionIndex;
  @override
  Widget build(BuildContext context) {
    return BottomCenter(
      child: ValueListenableBuilder<int>(
        valueListenable: sectionIndex,
        builder: (_, value, __) {
          return _CircularTitleBar(
            index: value,
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

class _CircularTitleBar extends StatelessWidget {
  const _CircularTitleBar({Key? key, required this.index}) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    double barSize = 100; // the actual size of this widget

    // note: this offset eliminates a subpixel line Flutter draws below the header
    return Transform.translate(
      offset: const Offset(0, 1),
      child: SizedBox(
        height: barSize,
        child: SizedBox(
          height: 50,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sections.length,
              itemBuilder: ((context, currentIndex) {
                return TextButton(
                    style: OutlinedButton.styleFrom(
                        foregroundColor: index == currentIndex
                            ? Colors.purple
                            : Colors.black),
                    onPressed: (() {}),
                    child: Text('index$currentIndex')
                        .animate(key: ValueKey(currentIndex))
                        .fade()
                        .scale(
                            begin: .5,
                            end: 1,
                            curve: Curves.easeOutBack,
                            duration: 400.ms));
              })),
        ),
      ),
    );
  }
}
