private ["_isHiveOk","_newPlayer","_isInfected","_model","_backpackMagTypes","_backpackMagQty","_backpackWpnTypes","_backpackWpnQtys","_countr","_isOK","_backpackType","_backpackWpn","_backpackWater","_playerUID","_msg","_myTime","_charID","_inventory","_backpack","_survival","_isNew","_version","_debug","_lastAte","_lastDrank","_usedFood","_usedWater","_worldspace","_state","_setDir","_setPos","_legs","_arms","_totalMins","_days","_hours","_mins","_messing","_myLoc","_id","_nul","_world","_nearestCity","_first","_AuthAttempt","_timeStart","_readytoAuth","_startCheck","_myEpochAnim","_myEpoch","_myEpochB","_myEpochSfx","_myEpochDayZ","_zombies"];

if(isNil "DZEdebug") then { DZEdebug = false; };
_debug = DZEdebug;
if (_debug) then {
	diag_log ("PSETUP: Initating");
};
//LOGIN INFORMATION
_playerUID = dayz_playerUID;
//diag_log ("PSETUP playerID Player [" + _playerUID + "]");
_msg = [];
dayzPlayerLogindayz_versionNo = getText(configFile >> "CfgMods" >> "DayZ" >> "version");
diag_log ("DAYZ: CLIENT IS RUNNING DAYZ_CODE " + str(dayz_versionNo));

_AuthAttempt = 0;

0 fadeSound 0;

progressLoadingScreen 0.1;
//0 cutText ["","BLACK"];

_timeStart = diag_tickTime;
_readytoAuth = false;
_startCheck = 0;
//player enableSimulation false;
if(isNil "DZEdebug") then { DZEdebug = false; };
_debug = DZEdebug;
//////////////////////////////////////////////////////////
endLoadingScreen;
if (_debug) then {
diag_log ("PLOGIN: Initating");
};
dayz_loadScreenMsg = (localize "str_player_13"); 
progressLoadingScreen 0.2;
//////////////////////////////////////////////////////////

if (!isnil "bis_fnc_init") then {
	dayz_forceSave = {
	_gearSave = false;
	
	if (!dialog) then {
		createGearDialog [player, "RscDisplayGear"];
		_gearSave = true;
	};
	
	_dialog = 			findDisplay 106;
	_magazineArray = 	[];
	
	//Primary Mags
	for "_i" from 109 to 120 do 
	{
		_control = 	_dialog displayCtrl _i;
		_item = 	gearSlotData _control;
		_val =		gearSlotAmmoCount _control;
		_max = 		getNumber (configFile >> "CfgMagazines" >> _item >> "count");
		if (_item != "") then {
			if (_val != _max) then {
				_magazineArray set [count _magazineArray,[_item,_val]];
			} else {
				_magazineArray set [count _magazineArray,_item];
			};
		};
	};
	
	//Secondary Mags
	for "_i" from 122 to 129 do 
	{
		_control = 	_dialog displayCtrl _i;
		_item = 	gearSlotData _control;
		_val =		gearSlotAmmoCount _control;
		_max = 		getNumber (configFile >> "CfgMagazines" >> _item >> "count");
		if (_item != "") then {
			if (_val != _max) then {
				_magazineArray set [count _magazineArray,[_item,_val]];
			} else {
				_magazineArray set [count _magazineArray,_item];
			};
		};
	};
	
	if (_gearSave) then {
		closeDialog 0;
	};
	
		_medical = player call player_sumMedical;
			
		/*
			Get character state details
		*/
		_currentWpn = 	currentMuzzle player;
		_currentAnim =	animationState player;
		_config = 		configFile >> "CfgMovesMaleSdr" >> "States" >> _currentAnim;
		_onLadder =		(getNumber (_config >> "onLadder")) == 1;
		_isTerminal = 	(getNumber (_config >> "terminal")) == 1;
		_isInVehicle = vehicle player != player;
		//_wpnDisabled =	(getNumber (_config >> "disableWeapons")) == 1;
		_currentModel = typeOf player;
		_charPos = getPosATL player;
		_playerPos = 	[round(direction player),_charPos];
		
		if (_onLadder or _isInVehicle or _isTerminal) then {
			_currentAnim = "";
			//If position to be updated, make sure it is at ground level!
			if ((count _playerPos > 0) and !_isTerminal) then {
				_charPos set [2,0];
				_playerPos set[1,_charPos];
			};
		};
		if (_isInVehicle) then {
			_currentWpn = "";
		} else {
			if ( typeName(_currentWpn) == "STRING" ) then {
				_muzzles = getArray(configFile >> "cfgWeapons" >> _currentWpn >> "muzzles");
				if (count _muzzles > 1) then {
					_currentWpn = currentMuzzle player;
				};	
			} else {
				//diag_log ("DW_DEBUG: _currentWpn: " + str(_currentWpn));
				_currentWpn = "";
			};
		};
		_temp = round(player getVariable ["temperature",100]);
		_currentState = [_currentWpn,_currentAnim,_temp];
		
		dayz_Magazines = _magazineArray;
		PVDZE_plr_Save = [player,dayz_Magazines,false,true];
		publicVariable "PVDZE_plr_Save";
		[player,dayz_Magazines,false,true] spawn server_playerSync;
				
		if (isServer) then {
			//PVDZE_plr_Save call server_playerSync;
		};
							
		dayz_lastSave = diag_tickTime;
		dayz_Magazines = [];
	};
};

