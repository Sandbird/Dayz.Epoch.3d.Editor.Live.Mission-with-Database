scriptName "Functions\misc\fn_saveGame.sqf";
/*
	File: fn_saveGame.sqf
	Author: Chose

	Description:
	Evaluates the current battlefield situation and saves the game when appropriate

	Parameter(s):
		0: units to check (ARRAY)

	Returns:
		nothing
*/

_essential = _this;
if (count _essential == 0) then {_essential = [player]};

if ({lifeState _x == "UNCONSCIOUS" || !(alive _x)} count _essential == 0) exitWith {saveGame};

_essential spawn {
	_essential = _this;
	waitUntil {{lifeState _x == "UNCONSCIOUS" || !(alive _x)} count _essential == 0};
	saveGame
};