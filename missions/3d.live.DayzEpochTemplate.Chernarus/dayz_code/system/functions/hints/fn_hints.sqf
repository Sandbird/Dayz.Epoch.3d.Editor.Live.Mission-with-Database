scriptName "modules_e\Functions\objects\fn_hints.sqf";
/*
	File: fn_hints.sqf
	Author: Jiri Wainar

	Description:
	Advanced hint system
*/

BIS_AdvHints_Path = "ca\modules_e\functions\hints\";
_system = "fn_hints_";

call compile preprocessfilelinenumbers (BIS_AdvHints_Path + _system + "main.sqf");
call compile preprocessfilelinenumbers (BIS_AdvHints_Path + _system + "functions.sqf");
call compile preprocessfilelinenumbers (BIS_AdvHints_Path + _system + "functions_animations.sqf");
call compile preprocessfilelinenumbers (BIS_AdvHints_Path + _system + "functions_navigation.sqf");
call compile preprocessfilelinenumbers (BIS_AdvHints_Path + _system + "functions_targeticons.sqf");

bis_fnc_hints_nav_helper = BIS_AdvHints_Path + _system + "nav_helper.fsm";

if (isnil "BIS_debugMode") then {BIS_debugMode = false};
if (isnil "BIS_MissionName") then {BIS_MissionName = "MISSING MISSION NAME"};
if (isnil "BIS_Objectives") then {BIS_Objectives = ["MISSING OBJECTIVES"]};

//set defaults
[] call BIS_AdvHints_setDefaults;