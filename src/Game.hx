import Data;

class Part extends h2d.SpriteBatch.BatchElement {
	public var z : Float;
	public var vx : Float;
	public var vy : Float;
	public var vz : Float;
	public var time : Float;
	public var bounce : Float;
	public function new(t) {
		super(t);
		z = 0;
		vz = 0;
		bounce = 0.5;
	}
	override function update( et : Float ) {
		time -= et;
		if( time < 0 ) return false;
		y += z;
		x += vx * et;
		y += vy * et;
		z += vz * et;
		if( z != 0 || vz != 0 ) {
			vz += 1 * et;
			if( z < 0 ) {
				z = -z;
				vz *= -bounce;
			}
		}
		y -= z;
		return true;
	}
}

class Game extends hxd.App {

	public var level : Level;
	public var entities : Array<ent.Entity>;
	public var hero : ent.Hero;
	var cache : h2d.CachedBitmap;
	public var root : h2d.Layers;

	var hicons : Array<h2d.Bitmap>;
	public var hearts = 0;
	public var currentLevel = 0;
	public var world = 0;

	var parts : h2d.SpriteBatch;
	var updates : Array < Float -> Bool > ;


	override function init() {
		super.init();
		updates  = [];
		s2d.setFixedSize(15 * 16, 12 * 16);

		cache = new h2d.CachedBitmap(s2d.width, s2d.height);
		s2d.add(cache, 0);

		var bg = new h2d.Bitmap(Res.sky.toTile(), cache);
		bg.tile.scaleToSize(s2d.width, s2d.height);
		bg.filter = true;
		bg.y = -70;

		root = new h2d.Layers(cache);


		parts = new h2d.SpriteBatch(Res.pixels.toTile());
		parts.hasUpdate = true;

		entities = [];
		initLevel();


	}

	public function restart() {
		world = 0;
		hearts = 0;
		initLevel();
	}

	public function waitUntil(f) {
		updates.push(f);
	}

	public function wait(t:Float, f) {
		waitUntil(function(dt) {
			t -= dt / 60;
			if( t < 0 ) {
				f();
				return true;
			}
			return false;
		});
	}

	public function initLevel() {

		for( e in entities.copy() )
			e.remove();

		while( root.numChildren > 0 )
			root.getChildAt(0).remove();

		root.add(parts, Const.LAYER_FX);


		if( hicons != null ) for( h in hicons ) h.remove();


		world = 0;
		level = new Level(currentLevel);

		hicons = [];
		var hp = level.data.hearts;
		var icons = Res.icons.toTile().split();
		for( i in 0...hp.length ) {
			var ic = new h2d.Bitmap(icons[hp[i].power.toInt()], s2d);
			ic.x = 4 + i * 10;
			ic.y = 4;
			ic.alpha = 0.4;
			ic.colorKey = 0xFF00FF;
			hicons.push(ic);
		}
	}

	public function shake( amount : Float, time : Float ) {
		waitUntil(function(dt) {
			time -= dt / 60;
			if( time < 0 ) {
				root.y = -world * Const.H;
				return true;
			}
			root.y = -world * Const.H - amount * 4 * Math.random();
			return false;
		});
	}

	public function fadeTo( color, time : Float, callb ) {
		var m = cache.colorMatrix;
		if( m == null ) {
			m = h3d.Matrix.I();
			cache.colorMatrix = m;
		}
		var t = 0.;
		var m2 = m.clone();
		var color = h3d.Vector.fromColor(color);
		waitUntil(function(dt) {
			var mt = dt / (60 * time);
			t += mt;
			m2.loadFrom(m);
			m2.multiplyValue(1 - t);
			m2._44 = 1;
			m2._41 += color.x * t;
			m2._42 += color.y * t;
			m2._43 += color.z * t;
			cache.colorMatrix = m2;
			if( t > 1 ) {
				cache.colorMatrix = null;
				callb();
				return true;
			}
			return false;
		});
	}

	public function nextHeart() {
		var p = level.data.hearts[hearts].power;
		if( p != Nothing )
			hero.powers.push(p);
		hicons[hearts].alpha = 1;
		hearts++;
		if( hearts == level.data.hearts.length )
			for( e in entities )
				e.wakeUp();
	}

	override function update(dt:Float) {
		for( e in entities )
			e.update(dt);


		for( e in updates.copy() ) {
			if( e(dt) )
				updates.remove(e);
		}

		root.ysort(Const.LAYER_OBJ);

		if( hxd.Key.isPressed(hxd.Key.F1) )
			cache.colorMatrix = null;
		if( hxd.Key.isPressed(hxd.Key.F2) ) {
			var m = h3d.Matrix.I();
			m.colorHue(-60);
			m.colorSaturation(0.1);
			m.colorContrast(0.4);
			cache.colorMatrix = m;
		}
		if( hxd.Key.isPressed(hxd.Key.F3) ) {
			var m = h3d.Matrix.I();
			m.colorHue(180);
			m.colorSaturation(-0.1);
			m.colorContrast( -0.6);
			m.colorBrightness( -0.25);
			m.colorContrast(0.7);
			cache.colorMatrix = m;
		}
	}

	public function emitPart( px : Int, py : Int, x : Float, y : Float, vx : Float, vy : Float, time : Float ) {
		var p = new Part(Res.pixels.toTile().sub(px, py, 1, 1));
		p.x = x;
		p.y = y;
		p.vx = vx;
		p.vy = vy;
		p.time = time;
		parts.add(p);
	}

	public static var inst : Game;

	static function main() {
		hxd.Res.initEmbed();
		Data.load(Res.data.entry.getBytes().toString());
		Texts.init();
		inst = new Game();
	}

}