import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'section_divider.dart';

class ScrollingContent extends StatelessWidget {
  const ScrollingContent(
      {Key? key, required this.scrollPos, required this.sectionNotifier})
      : super(key: key);
  final ValueNotifier<double> scrollPos;
  final ValueNotifier<int> sectionNotifier;
  @override
  Widget build(BuildContext context) {
    return SliverBackgroundColor(
      color: Colors.white,
      sliver: SliverPadding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        sliver: SliverList(
          delegate: SliverChildListDelegate.fixed([
            Center(
              child: SizedBox(
                // width: 800,
                child: Column(children: [
                  SectionDivider(scrollPos, sectionNotifier, index: 0),
                  const HeightBox(150),
                  const HeightBox(150),
                  const HeightBox(150),
                  SectionDivider(scrollPos, sectionNotifier, index: 1),
                  const HeightBox(150),
                  const HeightBox(150),
                  const HeightBox(150),
                  SectionDivider(scrollPos, sectionNotifier, index: 2),
                  const HeightBox(150),
                  const HeightBox(150),
                  const HeightBox(150),
                  SectionDivider(scrollPos, sectionNotifier, index: 3),
                  const HeightBox(150),
                  const HeightBox(150),
                  const HeightBox(150),
                  SectionDivider(scrollPos, sectionNotifier, index: 4),
                  const HeightBox(150),
                  const HeightBox(150),
                  const HeightBox(150),
                  const HeightBox(150),
                  const HeightBox(150),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class SliverBackgroundColor extends SingleChildRenderObjectWidget {
  const SliverBackgroundColor({
    Key? key,
    required this.color,
    Widget? sliver,
  }) : super(key: key, child: sliver);
  final Color color;

  @override
  RenderSliverBackgroundColor createRenderObject(BuildContext context) {
    return RenderSliverBackgroundColor(
      color,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderSliverBackgroundColor renderObject) {
    renderObject.color = color;
  }
}

class RenderSliverBackgroundColor extends RenderProxySliver {
  RenderSliverBackgroundColor(this._color);

  Color get color => _color;
  Color _color;
  set color(Color value) {
    if (value == color) {
      return;
    }
    _color = color;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null && child!.geometry!.visible) {
      final SliverPhysicalParentData childParentData =
          child!.parentData! as SliverPhysicalParentData;
      final Rect childRect = offset + childParentData.paintOffset &
          Size(constraints.crossAxisExtent, child!.geometry!.paintExtent);
      context.canvas.drawRect(
          childRect,
          Paint()
            ..style = PaintingStyle.fill
            ..color = color);
      context.paintChild(child!, offset + childParentData.paintOffset);
    }
  }
}

class HeightBox extends StatelessWidget {
  const HeightBox(this.defaultHeight, {super.key, this.height = 0, this.width});
  final double? height, width, defaultHeight;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: defaultHeight,
      width: width,
    );
  }
}
