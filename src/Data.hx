
private typedef Init = haxe.macro.MacroType < [cdb.Module.build("data.cdb")] > ;

class Const {
	public static inline var CW = 15;
	public static inline var CH = 13;
	public static inline var W = CW * 16;
	public static inline var H = CH * 16;

	public static inline var LAYER_BG = 1;
	public static inline var LAYER_OBJ = 2;
	public static inline var LAYER_FX = 3;
}

enum MobKind {
	Tree;	// same
	Rock;	// disapear
	Pink;
	Pilar;	// erase in other worlds
	Orange;	// appear
	Bomb;	// explode
	Dark; 	// pink all worlds
}

enum IKind {
	Heart;
	Stairs;
	Teleport;
	Npc;
}

enum EntityKind {
	EHero;
	EMob( m : MobKind );
	EInt( i : IKind );
	EFireball;
}

typedef Power = LevelData_hearts_power;