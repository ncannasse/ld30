package ent;
import Data;
import hxd.Key in K;
import hxd.Math;

class Hero extends Entity {

	var mx = 0.;
	var my = 0.;
	var time = 0.;
	var lock = false;

	public var powers : Array<Power>;

	public function new(x, y) {
		super(EHero, x, y);
		game.hero = this;
		powers = [Nothing, Fire];
	}

	override function set_dir(d) {
		dir = d;
		spr.scaleX = dir.x == 0 ? 1 : -dir.x;
		play(dir.y == 0 ? 0 : dir.y > 0 ? 1 : 2);
		return d;
	}

	override function init() {
		var g = Res.hero.toTile().grid(16);
		var fcount = [6,5,5,4];
		for( i in 0...g.length ) {
			g[i].dx = -8;
			g[i].dy = -16;
		}
		anims = [for( f in 0...fcount.length ) [for( i in 0...fcount[f] ) g[8 * f + i]]];
		spr.speed = 12;
	}

	function exit() {
		lock = true;
		play(3);
		spr.speed = 6;
		function next() {
			var f = [];
			for( e in game.entities ) {
				switch( e.kind ) {
				case EMob(Stairs):
				case EMob(h):
					f.push(e);
				default:
				}
			}
			f.sort(function(e1, e2) return Reflect.compare(hxd.Math.distanceSq(e2.ix - ix, e2.iy - iy), hxd.Math.distanceSq(e1.ix - ix, e1.iy - iy)));
			if( f.length == 0 ) {
				game.wait(1, function() {
					play(2);
					game.fadeTo(0x10B8E5, 1, function() {
						game.currentLevel++;
						game.initLevel();
					});
				});
				return;
			}

			var e = f[0];

			for( i in 0...30 ) {
				var a = -Math.PI/2 + Math.srand(Math.PI * 0.4);
				var sp = (10 + Math.random(5)) * 4;
				game.emitPart(Std.random(5), 1, e.spr.x + Math.srand(4), e.spr.y - 8 + Math.srand(4), Math.cos(a) * sp, Math.sin(a) * sp, 0.2 + Math.random(0.2));
			}

			e.remove();
			game.wait(0.05, next);
		}
		next();
	}

	override function update(dt:Float) {

		var k = {
			left : K.isDown(K.LEFT) || K.isDown("Q".code) || K.isDown("A".code),
			right : K.isDown(K.RIGHT) || K.isDown("D".code),
			up : K.isDown(K.UP) || K.isDown("Z".code) || K.isDown("W".code),
			down : K.isDown(K.DOWN) || K.isDown("S".code),
			action : K.isPressed(K.SPACE) || K.isPressed("E".code),
		};

		if( lock ) {
			k.left = k.right = k.up = k.down = k.action = false;
		}

		var pow = powers[powers.length - 1];

		time += dt;
		switch( pow ) {
		case Nothing:
			spr.color = null;
			spr.colorAdd = null;
		case Fire:
			spr.colorAdd = new h3d.Vector(Math.abs(Math.sin(time * 0.1)) * 0.2 + 0.2, 0, 0, 0);
		}

		if( k.action ) {
			switch( pow ) {
			case Nothing:
			case Fire:
				//powers.pop();
				var e = new ent.Fireball(ix, iy, dir);
				e.spr.x = spr.x + dir.x * 10;
				e.spr.y = spr.y - 8 + dir.y * 10;
			}
		}

		if( mx == 0 && my == 0 ) {

			for( e in game.entities )
				if( e.ix == ix && e.iy == iy && e != this && !lock )
					switch( e.kind ) {
					case EMob(Heart):
						e.remove();
						game.nextHeart();
					case EMob(Stairs):
						exit();
						return;
					default:
					}

			if( k.left ) {
				if( !collide(ix - 1, iy) ) {
					ix--;
					mx = -1;
				}
				dir = Left;
			} else if( k.right ) {
				if( !collide(ix + 1, iy) ) {
					ix++;
					mx = 1;
				}
				dir = Right;
			} else if( k.up ) {
				if( !collide(ix, iy - 1) ) {
					iy--;
					my = -1;
				}
				dir = Up;
			} else if( k.down ) {
				if( !collide(ix, iy + 1) ) {
					iy++;
					my = 1;
				}
				dir = Down;
			} else if( !lock )
				spr.currentFrame = 0;
			if( mx != 0 || my != 0 )
				update(dt);
		} else {
			if( mx > 0 && k.left && !collide(ix - 1, iy) ) {
				ix--;
				mx = -(1 - mx);
			}
			if( mx < 0 && k.right && !collide(ix + 1, iy) ) {
				ix++;
				mx = 1 + mx;
			}
			if( my > 0 && k.up && !collide(ix, iy - 1) ) {
				iy--;
				my = -(1 - my);
			}
			if( my < 0 && k.down && !collide(ix, iy + 1) ) {
				iy++;
				my = 1 + my;
			}

			var ds = 0.06 * dt;
			if( mx > 0 ) {
				var dm = ds > mx ? mx : ds;
				spr.x += dm * 16;
				mx -= dm;
			}
			if( my > 0 ) {
				var dm = ds > my ? my : ds;
				spr.y += dm * 16;
				my -= dm;
			}
			if( mx < 0 ) {
				var dm = ds > -mx ? mx : -ds;
				spr.x += dm * 16;
				mx -= dm;
			}
			if( my < 0 ) {
				var dm = ds > -my ? my : -ds;
				spr.y += dm * 16;
				my -= dm;
			}
		}
	}

}