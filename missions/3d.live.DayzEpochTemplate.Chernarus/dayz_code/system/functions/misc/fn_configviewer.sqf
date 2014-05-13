//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// filltree.sqf
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
BIS_configviewer_filltree =
{
	startLoadingScreen [""];
	_mainCfg = _this select 0;
	_cfg = _mainCfg;
	_color=[];
	_list= _this select 1;
	_selected =  "";
	if (count _this > 2) then {_selected =  _this select 2};
	_values=[];
	lbclear _list;
	if (typename _cfg == "SCALAR") then
	{
		_list lbAdd "config.bin";
		_list lbSetData [0, "configfile"];
		_list lbAdd "mission description.ext";
		_list lbSetData [1, "missionConfigFile"];
		_list lbAdd "campaign description.ext";
		_list lbSetData [2, "campaignConfigFile"];
		_list lbSetCurSel 0;
	}
	else
	{
		while {isclass _cfg} do
		{
			_count= count _cfg;
			for "_x" from 0 to _count-1 do
			{
				_item = _cfg select _x;
				if (isclass _item) then
				{
				_item =_mainCfg >> configname( _item);
				if (not(_item in _values)) then {_values=_values+[_item]};
				};
			};
			_cfg= inheritsFrom  _cfg;
		};

		_c=0;
		{
			_item =_x;
			_text=format["class %1 : %2 {};",configname _item,configname inheritsFrom _item];
			_list lbAdd _text;
			_list lbSetData [_c, configname _item];
			_c=_c+1;
		}foreach _values;
		_last = count _values-1;
		lbSort _list;
		if (_selected=="") then {_list lbSetCurSel 0;}
		else
		{
			for "_x" from 0 to (lbSize _list) -1 do
			{
				if (_selected==(_list lbData _x)) then {_list lbSetCurSel _x;};
			};
		};

		if (_last < (lbCurSel _list)) then {_list lbSetCurSel _last};

	};

	endLoadingScreen; // end loading ecreen
};



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// fillview.sqf
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
BIS_configviewer_fillview =
{
	//startLoadingScreen [""];
	_mainCfg = _this select 0;
	_cfg = _mainCfg;
	_color=[];
	_list= _this select 1;

	_values=[];

	//_preCount = lbSize _list;
	_lastSel = lbCurSel _list;
	lbclear _list;

	while {isclass _cfg} do
	{
		_ownername = configname _cfg;
		_count= count _cfg;
		for "_x" from 0 to _count-1 do
		{
			_item = _cfg select _x;
			if (not (isclass _item)) then
			{
				_item =_mainCfg >> configname( _item);
				if (not(_item in _values)) then {_values=_values+[_item]};
			};
		};
		_cfg= inheritsFrom	_cfg;
	};

	_c=0;
	{
		_item =_x ;
		//_ownername =_x select 1;
		_text="";

		if (istext _item) then {_text=format["%1 = ""%2"";",configname _item,gettext _item];_color=[1,0.8,0.8,1];};
		if (isnumber _item) then {_text=format["%1 = %2;",configname _item,getnumber _item];_color=[0.8,1,0.8,1]; };
		if (isarray _item) then {_text=format["%1 = %2;",configname _item,getarray _item];_color=[0.6,0.6,1,1];};

		if (config_Viewer_ExList==1) then {_text=format["[%1] %2",_ownername,_text]};
		_list lbAdd _text;
		_list lbSetColor [_c,_color];
		_list lbSetData [_c, configname _item];
		_c=_c+1;

	}foreach _values;

	lbSort _list;
	//_list lbSetCurSel 0;
	_last = count _values-1;
	if (_last < _lastSel) then {_list lbSetCurSel _last}else {_list lbSetCurSel _lastSel};
	//endLoadingScreen; // end loading ecreen
};



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// keydown.sqf
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
BIS_configviewer_keydown = {
	disableserialization;
	_display = uinamespace getvariable 'BIS_configviewer_display'; //findDisplay 2929;
	_list1 =_display displayCtrl 1;
	_path =_display displayCtrl 3;
	_text="Configfile";
	_key =_this select 1;
	_ctrl = _this select 3;

	if (_key==28) then
	{
		[_list1,lbCurSel _list1] spawn BIS_configviewer_open;
	}
	else
	{
		if (_key==14) then
		{
			[_list1,1] spawn BIS_configviewer_return;
		};
	};
	if (_key == 46 && _ctrl) then {
		_display = ((uinamespace getvariable 'BIS_configviewer_display') displayctrl 1);
		copytoclipboard (_display lbtext (lbcursel _display))
	};
};

