package ent;
import Data;

class Mob extends Entity {

	var mkind : MobKind;
	var wait : Float = 0.;

	public function new(k, x, y) {
		mkind = k;
		super(EMob(k), x, y);
		isCollide = true;
	}


	override function wakeUp() {
		spr.speed = 8;
		spr.currentFrame = Std.random(spr.frames.length);
	}

	override function die() {
		super.die();
		switch( mkind ) {
		case Bomb:
			for( dx in -1...2 )
				for( dy in -1...2 ) {
					var e = get(ix + dx, iy + dy);
					if( e != null && e != this ) e.die() else { var t = new ent.Mob(Tree, ix + dx, iy + dy); t.spr.visible = false; t.isCollide = false; t.die(); }
				}
		default:
		}
	}

	override function init() {
		var g = Res.anims.toTile().grid(16);
		var tl = [];
		var nframes = 4;
		for( i in 0...nframes ) { var t = g[mkind.getIndex() * 16 + i]; t.dx = -8; t.dy = -16; tl.push(t); }
		anims = [tl];
		switch( mkind ) {
		case Pilar:
			spr.loop = false;
			for( e in game.entities )
				if( e.kind.match(EMob(_)) && e != this && e.ix == ix && e.iy % Const.CH == iy )
					e.remove();
		default:
			spr.currentFrame = 1;
			spr.speed = 0;
			spr.scaleX = hxd.Rand.hash(ix + (iy%Const.CH)*Const.CW)&1 == 0 ? -1 : 1;
			spr.onAnimEnd = function() spr.scaleX = -spr.scaleX;
		}
	}

	override function update(dt:Float) {
		wait -= dt/60;
		if( wait > 0 ) return;
		switch( mkind ) {
		case Pink:
			if( !game.canExit() ) spr.speed = 0;
			if( !game.hero.lock && (game.hero.ix == ix || game.hero.iy == iy) ) {
				var d = hxd.Direction.from(game.hero.ix - ix, game.hero.iy - iy);

				var px = ix + d.x, py = iy + d.y;
				while( px != game.hero.ix || py != game.hero.iy ) {
					if( collide(px, py) ) {
						spr.speed = 6;
						return;
					}
					px += d.x;
					py += d.y;
				}

				var e = new Fireball(ix + d.x, iy + d.y, d);
				e.spr.y -= 8;
				e.hitHero = true;
				wait = 1;
			}
		case Bomb if( game.canExit() && !dieing ):
			if( hxd.Math.iabs(game.hero.ix - ix) <= 1 && hxd.Math.iabs(game.hero.iy - iy) <= 1 )
				die();
		default:
		}
	}

}