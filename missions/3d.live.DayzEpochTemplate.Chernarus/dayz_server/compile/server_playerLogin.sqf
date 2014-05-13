private ["_isInfected","_doLoop","_hiveVer","_isHiveOk","_playerID","_playerObj","_primary","_key","_charID","_playerName","_backpack","_isNew","_inventory","_survival","_model","_mags","_wpns","_bcpk","_config","_newPlayer"];
#ifdef DZE_SERVER_DEBUG
diag_log ("STARTING LOGIN: " + str(_this));
#endif

_playerID = _this select 0;
_playerObj = _this select 1;
_playerName = name _playerObj;
//diag_log format[">>>>>>>>>>>>>>>Login PlayerID:%1 playerObj:%2, Playername:%3",_playerID,_playerObj,_playerName ];

if (_playerName == '__SERVER__' || _playerID == '') exitWith {};

if (count _this > 2) then {
	dayz_players = dayz_players - [_this select 2];
};

//Variables
_inventory =	[];
_backpack = 	[];
_survival =		[0,0,0];
_isInfected =   0;
_model =		"";

if (_playerID == "") then {
	_playerUID = player getVariable ["playerUID", 0];
};

if ((_playerID == "") or (isNil "_playerID")) exitWith {
#ifdef DZE_SERVER_DEBUG
	diag_log ("LOGIN FAILED: Player [" + _playerName + "] has no login ID");
#endif
};

#ifdef DZE_SERVER_DEBUG
diag_log ("LOGIN ATTEMPT: " + str(_playerID) + " " + _playerName);
#endif

//Do Connection Attempt
//_key = format["CHILD:101:%1:%2:%3:",_playerID,dayZ_instance,_playerName];
_key = format["SELECT `CharacterID`, `Inventory`, `Backpack`, TIMESTAMPDIFF(MINUTE,`Datestamp`,`LastLogin`) as `SurvivalTime`, TIMESTAMPDIFF(MINUTE,`LastAte`,NOW()) as `MinsLastAte`, TIMESTAMPDIFF(MINUTE,`LastDrank`,NOW()) as `MinsLastDrank`, `Model` FROM `Character_DATA` WHERE `PlayerUID` = '%1' AND `Alive` = 1 ORDER BY `CharacterID` DESC LIMIT 1",_playerID];
_primary = _key call server_hiveReadWrite;
_primary = _primary select 0 select 0;
//diag_log format[">>>>>>>>>>>PRIMARY:%1", str(_primary)]; 

if (isNull _playerObj or !isPlayer _playerObj) exitWith {
#ifdef DZE_SERVER_DEBUG
	diag_log ("LOGIN RESULT: Exiting, player object null: " + str(_playerObj));
#endif
};

//Process request
_newPlayer = 	false;
_isNew = 		false; //_result select 1;
_charID = 	_primary select 0;

#ifdef DZE_SERVER_DEBUG
diag_log ("LOGIN RESULT: " + str(_primary));
#endif

/* PROCESS */
_hiveVer = 0;

if (!_isNew) then {
	//RETURNING CHARACTER		
	_inventory = 	_primary select 1;
	_backpack = 	_primary select 2;
	//_survival =		_primary select 3;
	_survival = call compile format["[%1,%2,%3]", (_primary select 3),(_primary select 4),(_primary select 5)]; //0 mins alive, 0 mins since last ate, 0 mins since last drank
	
	_model =		_primary select 6;
	_hiveVer =		0.96;
	
	if (!(_model in AllPlayers)) then {
		_model = "Survivor2_DZ";
	};
	
};

#ifdef DZE_SERVER_DEBUG
diag_log ("LOGIN LOADED: " + str(_playerObj) + " Type: " + (typeOf _playerObj) + " at location: " + (getPosATL _playerObj));
#endif

_isHiveOk = true;

if (worldName == "chernarus") then {
	([4654,9595,0] nearestObject 145259) setDamage 1;
	([4654,9595,0] nearestObject 145260) setDamage 1;
};

dayzPlayerLogin = [_charID,_inventory,_backpack,_survival,_isNew,dayz_versionNo,_model,_isHiveOk,_newPlayer,_isInfected];
(owner _playerObj) publicVariableClient "dayzPlayerLogin";
//diag_log format[">>>>>>>>> Made playerLOgin: %1",dayzPlayerLogin];
