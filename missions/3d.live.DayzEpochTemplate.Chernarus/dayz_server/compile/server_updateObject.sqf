/*
[_object,_type] spawn server_updateObject;
*/
private ["_object","_type","_objectID","_uid","_lastUpdate","_needUpdate","_object_position","_object_inventory","_object_damage","_isNotOk","_parachuteWest","_firstTime","_object_killed","_object_repair","_isbuildable"];

_object = _this select 0;

if(isNull(_object)) exitWith {
	diag_log format["Skipping Null Object: %1", _object];
};

_type = 	_this select 1;
_parachuteWest = ((typeOf _object == "ParachuteWest") or (typeOf _object == "ParachuteC"));
_isbuildable = (typeOf _object) in dayz_allowedObjects;
_isNotOk = false;
_firstTime = false;

_objectID =	_object getVariable ["ObjectID","0"];
_uid = 		_object getVariable ["ObjectUID","0"];

if ((_object getVariable["DZAI",0]) == 1) exitWith {};  // Sandbird

if ((typeName _objectID != "string") || (typeName _uid != "string")) then
{ 
    diag_log(format["Non-string Object: ID %1 UID %2", _objectID, _uid]);
    //force fail
    _objectID = "0";
    _uid = "0";
};
if (!_parachuteWest and !(locked _object)) then {
	// Sandbird
	if (_objectID == "0" && _uid == "0" && (vehicle _object getVariable ["DZAI",0] != 1)) then
	{
		_object_position = getPosATL _object;
    	_isNotOk = true;
	};
};

// do not update if buildable and not ok
if (_isNotOk and _isbuildable) exitWith {  };

// delete if still not ok
//Sandbird disable to allow vehicles to spawn when bought and not delete till next restart where they'll spawn again.
//if (_isNotOk) exitWith { deleteVehicle _object; diag_log(format["Deleting object %1 with invalid ID at pos [%2,%3,%4]",typeOf _object,_object_position select 0,_object_position select 1, _object_position select 2]); };


_lastUpdate = _object getVariable ["lastUpdate",time];
_needUpdate = _object in needUpdate_objects;

// TODO ----------------------
_object_position = {
	private["_position","_worldspace","_fuel","_key"];
		_position = getPosATL _object;
		_worldspace = [
			round(direction _object),
			_position
		];
		_fuel = 0;
		if (_object isKindOf "AllVehicles") then {
			_fuel = fuel _object;
		};
		//_key = format["CHILD:305:%1:%2:%3:",_objectID,_worldspace,_fuel];
		_key = format["UPDATE object_data SET Worldspace = '%2', Fuel = '%3' WHERE ObjectID = '%1'",_objectID,_worldspace,_fuel];
		//diag_log ("HIVE: WRITE: "+ str(_key));
		_key call server_hiveWrite;
};

_object_inventory = {
	private["_inventory","_previous","_key"];
			_inventory = [
			getWeaponCargo _object,
			getMagazineCargo _object,
			getBackpackCargo _object
		];
	
	_previous = str(_object getVariable["lastInventory",[]]);
		if (str(_inventory) != _previous) then {
			_object setVariable["lastInventory",_inventory];
			if (_objectID == "0") then {
				//_key = format["CHILD:309:%1:%2:",_uid,_inventory];
				_key = format["UPDATE object_data SET Inventory = '%2' WHERE ObjectUID = '%1'",_uid,_inventory];
				_key call server_hiveWrite;
			} else {
				//_key = format["CHILD:303:%1:%2:",_objectID,_inventory];
				_key = format["UPDATE object_data SET Inventory = '%2' WHERE ObjectID = '%1'",_objectID,_inventory];
				_key call server_hiveWrite;
			};
			//diag_log ("HIVE: WRITE: "+ str(_key));
		};
};

_object_damage = {
	private["_hitpoints","_array","_hit","_selection","_key","_damage"];
		_hitpoints = _object call vehicle_getHitpoints;
		_damage = damage _object;
		_array = [];
		{
			_hit = [_object,_x] call object_getHit;
			_selection = getText (configFile >> "CfgVehicles" >> (typeOf _object) >> "HitPoints" >> _x >> "name");
			if (_hit > 0) then {_array set [count _array,[_selection,_hit]]};
			_object setHit ["_selection", _hit]
		} forEach _hitpoints;
	
		//_key = format["CHILD:306:%1:%2:%3:",_objectID,_array,_damage];
		_key = format["UPDATE object_data SET Hitpoints = '%2', Damage = '%3' WHERE ObjectID = '%1'",_objectID,_array,_damage];
		//diag_log ("HIVE: WRITE: "+ str(_key));
		_key call server_hiveWrite;
		_object setVariable ["needUpdate",false,true];
	};

