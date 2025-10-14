import 'dart:async';

import 'package:flutter/material.dart';

import 'context_utils.dart';

class SectionDescription extends StatefulWidget {
  const SectionDescription(
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
  State<SectionDescription> createState() => SectionDescriptionState();
}

class SectionDescriptionState extends State<SectionDescription>
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
