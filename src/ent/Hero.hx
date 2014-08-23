package ent;

import hxd.Key in K;

class Hero extends Entity {

	var mx = 0.;
	var my = 0.;

	public function new(x, y) {
		super(EHero, x, y);
		game.hero = this;
	}

	override function set_dir(d) {
		dir = d;
		spr.scaleX = dir.x == 0 ? 1 : -dir.x;
		play(dir.y == 0 ? 0 : dir.y > 0 ? 1 : 2);
		return d;
	}

	override function init() {
		var g = Res.hero.toTile().grid(16);
		var fcount = [6,5,5];
		for( i in 0...g.length ) {
			g[i].dx = -8;
			g[i].dy = -16;
		}
		anims = [for( f in 0...fcount.length ) [for( i in 0...fcount[f] ) g[8 * f + i]]];
		spr.speed = 12;
	}

	override function update(dt:Float) {

		var k = {
			left : K.isDown(K.LEFT) || K.isDown("Q".code) || K.isDown("A".code),
			right : K.isDown(K.RIGHT) || K.isDown("D".code),
			up : K.isDown(K.UP) || K.isDown("Z".code) || K.isDown("W".code),
			down : K.isDown(K.DOWN) || K.isDown("S".code),
		};

		if( mx == 0 && my == 0 ) {
			if( k.left ) {
				mx = -1;
				dir = Left;
			} else if( k.right ) {
				mx = 1;
				dir = Right;
			} else if( k.up ) {
				my = -1;
				dir = Up;
			} else if( k.down ) {
				my = 1;
				dir = Down;
			} else
				spr.currentFrame = 0;
			if( mx != 0 || my != 0 )
				update(dt);
		} else {
			if( mx > 0 && k.left )
				mx = -(1 - mx);
			if( mx < 0 && k.right )
				mx = 1 + mx;
			if( my > 0 && k.up )
				my = -(1 - my);
			if( my < 0 && k.down )
				my = 1 + my;

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