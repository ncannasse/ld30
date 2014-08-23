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
		height = Const.CH;
		game = Game.inst;
		init();
	}

	function init() {
		collide = [];
		for( x in 0...width )
			collide[x] = [];
		for( x in 0...width )
			collide[x][0] = true;
		collide[0][1] = true;
		collide[width - 1][1] = true;
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
						switch( MobKind.createByIndex(p) ) {
						case Hero:
							new ent.Hero(x, y);
						case m:
							new ent.Mob(m, x, y);
						}
					}
				}
			default:
				var t = new h2d.TileGroup(tl[0]);
				t.colorKey = 0xFF00FF;
				game.root.add(t, Const.LAYER_BG);
				for( y in 0...height ) {
					for( x in 0...width ) {
						var p = data[pos++] - 1;
						if( p < 0 ) continue;
						t.add(x * 16, y * 16, tl[p]);
					}
				}
			}
		}
	}

}