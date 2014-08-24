import Data;
import hxd.Key in K;

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
		if( time < 0.2 ) alpha = time * 5;
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

class Render extends h2d.CachedBitmap {

	var time = 0.;

	override function drawRec( ctx : h2d.RenderContext ) {
		super.drawRec(ctx);
		var game = Game.inst;
		if( game.splits.length == 0 ) return;
		var old = this.colorMatrix;

		time += ctx.elapsedTime;

		var m = h3d.Matrix.I();
		m.colorHue(60);
		m.colorSaturation(1.5);
		colorMatrix = m;

		sinusDeform = new h3d.Vector(time * 4, 100, 0.003);

		var game = Game.inst;

		for( s in game.splits ) {
			if( Std.int(s.iy / Const.CH) != game.world ) continue;
			var iy = s.iy % Const.CH;
			var z = ctx.engine.width == 720 ? 3 : 2;
			switch( s.dir ) {
			case Down:
				ctx.engine.setRenderZone((s.ix * 16 + 8) * z, (iy * 16 + 4) * z, ctx.engine.width, ctx.engine.height);
			case Left:
				ctx.engine.setRenderZone(0, (iy * 16 + 4) * z, (s.ix * 16 + 8) * z, ctx.engine.height);
			case Up:
				ctx.engine.setRenderZone(0, 0, (s.ix * 16 + 8) * z, (iy * 16 + 4) * z);
			case Right:
				ctx.engine.setRenderZone((s.ix * 16 + 8) * z, 0, ctx.engine.width, (iy * 16 + 4) * z);
			default:
				throw "TODO";
			}
			super.drawRec(ctx);
		}
		ctx.engine.setRenderZone();
		colorMatrix = old;
		sinusDeform = null;
	}

}

class Game extends hxd.App {

	public var level : Level;
	public var entities : Array<ent.Entity>;
	public var hero : ent.Hero;
	var cache : Render;
	public var root : h2d.Layers;

	var hicons : Array<h2d.Bitmap>;
	public var hearts = 0;
	public var currentLevel = 18;
	public var world = 0;

	public var curPower : h2d.Anim;

	var parts : h2d.SpriteBatch;
	var updates : Array < Float -> Bool > ;

	public var splits : Array<ent.Split>;

	public var keys : { left : Bool, right : Bool, up : Bool, down : Bool, action : Bool };


	override function init() {
		super.init();

		#if !debug
		currentLevel = 0;
		#end

		updates  = [];
		s2d.setFixedSize(15 * 16, 12 * 16);

		cache = new Render(s2d.width, s2d.height);
		cache.blendMode = None;
		s2d.add(cache, 0);

		var bg = new h2d.Bitmap(Res.sky.toTile(), cache);
		bg.tile.scaleToSize(s2d.width, s2d.height);
		bg.filter = true;
		bg.y = -70;

		curPower = new h2d.Anim(Res.curPower.toTile().split());
		curPower.colorKey = 0xFF00FF;
		s2d.add(curPower, 2);
		curPower.y = 3;

		root = new h2d.Layers(cache);

		entities = [];
		initLevel();
	}