///////////////////////////////////////////////////////////
if (_debug) then {
diag_log ("PLOGIN: Enable Sim");
};

_myEpochAnim = getText(configFile >> "CfgPatches" >> "dayz_anim" >> "dayzVersion");
_myEpoch = getText(configFile >> "CfgPatches" >> "dayz_epoch" >> "dayzVersion");
_myEpochB = getText(configFile >> "CfgPatches" >> "dayz_epoch_b" >> "dayzVersion");
_myEpochSfx = getText(configFile >> "CfgPatches" >> "dayz_sfx" >> "dayzVersion");
_myEpochDayZ = getText(configFile >> "CfgPatches" >> "dayz" >> "dayzVersion");

player enableSimulation true;
///////////////////////////////////////////////////////////
if (!isNull player) then {
	if (_debug) then {
	diag_log ("PLOGIN: Player Ready");
	};
	dayz_loadScreenMsg = (localize "str_player_13"); 
	progressLoadingScreen 0.3;
	_playerUID = dayz_playerUID;
};
///////////////////////////////////////////////////////////
if !(isNil "_playerUID") then {
	_myTime = diag_tickTime;
	dayz_loadScreenMsg = ("Waiting for server to start authentication");
	if (_debug) then {
		diag_log "PLOGIN: Waiting for server to start authentication";
		};
		progressLoadingScreen 0.5;
};
///////////////////////////////////////////////////////////
	if (_debug) then {
		diag_log ("PLOGIN: Requesting Authentication... (" + _playerUID + ")");
	};
	dayz_loadScreenMsg = (localize "str_player_15");
	progressLoadingScreen 0.7;
	
	_msg = [];
	dayzPlayerLogin = [];
	PVDZE_plr_Login = [_playerUID,player];
	publicVariable "PVDZE_plr_Login";
	[_playerUID,player] call server_playerLogin;
	
	_myTime = diag_tickTime;
	_msg = dayzPlayerLogin;
	
	//diag_log format[">>>>>>>>> Got the login data: %1",_msg];
	
	
///////////////////////////////////////////////////////////
	dayz_authed = true;

	if (_debug) then {
		diag_log format["Dress Player with: %1",_msg];
	};
	
	
	progressLoadingScreen 0.6;
	_charID		= _msg select 0;
	_inventory	= _msg select 1;
	_backpack	= _msg select 2;
	_survival 	= _msg select 3;
	_isNew 		= _msg select 4;
	_state 		= _msg select 5;
	_version	= _msg select 5;
	_model		= _msg select 6;
	
	_isHiveOk = false;
	_newPlayer = false;
	_isInfected = false;
	
	if (count _msg > 7) then {
		_isHiveOk = _msg select 7;
		_newPlayer = _msg select 8;
		_isInfected = _msg select 9;
		diag_log ("PLAYER RESULT: " + str(_isHiveOk));
	};
	
	dayz_loadScreenMsg = (localize "str_player_17"); 
	progressLoadingScreen 0.8;
	if (_debug) then {
	diag_log ("PLOGIN: authenticated with : " + str(_msg));
	};
	//Not Equal Failure
	
	if (isNil "_model") then {
		_model = "Survivor2_DZ";
		diag_log ("PLOGIN: Model was nil, loading as survivor");
	};
	
	if (_model == "") then {
		_model = "Survivor2_DZ";
		diag_log ("PLOGIN: Model was empty, loading as survivor");
	};
	
	if (_model == "Survivor1_DZ") then {
		_model = "Survivor2_DZ";
	};

