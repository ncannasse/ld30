package ent;
import Data;

class Mob extends Entity {

	var mkind : MobKind;
	var wait : Float = 0.;
	var lockPush = false;
	var canFire = false;

	public function new(k, x, y) {
		mkind = k;
		super(EMob(k), x, y);
		isCollide = true;
	}


	override function wakeUp() {
		if( mkind == Pilar ) return;
		spr.speed = 8;
		spr.currentFrame = Std.random(spr.frames.length);
		update(0);
	}

	override function die() {
		super.die();

		for( e in getSync() )
			if( !e.dieing )
				e.die();

		switch( mkind ) {
		case Bomb:
			Res.sfx.bomb.play();
			Res.sfx.burning.play();
			for( dx in -1...2 )
				for( dy in -1...2 ) {
					if( dx == 0 && dy == 0 ) continue;
					var e = get(ix + dx, iy + dy);
					if( e == null ) {
						var t = new ent.Mob(Tree, ix + dx, iy + dy);
						t.spr.visible = false;
						t.isCollide = false;
						t.die();
						continue;
					}
					if( e == this || e.dieing || e.isHidden() ) continue;
					e.die();
					if( e.kind.match(EInt(Heart)) ) {
						game.wait(1, function() {
							if( game.canExit() )
								for( e in game.entities )
									e.wakeUp();
						});
					}
				}
		default:
		}
	}

	override function telekill() {
		return switch( mkind ) {
		case Bomb: true;
		default: false;
		}
	}

	override function canPush() {
		return !lockPush && switch( mkind ) {
		case Pink, Bomb: game.world != 0;
		default: false;
		}
	}

	override function collideWith( e : Entity ) {
		return mkind != Dark || !e.kind.match(EMob(Tree));
	}

	override function push(dir : hxd.Direction) {
		var telep = get(ix + dir.x, iy + dir.y);
		var a = getSync();
		super.push(dir);
		for( e in a ) {
			e.ix += dir.x;
			e.iy += dir.y;
			e.spr.x += dir.x * 16;
			e.spr.y += dir.y * 16;

			for( e2 in game.entities )
				if( e2 != e && e2.isCollide && e2.ix == e.ix && e2.iy == e.iy ) {
					e2.remove();
					break;
				}
		}


		if( telep != null && telep.kind.match(EInt(Teleport)) ) {
			for( e in a )
				e.remove();
			lockPush = true;
			game.wait(1, function() {
				Res.sfx.teleport.play();
				game.waitUntil(function(dt) {
					spr.alpha -= 0.1 * dt;
					if( spr.alpha < 0 ) {
						var way = iy >= Const.CH ? -1 : 1;
						iy += Const.CH * way;
						spr.y += Const.H * way;
						spr.alpha = 1;
						lockPush = false;
						return true;
					}
					return false;
				});
			});
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
				if( e.kind.match(EMob(_)) && e != this && e.ix == ix && e.iy % Const.CH == iy % Const.CH )
					e.remove();
		default:
			spr.currentFrame = 1;
			spr.speed = 0;
			spr.scaleX = hxd.Rand.hash(ix + (iy%Const.CH)*Const.CW)&1 == 0 ? -1 : 1;
			spr.onAnimEnd = function() {
				spr.scaleX = -spr.scaleX;
				for( e in getSync() )
					e.spr.scaleX = spr.scaleX;
			};
		}
	}

	override function checkHero() {
		switch( mkind ) {
		case Dark if( canFire ):
			Res.sfx.dark.play();
			game.hero.lock = true;
			game.hero.play(4);
			var px = spr.x, py = spr.y - 8;
			var d = hxd.Direction.from(game.hero.ix - ix, game.hero.iy - iy);
			game.waitUntil(function(dt) {
				px += d.x * dt * 2;
				py += d.y * dt * 2;
				if( Math.random() < 0.2 * dt ) Res.sfx.die2.play();
				game.emitPart(Std.random(3), 1, px + hxd.Math.srand(4), py + hxd.Math.srand(4) - 4, hxd.Math.srand(4), (1 + hxd.Math.random()) * 2.5, 1 + hxd.Math.random() * 2);
				if( Std.int(px / 16) == game.hero.ix && Std.int(py / 16) == game.hero.iy ) {
					Res.sfx.burning.play();
					game.hero.die();
					return true;
				}
				return false;
			});
		default:
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

				if( game.world != 0 || game.hero.isHidden() ) {
					spr.speed = 6;
					return;
				}

				var e = new Fireball(ix + d.x, iy + d.y, d);
				e.spr.y -= 8;
				e.hitHero = true;
				wait = 1;
			}
		case Dark:


			for( s in game.splits )
				if( s.inZone(this) && !dieing ) {
					Res.sfx.darkdie.play();
					die();
					return;
				}

			if( !game.canExit() ) spr.speed = 0;
			canFire = false;
			if( !game.hero.lock && (game.hero.ix == ix || game.hero.iy == iy) ) {
				var d = hxd.Direction.from(game.hero.ix - ix, game.hero.iy - iy);
				var px = ix + d.x, py = iy + d.y;
				while( px != game.hero.ix || py != game.hero.iy ) {
					if( collide(px, py) ) {
						spr.speed = 10;
						return;
					}
					px += d.x;
					py += d.y;
				}

				if( @:privateAccess hxd.Math.abs(game.hero.mx + game.hero.my) > 0.2 || game.hero.isHidden() ) {
					spr.speed = 10;
					return;
				}

				canFire = true;
			}



		case Bomb:
			if( hxd.Math.iabs(game.hero.ix - ix) <= 1 && hxd.Math.iabs(game.hero.iy - iy) <= 1 ) {
				if( game.canExit() && !dieing )
					die();
				else
					spr.speed = 6;
			} else
				spr.speed = game.canExit() ? 8 : 0;
		default:
		}
	}

}