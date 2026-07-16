import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// يخلي أي منطقة تمرير تستجيب لأسهم لوحة المفاتيح (فوق/تحت) بالويب، متل أي
/// موقع عادي — لفّي فيها الـ SingleChildScrollView/ListView الرئيسي لأي شاشة،
/// ومرّري لها نفس الـ [controller] المستخدم بهيك القائمة.
class KeyboardScrollable extends StatefulWidget {
  final ScrollController controller;
  final Widget child;
  const KeyboardScrollable({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  State<KeyboardScrollable> createState() => _KeyboardScrollableState();
}

class _KeyboardScrollableState extends State<KeyboardScrollable> {
  final FocusNode _focusNode = FocusNode(
    debugLabel: 'KeyboardScrollable',
    skipTraversal: true,
  );

  static const double _lineStep = 90;
  static const double _pageFactor = 0.8;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollBy(double delta) {
    final controller = widget.controller;
    if (!controller.hasClients) return;
    final target = (controller.offset + delta).clamp(
      0.0,
      controller.position.maxScrollExtent,
    );
    controller.jumpTo(target);
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final controller = widget.controller;
    if (!controller.hasClients) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown) {
      _scrollBy(_lineStep);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _scrollBy(-_lineStep);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.pageDown) {
      _scrollBy(controller.position.viewportDimension * _pageFactor);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.pageUp) {
      _scrollBy(-controller.position.viewportDimension * _pageFactor);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKey,
      child: widget.child,
    );
  }
}
