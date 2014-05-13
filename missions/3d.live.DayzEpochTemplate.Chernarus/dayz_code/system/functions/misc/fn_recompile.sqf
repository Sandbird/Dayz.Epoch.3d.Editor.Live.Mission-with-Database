scriptName "Functions\misc\fn_recompile.sqf";
/*
	File: fn_recompile.sqf
	Author: Karel Moricky

	Description:
	Recompiles all functions
*/

["RecompileAllFunctionsBecauseDesignersAreTooLazyToRestartTheMission"] call compile preprocessfilelinenumbers "ca\Modules\Functions\init.sqf";
true;