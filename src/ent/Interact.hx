package ent;
import Data;

class Interact extends Entity {

	var ikind : IKind;

	public function new(k, x, y) {
		ikind = k;
		super(EInt(k), x, y);
		switch( k ) {
		case Heart:
			isCollide = true;
		case Stairs:
			spr.visible = false;
		case Teleport:
			spr.speed = 4;
			spr.y += 2;
		case Npc:
			isCollide = true;
			spr.speed = 0;
		default:
		}
	}

	override function activate() {
		switch( ikind ) {
		case Npc:
			spr.speed = 6;

			var text = switch( game.currentLevel ) {
			case 0:
				"Hello young Selenite, did you fall from the moon?
				#I haven't seen any of your kind for a long time...
				#If you want to return to your home, you'll have to climb the Jeru Tower.
				#Get all the hearts to unlock the stairs to the next floor.
				#Good luck!
				";
			case 1:
				"Hearts will sometimes give you a special power.
				#Don't waste it, or you will not be able to complete the floor.
				#If you are stuck, use the \"Escape\" magic word to try again.
				";
			case 2:
				"Some monsters will attack you even while they're asleep.
				#Use the Pilar Invocation power to protect yourself.";
			case 3:
				"The Jeru Tower lives at the crossroad of multiple connected worlds.
				#The Selenites such as you can sometimes open portals between these worlds.
				#They are the same, and still different.
				";
			case 4:
				"The Pilar can prevent things from appearing in other worlds.";
			case 5:
				"The Bomb will only explode if you are near and if all the hearts have been taken.";
			case 6:
				"When changing worlds, the pink monsters will lose their powers and can be pushed.";
			case 7:
				"The Dark One is the most dangerous... It can even reach you through Plantustics!";
			case 8:
				"Did you ever try to push some monsters trough a Portal?
				#I wonder what could happen with some of them...";
			default: "TODO:" + [game.currentLevel, game.world];
			}

			game.dialog(text, function() {
				game.hero.lock = false;
				spr.speed = 0;
				spr.currentFrame = 0;
			});

			return true;
		default:
		}
		return false;
	}

	override function wakeUp() {
		switch( ikind ) {
		case Stairs:
			spr.visible = true;
		default:
		}
	}

	override function collideWith( e : Entity ) {
		switch( [ikind, e.kind] ) {
		case [Heart, EHero]:
			return false;
		default:
		}
		return true;
	}

	override function init() {
		var g = Res.anims.toTile().grid(16);
		var tl = [];
		var nframes = 4;
		for( i in 0...nframes ) { var t = g[ikind.getIndex() * 16 + i + 8]; t.dx = -8; t.dy = -16; tl.push(t); }
		anims = [tl];
		game.root.add(spr, Const.LAYER_OBJ - 1);
	}

	override function update(dt) {
		switch( ikind ) {
		case Teleport:
			if( Math.random() < 0.5 )
				game.emitPart(Std.random(3), 2, (ix * 16 + Std.random(16)), iy * 16 + 2 + Std.random(14), 0, -(1 + Math.random()) * 10, 1 + Math.random());
		default:
		}
	}

}