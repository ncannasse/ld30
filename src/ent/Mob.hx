package ent;
import Data;

class Mob extends Entity {

	var mkind : MobKind;

	public function new(k, x, y) {
		mkind = k;
		super(EMob(k), x, y);
		switch( k ) {
		case Heart:
		default:
			spr.scaleX = Std.random(2) == 0 ? -1 : 1;
			spr.onAnimEnd = function() spr.scaleX = -spr.scaleX;
		}
	}

	override function init() {
		var g = Res.anims.toTile().grid(16);
		var tl = [];
		for( i in 0...4 ) { var t = g[mkind.getIndex() * 16 + i]; t.dx = -8; t.dy = -16; tl.push(t); }
		anims = [tl];
		spr.currentFrame = Std.random(4);
	}

}