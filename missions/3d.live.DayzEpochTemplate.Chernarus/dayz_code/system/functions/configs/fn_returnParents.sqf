scriptName "Functions\configs\fn_returnParents.sqf";
/*
	File: fn_returnParents.sqf
	Author: Karel Moricky

	Description:
	Returns list of all parent classes
	
	Parameter(s):
	_this select 0: starting config class (Config)
	_this select 1: true if you want to return only classnames (Boolean)
	
	Returns:
	Array - List of all classes (including starting one)
*/
private ["_entry","_returnString","_parents","_element"];

_entry = _this select 0;
_returnString = if (count _this > 1) then {true} else {false};
_parents = [];

if (typename _entry != "CONFIG") exitwith {debuglog "Log: [Functions/returnParents] Entry (0) must be of type Config!"};

while {str _entry != ""} do {
	_element = if (_returnString) then {configname _entry} else {_entry};
	_parents = _parents + [_element];
	_entry = inheritsfrom _entry;
};

_parents