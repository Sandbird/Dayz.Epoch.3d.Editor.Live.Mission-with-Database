//--------------------------------------------------------------------------------------------------
// INIT
//--------------------------------------------------------------------------------------------------
BIS_COLOR_GREEN 			= "#66ab47";		//ui green
BIS_COLOR_SHADOW 			= "#312100";		//shadow color (dark braun)
BIS_COLOR_HILITE 			= "#e6b448";		//orange
BIS_COLOR_HILITE_BRIGHT 	= "#fed886";		//bright orange/yellow
BIS_COLOR_TEXT			 	= "#818960";		//light braun



BIS_COLOR_FRIENDLY = "#4e8d31";		//green
BIS_COLOR_NEUTRAL = "#9f9f9f";		//grey
BIS_COLOR_ENEMY = "#9d0000";		//red

//--------------------------------------------------------------------------------------------------
// ICONS
//--------------------------------------------------------------------------------------------------
//[<icon>,<color>,<placement>,<size>] call BIS_getIcon;
BIS_getIcon = {
	private["_html","_icon","_color","_placement","_size","_shadow","_shadowColor","_sizeAdj"];
	
	//icon
	_icon =  _this select 0;
	
	//color
	if (count _this > 1) then {
		_color = _this select 1;
	} else {
		_color = BIS_COLOR_GREEN;
	};

	//align
	if (count _this > 2) then {
		_placement = _this select 2;
	} else {
		_placement = switch (_icon) do {
			case "repair": {"x"};
			default {"_x_"};
		};			
	};

	//size
	if (count _this > 3) then {
		_size = _this select 3;
	} else {
		_size = 1;
	};
	_sizeAdj = switch (_icon) do {
			case "heal": {0.9};
			case "timer": {1.2};
			case "reammo": {1.2};
			case "refuel": {1.0};
			default {1.1};
	};	
	_size = _size * _sizeAdj;

	//set-in-stone defaults
	_shadow = 1;
	_shadowColor = BIS_COLOR_SHADOW;
	
	_html =  format["<img color='%2' image='%6img_icons\icon_%1_ca.paa' size='%3' shadow='%4' shadowColor='%5'/>",_icon,_color,_size,_shadow,_shadowColor,BIS_AdvHints_Path];
	
	//add spaces
	_html = switch (_placement) do {
		case "_x_": {" "+_html+" "};
		case "x": {_html};
		case "_x": {" "+_html};
		case "x_": {_html+" "};
		default {_html};
	};		
	
	_html	
};

BIS_runIconDemo = {
	private["_text","_id"];

	_text = "Re-designed icons:<br/>";
	_id = 0;

	{
		_id = _id + 1;
		_text = _text + "<br/>" + str(_id) + ": " + _x + ([_x] call BIS_getIcon) + _x;
		
	} forEach [
		"commander",
		"driver",
		"gunner",
		"heal",
		"open",
		"pilot",
		"reammo",
		"refuel",
		"reload",
		"repair",
		"targetlocked",
		"timer"
	];


	BIS_AdvHints_THeader =  "ICON DEMO";
	BIS_AdvHints_TInfo =  _text;
	BIS_AdvHints_TAction =  "";
	BIS_AdvHints_TBinds = "";
	BIS_AdvHints_Text = call BIS_AdvHints_formatText;
	call BIS_AdvHints_showHint;	
};