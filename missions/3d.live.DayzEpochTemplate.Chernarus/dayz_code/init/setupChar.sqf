private ["_isHiveOk","_newPlayer","_isInfected","_model","_backpackMagTypes","_backpackMagQty","_backpackWpnTypes","_backpackWpnQtys","_countr","_isOK","_backpackType","_backpackWpn","_backpackWater","_mags","_magsb","_wpns","_bcpk","_bcpkWpn","_config","_playerUID","_msg","_myTime","_charID","_inventory","_backpack","_survival","_isNew","_version","_debug","_lastAte","_lastDrank","_usedFood","_usedWater","_worldspace","_state","_setDir","_setPos","_legs","_arms","_totalMins","_days","_hours","_mins","_messing"];
if(isNil "DZEdebug") then { DZEdebug = false; };
_debug = DZEdebug;
if (_debug) then {
	diag_log ("PSETUP: Initating");
};
progressLoadingScreen 0.8;
if (isNil "freshSpawn") then {
	freshSpawn = 0;
};


	//player is new, add initial loadout only if player is not pzombie
	if(!(player isKindOf "PZombie_VB")) then {
		//Just to be sure.
		removeAllItems player;
		removeAllWeapons player;
		removeBackpack player;
		_config = (configFile >> "CfgSurvival" >> "Inventory" >> "Default");
		_mags = getArray (_config >> "magazines");
		_magsb = getArray (_config >> "magazines");
		_wpns = getArray (_config >> "weapons");		
		_bcpk = getText (_config >> "backpack");
		_bcpkWpn = getText (_config >> "backpackWeapon");
		if(!isNil "DefaultMagazines") then {
			_mags = DefaultMagazines;
		};
		if(!isNil "DefaultBackpackMagazines") then {
			_magsb = DefaultBackpackMagazines;
		};
		if(!isNil "DefaultWeapons") then {
			_wpns = DefaultWeapons;
		};
		if(!isNil "DefaultBackpack") then {
			_bcpk = DefaultBackpack;
		};
		if(!isNil "DefaultBackpackWeapon") then {
			_bcpkWpn = DefaultBackpackWeapon;
		};
		//Add inventory
		{
			_isOK = 	isClass(configFile >> "CfgMagazines" >> _x);
			if (_isOK) then {
				player addMagazine _x;
			};
		} forEach _mags;
		{
			_isOK = 	isClass(configFile >> "CfgWeapons" >> _x);
			if (_isOK) then {
				player addWeapon _x;
			};
		} forEach _wpns;
		if (_bcpk != "") then {
			player addBackpack _bcpk; 
			dayz_myBackpack =	unitBackpack player;
		};
		if (_bcpkWpn != "") then {
			dayz_myBackpack addWeaponCargoGlobal [_bcpkWpn,1];
		};
		{
			_isOK = 	isClass(configFile >> "CfgMagazines" >> _x);
			if (_isOK) then {
				dayz_myBackpack addMagazineCargoGlobal [_x,1];
			};
		} forEach _magsb;
//	};
 };

////////////////////////////
// Setup a default character
////////////////////////////
       

//Record current weapon state
dayz_myWeapons = 		weapons player;		//Array of last checked weapons
dayz_myItems = 			items player;		//Array of last checked items
dayz_myMagazines = 	magazines player;
dayz_playerName = name player;

dayz_myCursorTarget = cursortarget;
dayz_myPosition = 		getPosATL player;	//Last recorded position
dayz_lastMeal =			(3 * 60);
dayz_lastDrink =		(3 * 60);
dayz_zombiesLocal = 	0;			//Used to record how many local zombies being tracked
dayz_Survived = 10;  //total alive dayz
       
//load in medical details
r_player_dead = 		player getVariable["USEC_isDead",false];
r_player_unconscious = 	player getVariable["NORRN_unconscious", false];
r_player_infected =	player getVariable["USEC_infected",false];
r_player_injured = 	player getVariable["USEC_injured",false];
r_player_inpain = 	player getVariable["USEC_inPain",false];
r_player_cardiac = 	player getVariable["USEC_isCardiac",false];
r_player_lowblood =	player getVariable["USEC_lowBlood",false];
r_player_blood = 		player getVariable["USEC_BloodQty",r_player_bloodTotal];
       
       
       
//player variables
player setIdentity "My_Player"; 										// check description.ext file....There is no other way to get the name of the player in the editor.
player setVariable ["CharacterID", "1", true];      // Set here the characterID of the player
player setVariable ["playerUID", "111111", true];   // Set here the playerUID of the player (by default the 2nd bot inside the game is friend to player with id 111111
dayz_Survived = 10;  // Fixed number for days the player has survived without dying
player setVariable["humanity", 11000];
player setVariable["humanKills", 10];
player setVariable["banditKills", 20];
player setVariable["zombieKills", 30];
player setVariable ["friendlies", ["222222","333333"], true]; //Both DZE_Friends and this must be set for friendlies to work properly
DZE_Friends = ["222222","333333"];



dayz_characterID =	player getVariable ["CharacterID","0"];
_playerUID = player getVariable ["playerUID", 0];
dayz_playerUID 	 = _playerUID;  // Fix...This has to be initiated after it was set

//Initial State of player
dayz_loadScreenMsg =  "Character Data received";