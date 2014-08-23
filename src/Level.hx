import Data;

class Level {

	var game : Game;
	public var collide : Array<Array<Bool>>;
	public var id : Int;
	public var width : Int;
	public var height : Int;
	public var data : Data.LevelData;

	public function new( id : Int ) {
		this.id = id;
		data = Data.levelData.all[id];
		width = Const.CW;
		height = data.height;
		game = Game.inst;
		init();
	}

	function init() {
		collide = [];
		for( x in 0...width )
			collide[x] = [];
		for( y in 0...Std.int(height / 12) ) {
			var y = y * 12;
			for( x in 0...width )
				collide[x][y] = true;
			collide[0][y+1] = true;
			collide[width - 1][y+1] = true;
		}
		var tl = Res.tiles.toTile().grid(16);
		for( l in data.layers ) {
			var data = l.data.data.decode();
			var pos = 0;
			switch( l.name ) {
			case "objects":
				for( y in 0...height ) {
					for( x in 0...width ) {
						var p = data[pos++] - 17;
						if( p < 0 ) continue;
						switch( p ) {
						case 0: new ent.Mob(Tree, x, y);
						case 1: new ent.Mob(Rock, x, y);
						case 2: new ent.Mob(Pink, x, y);
						case 3: new ent.Interact(Heart, x, y);
						case 4: new ent.Hero(x, y);
						case 5: new ent.Interact(Stairs, x, y);
						case 6: new ent.Interact(Teleport, x, y);
						}
					}
				}
			default:
				var t = new h2d.TileGroup(tl[0]);
				t.colorKey = 0xFF00FF;
				game.root.add(t, Const.LAYER_BG);
				var rnd = new hxd.Rand(42);
				for( y in 0...height ) {
					for( x in 0...width ) {
						var p = data[pos++] - 1;
						if( p < 0 ) continue;
						if( p == 0 ) {
							rnd.init(x + (y % 12) * 16);
							if( rnd.random(4) == 0 ) p += rnd.random(3);
						}
						t.add(x * 16, y * 16, tl[p]);
					}
				}
			}
		}
	}

}