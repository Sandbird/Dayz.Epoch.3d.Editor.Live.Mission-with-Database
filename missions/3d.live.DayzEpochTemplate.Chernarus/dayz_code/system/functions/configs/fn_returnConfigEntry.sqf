scriptName "Functions\configs\fn_returnConfigEntry.sqf";
/*
	File: returnConfigEntry.sqf
	Author: Joris-Jan van 't Land

	Description:
	Explores parent classes in the run-time config for the value of a config entry.
	
	Parameter(s):
	_this select 0: starting config class (Config)
	_this select 1: queried entry name (String)
	
	Returns:
	Number / String - value of the found entry
*/

//Validate parameter count
if ((count _this) < 2) exitWith {debugLog "Log: [returnConfigEntry] This function requires at least 2 parameters!"; nil};

private ["_config", "_entryName"];
_config = _this select 0;
_entryName = _this select 1;

//Validate parameters
if ((typeName _config) != (typeName configFile)) exitWith {debugLog "Log: [returnConfigEntry] Starting class (0) must be of type Config!"; nil};
if ((typeName _entryName) != (typeName "")) exitWith {debugLog "Log: [returnConfigEntry] Entry name (1) must be of type String!"; nil};

private ["_entry", "_value"];
_entry = _config >> _entryName;

//If the entry is not found and we are not yet at the config root, explore the class' parent.
if (((configName (_config >> _entryName)) == "") && (!((configName _config) in ["CfgVehicles", "CfgWeapons", ""]))) then
{
	[inheritsFrom _config, _entryName] call BIS_fnc_returnConfigEntry;
}
else
{
	//Supporting either Numbers or Strings
	if (isNumber _entry) then
	{
		_value = getNumber _entry;
	}
	else
	{
		if (isText _entry) then
		{
			_value = getText _entry;
		};
	};
};

//Make sure returning 'nil' works.
if (isNil "_value") exitWith {nil};
 
_value