BIS_configviewer_keydown_list = {
	disableserialization;
	_key =_this select 1;
	_ctrl = _this select 3;
	if (_key == 46 && _ctrl) then {
		_display = ((uinamespace getvariable 'BIS_configviewer_display') displayctrl 2);
		copytoclipboard (_display lbtext (lbcursel _display))
	};
};


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// makepath.sqf
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
BIS_configviewer_makepath = {
	private ["_return","_c"];
	_c=0;
	_cfg = configfile;
	{
		if (_c==0) then
		{
			_c=1;
			call compile format["_return = %1",_x];
		}
		else
		{
			_return = _return >> _x;
		}
	}foreach _this;

	_return
};



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// open.sqf
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
BIS_configviewer_open = {
	disableserialization;
	_display = uinamespace getvariable 'BIS_configviewer_display'; //findDisplay 2929;
	_list2 =_display displayCtrl 2;
	_list1 =_display displayCtrl 1;
	_path =_display displayCtrl 3;

	lbClear _list2;
	_text="Configfile";

	{_text=format["%1 << %2",_text,_x]}foreach currentConfigPosition;

	_cls = _list1 lbdata (_this select 1);
	_cfg = (currentConfigPosition+[_cls]) call BIS_configviewer_makepath;

	if ( isclass (_cfg)) then
	{
		currentConfigPosition=currentConfigPosition+[_cls];
		_text=format["%1 << %2",_text,_cls];
		_path ctrlSetText format["%1",_text];
		[_cfg,_list1] call BIS_configviewer_filltree;
	};
};



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// return.sqf
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
BIS_configviewer_return = {
	private["_cfg"];
	disableserialization;
	_display = uinamespace getvariable 'BIS_configviewer_display'; //findDisplay 2929;
	_list1 =_display displayCtrl 1;
	_path =_display displayCtrl 3;
	_text="Configfile";

	if ((_this select 1)==1) then
	{
		_current = "";
		if (count currentConfigPosition>0) then {_current = currentConfigPosition select ((count currentConfigPosition) -1)};
		currentConfigPosition resize ((count currentConfigPosition-1)max 0);
		if (count currentConfigPosition == 0) then
		{
			_cfg=0;
		}
		else
		{
			_cfg = currentConfigPosition call BIS_configviewer_makepath;
		};

		{_text=format["%1 << %2",_text,_x]}foreach currentConfigPosition;
		_path ctrlSetText format["%1",_text];
		[_cfg,_list1,_current] call BIS_configviewer_filltree;
	};
};



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// show.sqf
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
BIS_configviewer_show = {
	private["_cfg"];
	disableserialization;
	_display = uinamespace getvariable 'BIS_configviewer_display'; //findDisplay 2929;
	_list2 =_display displayCtrl 2;
	_list1 =_display displayCtrl 1;
	_cls = _list1 lbdata (_this select 1);
	_count =count (configfile >>  _cls);
	_cfg = (currentConfigPosition+[_cls]) call BIS_configviewer_makepath;
	[_cfg,_list2] call BIS_configviewer_fillview;
};



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// #NIL
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
BIS_configviewer_unload = {
	BIS_configviewer_display = nil;
	currentconfigposition = nil;
	config_viewer_exlist = nil;
	currentconfiggoot = nil;
	BIS_configviewer_filltree = nil;
	BIS_configviewer_fillview = nil;
	BIS_configviewer_keydown = nil;
	BIS_configviewer_makepath = nil;
	BIS_configviewer_open = nil;
	BIS_configviewer_return = nil;
	BIS_configviewer_show = nil;
	BIS_configviewer_unload = nil;
};



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// init.sqf
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
disableserialization;
currentConfigGoot=0;
currentConfigPosition=[];
config_Viewer_ExList=0;
createDialog "RscConfigEditor_Main";

_display = uinamespace getvariable 'BIS_configviewer_display'; //findDisplay 2929;
_list1 =_display displayCtrl 1;

[0,_list1] call BIS_configviewer_filltree;