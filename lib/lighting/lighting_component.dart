import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/lighting/lighting.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:flutter/widgets.dart';

abstract class LightingInterface {
  void animateToColor(
    Color color, {
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.decelerate,
  });
}

/// Layer component responsible for adding lighting to the game.
class LightingComponent extends GameComponent implements LightingInterface {
  Color? color;
  late Paint _paintFocus;
  Paint _paintLighting = Paint();
  Iterable<Lighting> _visibleLight = [];
  double _dtUpdate = 0.0;
  ColorTween? _tween;

  @override
  PositionType get positionType => PositionType.viewport;

  LightingComponent({this.color}) {
    _paintFocus = Paint()..blendMode = BlendMode.clear;
  }

  @override
  int get priority {
    return LayerPriority.getLightingPriority(gameRef.highestPriority);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (!_containsColor()) return;
    Vector2 size = gameRef.camera.canvasSize;
    canvas.saveLayer(Offset.zero & Size(size.x, size.y), Paint());
    canvas.drawColor(color!, BlendMode.dstATop);
    _visibleLight.forEach((light) {
      final config = light.lightingConfig;
      if (config == null) return;
      final sigma = _convertRadiusToSigma(config.blurBorder);
      config.update(_dtUpdate);
      canvas.save();

      canvas.translate(
        -(gameRef.camera.position.x),
        -(gameRef.camera.position.y),
      );

      canvas.drawCircle(
        Offset(
          light.center.x,
          light.center.y,
        ),
        config.radius *
            (config.withPulse
                ? (1 - config.valuePulse * config.pulseVariation)
                : 1),
        _paintFocus
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            sigma,
          ),
      );

      _paintLighting
        ..color = config.color
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          sigma,
        );
      canvas.drawCircle(
        light.center.toOffset(),
        config.radius *
            (config.withPulse
                ? (1 - config.valuePulse * config.pulseVariation)
                : 1),
        _paintLighting,
      );

      canvas.restore();
    });
    canvas.restore();
  }

  static double _convertRadiusToSigma(double radius) {
    return radius * 0.57735 + 0.5;
  }

  @override
  // ignore: must_call_super
  void update(double dt) {
    if (!_containsColor()) return;
    _dtUpdate = dt;
    _visibleLight = gameRef.lightVisible();
  }

  void animateToColor(
    Color color, {
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.decelerate,
  }) {
    _tween = ColorTween(begin: this.color ?? Color(0x00000000), end: color);

    gameRef.getValueGenerator(
      duration,
      onChange: (value) {
        this.color = _tween?.transform(value);
      },
      onFinish: () {
        this.color = color;
      },
      curve: curve,
    ).start();
  }

  bool _containsColor() {
    return color != null && color != Color(0x00000000);
  }
}
