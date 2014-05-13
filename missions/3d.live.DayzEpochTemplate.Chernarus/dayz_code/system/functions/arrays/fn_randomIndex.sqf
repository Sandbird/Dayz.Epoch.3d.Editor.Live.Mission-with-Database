scriptName "Functions\arrays\fn_randomIndex.sqf";
/************************************************************
	Random Index
	By Andrew Barron

Parameters: array

This returns a random integer representing an index in the passed array.

Example: [1,2,3] call BIS_fnc_selectRandom
Returns: 0, 1, or 2
************************************************************/

private "_ret";

_ret = (count _this) - 1;           //number of elements in the array
_ret = [0, _ret] call BIS_fnc_randomInt; //choose random index
_ret