///////////////////////////////////////////////////////////
dayz_playerName = name player;
_model call player_switchModel;


player allowDamage false;
_lastAte = _survival select 1;
_lastDrank = _survival select 2;

_usedFood = 0;
_usedWater = 0;
_inventory = call compile _inventory;
dayzGearSave = false;
_inventory call player_gearSet;

//player addMagazine "7Rnd_45ACP_1911";

_backpack = call compile _backpack;
//Assess in backpack
if (count _backpack > 0) then {
	//Populate
	_backpackType = 	_backpack select 0;
	_backpackWpn = 		_backpack select 1;
	_backpackMagTypes = [];
	_backpackMagQty = [];
	if (count _backpackWpn > 0) then {
		_backpackMagTypes = (_backpack select 2) select 0;
		_backpackMagQty = 	(_backpack select 2) select 1;
	};
	_countr = 0;
	_backpackWater = 0;

	//Add backpack
	if (_backpackType != "") then {
		_isOK = 	isClass(configFile >> "CfgVehicles" >>_backpackType);
		if (_isOK) then {
			player addBackpack _backpackType; 
			dayz_myBackpack =	unitBackpack player;
			
			//Fill backpack contents
			//Weapons
			_backpackWpnTypes = [];
			_backpackWpnQtys = [];
			if (count _backpackWpn > 0) then {
				_backpackWpnTypes = _backpackWpn select 0;
				_backpackWpnQtys = 	_backpackWpn select 1;
			};
			_countr = 0;
			{
				if(_x in (DZE_REPLACE_WEAPONS select 0)) then {
					_x = (DZE_REPLACE_WEAPONS select 1) select ((DZE_REPLACE_WEAPONS select 0) find _x);
				};
				dayz_myBackpack addWeaponCargoGlobal [_x,(_backpackWpnQtys select _countr)];
				_countr = _countr + 1;
			} forEach _backpackWpnTypes;
			
			//Magazines
			_countr = 0;
			{
				if (_x == "BoltSteel") then { _x = "WoodenArrow" }; // Convert BoltSteel to WoodenArrow
				if (_x == "ItemTent") then { _x = "ItemTentOld" };
				dayz_myBackpack addMagazineCargoGlobal [_x,(_backpackMagQty select _countr)];
				_countr = _countr + 1;
			} forEach _backpackMagTypes;
			
			dayz_myBackpackMags =	getMagazineCargo dayz_myBackpack;
			dayz_myBackpackWpns =	getWeaponCargo dayz_myBackpack;
		} else {
			dayz_myBackpack		=	objNull;
			dayz_myBackpackMags = [];
			dayz_myBackpackWpns = [];
		};
	} else {
		dayz_myBackpack		=	objNull;
		dayz_myBackpackMags =	[];
		dayz_myBackpackWpns =	[];
	};
} else {
	dayz_myBackpack		=	objNull;
	dayz_myBackpackMags =	[];
	dayz_myBackpackWpns =	[];
};

dayzPlayerLogin2 = [];
//["PVDZE_plr_Login2",[_charID,player,_playerUID]] call callRpcProcedure;

PVDZE_plr_Login2 = [_charID,player,_playerUID];
publicVariable "PVDZE_plr_Login2";
[_charID,player,_playerUID] call server_playerSetup;

