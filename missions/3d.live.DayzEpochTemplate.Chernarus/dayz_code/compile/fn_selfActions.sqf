private ["_text","_isDeployed","_playerUID","_adminList","_allowedDistance","_cursorTarget","_typeOfCursorTarget","_myGuy","_vehicle","_isPZombie","_inVehicle","_itemsPlayer","_hasKnife","_hasToolbox","_hasShovel","_onLadder","_canDo","_mags","_isAir","_isShip","_ownerKeyId","_ownerKeyName","_player_lockUnlock_crtl","_Unlock","_hasHotwireKit","_lock","_hasKey","_oldOwner","_menu1","_menu","_player_butcher","_isHarvested","_isAnimal","_isZombie","_humanity_logic","_low_high","_cancel","_buy","_metals_trader","_humanity","_traderMenu","_temp_keys","_temp_keys_names","_key_colors","_isMan","_isAlive","_ownerID","_isVehicle","_traderType","_isDisallowRepair"];
_adminList = call compile preProcessFileLineNumbers "superadmins.sqf";
_myGuy = player;
_vehicle = vehicle player;
_cursorTarget = cursorTarget;
_typeOfCursorTarget = typeOf _cursorTarget;
_playerUID = player getVariable ["playerUID", 0];
_ownerID = cursorTarget getVariable ["CharacterID","0"];
_isPZombie = player isKindOf "PZombie_VB";
_inVehicle = (_vehicle != player);
_itemsPlayer = items player;
_hasKnife = 	"ItemKnife" in _itemsPlayer;
_hasToolbox = "ItemToolbox" in _itemsPlayer;
_hasShovel = 	"ItemEtool" in _itemsPlayer;
_onLadder =		(getNumber (configFile >> "CfgMovesMaleSdr" >> "States" >> (animationState player) >> "onLadder")) == 1;
_canDo = (!r_drag_sqf and !r_player_unconscious and !_onLadder);
_mags = magazines player;
_allowedDistance = 4;
_isAir = cursorTarget isKindOf "Air";
_isShip = cursorTarget isKindOf "Ship";
_isVehicle = cursorTarget isKindOf "AllVehicles";
_traderType = _typeOfCursorTarget;
//Disabllow repair for objects in this array
_isDisallowRepair = _typeOfCursorTarget in ["M240Nest_DZ"];

if(_isAir or _isShip) then {
	_allowedDistance = 8;
};
//	cutText [format["CursTarget: %1",cursorTarget], "PLAIN DOWN"];

/*
	//To show friendlies with player
	_friendlies = player getVariable ["friendlies", []];
	_playerUID = player getVariable ["playerUID", "0"];

	cutText [format["MyFriendlies: %1\ncharID: %2",
	_friendlies,  // 222222,333333
	_playerUID
	], "PLAIN DOWN"];
*/

// >>>>>>>>>>>>>> Count keys on player inv <<<<<<<<<<<<<<<<<<
	_player_lockUnlock_crtl = false;
	_temp_keys = [];
	_temp_keys_names = [];
	// find available keys
	_key_colors = ["ItemKeyYellow","ItemKeyBlue","ItemKeyRed","ItemKeyGreen","ItemKeyBlack"];
	{
		if (configName(inheritsFrom(configFile >> "CfgWeapons" >> _x)) in _key_colors) then {
			_ownerKeyId = getNumber(configFile >> "CfgWeapons" >> _x >> "keyid");
			_ownerKeyName = getText(configFile >> "CfgWeapons" >> _x >> "displayName");
			_temp_keys_names set [_ownerKeyId,_ownerKeyName];
			_temp_keys set [count _temp_keys,str(_ownerKeyId)];
		};
	} forEach _itemsPlayer;


