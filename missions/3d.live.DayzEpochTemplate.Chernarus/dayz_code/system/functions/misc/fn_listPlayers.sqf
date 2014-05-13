scriptName "Functions\misc\fn_listPlayers.sqf";
/*
	File: listPlayers.sqf
	Author: Karel Moricky

	Description:
	Returns list of players and playable units

	Returns:
	Boolean (true when position is in area, false if not).
*/
private ["_this","_SPlist","_MPlist","_resultList"];

_SPlist = switchableUnits;
_MPlist = playableunits;
_resultList = [player];

if (isnil "_this") then {
	{
		if !(_x in _resultList) then {_resultList = _resultList + [_x]};
	} foreach (_SPlist + _MPlist);
} else {
	{
		if (isplayer _x && !(_x in _resultList)) then {_resultList = _resultList + [_x]};
	} foreach (_SPlist + _MPlist);
};

_resultList;