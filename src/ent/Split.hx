package ent;
import Data;

class Split extends Mob {

	var tf : h2d.Text;
	public var moves(default, set) : Int;

	public function new(x, y, dir) {
		super(Split, x, y);
		game.splits.push(this);
		this.dir = dir;
		spr.scaleX = 1;
		moves = 9;
	}

	function set_moves(v:Int) {
		if( moves == v )
			return v;
		moves = v;
		if( tf == null ) {
			tf = new h2d.Text(Res.font.toFont(), spr);
			tf.x = -4;
			tf.y = -20;
			tf.dropShadow = { dx : 0, dy : 1, color : 0, alpha : 0.8 };
		}
		for( e in getSync() )
			cast(e, Split).moves = v;
		tf.text = v == 9  ? "" : ""+v;
		return v;
	}

	override function canTurn() {
		return true;
	}

	public function inZone( e : Entity ) {
		if( Std.int(e.iy / Const.CH) != Std.int(iy / Const.CH) )
			return false;
		switch( dir ) {
		case Down:
			return e.ix >= ix && e.iy >= iy;
		case Left:
			return e.ix <= ix && e.iy >= iy;
		case Up:
			return e.ix <= ix && e.iy <= iy;
		case Right:
			return e.ix >= ix && e.iy <= iy;
		default:
			throw "TODO";
			return false;
		}
	}

	override function checkHero() {
		if( inZone(game.hero) ) {
			moves--;
			if( moves == 0 ) {
				Res.sfx.splitKill.play();
				game.hero.die();
			} else
				Res.sfx.split.play();
		}
	}

	override function remove() {
		super.remove();
		game.splits.remove(this);
	}

	override function wakeUp() {
	}

	override function set_dir(d) {
		if( dir == d )
			return d;
		dir = d;
		if( dir.y > 0 )
			spr.currentFrame = 0;
		else if( dir.y < 0 )
			spr.currentFrame = 2;
		else if( dir.x < 0 )
			spr.currentFrame = 1;
		else
			spr.currentFrame = 3;
		for( e in getSync() )
			e.dir = dir;
		return d;
	}

}