scriptName "Functions\misc\fn_help.sqf";
/*
	File: help.sqf
	Author: Karel Moricky

	Description:
	Displays list of all available functions
*/

















if (!isnil {BIS_functions_mainscope getvariable "help"}) exitwith {};
[] spawn {
	disableserialization;
	createDialog  "RscFunctionsViewer";

	_display = findDisplay 2929;
	_listFunctions = _display displayCtrl 292901;
	_listSources = _display displayCtrl 292902;
	_listTags = _display displayCtrl 292903;
	_listCats = _display displayCtrl 292904;

	_listSources lbAdd "configFile";
	_listSources lbAdd "missionConfigFile";
	_listSources lbAdd "campaignConfigFile";
	bis_functions_mainscope setvariable ["help_listSources",[configfile,missionconfigfile,campaignconfigfile]];
	BIS_functions_mainscope setvariable ["help_id",0];
	BIS_functions_mainscope setvariable ["help_fnc",-1];
	BIS_functions_mainscope setvariable ["help_refresh",false];

	bis_functions_mainscope setvariable ["help_codeSources",{
			disableserialization;
			_id = _this select 1;
			if (_id < 0) exitwith {};
			_source = ((bis_functions_mainscope getvariable "help_listSources") select _id) >> "cfgFunctions";
			_listTags = (findDisplay 2929) displayctrl 292903;
			lbclear _listTags;
			for "_s" from 0 to (count _source - 1) do {
				_currentTag = _source select _s;
				if (isclass _currentTag) then {
					_currentTagName = configname _currentTag;
					_lbTag = _listTags lbadd _currentTagName;
				};
			};
			lbsort _listTags;
			_listTags lbsetcursel 0;
			if (count _source == 0) then {[-1,-1] spawn (bis_functions_mainscope getvariable 'help_codeTags')};
		}
	];
	bis_functions_mainscope setvariable ["help_codeTags",{
			disableserialization;
			_id = _this select 1;
			_listSources = (findDisplay 2929) displayCtrl 292902;
			_listTags = (findDisplay 2929) displayctrl 292903;
			_listCats = (findDisplay 2929) displayctrl 292904;

			if (_id < 0) exitwith {
				lbclear _listCats;
				[-1,-1] spawn (bis_functions_mainscope getvariable 'help_codeCats');
			};
			_tag = (bis_functions_mainscope getvariable "help_listSources") select (lbcursel _listSources) >> "cfgFunctions" >> (_listTags lbtext (lbcursel _listTags));
			lbclear _listCats;
			for "_t" from 0 to (count _tag - 1) do {
				_currentCat = _tag select _t;
				if (isclass _currentCat) then {
					_currentCatName = configname _currentCat;
					_lbCat = _listCats lbadd _currentCatName;
				};
			};
			lbsort _listCats;
			_listCats lbsetcursel 0;
		}
	];
	bis_functions_mainscope setvariable ["help_codeCats",{
			disableserialization;
			_id = _this select 1;
			_listSources = (findDisplay 2929) displayCtrl 292902;
			_listTags = (findDisplay 2929) displayctrl 292903;
			_listCats = (findDisplay 2929) displayctrl 292904;
			_listFncs = (findDisplay 2929) displayctrl 292901;

			if (_id < 0) exitwith {lbclear _listFncs;};
			_cat = (bis_functions_mainscope getvariable "help_listSources") select (lbcursel _listSources) >> "cfgFunctions" >> (_listTags lbtext (lbcursel _listTags)) >> (_listCats lbtext (lbcursel _listCats));
			lbclear _listFncs;
			_tag = _listTags lbtext (lbcursel _listTags);
			for "_t" from 0 to (count _Cat - 1) do {
				_currentFnc = _Cat select _t;
				if (isclass _currentFnc) then {
					_currentFncName = configname _currentFnc;
					_lbFnc = _listFncs lbadd (_tag + "_fnc_" + _currentFncName);
					_listFncs lbsetdata [_lbFnc,_currentFncName];
				};
			};
			lbsort _listFncs;
			_listFncs lbsetcursel 0;
		}
	];


	_listSources ctrlseteventhandler ["LBSelChanged","_this spawn (bis_functions_mainscope getvariable 'help_codeSources')"];
	_listTags ctrlseteventhandler ["LBSelChanged","_this spawn (bis_functions_mainscope getvariable 'help_codeTags')"];
	_listCats ctrlseteventhandler ["LBSelChanged","_this spawn (bis_functions_mainscope getvariable 'help_codeCats')"];
	_listFunctions ctrlseteventhandler ["LBSelChanged","BIS_functions_mainscope setvariable ['help_fnc',_this select 1]"];
	_listSources lbsetcursel 0;


	BIS_functions_mainscope setvariable ["help_fnc",0];


	_textCode = _display displayctrl 292908;
	_textCode ctrlshow false;
	_btnCopy = _display displayctrl 292909;
	_btnCopy ctrlshow false;

	_categories = [];

	waituntil {(_listfunctions lbtext (lbcursel _listFunctions)) != ""};


	[_display,_listSources,_listFunctions] spawn {
		disableserialization;
		_display = _this select 0;
		_listSources = _this select 1;
		_listFunctions = _this select 2;
		_textTitle = _display displayctrl 292905;
		_textPath = _display displayctrl 292906;
		_textDesc = _display displayctrl 292907;
		_textCode = _display displayctrl 292908;
		_btnCopy = _display displayctrl 292909;
		while {!isnil {BIS_functions_mainscope getvariable "help"}} do {
			_listFunctions = _display displayCtrl 292901;
			_listSources = _display displayCtrl 292902;
			_listTags = _display displayCtrl 292903;
			_listCats = _display displayCtrl 292904;

			_idfnc = BIS_functions_mainscope getvariable "help_fnc";
			_title = _listFunctions lbtext _idfnc;
			_color = _listFunctions lbcolor _idfnc;
			_source = (bis_functions_mainscope getvariable "help_listSources") select (lbcursel _listSources);
			_itemConfig = _source >> "cfgFunctions" >> (_listTags lbtext (lbcursel _listTags)) >> (_listCats lbtext (lbcursel _listCats)) >> (_listFunctions lbdata _idfnc);
			//hint str ["X",_source,(_listTags lbtext (lbcursel _listTags)),(_listCats lbtext (lbcursel _listCats)),(_listFunctions lbdata _idfnc)];
			_desc = gettext (_itemConfig >> "description");
			_descColor = [1,1,1,1];
			if (_desc == "") then {_desc = "MISSING DESCRIPTION!"; _descColor = [1,0.3,0,1]};

			_codePath = call compile format ["%1_path",_title];
			_code = loadfile _codepath;
			bis_functions_mainscope setvariable ["help_code",_code];

			if (format ["%1",_code] == "") then {
				_textCode ctrlshow false;
				_btnCopy ctrlshow false;
			} else {
				_textCode ctrlshow true;
				_btnCopy ctrlshow true;
			};

			_textDesc ctrlsettextcolor _descColor;

			_textTitle ctrlsettext _title;
			_textPath ctrlsettext ("  " + _codePath);
			_textDesc ctrlsettext _desc;
			_textCode ctrlsettext _code;

			//waituntil {BIS_functions_mainscope getvariable "help_fnc" != _idfnc};
			waituntil {_listFunctions lbtext (lbcursel _listFunctions) != _title || BIS_functions_mainscope getvariable "help_refresh"};
			BIS_functions_mainscope setvariable ["help_refresh",false];
			_textTitle ctrlsettext "";
			_textPath ctrlsettext "";
			_textDesc ctrlsettext "";
			_textCode ctrlsettext "";
		};
	};

	waituntil {isnil {BIS_functions_mainscope getvariable "help"}};
	BIS_functions_mainscope setvariable ["help",nil];
	BIS_functions_mainscope setvariable ["help_fnc",nil];
	BIS_functions_mainscope setvariable ["help_code",nil];
	bis_functions_mainscope setvariable ["help_listSources",nil];
	bis_functions_mainscope setvariable ["help_codeSources",nil];
	bis_functions_mainscope setvariable ["help_codeTags",nil];
	bis_functions_mainscope setvariable ["help_codeCats",nil];
	bis_functions_mainscope setvariable ["help_codeFncs",nil];
};