package ent;
import Data;

class Entity {

	var game : Game;
	var anims : Array<Array<h2d.Tile>>;
	public var x : Float;
	public var y : Float;
	public var kind : Data.EntityKind;
	public var spr : h2d.Anim;
	public var dir(default,set) : hxd.Direction;

	public function new(k, x, y) {
		anims = [];
		game = Game.inst;
		kind = k;
		this.x = x;
		this.y = y;
		spr = new h2d.Anim(null,6);
		spr.x = (x + 0.5) * 16;
		spr.y = (y + 1) * 16;
		spr.colorKey = 0xA4F50D;
		game.s2d.add(spr, Const.LAYER_OBJ);
		dir = Down;
		init();
		play(0);
		game.entities.push(this);
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