dayz_loadScreenMsg =  "Requesting Character data from server";
progressLoadingScreen 0.9;
if (isServer) then {
	//PVDZE_plr_Login2 call sdbd_fnc_setup;
//	PVDZE_plr_Login2 call server_playerSetup;
};

if (_debug) then {
diag_log "Attempting Phase two...";
};
///////////////////////////////////////////////////////////
if (count (dayzPlayerLogin2) > 0) then {
	dayz_loadScreenMsg =  "Character Data received from server"; 
	if (_debug) then {
		diag_log "####dayzPlayerLogin2 true";
		diag_log "Finished...";
	};
	_worldspace = 	dayzPlayerLogin2 select 0;
	_state =			dayzPlayerLogin2 select 1;
	
	_setDir = 			_worldspace select 0;
	_setPos = 			_worldspace select 1;
	
	if (isNil "freshSpawn") then {
		freshSpawn = 0;
	};
	
	if(dayz_paraSpawn and (freshSpawn == 2)) then {
		player setDir _setDir;
		player setPosATL [(_setPos select 0),(_setPos select 1),2000];
		//[player,2000] spawn BIS_fnc_halo;
	} else {
	
		// make protective box
		DZE_PROTOBOX = createVehicle ["DebugBoxPlayer_DZ", _setPos, [], 0, "CAN_COLLIDE"];
		DZE_PROTOBOX setDir _setDir;
		DZE_PROTOBOX setPosATL _setPos;
	
		player setDir _setDir;
		player setPosATL _setPos;
	};
	
	{
		if (player getVariable["hit_"+_x,false]) then { 
			[player,_x,_x] spawn fnc_usec_damageBleed; 
			usecBleed = [player,_x,_x];
			publicVariable "usecBleed"; // draw blood stream on character, on all gameclients
		};
	} forEach USEC_typeOfWounds;
	//Legs and Arm fractures
	_legs = player getVariable ["hit_legs",0];
	_arms = player getVariable ["hit_hands",0];
	
	if (_legs > 1) then {
		player setHit["legs",1];
		r_fracture_legs = true;
	};
	if (_arms > 1) then {
		player setHit["hands",1];
		r_fracture_arms = true;
	};
	
	//Record current weapon state
	dayz_myWeapons = 		weapons player;		//Array of last checked weapons
	dayz_myItems = 			items player;		//Array of last checked items
	dayz_myMagazines = 	magazines player;
	
	dayz_playerUID = _playerUID;

	
	//Work out survival time
	_totalMins = _survival select 0;
	_days = floor (_totalMins / 1440);
	_totalMins = (_totalMins - (_days * 1440));
	_hours = floor (_totalMins / 60);
	_mins =  (_totalMins - (_hours * 60));
	
	if ((count _state > 3) and DZE_FriendlySaving) then {
		DZE_Friends = _state select 3;
	}; 
      
	
	//player variables
	dayz_characterID =		_charID;
	dayz_hasFire = 			objNull;		//records players Fireplace object
	dayz_myCursorTarget = 	objNull;
	dayz_myPosition = 		getPosATL player;	//Last recorded position
	dayz_lastMeal =			(_lastAte * 60);
	dayz_lastDrink =		(_lastDrank * 60);
	dayz_zombiesLocal = 	0;			//Used to record how many local zombies being tracked
	dayz_Survived = _days;  //total alive dayz
	
	//load in medical details
	r_player_dead = 		player getVariable["USEC_isDead",false];
	r_player_unconscious = 	player getVariable["NORRN_unconscious", false];
	r_player_infected =	player getVariable["USEC_infected",false];
	r_player_injured = 	player getVariable["USEC_injured",false];
	r_player_inpain = 		player getVariable["USEC_inPain",false];
	r_player_cardiac = 	player getVariable["USEC_isCardiac",false];
	r_player_lowblood =	player getVariable["USEC_lowBlood",false];
	r_player_blood = 		player getVariable["USEC_BloodQty",r_player_bloodTotal];
	
	//Hunger/Thirst
	_messing =			player getVariable["messing",[0,0]];
	dayz_hunger = 	_messing select 0;
	dayz_thirst = 		_messing select 1;
	dayz_loadScreenMsg =  "Character Data received";	
};
