package ent;
import Data;
import hxd.Math;

class Entity {

	var game : Game;
	var anims : Array<Array<h2d.Tile>>;
	var dieing : Bool;
	public var isCollide : Bool;
	public var ix : Int;
	public var iy : Int;
	public var kind : Data.EntityKind;
	public var spr : h2d.Anim;
	public var dir(default,set) : hxd.Direction;

	public function new(k, x, y) {
		anims = [];
		game = Game.inst;
		kind = k;
		ix = x;
		iy = y;
		spr = new h2d.Anim(null,6);
		spr.x = (x + 0.5) * 16;
		spr.y = (y + 1) * 16;
		spr.colorKey = 0xA4F50D;
		game.root.add(spr, Const.LAYER_OBJ);
		dir = Down;
		init();
		play(0);
		game.entities.push(this);
	}

	public function isHidden() {
		for( s in game.splits )
			if( s.inZone(this) )
				return true;
		return false;
	}

	public function wakeUp() {
	}

	public function activate() {
		return false;
	}

	function get( x : Int, y : Int ) {
		for( e in game.entities )
			if( e.ix == x && e.iy == y )
				return e;
		return null;
	}

	function getSync() {
		var other = [];
		for( e in game.entities )
			if( e != this && e.ix == ix && e.iy % Const.CH == iy % Const.CH && e.kind.equals(kind) )
				other.push(e);
		return other;
	}

	public function telekill() {
		return false;
	}

	public function die() {
		dieing = true;
		var m = new h3d.Matrix();
		var time = 0.;
		m.identity();
		spr.colorMatrix = m;
		game.waitUntil(function(dt) {
			time += dt * 0.04;
			m.identity();
			m.colorSaturation( Math.max(2-Math.pow(time,3),0) );
			m.colorBrightness( -time * 0.2 );

			var a = -Math.PI / 2 + Math.srand(Math.PI * 0.4);
			var sp = (10 + Math.random(5));
			game.emitPart(Std.random(4), 1, spr.x + Math.srand(4), spr.y - 8 + Math.srand(4), Math.cos(a) * sp, Math.sin(a) * sp, (0.2 + Math.random(0.2)) * 3);

			if( time > 1 )
				spr.scaleY -= 0.04 * dt;
			if( spr.scaleY < 0 ) {
				remove();
				if( this == game.hero )
					game.wait(1.5, function() { Res.sfx.piou2.play(); game.restart(); });
				return true;
			}
			return false;
		});
	}

	public function canTurn() {
		return false;
	}

	public function canPush() {
		return false;
	}

	public function checkHero() {
	}

	public function push( dir : hxd.Direction ) {
		ix += dir.x;
		iy += dir.y;
		var mx : Float = dir.x * 16;
		var my : Float = dir.y * 16;
		game.waitUntil(function(dt) {
			var dm = dt * 1.;
			if( Math.abs(mx) < dm && Math.abs(my) < dm ) {
				spr.x += mx;
				spr.y += my;
				return true;
			}
			if( mx < 0 || my < 0 )
				dm = -dm;
			if( mx != 0 ) {
				spr.x += dm;
				mx -= dm;
			}
			if( my != 0 ) {
				spr.y += dm;
				my -= dm;
			}
			return false;
		});
	}

	public function collide( x : Int, y : Int ) {
		if( x < 0 || y < 0 || x >= Const.CW || y >= game.level.height )
			return true;
		if( game.level.collide[x][y] )
			return true;
		for( e in game.entities )
			if( e.ix == x && e.iy == y && e.isCollide && e != this && e.collideWith(this) && this.collideWith(e) )
				return true;
		return false;
	}

	public function collideWith( e : Entity ) {
		return true;
	}

	public function remove() {
		game.entities.remove(this);
		spr.remove();
	}

	function set_dir(d) {
		return dir = d;
	}

	public function play(anim) {
		var a = anims[anim];
		if( spr.frames != a ) spr.play(a);
	}

	function init() {
	}

	public function update(dt:Float) {
	}

}