	public function restart() {
		world = 0;
		hearts = 0;
		root.y = 0;
		cache.colorMatrix = null;
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

	public function dialog( text : String, onEnd : Void -> Void ) {

		var box = new h2d.ScaleGrid(Res.box.toTile(), 4, 4, s2d);
		box.width = s2d.width;
		box.height = 50;
		box.colorKey = 0xFF00FF;
		box.y = s2d.height - box.height;

		var t = new h2d.Text(Res.font.toFont(), box);
		t.x = 5;
		t.y = 5;
		var maxWidth = box.width - 10;
		t.textColor = 0x743102;
		t.dropShadow = { dx : 1, dy : 1, color : 0x743102, alpha : 0.2 };

		keys.action = false;

		var texts = text.split("#");

		texts = [for( l in texts ) {
			var out = [];
			var words = l.split(" ");
			var txt = "";
			for( i in 0...words.length ) {
				var prev = txt;
				txt += (i == 0 ? "" : " ") + words[i];
				if( t.calcTextWidth(txt) > maxWidth ) {
					out.push(prev);
					txt = words[i];
				}
			}
			if( txt != "" )
				out.push(txt);
			out.join("\n");
		}];
		t.maxWidth = maxWidth;

		text = StringTools.trim(texts.shift());

		var len = 0.;
		waitUntil(function(dt) {
			len += dt;
			t.text = text.substr(0, Std.int(len));
			if( len < text.length && !Res.sfx.old.isPlaying() )
				Res.sfx.old.play();
			if( keys.action ) {
				if( len < text.length )
					len = text.length;
				else {
					text = texts.shift();
					len = 0;
					if( text == null ) {
						box.remove();
						onEnd();
						return true;
					}
					text = StringTools.trim(text);
				}
			}
			return false;
		});
	}

	public function initLevel() {

		for( e in entities.copy() )
			e.remove();

		while( root.numChildren > 0 )
			root.getChildAt(0).remove();

		if( hicons != null ) for( h in hicons ) h.remove();


		parts = new h2d.SpriteBatch(Res.pixels.toTile());
		parts.hasUpdate = true;
		root.add(parts, Const.LAYER_FX);

		splits = [];

		world = 0;
		level = new Level(currentLevel);

		hicons = [];
		var hp = level.data.hearts;
		var icons = Res.icons.toTile().split();
		for( i in 0...hp.length ) {
			var ic = new h2d.Bitmap(icons[hp[i].power.toInt()]);
			s2d.add(ic, 1);
			ic.x = 3 + i * 12;
			ic.y = 3;
			ic.alpha = 0.4;
			ic.colorKey = 0xFF00FF;
			hicons.push(ic);
		}


		var t = new h2d.Text(Res.font.toFont(), s2d);
		t.text = "Floor #" + StringTools.lpad("" + (currentLevel + 1), "0", 2);
		t.x = (s2d.width - t.textWidth) >> 1;
		t.y = s2d.height - 60;
		t.dropShadow = { dx : 1, dy : 1, color : 0, alpha : 0.4 };
		t.alpha = 0;
		waitUntil(function(dt) {
			t.alpha += 0.1 * dt;
			if( t.alpha > 1 ) {
				wait(1, function() {
					waitUntil(function(dt) {
						t.alpha -= dt * 0.05;
						if( t.alpha < 0 ) {
							t.remove();
							return true;
						}
						return false;
					});
				});
				return true;
			}
			return false;
		});

		if( canExit() )
			for( e in entities )
				e.wakeUp();

		if( hero.iy >= Const.CH ) {
			hero.iy -= Const.CH;
			hero.spr.y -= Const.H;
			nextWorld();
		}
	}

	public function nextWorld() {
		world = 1 - world;
		var prev = new h2d.Bitmap(cache.getTile(), s2d);
		@:privateAccess cache.tile = null;

		if( world == 0 ) {
			root.y = 0;
			hero.spr.y %= Const.H;
			hero.iy %= Const.CH;
		} else {
			root.y -= Const.H;
			hero.spr.y += Const.H;
			hero.iy += Const.CH;
		}
		hero.lock = true;

		switch( world ) {
		case 0:
			cache.colorMatrix = null;
		case 1:
			var m = h3d.Matrix.I();
			m.colorHue(-60);
			m.colorSaturation(0.2);
			m.colorContrast(0.4);
			cache.colorMatrix = m;
		}

		waitUntil(function(dt) {
			prev.alpha -= dt * 0.02;
			if( prev.alpha < 0 ) {
				prev.tile.dispose();
				prev.remove();
				if( hero.collide(hero.ix, hero.iy) ) {
					for( e in entities )
						if( e.isCollide && e.ix == hero.ix && e.iy == hero.iy && e != hero && e.collideWith(hero) && hero.collideWith(e) ) {
							if( e.telekill() ) {
								e.die();
								continue;
							}
							hero.die();
							return true;
						}
				}
				hero.lock = false;
				for( e in entities ) {
					if( e != hero ) e.update(0);
					e.checkHero();
				}
				return true;
			}
			return false;
		});
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

	public function canExit() {
		for( e in entities )
			switch( e.kind ) {
			case EInt(Heart): return false;
			default:
			}
		return true;
	}

	public function nextHeart() {
		var p = level.data.hearts[hearts];
		if( p != null && p.power != Nothing )
			hero.powers.push({ p : p.power, i : hearts });
		if( hicons[hearts] != null ) hicons[hearts].alpha = 1;
		hearts++;
		if( canExit() )
			for( e in entities )
				e.wakeUp();
	}

	override function update(dt:Float) {

		keys = {
			left : K.isDown(K.LEFT) || K.isDown("Q".code) || K.isDown("A".code),
			right : K.isDown(K.RIGHT) || K.isDown("D".code),
			up : K.isDown(K.UP) || K.isDown("Z".code) || K.isDown("W".code),
			down : K.isDown(K.DOWN) || K.isDown("S".code),
			action : K.isPressed(K.SPACE) || K.isPressed("E".code),
		};

		if( K.isPressed(K.ESCAPE) ) {
			restart();
			return;
		}

		#if debug
		if( K.isDown(K.F1) )
			engine.resize(480, 384);
		if( K.isPressed(K.PGUP) && currentLevel > 0 ) {
			currentLevel--;
			restart();
			return;
		}
		if( K.isPressed(K.PGDOWN) && currentLevel < Data.levelData.all.length - 1 ) {
			currentLevel++;
			restart();
			return;
		}
		#end


		for( e in entities )
			e.update(dt);


		for( e in updates.copy() ) {
			if( e(dt) )
				updates.remove(e);
		}

		root.ysort(Const.LAYER_OBJ);
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
		//var title = new Title();
		inst = new Game();
	}

}