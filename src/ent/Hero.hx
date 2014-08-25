package ent;
import Data;
import hxd.Math;

class Hero extends Entity {

	var mx = 0.;
	var my = 0.;
	var time = 0.;
	var pushTime = 0.;
	var hasMoved = false;
	public var lock(default,set) = false;

	public var powers : Array<{ p : Power, i : Int }>;

	public function new(x, y) {
		super(EHero, x, y);
		game.hero = this;
		isCollide = true;
		powers = [{ p : Nothing, i : -10 }];
		spr.alpha = 0;
		game.waitUntil(function(dt) {
			spr.alpha += 0.1 * dt;
			if( spr.alpha > 1 ) {
				spr.alpha = 1;
				return true;
			}
			return false;
		});
	}

	override function die() {
		super.die();
		lock = true;
	}

	function set_lock(l) {
		if( l ) {
			spr.speed = 0;
			spr.currentFrame = 0;
		} else {
			spr.speed = 12;
		}
		return lock = l;
	}

	override function set_dir(d) {
		dir = d;
		spr.scaleX = dir.x == 0 ? 1 : -dir.x;
		play(dir.y == 0 ? 0 : dir.y > 0 ? 1 : 2);
		return d;
	}

	override function init() {
		var g = Res.hero.toTile().grid(16);
		var fcount = [6,5,5,4, 1];
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
				case EMob(h):
					if( Std.int(e.iy/Const.CH) == Std.int(iy/Const.CH) )
						f.push(e);
				default:
				}
			}
			f.sort(function(e1, e2) return Reflect.compare(hxd.Math.distanceSq(e2.ix - ix, e2.iy - iy), hxd.Math.distanceSq(e1.ix - ix, e1.iy - iy)));
			if( f.length == 0 ) {
				game.wait(1, function() {
					play(2);
					Res.sfx.climb.play();
					game.fadeTo(0xA4F50D, 1, function() {
						// prevent music reset
						@:privateAccess  {
							for( h in game.hicons )
								h.remove();
							game.hicons = null;
						};
						game.currentLevel++;
						game.restart();
					});
				});
				return;
			}

			var e = f[0];

			game.shake(0.5, 0.2);
			for( i in 0...30 ) {
				var a = -Math.PI/2 + Math.srand(Math.PI * 0.4);
				var sp = (10 + Math.random(5)) * 4;
				game.emitPart(Std.random(5), 1, e.spr.x + Math.srand(4), e.spr.y - 8 + Math.srand(4), Math.cos(a) * sp, Math.sin(a) * sp, 0.2 + Math.random(0.2));
			}
			Res.sfx.die2.play();

			e.remove();
			game.wait(0.05, next);
		}
		next();
	}

	override function update(dt:Float) {

		var k = game.keys;

		if( lock || dieing ) {
			mx = my = 0;
			k = { left : false, right : false, up : false, down : false, action : false };
		}

		var pow = powers[powers.length - 1].p;


		game.curPower.x = 3 + powers[powers.length - 1].i * 12;
		game.curPower.visible = Std.int(time / 15) & 1 == 0;

		time += dt;
		switch( pow ) {
		case Nothing:
			spr.color = null;
			spr.colorAdd = null;
		default:
			var k = 1-Math.abs(Math.sin(time * 0.1)) * 0.5;
			spr.color = new h3d.Vector(k,k,k,1);
		}

		if( k.action ) {

			if( mx == 0 && my == 0 ) {
				for( e in game.entities )
					if( e.isCollide && e.ix == ix + dir.x && e.iy == iy + dir.y && e.activate() ) {
						lock = true;
						spr.currentFrame = 0;
						spr.speed = 0;
						return;
					}
			}

			switch( pow ) {
			case Nothing:
				Res.sfx.nopowa.play();
			case Fire:
				powers.pop();
				var e = new ent.Fireball(ix, iy, dir);
				e.spr.x = spr.x + dir.x * 10;
				e.spr.y = spr.y - 8 + dir.y * 10;
			case Pilar:
				if( mx == 0 && my == 0 ) {
					if( !collide(ix + dir.x, iy + dir.y) ) {
						powers.pop();
						var e = new ent.Mob(Pilar, ix + dir.x, iy + dir.y);
						Res.sfx.pilar.play();
						// single dimention
					} else
						Res.sfx.nopowa.play();
				}
			case Portal:
				if( mx == 0 && my == 0 ) {
					if( !collide(ix + dir.x, iy + dir.y) && get(ix+dir.x,iy+dir.y) == null ) {
						powers.pop();
						var e = new Interact(Teleport, ix + dir.x, (iy + dir.y) % Const.CH);
						var e2 = new Interact(Teleport, ix + dir.x, (iy + dir.y) % Const.CH + Const.CH);
						Res.sfx.portal.play();
					}  else
						Res.sfx.nopowa.play();
				}
			case Rotate:
				if( mx == 0 && my == 0 ) {
					var e = get(ix + dir.x, iy + dir.y);
					if( e != null && e.canTurn() ) {
						powers.pop();
						Res.sfx.splitRot.play();
						e.dir = hxd.Direction.from( e.dir.y, -e.dir.x);
					} else
						Res.sfx.nopowa.play();
				}
			}
		}

		if( mx == 0 && my == 0 ) {

			for( e in game.entities )
				if( e.ix == ix && e.iy == iy && e != this && !lock )
					switch( e.kind ) {
					case EInt(Stairs) if( game.canExit() ):
						exit();
						return;
					case EInt(Teleport):
						if( hasMoved ) {
							Res.sfx.teleport.play();
							hasMoved = false;
							game.nextWorld();
							return;
						}
					default:
					}

			if( k.left ) {
				if( !collide(ix - 1, iy) ) {
					ix--;
					mx = -1;
				} else
					pushTime += dt;
				dir = Left;
			} else if( k.right ) {
				if( !collide(ix + 1, iy) ) {
					ix++;
					mx = 1;
				} else
					pushTime += dt;
				dir = Right;
			} else if( k.up ) {
				if( !collide(ix, iy - 1) ) {
					iy--;
					my = -1;
				} else
					pushTime += dt;
				dir = Up;
			} else if( k.down ) {
				if( !collide(ix, iy + 1) ) {
					iy++;
					my = 1;
				} else
					pushTime += dt;
				dir = Down;
			} else if( !lock ) {
				pushTime = 0;
				spr.currentFrame = 0;
			}
			if( mx != 0 || my != 0 )
				update(dt);
			else if( pushTime > 10 ) {
				pushTime = 0;
				var e = get(ix + dir.x, iy + dir.y);
				var esub = null;
				if( e != null && e.canPush() && !collide(ix + dir.x * 2, iy + dir.y * 2) && ((esub = get(ix + dir.x * 2, iy + dir.y * 2)) == null || esub.kind.match(EInt(Teleport))) ) {
					mx = dir.x;
					my = dir.y;
					ix += dir.x;
					iy += dir.y;
					e.push(dir);
					Res.sfx.push.play();
					update(dt);
				}
			}
		} else {
			hasMoved = true;
			pushTime = 0;
			if( mx > 0 && k.left && !collide(ix - 1, iy) ) {
				ix--;
				mx = -(1 - mx);
				dir = Left;
			}
			if( mx < 0 && k.right && !collide(ix + 1, iy) ) {
				ix++;
				mx = 1 + mx;
				dir = Right;
			}
			if( my > 0 && k.up && !collide(ix, iy - 1) ) {
				iy--;
				my = -(1 - my);
				dir = Up;
			}
			if( my < 0 && k.down && !collide(ix, iy + 1) ) {
				iy++;
				my = 1 + my;
				dir = Down;
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

			if( mx == 0 && my == 0 )
				for( e in game.entities )
					e.checkHero();
		}
	}

}