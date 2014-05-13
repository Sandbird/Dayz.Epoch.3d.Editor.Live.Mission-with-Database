private ["_cTarget","_isOk","_display","_inVehicle","_charID","_friend","_humanityTarget","_friendlies"];
disableSerialization;
_display = (_this select 0);
_inVehicle = (vehicle player) != player;
_cTarget = cursorTarget;
if(_inVehicle) then {
	_cTarget = (vehicle player);
};

_isOk = false;
{
	if(!_isOk) then {
		_isOk = _cTarget isKindOf _x;
	};
} forEach ["LandVehicle","Air", "Ship"];

if((locked _cTarget) and _isOk and (((vehicle player) distance _cTarget) < 12)) then {
	cutText [(localize "str_epoch_player_7") , "PLAIN DOWN"];
	_display closeDisplay 1;
};
// IN SAFE ZONE
if( !canbuild ) then
{
	if( isPlayer cursorTarget and alive cursorTarget and vehicle cursorTarget == cursorTarget ) then
	{
		_humanityTarget = cursorTarget;
		_friendlies = player getVariable ["friendlyTo",[]];
		_charID = _humanityTarget getVariable ["playerUID", "0"]; //getPlayerUID _humanityTarget;

		_friend = _charID in _friendlies; //_ownerID

		// check if friendly to owner
		if( !_friend ) then {
			cutText["------Anti-Theft------\nThis Player is not your Friend\nYou cant access his gear\nTag Player as Friend to get access.", "PLAIN DOWN",0];
			_display closeDisplay 1;
		};
	};
};