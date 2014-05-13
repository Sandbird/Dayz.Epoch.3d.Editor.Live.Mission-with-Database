private ["_part","_cancel","_color","_percent","_string","_handle","_damage","_cmpt","_vehicle","_hitpoints","_vtype","_classes"];

_vehicle = _this select 3;
{dayz_myCursorTarget removeAction _x} forEach s_player_repairActions;s_player_repairActions = [];
// dayz_myCursorTarget = _vehicle;

// _allFixed = true;
_hitpoints = _vehicle call vehicle_getHitpoints;
/*
_vtype = typeOf _vehicle;
(configfile >> "CfgVehicles" >> _vtype >> "HitPoints") call { 
	_hitpoints = []; 
	for "_i" from 0 to ((count _this) - 1) do { 
		if (isClass (_this select _i)) then { 
			_hitpoints set [count _hitpoints, configName (_this select _i)]; 
		}; 
	}; 
	 diag_log format["Type: %1  Hitpoints: %2",str _vtype, str _hitpoints];  
};
*/
{			
	_damage = [_vehicle,_x] call object_getHit;
	_part = "PartGeneric";
	//change "HitPart" to " - Part" rather than complicated string replace
	_cmpt = toArray (_x);
	_cmpt set [0,20];
	_cmpt set [1,toArray ("-") select 0];
	_cmpt set [2,20];
	_cmpt = toString _cmpt;
	
	if(["Engine",str(_x),false] call fnc_inString) then {
		_part = "PartEngine";
	};
		
	if(["HRotor",str(_x),false] call fnc_inString) then {
		_part = "PartVRotor"; //yes you need PartVRotor to fix HRotor LOL
	};

	if(["Fuel",str(_x),false] call fnc_inString) then {
		_part = "PartFueltank";
	};

	if(["Wheel",str(_x),false] call fnc_inString) then {
		_part = "PartWheel";
	};	
		
	if(["Glass",str(_x),false] call fnc_inString) then {
		_part = "PartGlass";
	};

	// allow removal of any lightly damaged parts
	if (_damage < 1 and _damage >= 0) then {
		
		// Do not allow removal of engine or fueltanks
		//if( _part == "PartGlass" or _part == "PartWheel" ) then {
			if( _part != "PartEngine" ) then {
			_color = "color='#ffff00'"; //yellow
			if (_damage >= 0.5) then {_color = "color='#ff8800'";}; //orange
			if (_damage >= 0.9) then {_color = "color='#ff0000'";}; //red

			_percent = round(_damage*100);
			_string = format["<t %2>Remove%1 (%3 %4)</t>",_cmpt,_color,_percent,"%"]; //Remove - Part
			_handle = dayz_myCursorTarget addAction [_string, "dayz_code\actions\salvage.sqf",[_vehicle,_part,_x], 0, false, true, "",""];
			s_player_repairActions set [count s_player_repairActions,_handle];
			
		};
	};

} forEach _hitpoints;

if(count _hitpoints > 0 ) then {
	
	_cancel = dayz_myCursorTarget addAction [localize "STR_EPOCH_PLAYER_CANCEL", "\z\addons\dayz_code\actions\repair_cancel.sqf","repair", 0, true, false, "",""];
	s_player_repairActions set [count s_player_repairActions,_cancel];
	s_player_repair_crtl = 1;
};
