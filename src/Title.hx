class Title extends hxd.App {

	var bg : h2d.Bitmap;
	var tower : h2d.Bitmap;
	var hero : h2d.Anim;

	var scroll : h2d.Layers;

	var title : h2d.Bitmap;
	var titleFront : h2d.Bitmap;

	var birds : Array<{ b : h2d.Anim, dx : Float, dy : Float }>;
	var time : Float = 0;
	var start : h2d.Text;

	var finish : Bool;


	override function init() {
		birds = [];
		s2d.setFixedSize(15 * 16, 12 * 16);
		bg = new h2d.Bitmap(Res.titleBg.toTile(), s2d);
		bg.scaleY = 0.7;
		scroll = new h2d.Layers(s2d);
		tower = new h2d.Bitmap(Res.titleTower.toTile());
		tower.colorKey = 0x10b8e5;
		scroll.add(tower, 1);
		if( finish ) endGame();
	}

	public function endGame() {
		finish = true;
		if( birds != null ) {
			title = new h2d.Bitmap();
			titleFront = title;
			scroll.y = -(tower.tile.height - s2d.height);
		}
	}

	override function update(dt:Float) {
		if( title == null )
			scroll.y -= 1 * dt;
		else
			scroll.y += (finish ? 0.5 : -scroll.y / 400) * dt;

		if( scroll.y > 0 ) {
			scroll.y = 0;
			if( finish && hero == null ) {
				hero = new h2d.Anim(Res.hero.toTile().sub(0, 0, 6 * 16, 16).split(), 12, s2d);
				hero.y = 27;
				hero.x = 125;
				hero.scale(0.5);
				hero.color = new h3d.Vector(0, 0, 0, 0);
				hero.colorKey = 0xA4F50D;
			}
		}

		if( hero != null && finish ) {
			if( hero.x > 92 ) {
				hero.x -= 0.1 * dt;
				if( hero.x <= 92 ) {
					hero.x = 92;
					hero.play(Res.hero.toTile().sub(0, 32, 5 * 16, 16).split());
				}
			} else if( hero.y > -10 ) {
				hero.y -= 0.1 * dt;
				if( hero.y <= -10 ) {

					var end = new h2d.Text(Res.font.toFont(), s2d);
					end.textAlign = Center;
					end.text = "Made in 48h for Lumdum Dare 30\nby @ncannasse\nThank you for playing!";
					end.x = (s2d.width - end.textWidth) >> 1;
					end.y = 120;
					end.dropShadow = { dx : 1, dy : 1, color : 0, alpha : 0.6 };

				}
			}
			var c = hero.color.x + dt * 0.01;
			if( c > 1 ) c = 1;
			hero.color.set(c, c, c, c);
		}

		if( Math.random() < 0.06 ) {
			var b = new h2d.Anim(Res.bird.toTile().split(), 6 + Math.random() * 6, scroll);
			b.x = Std.random(2) == 0 ? -16 : s2d.width;
			b.y = 40 + Std.random(tower.tile.height - 80);
			b.scale(0.7 + Math.random() * 0.5);
			if( b.scaleX >= 0.9 )
				scroll.add(b, 1);
			b.colorKey = 0x10b8e5;
			var dx = b.x < 0 ? 1 + Math.random() : -(1 + Math.random());
			var dy = hxd.Math.srand(1.5) - 0.8;
			b.speed = Math.sqrt(dx * dx + dy * dy) * 8;
			birds.push({ b : b, dx : dx, dy : dy });
		}

		for( b in birds.copy() ) {
			b.b.x += b.dx * dt * 0.5;
			b.b.y += b.dy * dt * 0.5;
			if( b.b.x < -30 || b.b.x > s2d.width + 30 ) {
				b.b.remove();
				birds.remove(b);
			}
		}
		if( Math.random() * dt < 0.1 ) {
			if( Std.random(3) == 0 )
				Res.sfx.bird2.play();
			else
				Res.sfx.bird1.play();
		}


		if( scroll.y < -(tower.tile.height - s2d.height) ) {
			scroll.y = -(tower.tile.height - s2d.height);
			if( hero == null ) {
				hero = new h2d.Anim(Res.hero.toTile().sub(0, 32, 5 * 16, 16).split(), 12, s2d);
				hero.y = s2d.height + 15;
				hero.scale(0.5);
				hero.color = new h3d.Vector(1, 1, 1, 1);
				hero.colorKey = 0xA4F50D;
				hero.x = 150;
			}
		}
		if( hero != null && !finish ) {
			hero.y -= dt * 0.2;
			if( hero.y < s2d.height - 25 ) {
				hero.y += dt * 0.15;
				hero.alpha -= 0.02 * dt;
				hero.color.x -= 0.04 * dt;
				hero.color.y = hero.color.z = hero.color.x;
				if( hero.alpha < 0 ) {
					hero.remove();
					hero = null;

					title = new h2d.Bitmap(Res.titleText.toTile(), s2d);
					title.alpha = 0;
					title.colorKey = 0xFFFFFF;

					titleFront = new h2d.Bitmap(Res.titleText.toTile(), s2d);
					titleFront.alpha = 0;
					titleFront.colorKey = 0xFFFFFF;
					titleFront.colorAdd = new h3d.Vector(1, 1, 1, 1);
					titleFront.x = titleFront.y = -2;

					title.x += 6;
					titleFront.x += 6;


					start = new h2d.Text(Res.font.toFont(), s2d);
					start.text = "Click to start";
					start.x = (s2d.width - start.textWidth) >> 1;
					start.y = 160;
					start.dropShadow = { dx : 1, dy : 1, color : 0, alpha : 0.6 };

					new h2d.Interactive(s2d.width, s2d.height, s2d).onClick = function(_) {
						s2d.dispose();
						Game.inst = new Game(engine);
					};

					var copy = new h2d.Text(Res.font.toFont(), s2d);
					copy.scale(0.5);
					copy.text = "(C)2014 NCA";
					copy.dropShadow = { dx : 1, dy : 1, color : 0, alpha : 0.6 };
					copy.x = 2;
					copy.filter = true;
					copy.y = s2d.height - 2 - (copy.textHeight >> 1);
				}
			}
		}

		if( start != null ) {
			time += dt / 30;
			start.visible = Std.int(time) & 1 == 0;
		}

		if( title != null ) {
			title.alpha += 0.05 * dt;
			if( title.alpha > 1 ) title.alpha = 1;
			titleFront.alpha = title.alpha;
		}
		bg.y = scroll.y * bg.scaleY;
	}

}