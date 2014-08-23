class Game extends hxd.App {

	public var level : Level;
	public var entities : Array<ent.Entity>;
	public var hero : ent.Hero;

	override function init() {
		super.init();
		s2d.setFixedSize(15 * 16, 12 * 16);

		var bg = new h2d.Bitmap(Res.sky.toTile(), s2d);
		bg.tile.scaleToSize(s2d.width, s2d.height);
		bg.filter = true;
		bg.y = -70;

		entities = [];
		level = new Level(0);
	}

	override function update(dt:Float) {
		for( e in entities )
			e.update(dt);
	}

	public static var inst : Game;

	static function main() {
		hxd.Res.initEmbed();
		Data.load(Res.data.entry.getBytes().toString());
		Texts.init();
		inst = new Game();
	}

}