_object_killed = {
	private["_hitpoints","_array","_hit","_selection","_key","_damage"];
	_hitpoints = _object call vehicle_getHitpoints;
	//_damage = damage _object;
	_damage = 1;
	_array = [];
	{
		_hit = [_object,_x] call object_getHit;
		_selection = getText (configFile >> "CfgVehicles" >> (typeOf _object) >> "HitPoints" >> _x >> "name");
		if (_hit > 0) then {_array set [count _array,[_selection,_hit]]};
		_hit = 1;
		_object setHit ["_selection", _hit]
	} forEach _hitpoints;
	
	if (_objectID == "0") then {
		//_key = format["CHILD:306:%1:%2:%3:",_uid,_array,_damage];
		_key = format["UPDATE object_data SET Hitpoints = '%2', Damage = '%3' WHERE ObjectUID = '%1'",_uid,_array,_damage];
		_key call server_hiveWrite;
	} else {
		//_key = format["CHILD:306:%1:%2:%3:",_objectID,_array,_damage];
		_key = format["UPDATE object_data SET Hitpoints = '%2', Damage = '%3' WHERE ObjectID = '%1'",_objectID,_array,_damage];
		_key call server_hiveWrite;
	};
	//diag_log ("HIVE: WRITE: "+ str(_key));
	_object setVariable ["needUpdate",false,true];
};

_object_repair = {
	private["_hitpoints","_array","_hit","_selection","_key","_damage"];
	_hitpoints = _object call vehicle_getHitpoints;
	_damage = damage _object;
	_array = [];
	{
		_hit = [_object,_x] call object_getHit;
		_selection = getText (configFile >> "CfgVehicles" >> (typeOf _object) >> "HitPoints" >> _x >> "name");
		if (_hit > 0) then {_array set [count _array,[_selection,_hit]]};
		_object setHit ["_selection", _hit]
	} forEach _hitpoints;
	
	//_key = format["CHILD:306:%1:%2:%3:",_objectID,_array,_damage];
	_key = format["UPDATE object_data SET Hitpoints = '%2', Damage = '%3' WHERE ObjectID = '%1'",_objectID,_array,_damage];
	//diag_log ("HIVE: WRITE: "+ str(_key));
	_key call server_hiveWrite;
	_object setVariable ["needUpdate",false,true];
};

