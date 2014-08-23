package ent;
import Data;
import hxd.Math;

class Entity {

	var game : Game;
	var anims : Array<Array<h2d.Tile>>;
	var isCollide : Bool;
	var dieing : Bool;
	public var x : Float;
	public var y : Float;
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
		this.x = x;
		this.y = y;
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
					game.wait(1.5, function() game.restart());
				return true;
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

	function collideWith( e : Entity ) {
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