scriptName "Functions\numbers\fn_greatestNum.sqf";
/************************************************************
	Find Greatest Number
	By Andrew Barron

Parameters: [number set]
Returns: number

Returns the highest number out of the passed set.

Example: [1,5,10] call BIS_fnc_greatestNum
	returns 1
************************************************************/

private "_highest";

_highest = -1e9;
{
	if(_x > _highest) then
	{
		_highest = _x;
	};
} foreach _this;

_highest