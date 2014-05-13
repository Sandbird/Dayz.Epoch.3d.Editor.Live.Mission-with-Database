
adminmenu =
[
	["",true],
		['Generate Key', [2], '', -5, [['expression', '[] call admin_generatekey;']], '1', '1'],
		['Show ID', [3], '', -5, [['expression', '[] call admin_showid;']], '1', '1'],
		['Lower Terrain', [4], '', -5, [['expression', '[] call admin_low_terrain;']], '1', '1'],
		['GOD', [5], '', -5, [['expression', '[] call admingod;']], '1', '1'],
		["", [-1], "", -5, [["expression", ""]], "1", "0"],
	["Exit", [13], "", -3, [["expression", ""]], "1", "1"]		
];


	admin_showid =
	{
		_obj = cursortarget;
		if (!isNull _obj) then
		{
			_charID = _obj getVariable ["CharacterID","0"];
			_objID 	= _obj getVariable["ObjectID","0"];
			_objUID	= _obj getVariable["ObjectUID","0"];
			_lastUpdate = _obj getVariable ["lastUpdate",time];
			
			systemchat format["%1: charID: %2, objID: %3, objUID: %4, lastUpdate: %5",typeOF _obj,_charID,_objID,_objUID,_lastUpdate];
		};
	};

	admin_generatekey =
	{
		private ["_ct","_id","_result","_inventory","_backpack"];
		_ct = cursorTarget;
		if (!isNull _ct) then {
			if (_ct distance player > 12) exitWith {cutText [format["%1 is to far away.",typeOF _ct], "PLAIN"];};
			if !((_ct isKindOf "LandVehicle") || (_ct isKindOf "Air") || (_ct isKindOf "Ship")) exitWith {cutText [format["%1 is not a vehicle..",typeOF _ct], "PLAIN"];};
			
			_id = _ct getVariable ["CharacterID","0"];
			_id = parsenumber _id;
			if (_id == 0) exitWith {cutText [format["%1 has ID 0 - No Key possible.",typeOF _ct], "PLAIN"];};
			if ((_id > 0) && (_id <= 2500)) then {_result = format["ItemKeyGreen%1",_id];};
			if ((_id > 2500) && (_id <= 5000)) then {_result = format["ItemKeyRed%1",_id-2500];};
			if ((_id > 5000) && (_id <= 7500)) then {_result = format["ItemKeyBlue%1",_id-5000];};
			if ((_id > 7500) && (_id <= 10000)) then {_result = format["ItemKeyYellow%1",_id-7500];};
			if ((_id > 10000) && (_id <= 12500)) then {_result = format["ItemKeyBlack%1",_id-10000];};
			
			_inventory = (weapons player);
			_backpack = ((getWeaponCargo unitbackpack player) select 0);
			if (_result in (_inventory+_backpack)) then
			{
				if (_result in _inventory) then {cutText [format["Key [%1] already in your inventory!",_result], "PLAIN"];};
				if (_result in _backpack) then {cutText [format["Key [%1] already in your backpack!",_result], "PLAIN"];};
			}
			else
			{
				player addweapon _result;
				cutText [format["Key [%1] added to inventory!",_result], "PLAIN"];
			};
		};
	};

	admin_low_terrain = {
		if (isNil "admin_terrain") then {admin_terrain = true;} else {admin_terrain = !admin_terrain};
		if (admin_terrain) then {
		setTerrainGrid 50;
		hint "Terrain Low";
		cutText [format["Terrain Low"], "PLAIN DOWN"];
		_savelog = format["%1 Terrain Low",name player];
		PVAH_WriteLogReq = [_savelog];
		publicVariableServer "PVAH_WriteLogReq";
		} else {
		setTerrainGrid 25;
		hint "Terrain Normal";
		cutText [format["Terrain Normal"], "PLAIN DOWN"];
		_savelog = format["%1 Terrain Normal",name player];
		PVAH_WriteLogReq = [_savelog];
		publicVariableServer "PVAH_WriteLogReq";
		};
	};

	admingod =
	{
		if (isNil 'gmdadmin') then {gmdadmin = 0;};
		if (gmdadmin == 0) then
		{
			gmdadmin = 1;
			hint 'God ON';
			
			[] spawn {
				while {gmdadmin == 1} do
				{
					dayz_temperatur = dayz_temperaturnormal;
					dayz_hunger = 0;
					dayz_thirst = 0;
					fnc_usec_damageHandler = {};
					player_zombieCheck = {};
					player_zombieAttack = {};
					player allowDamage false;
					player removeAllEventhandlers 'handleDamage';
					player addEventhandler ['handleDamage', {false}];
					sleep 0.5;
				};
				sleep 1;
				player_zombieCheck = compile preprocessFileLineNumbers '\z\addons\dayz_code\compile\player_zombieCheck.sqf';
				player_zombieAttack = compile preprocessFileLineNumbers '\z\addons\dayz_code\compile\player_zombieAttack.sqf';
				fnc_usec_damageHandler = compile preprocessFileLineNumbers '\z\addons\dayz_code\compile\fn_damageHandler.sqf';
				player allowDamage true;
				player removeAllEventHandlers 'HandleDamage';
				player addeventhandler ['HandleDamage',{_this call fnc_usec_damageHandler;} ];
			};
			
			
			_savelog = format['%1 G_o_d ON',name player];
			PVAH_WriteLogReq = [_savelog];
			publicVariableServer 'PVAH_WriteLogReq';
		}
		else
		{
			gmdadmin = 0;
			hint 'God OFF';
			
			fnc_usec_damageHandler = compile preprocessFileLineNumbers '\z\addons\dayz_code\compile\fn_damageHandler.sqf';
			player allowDamage true;
			player removeAllEventHandlers 'HandleDamage';
			player addeventhandler ['HandleDamage',{_this call fnc_usec_damageHandler;} ];
			
			
			_savelog = format['%1 G_o_d OFF',name player];
			PVAH_WriteLogReq = [_savelog];
			publicVariableServer 'PVAH_WriteLogReq';
		};
	};


showCommandingMenu "#USER:adminmenu";