if (!isNull cursorTarget and !_inVehicle and !_isPZombie and (player distance cursorTarget < _allowedDistance) and _canDo) then {	//Has some kind of target
	_isAlive = alive _cursorTarget;
	_isAnimal = cursorTarget isKindOf "Animal";
	_isZombie = cursorTarget isKindOf "zZombie_base";
	_isHarvested = cursorTarget getVariable["meatHarvested",false];
	_isMan = cursorTarget isKindOf "Man";
	
	// Example on how to use _adminList
  if((typeOf(cursortarget) == "Plastic_Pole_EP1_DZ") and _ownerID != "0" and (player distance _cursorTarget < 2)) then {
      if (_playerUID in _adminList) then {
          cutText [format["Plot Pole Owner PUID is: %1",_playerUID], "PLAIN DOWN"];
      };
   };

	//Deployable Vehicles
	_isDeployed = cursorTarget getVariable ["Deployed",false];
	_text = getText (configFile >> "CfgVehicles" >> _typeOfCursorTarget >> "displayName");
	
	if (_isDeployed) then {
		if (s_player_packOBJ < 0) then {
			s_player_packOBJ = player addaction [("<t color=""#00FF04"">" + ("Pack "+_text+"") +"</t>"),"custom\deploy\pack.sqf",cursorTarget,6,false,true,"", ""];
		};
	} else {
		player removeAction s_player_packOBJ;
		s_player_packOBJ = -1;
	};
	
	// >>>>>>>>>>>>>> Unlocking vehicles <<<<<<<<<<<<<<<<<<<
	if(!_isMan and _ownerID != "0" and !(_cursorTarget isKindOf "Bicycle")) then {
		_player_lockUnlock_crtl = true;
	};
	// Allow Owner to lock and unlock vehicle  
	if(_player_lockUnlock_crtl) then {
		if (s_player_lockUnlock_crtl < 0) then {
			_hasKey = _ownerID in _temp_keys;
			_oldOwner = (_ownerID == _playerUID);
			if(locked _cursorTarget) then {
				if(_hasKey or _oldOwner or (_playerUID) in _adminList) then {
					if (!_hasKey and !_oldOwner and (_playerUID) in _adminList) then { //EDITS
					_Unlock = player addAction [format["<t color='#ff0000'>Admin Unlock %1</t>",_text], "\z\addons\dayz_code\actions\unlock_veh.sqf",[_cursorTarget,(_temp_keys_names select (parseNumber _ownerID))], 2, true, true, "", ""];//EDITS
					s_player_lockunlock set [count s_player_lockunlock,_Unlock];
					s_player_lockUnlock_crtl = 1;
					} else {
					_Unlock = player addAction [format["Unlock %1",_text], "\z\addons\dayz_code\actions\unlock_veh.sqf",[_cursorTarget,(_temp_keys_names select (parseNumber _ownerID))], 2, true, true, "", ""];

					s_player_lockunlock set [count s_player_lockunlock,_Unlock];
					s_player_lockUnlock_crtl = 1;
					};
				} else {
					if(_hasHotwireKit) then {
							_Unlock = player addAction [format["Hotwire %1",_text], "\z\addons\dayz_code\actions\hotwire_veh.sqf",_cursorTarget, 2, true, true, "", ""];
					} else {
					_Unlock = player addAction ["<t color='#ff0000'>Vehicle Locked</t>", "",_cursorTarget, 2, true, true, "", ""];
					};
					s_player_lockunlock set [count s_player_lockunlock,_Unlock];
					s_player_lockUnlock_crtl = 1;
				};
			} else {
				if(_hasKey or _oldOwner or (_playerUID) in _adminList) then {
					if (!_hasKey and !_oldOwner and (_playerUID) in _adminList) then { //EDITS
						_lock = player addAction [format["<t color='#ff0000'>Admin Lock %1</t>",_text], "\z\addons\dayz_code\actions\lock_veh.sqf",_cursorTarget, 2, true, true, "", ""];//EDITS
						s_player_lockunlock set [count s_player_lockunlock,_lock];
						s_player_lockUnlock_crtl = 1;
					} else {
						_lock = player addAction [format["Lock %1",_text], "\z\addons\dayz_code\actions\lock_veh.sqf",_cursorTarget, 1, true, true, "", ""];
						s_player_lockunlock set [count s_player_lockunlock,_lock];
						s_player_lockUnlock_crtl = 1;
					};
				};
			};
		};
	} else {
		{player removeAction _x} forEach s_player_lockunlock;s_player_lockunlock = [];
		s_player_lockUnlock_crtl = -1;
	};
	// >>>>>>>>>>>>>> Unlocking vehicles end <<<<<<<<<<<<<<<<<<<
	

	// >>>>>>>>>>>>>> Repairing Vehicles <<<<<<<<<<<<<<<<<<<
	 if ((dayz_myCursorTarget != _cursorTarget) and _isVehicle and !_isMan and _hasToolbox and (damage _cursorTarget < 1) and !_isDisallowRepair) then {
        _hasKey = _ownerID in _temp_keys;
        _oldOwner = (_ownerID == dayz_playerUID);
        if (s_player_repair_crtl < 0) then {
            dayz_myCursorTarget = _cursorTarget;
            _menu = dayz_myCursorTarget addAction ["Repair Vehicle", "\z\addons\dayz_code\actions\repair_vehicle.sqf",_cursorTarget, 0, true, false, "",""];
            s_player_repairActions set [count s_player_repairActions,_menu];
            if(!locked _cursorTarget) then {
            _menu1 = dayz_myCursorTarget addAction ["Salvage Vehicle", "dayz_code\actions\salvage_vehicle.sqf",_cursorTarget, 0, true, false, "",""];
            s_player_repairActions set [count s_player_repairActions,_menu1];};
            s_player_repair_crtl = 1;    
        } else {
            {dayz_myCursorTarget removeAction _x} forEach s_player_repairActions;s_player_repairActions = [];
            s_player_repair_crtl = -1;
        };
    };
	// >>>>>>>>>>>>>> Repairing Vehicles end <<<<<<<<<<<<<<<<<<<
	
	
	// >>>>>>>>>>>>>> Gut Zombie <<<<<<<<<<<<<<<<<<<
	if (!_isAlive) then {
		// Gut animal/zed
		if((_isAnimal or _isZombie) and _hasKnife) then {
			_isHarvested = _cursorTarget getVariable["meatHarvested",false];
			if (!_isHarvested) then {
				_player_butcher = true;
			};
		};
	} else {
		// unit alive
	};
	// Human Gut animal or zombie
	if (_player_butcher) then {
		if (s_player_butcher < 0) then {
			if(_isZombie) then {
				s_player_butcher = player addAction ["Gut Zombie", "\z\addons\dayz_code\actions\gather_zparts.sqf",_cursorTarget, 0, true, true, "", ""];
			} else {
				s_player_butcher = player addAction [localize "str_actions_self_04", "\z\addons\dayz_code\actions\gather_meat.sqf",_cursorTarget, 3, true, true, "", ""];
			};
		};
	} else {
		player removeAction s_player_butcher;
		s_player_butcher = -1;
	};
	// >>>>>>>>>>>>>> Gut Zombie end <<<<<<<<<<<<<<<<<<<
	
	
	
	// >>>>>>>>>>>>>> Trade with Vendors <<<<<<<<<<<<<<<<<<<
	// All Traders
	if (_isMan and !_isPZombie and _traderType in serverTraders) then {
	
		if (s_player_parts_crtl < 0) then {

			// get humanity
			_humanity = player getVariable ["humanity",0];
			_traderMenu = call compile format["menu_%1;",_traderType];

			// diag_log ("TRADER = " + str(_traderMenu));
			
			_low_high = "low";
			_humanity_logic = false;
			if((_traderMenu select 2) == "friendly") then {
				_humanity_logic = (_humanity < -5000);
			};
			if((_traderMenu select 2) == "hostile") then {
				_low_high = "high";
				_humanity_logic = (_humanity > -5000);
			};
			if((_traderMenu select 2) == "hero") then {
				_humanity_logic = (_humanity < 5000);
			};
			if(_humanity_logic and !((getPlayerUID player) in _adminList)) then {
				_cancel = player addAction [format["Your humanity is too %1 this trader refuses to talk to you.",_low_high], "\z\addons\dayz_code\actions\trade_cancel.sqf",["na"], 0, true, false, "",""];
				s_player_parts set [count s_player_parts,_cancel];				
			} else {
				
				// Static Menu
				{
					//diag_log format["DEBUG TRADER: %1", _x];
					_buy = player addAction [format["Trade %1 %2 for %3 %4",(_x select 3),(_x select 5),(_x select 2),(_x select 6)], "\z\addons\dayz_code\actions\trade_items_wo_db.sqf",[(_x select 0),(_x select 1),(_x select 2),(_x select 3),(_x select 4),(_x select 5),(_x select 6)], (_x select 7), true, true, "",""];
					s_player_parts set [count s_player_parts,_buy];
				
				} forEach (_traderMenu select 1);
				// Database menu 
				_buy = player addAction [localize "STR_EPOCH_PLAYER_289", "dayz_code\actions\show_dialog.sqf",(_traderMenu select 0), 999, true, false, "",""];
					s_player_parts set [count s_player_parts,_buy];
				
				// Add static metals trader options under sub menu
    		_metals_trader = player addAction ["Trade Gems", "dayz_code\actions\trade_metals.sqf",["na"], 0, true, false, "",""];				
    		s_player_parts set [count s_player_parts,_metals_trader];
			};
			s_player_parts_crtl = 1;
			
		};
	} else {
		{player removeAction _x} forEach s_player_parts;s_player_parts = [];
		s_player_parts_crtl = -1;
	};	
	// >>>>>>>>>>>>>> Trade with Vendors end <<<<<<<<<<<<<<<<<<<
	

	// >>>>>>>>>>>>>> Maintain Plot Pole <<<<<<<<<<<<<<<<<<<
	_player_flipveh = false;
	_player_deleteBuild = false;
	_player_lockUnlock_crtl = false;

	 if (_canDo && (speed player <= 1) && (_cursorTarget isKindOf "Plastic_Pole_EP1_DZ")) then {
		 if (s_player_maintain_area < 0) then {
		  s_player_maintain_area = player addAction ["<t color=""#0074E8"">Maintain Area</t>", "dayz_code\actions\maintain_area.sqf", "maintain", 5, false]; //\z\addons\
		 	s_player_maintain_area_preview = player addAction ["<t color=""#0074E8"">Cost Preview</t>", "dayz_code\actions\maintain_area.sqf", "preview", 5, false]; //\z\addons\
		 };
	 } else {
    		player removeAction s_player_maintain_area;
    		s_player_maintain_area = -1;
    		player removeAction s_player_maintain_area_preview;
    		s_player_maintain_area_preview = -1;
	 };
	// >>>>>>>>>>>>>> Maintain Plot Pole end <<<<<<<<<<<<<<<<<<<
	

		
} else {
	//Engineering
	{dayz_myCursorTarget removeAction _x} forEach s_player_repairActions;s_player_repairActions = [];
	s_player_repair_crtl = -1;
	dayz_myCursorTarget = objNull;
	s_player_lastTarget = [objNull,objNull,objNull,objNull,objNull];
	{player removeAction _x} forEach s_player_parts;s_player_parts = [];
	s_player_parts_crtl = -1;
	{player removeAction _x} forEach s_player_lockunlock;s_player_lockunlock = [];
	s_player_lockUnlock_crtl = -1;
	player removeAction s_player_checkGear;
	s_player_checkGear = -1;
	player removeAction s_player_SurrenderedGear;
	s_player_SurrenderedGear = -1;
	//Others
	player removeAction s_player_forceSave;
	s_player_forceSave = -1;
	player removeAction s_player_flipveh;
	s_player_flipveh = -1;
	player removeAction s_player_sleep;
	s_player_sleep = -1;
	//Sleep Base Asset
	player removeAction s_player_sleepba;
	s_player_sleepba = -1;
	player removeAction s_player_deleteBuild;
	s_player_deleteBuild = -1;
	player removeAction s_player_codeRemove;
	s_player_codeRemove = -1;
	player removeAction s_player_disarmBomb;
	s_player_disarmBomb = -1;
	player removeAction s_player_codeObject;
	s_player_codeObject = -1;
	player removeAction s_player_butcher;
	s_player_butcher = -1;
	player removeAction s_player_cook;
	s_player_cook = -1;
	player removeAction s_player_boil;
	s_player_boil = -1;
	player removeAction s_player_fireout;
	s_player_fireout = -1;
	player removeAction s_player_packtent;
	s_player_packtent = -1;
	player removeAction s_player_fillfuel;
	s_player_fillfuel = -1;
	player removeAction s_player_clothes;
	s_player_clothes = -1;
	player removeAction s_player_dance;
  s_player_dance = -1;
	player removeAction s_player_notebook;
	s_player_notebook = -1;
	player removeAction s_player_studybody;
	s_player_studybody = -1;
	player removeAction s_player_bury_human;
	s_player_bury_human = -1;
	player removeAction s_player_tamedog;
	s_player_tamedog = -1;
	player removeAction s_player_feeddog;
	s_player_feeddog = -1;
	player removeAction s_player_waterdog;
	s_player_waterdog = -1;
	player removeAction s_player_staydog;
	s_player_staydog = -1;
	player removeAction s_player_trackdog;
	s_player_trackdog = -1;
	player removeAction s_player_barkdog;
	s_player_barkdog = -1;
	player removeAction s_player_warndog;
	s_player_warndog = -1;
	player removeAction s_player_followdog;
	s_player_followdog = -1;
    // vault
	player removeAction s_player_unlockvault;
	s_player_unlockvault = -1;
	player removeAction s_player_packvault;
	s_player_packvault = -1;
	player removeAction s_player_lockvault;
	s_player_lockvault = -1;
	player removeAction s_player_information;
	s_player_information = -1;
	player removeAction s_player_fillgen;
	s_player_fillgen = -1;
	player removeAction s_player_upgrade_build;
	s_player_upgrade_build = -1;
	player removeAction s_player_maint_build;
	s_player_maint_build = -1;
	player removeAction s_player_downgrade_build;
	s_player_downgrade_build = -1;
	player removeAction s_player_towing;
	s_player_towing = -1;
	player removeAction s_player_fuelauto;
	s_player_fuelauto = -1;
	player removeAction s_player_fuelauto2;
	s_player_fuelauto2 = -1;
	player removeAction s_player_packOBJ;
	s_player_packOBJ = -1;
};