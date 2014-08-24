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

	override function canPush() {
		return ikind == Npc && game.world > 0;
	}

	override function activate() {
		switch( ikind ) {
		case Npc:
			spr.speed = 6;

			var text = switch( game.level.data.id ) {
			case Tuto1:
				"Hello young Selenite, did you fall from the moon?
				#I haven't seen any of your kind for a long time...
				#If you want to return to your home, you'll have to climb Jeru's Tower.
				#Get all the hearts to unlock the stairs to the next floor.
				#Good luck!
				";
			case Tuto2:
				"Hearts will sometimes give you a special powa.
				#Don't waste it, or you will not be able to complete the floor.
				#If you are stuck, use the \"Escape\" magic word to try again.
				";
			case Tuto3:
				"Jeru's Tower is populated by many different moobs.
				#Some of them will attack you even while they're asleep.
				#Use the Pilar Invocation powa to protect yourself.";
			case Tuto4:
				"Jeru's Tower lives at the crossroad of multiple connected worlds.
				#The Selenites such as you can sometimes open portals between these worlds.
				#Theses worlds are similar, but different rules apply between them.
				";
			case Pilar:
				"The Pilar can destroy things in other worlds.";
			case Boombo:
				"The Boombo will only explode if you are near and if all the hearts have been taken.
				#Some moobs can be pushed were you're into the Grey World.";
			case PushPink:
				"Into the Grey World, Pinkies moobs will lose their powas and can be pushed.";
			case PowerOrder:
				"Using your powas in the right order is the first step to reach your goal in life.";
			case DarkOne:
				"The Dark One is the most dangerous... It can even reach you through Plantustics!
				#You can be glad that other moobs and hearts will protect you from him.";
			case Split:
				"Splitty moobs creates local Pink Worlds where ennemies cannot reach you.
				#But Splitty will give you limits on how many steps you can make in Pink Worlds.";
			case SplitRot:
				"Splitty moobs can be rotated when you get the Turn'ing powa.
				#Dark Ones can't survive inside the Pink World.
				#I guess that's too much colorful for them...";
			case PushOld:
				"Although I hate to tell you that.
				#There's some other \"things\" that you can push in the Grey World";
			case Telekill:
				"Did you ever try to push some monsters trough a Portal?
				#I wonder what could happen with some of them...";
			default:
				"TODO:" + game.level.data.id;
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