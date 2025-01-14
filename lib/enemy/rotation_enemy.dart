import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/assets_loader.dart';
import 'package:flutter/widgets.dart';

/// Enemy used for top-down perspective
class RotationEnemy extends Enemy with WithSpriteAnimation, WithAssetsLoader {
  SpriteAnimation? animIdle;
  SpriteAnimation? animRun;

  RotationEnemy({
    required Vector2 position,
    required Vector2 size,
    required Future<SpriteAnimation> animIdle,
    required Future<SpriteAnimation> animRun,
    double currentRadAngle = -1.55,
    double speed = 100,
    double life = 100,
  }) : super(
          position: position,
          size: size,
          life: life,
          speed: speed,
        ) {
    angle = currentRadAngle;
    loader?.add(AssetToLoad(animIdle, (value) {
      this.animIdle = value;
    }));
    loader?.add(AssetToLoad(animRun, (value) {
      this.animRun = value;
    }));
  }

  @override
  void moveFromAngleDodgeObstacles(
    double speed,
    double angle, {
    VoidCallback? onCollision,
  }) {
    this.animation = animRun;
    this.angle = angle;
    super.moveFromAngleDodgeObstacles(speed, angle, onCollision: onCollision);
  }

  void idle() {
    this.animation = animIdle;
    super.idle();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    idle();
  }
}
