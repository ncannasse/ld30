package ent;
import Data;
import hxd.Math;

class Fireball extends Entity  {

	public var hitHero = false;

	public function new(x,y,dir) {
		super(EFireball, x, y);
		this.dir = dir;
		Res.sfx.fireball.play();
	}

	override function set_dir(d) {
		dir = d;
		if( dir.x < 0 ) {
			spr.scaleX = -1;
			spr.rotation = 0;
		} else {
			spr.scaleX = 1;
			spr.rotation = Math.atan2(dir.y, dir.x);
		}
		return d;
	}

	override function collideWith(e:Entity) {
		return hitHero ? true : e != game.hero;
	}

	override function init() {
		anims = [Res.fireball.toTile().split()];
		for( a in anims[0] ) {
			a.dx = -8;
			a.dy = -8;
		}
		game.root.add(spr, Const.LAYER_OBJ + 1);
		spr.speed = 20;
	}

	override function update(dt:Float) {
		spr.x += dt * 3 * dir.x;
		spr.y += dt * 3 * dir.y;
		ix = Std.int(spr.x/16);
		iy = Std.int(spr.y / 16);
		var a = Math.atan2( -dir.y, -dir.x) + Math.srand(0.5) * (dir.x == 0 ? 1 : -dir.x);
		var sp = 10 + Math.random(5);
		game.emitPart(Std.random(5), 0, spr.x + Math.srand(4), spr.y + Math.srand(4), Math.cos(a) * sp, Math.sin(a) * sp, 0.5);
		if( collide(ix, iy) ) {

			Res.sfx.firekill.play();

			game.shake(0.5, 0.2);

			for( i in 0...30 ) {
				var a = Math.atan2( -dir.y, -dir.x) + Math.srand(Math.PI * 0.4);
				var sp = (10 + Math.random(5)) * 4;
				game.emitPart(Std.random(5), 0, spr.x + Math.srand(4), spr.y + Math.srand(4), Math.cos(a) * sp, Math.sin(a) * sp, 0.2 + Math.random(0.2));
			}

			for( e in game.entities )
				if( (hitHero ? e == game.hero : e.isCollide) && e.ix == ix && e.iy == iy ) {
					Res.sfx.burning.play();
					e.die();
				}

			remove();
		}
	}

}