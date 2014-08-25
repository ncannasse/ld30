package ent;
import Data;

class Interact extends Entity {

	var ikind : IKind;
	var lockPush = false;

	public function new(k, x, y) {
		ikind = k;
		super(EInt(k), x, y);
		switch( k ) {
		case Heart:
			isCollide = true;
			game.entities.remove(this);
			game.entities.unshift(this);
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
		return !lockPush && ikind == Npc && game.world > 0;
	}

	override function push(dir : hxd.Direction) {
		var telep = get(ix + dir.x, iy + dir.y);
		var a = getSync();
		super.push(dir);
		for( e in a ) {
			e.ix += dir.x;
			e.iy += dir.y;
			e.spr.x += dir.x * 16;
			e.spr.y += dir.y * 16;

			for( e2 in game.entities )
				if( e2 != e && e2.isCollide && e2.ix == e.ix && e2.iy == e.iy ) {
					e2.remove();
					break;
				}
		}


		if( telep != null && telep.kind.match(EInt(Teleport)) ) {
			for( e in a )
				e.remove();
			lockPush = true;
			game.wait(1, function() {
				Res.sfx.teleport.play();
				game.waitUntil(function(dt) {
					spr.alpha -= 0.1 * dt;
					if( spr.alpha < 0 ) {
						var way = iy >= Const.CH ? -1 : 1;
						iy += Const.CH * way;
						spr.y += Const.H * way;
						spr.alpha = 1;
						lockPush = false;
						return true;
					}
					return false;
				});
			});
		}
	}

	override function checkHero() {
		switch( ikind ) {
		case Heart:
			if( game.hero.ix == ix && game.hero.iy == iy ) {
				remove();
				for( e in getSync() )
					e.remove();
				game.nextHeart();
			}
		default:
		}
	}

	override function activate() {
		switch( ikind ) {
		case Npc:
			spr.speed = 6;

			var text = switch( game.level.data.id ) {
			case Tuto1:
				"Hello young Selenite!\nDid you fall from the moon?
				#I haven't seen any of your kind for a long time...
				#If you want to return to your home, you'll have to climb Jeru's Tower.
				#Get all the hearts to unlock the stairs to the next floor.
				#Good luck!
				";
			case Tuto2:
				"Collecting hearts will give you a special powa.
				#Don't waste it, or you will not be able to complete the floor.
				#If you are stuck, use the \"Escape\" magic word to try again.
				";
			case Tuto3:
				"Jeru's Tower is populated by many different moobs.
				#Some of them will attack you even while they're asleep.
				#Use the Pilar Invocation powa to protect yourself.";
			case Tuto4:
				"Jeru's Tower lives at the crossroad of multiple connected worlds.
				#The Selenites such as you can open portals between these worlds.
				#These worlds are similar, but have different rules.
				";
			case Pilar:
				"Did you know that the Pilar can also destroy things in other worlds?";
			case Boombo:
				"The Boombo will only explode if you are near and if all the hearts have been taken.
				#Some moobs can be pushed when you're into the Grey World.";
			case PushPink:
				"Into the Grey World, Pinkies moobs will lose their fire and can be pushed.";
			case PowerOrder:
				"Using your powas in the right order is the first step to have a successful life.
				#But are you interested in anothing apart climbing Jeru's Tower?";
			case DarkOne:
				"The Dark One is the most dangerous... It can even reach you through Plantustics!
				#You can be glad that hearts and other moobs will protect you from him.";
			case MultiPortal:
				"Conflicts can occur between worlds when two moobs collide.
				#This is easily handled by the complete destruction of the moob that gets overwritten.
				#Science is a beautiful thing, don't you think?";
			case Split:
				"Splitty moobs creates local Pink Worlds where ennemies cannot reach you.
				#But Splitty will give you limits on how many steps you can make in Pink Worlds.
				#That's not very friendly of them actually...";
			case SplitRot:
				"Splitty moobs can be rotated when you get the Turn'ing powa.
				#Dark Ones can't survive inside the Pink World.
				#I guess that's too much colorful for them...";
			case PushOld:
				"Although I hate to tell you that...
				#There's some other \"things\" that you can push in the Grey World.
				#I won't tell you more, I have my own pride.";
			case Telekill:
				"Did you ever try to push some monsters through a Portal?
				#I wonder if funny things could happen with some of them...";
			case DoubleSplit:
				"Killing moobs with fireballs while you're in the Pink World is acting cowardly !!!
				#On the other hand it's a lot of fun...";
			case Princess:
				"Sorry but the princess is in another castle!
				#....
				#Noooo ! Don't touch me !!!!";
			case Sacrifice:
				"Sacrifices are sometimes necessary...
				#No, I'm not talking about you. I already know you enjoy dying.
				#Or else, why would you still be trying to reach the top of Jeru's Tower?";
			case BombTriangle:
				"Be careful of the Boombos !
				#Yes, I know I'm not being very helpful...
				#I'll do my best next time...";
			case Pilar3:
				"You should be able to handle this one by yourself without my help.
				#At least I hope so...";
			case PushingAround:
				"Sorry I don't really feel like talking today...
				#Yes, I know that's annoying, but I really can't help it.
				#Please talk to me again, on another floor.
				#You know I'm still your friend, right?";
			case MultiFire:
				"Eh! Don't suprise me this way, I thought it was a Dark One!";
			case PilarAgain:
				"Keep going, you're almost at the top of Jeru's Tower!";
			case ZigZag:
				"This floor is named \"Zigzag\". I wonder why...";
			case Casual:
				"So far you have died " + game.dieCount + " times.
				#That's pretty impressive, don't you think?";
			case MultiRotate:
				"You know, you don't ALWAYS have to use ALL the powas you get!";
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
		var layer = Const.LAYER_OBJ - 1;
		if( ikind == Npc ) layer++;
		game.root.add(spr, layer);
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