_object_vehicleKey = {
	private["_hitpoints","_array","_hit","_selection","_key","_damage","_fuel","_inventory","_class","_position","_worldspace","_newKey","_newKeyName","_player","_oldVehicleID","_vehicleID","_vehicleUID","_result","_outcome","_retry","_gotcha"];
	
	/* Setting up variables */
	_player = _this select 0;
	_class = _this select 1;
	_newKey = _this select 2;
	_newKeyName = _this select 3;
	_oldVehicleID = _this select 4;
	_vehicleUID = _this select 5;

	/* Get Damage of the Vehicle */
	_hitpoints = _object call vehicle_getHitpoints;
	_damage = damage _object;
	_array = [];
	{
		_hit = [_object,_x] call object_getHit;
		_selection = getText (configFile >> "CfgVehicles" >> (typeOf _object) >> "HitPoints" >> _x >> "name");
		if (_hit > 0) then {_array set [count _array,[_selection,_hit]]};
		_object setHit ["_selection", _hit]
	} forEach _hitpoints;
	
	/* Get the Fuel of the Vehicle */
	_fuel = 0;
	if (_object isKindOf "AllVehicles") then {
		_fuel = fuel _object;
	};
	
	/* Get the Inventory of the Vehicle */
	_inventory = [
		getWeaponCargo _object,
		getMagazineCargo _object,
		getBackpackCargo _object
	];
	
	/* Get the position of the Vehicle */
	_position = getPosATL _object;
	_worldspace = [
		round(direction _object),
		_position
	];

	/* Delete the current Database entry */
	[_oldVehicleID,_vehicleUID,_player] call server_deleteObj;
	sleep 1;
	
	/* Write the new Database entry and LOG the action*/
	//_key = format["CHILD:308:%1:%2:%3:%4:%5:%6:%7:%8:%9:",dayZ_instance, _class, _damage , _newKey, _worldspace, _inventory, _array, _fuel,_vehicleUID];
	_key = format["insert into object_data (ObjectUID, Instance, Classname, CharacterID, Worldspace, Inventory, Hitpoints, Fuel, Damage) values ('%1','%2','%3','%4','%5','%6','%7','%8','%9')",_vehicleUID,dayZ_instance,_class,_newKey,_worldspace,_inventory,_array,_fuel,_damage];
	diag_log ("HIVE: WRITE: "+ str(_key)); 
	_key call server_hiveWrite;
	diag_log ("HIVE: WRITE: VEHICLE KEY CHANGER: "+ str(_key)); 
	diag_log format["HIVE: WRITE: VEHICLE KEY CHANGER: Vehicle:%1 NewKey:%2 BY %3(%4)", _object, _newKeyName, (name _player), (getPlayerUID _player)];

	/* Get the ObjectID of the entry in the Database */
	_retry = 0;
	_gotcha = false;
	while {!_gotcha && _retry < 10} do {
		sleep 1;
		
		/* Send the request */
		//_key = format["CHILD:388:%1:",_vehicleUID];	
		_key 	= format["select ObjectID from object_data WHERE ObjectUID = '%1'",_vehicleUID];
		diag_log ("HIVE: READ: VEHICLE KEY CHANGER: "+ str(_key));
		_result = _key call server_hiveReadWrite;
		_outcome = _result select 0 select 0;

		_vehicleID = _outcome select 0;
			
			/* Compare with old ObjectID to check if it not was deleted yet */
			if (_oldVehicleID == _vehicleID) then {
				/* Not good lets give it another try */
				_gotcha = false;
				_retry = _retry + 1;
			} else {
				/* GOTCHA! */
				diag_log("CUSTOM: VEHICLE KEY CHANGER: Selected " + str(_vehicleID));
				_gotcha = true;
				_retry = 11;
			};
	};

	/* Lock the Vehicle */
	_object setvehiclelock "locked";
	/* Save the ObjectID to the vehicles variable and make it public */
	_object setVariable ["ObjectID", _vehicleID, true];
	/* Save the ObjectUID to the vehicles variable and make it public */
	_object setVariable ["ObjectUID", _vehicleUID, true];
	/* Set the lastUpdate time to current */
	_object setVariable ["lastUpdate",time];
	/* Set the CharacterID to the new Key so we can access it! */
	_object setVariable ["CharacterID", _newKey, true];
	/* Some other variables you might need for disallow lift/tow/cargo locked Vehicles and such */
	/* Uncomment if you use this */
	/* R3F Arty and LOG block lift/tow/cargo locked vehicles*/
	_object setVariable ["R3F_LOG_disabled",true,true];
	/* =BTC= Logistic block lift locked vehicles*/
	_object setVariable ["BTC_Cannot_Lift",true,true];
	_object setVariable ["sidegundeployed",0,true];
	_object setVariable ["reargundeployed",0,true];
	
	_object call fnc_veh_ResetEH;
};

// TODO ----------------------

_object setVariable ["lastUpdate",time,true];
switch (_type) do {
	case "all": {
		call _object_position;
		call _object_inventory;
		call _object_damage;
		};
	case "position": {
		if (!(_object in needUpdate_objects)) then {
			//diag_log format["DEBUG Position: Added to NeedUpdate=%1",_object];
			needUpdate_objects set [count needUpdate_objects, _object];
		};
	};
	case "gear": {
		call _object_inventory;
			};
	case "damage": {
		if ( (time - _lastUpdate) > 5) then {
			call _object_damage;
		} else {
			if (!(_object in needUpdate_objects)) then {
				//diag_log format["DEBUG Damage: Added to NeedUpdate=%1",_object];
				needUpdate_objects set [count needUpdate_objects, _object];
			};
		};
	};
	case "killed": {
		call _object_killed;
	};
	case "repair": {
		call _object_damage;
	};
	case "vehiclekey": {
		_activatingPlayer = _this select 2;
		_vehicleClassname = _this select 3;
		_toKey = _this select 4;
		_toKeyName = _this select 5;
		_vehicle_ID = _this select 6;
		_vehicle_UID = _this select 7;
		[_activatingPlayer, _vehicleClassname, _toKey, _toKeyName, _vehicle_ID, _vehicle_UID] call _object_vehicleKey;
	};
};
