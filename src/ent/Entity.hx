package ent;
import Data;

class Entity {

	var game : Game;
	var anims : Array<Array<h2d.Tile>>;
	var isCollide : Bool;
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

	function collide( x : Int, y : Int ) {
		if( x < 0 || y < 0 || x >= Const.CW || y >= Const.CH )
			return true;
		if( game.level.collide[x][y] )
			return true;
		for( e in game.entities )
			if( e.ix == x && e.iy == y && e.isCollide && e != this )
				return true;
		return false;
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