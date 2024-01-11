import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SectionDivider extends StatefulWidget {
  const SectionDivider(this.scrollNotifier, this.sectionNotifier,
      {Key? key, required this.index})
      : super(key: key);
  final int index;
  final ValueNotifier<double> scrollNotifier;
  final ValueNotifier<int> sectionNotifier;

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
            child: Column(
              children: [
                Text("index${widget.sectionNotifier.value}"),
                CompassDivider(isExpanded: value),
              ],
            ),
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

class CompassDivider extends StatelessWidget {
  const CompassDivider(
      {Key? key,
      required this.isExpanded,
      this.duration,
      this.linesColor,
      this.compassColor})
      : super(key: key);
  final bool isExpanded;
  final Duration? duration;
  final Color? linesColor;
  final Color? compassColor;

  @override
  Widget build(BuildContext context) {
    Duration duration = this.duration ?? 1500.ms;
    Widget buildHzAnimatedDivider({bool alignLeft = false}) {
      return TweenAnimationBuilder<double>(
        duration: duration,
        tween: Tween(begin: 0, end: isExpanded ? 1 : 0),
        curve: Curves.easeOut,
        child: Divider(
            height: 1, thickness: .5, color: linesColor ?? Colors.purple),
        builder: (_, value, child) {
          return Transform.scale(
            scaleX: value,
            alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
            child: child!,
          );
        },
      );
    }

    return Row(
      children: [
        Expanded(child: buildHzAnimatedDivider()),
        const SizedBox(
          height: 20,
        ),
        TweenAnimationBuilder<double>(
          duration: duration,
          tween: Tween(begin: 0, end: isExpanded ? .5 : 0),
          curve: Curves.easeOutBack,
          builder: (_, value, child) => Transform.rotate(
            angle: value * pi * 2,
            child: child,
          ),
          child: const SizedBox(
              height: 32, width: 32, child: Icon(Icons.done_all)),
        ),
        const SizedBox(
          height: 20,
        ),
        Expanded(child: buildHzAnimatedDivider(alignLeft: true)),
      ],
    );
  }
}
