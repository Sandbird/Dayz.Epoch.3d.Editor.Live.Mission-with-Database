scriptName "Functions\misc\fn_PosToGrid.sqf";
/*
	File: PosToGrid.sqf
	Author: Karel Moricky

	Description:
	Converts array position to map grid position.

	Parameter(s):
	_this: Object, Array in format position or String with marker name

	Returns:
	Array in format ["X","Y"]
*/
private ["_x","_y","_xgrid","_ygrid","_xcoord","_ycoord","_result"];

_x = -1;
_y = -1;

switch (typename _this) do
{
	//--- Coordinates
	case "ARRAY": {
		_x = _this select 0;
		_y = _this select 1;
	};
	//--- Unit
	case "OBJECT": {
		_x = position _this select 0;
		_y = position _this select 1;
	};
	//--- Marker
	case "STRING": {
		_x = markerpos _this select 0;
		_y = markerpos _this select 1;
	};
	default {
		if (true) exitwith {hintc format ["Bad input in ""PosToGrid.sqf"" - %1.",typename _this]};
	};
};

_xgrid = floor (_x / 100);
_ygrid = floor ((15360 - _y) / 100);

_xcoord =
	if (_xgrid >= 100) then {
		str _xgrid;
	} else {
		if (_xgrid >= 10) then {
			"0" + str _xgrid;
		} else {
			"00" + str _xgrid;
		};
	};

_ycoord =
	if (_ygrid >= 100) then {
		str _ygrid;
	} else {
		if (_ygrid >= 10) then {
			"0" + str _ygrid;
		} else {
			"00" + str _ygrid;
		};
	};

_result = [_xcoord,_ycoord];
_result;