scriptName "Functions\spawning\fn_spawnVehicle.sqf";
/*
	File: spawnVehicle.sqf
	Author: Joris-Jan van 't Land

	Description:
	Function to spawn a certain vehicle type with all crew (including turrets).
	The vehicle can either become part of an existing group or create a new group.

	Parameter(s):
	_this select 0: desired position (Array).
	_this select 1: desired azimuth (Number).
	_this select 2: type of the vehicle (String).
	_this select 3: side or existing group (Side or Group).

	Returns:
	Array:
	0: new vehicle (Object).
	1: all crew (Array of Objects).
	2: vehicle's group (Group).
*/

//Validate parameter count
if ((count _this) < 4) exitWith {debugLog "Log: [spawnVehicle] Function requires at least 4 parameters!"; []};

private ["_pos", "_azi", "_type", "_param4", "_grp", "_side", "_newGrp"];
_pos = _this select 0;
_azi = _this select 1;
_type = _this select 2;
_param4 = _this select 3;

//Determine if an actual group was passed or a new one should be created.
if ((typeName _param4) == (typeName sideEnemy)) then
{
	_side = _param4;
	_grp = createGroup _side;
	_newGrp = true;
}
else
{
	_grp = _param4;
	_side = side _grp;
	_newGrp = false;
};

//Validate parameters
if ((typeName _pos) != (typeName [])) exitWith {debugLog "Log: [spawnVehicle] Position (0) must be an Array!"; []};
if ((typeName _azi) != (typeName 0)) exitWith {debugLog "Log: [spawnVehicle] Azimuth (1) must be a Number!"; []};
if ((typeName _type) != (typeName "")) exitWith {debugLog "Log: [spawnVehicle] Type (2) must be a String!"; []};
if ((typeName _grp) != (typeName grpNull)) exitWith {debugLog "Log: [spawnVehicle] Group (3) must be a Group!"; []};

private ["_sim", "_veh", "_crew"];
_sim = getText(configFile >> "CfgVehicles" >> _type >> "simulation");

if (_sim in ["airplane", "helicopter"]) then
{
	//Make sure aircraft start at a reasonable height.
	if ((count _pos) == 2) then 
	{
		_pos = _pos + [50];	
	};
	
	_veh = createVehicle [_type, _pos, [], 0, "FLY"];

	//Set a good velocity in the correct direction.
	_veh setVelocity [50 * (sin _azi), 50 * (cos _azi), 0];
}
else
{
	_veh = _type createVehicle _pos;
};

//Set the correct direction.
_veh setDir _azi;

//Make sure the vehicle is where it should be.
_veh setPos _pos;

//Spawn the crew and add the vehicle to the group.
_crew = [_veh, _grp] call BIS_fnc_spawnCrew;
_grp addVehicle _veh;

//If this is a new group, select a leader.
if (_newGrp) then
{
	_grp selectLeader (commander _veh);
};

[_veh, _crew, _grp]