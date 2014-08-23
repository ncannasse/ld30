package ent;
import Data;

class Interact extends Entity {

	var ikind : IKind;

	public function new(k, x, y) {
		ikind = k;
		super(EInt(k), x, y);
		switch( k ) {
		case Heart:
			isCollide = true;
		case Stairs:
			spr.visible = false;
		case Teleport:
			spr.speed = 4;
			spr.y += 2;
		}
	}

	override function wakeUp() {
		switch( ikind ) {
		case Stairs:
			spr.visible = true;
		default:
		}
	}

	override function collideWith( e : Entity ) {
		switch( [ikind, e.kind] ) {
		case [Heart, EHero]:
			return false;
		default:
		}
		return true;
	}

	override function init() {
		var g = Res.anims.toTile().grid(16);
		var tl = [];
		var nframes = 4;
		for( i in 0...nframes ) { var t = g[ikind.getIndex() * 16 + i + 8]; t.dx = -8; t.dy = -16; tl.push(t); }
		anims = [tl];
		game.root.add(spr, Const.LAYER_OBJ - 1);
	}

	override function update(dt) {
		switch( ikind ) {
		case Teleport:
			if( Math.random() < 0.5 )
				game.emitPart(Std.random(3), 2, (ix * 16 + Std.random(16)), iy * 16 + 2 + Std.random(14), 0, -(1 + Math.random()) * 10, 1 + Math.random());
		default:
		}
	}

}