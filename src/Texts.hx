import Res;

@:build(hxd.res.DynamicText.build("texts.xml", true))
class Texts {

	public static function init() {
		var path = "";
		load(Res.load(path+"texts.xml").toText());
	}

}
