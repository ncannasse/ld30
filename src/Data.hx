
private typedef Init = haxe.macro.MacroType < [cdb.Module.build("data.cdb")] > ;

class Const {
	public static inline var CW = 15;
	public static inline var CH = 12;
	public static inline var W = CW * 16;
	public static inline var H = CH * 16;

	public static inline var LAYER_BG = 1;
	public static inline var LAYER_OBJ = 2;
}

enum MobKind {
	Tree;
	Rock;
	Pink;
	Heart;
	Hero;
}

enum EntityKind {
	EHero;
	EMob( m : MobKind );
}