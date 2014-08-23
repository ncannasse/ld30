import Data;

class Level {

	var game : Game;
	public var id : Int;
	public var width : Int;
	public var height : Int;

	public function new( id : Int ) {
		this.id = id;
		width = Const.CW;
		height = Const.CH;
		game = Game.inst;
		init();
	}

	function init() {
		var data = Data.levelData.all[id];
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
				game.s2d.add(t, Const.LAYER_BG);
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