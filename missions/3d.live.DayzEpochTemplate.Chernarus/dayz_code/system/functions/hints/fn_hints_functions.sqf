//debuglog function
BIS_debugLog = 
{
	private ["_id", "_message"];
	
	if!(isNil "BIS_debugMode") then {
		if(BIS_debugMode) then {
			_message = _this select 0;
			_id = _this select 1;
			
			if !(isNil "_id") then {
				DEBUGLOG format ["Debug >> %2: %1", _id, _message];	
				//player sideChat format ["Debug >> %2: %1", _id, _message];			
			} else {
				DEBUGLOG format ["Debug >> %1", _message];
				//player sideChat format ["Debug >> %1", _message];				
			};
		};
	};
};

//Is player looking at "_target"?
//[player,<object>] call BIS_isLookingAt
BIS_isLookingAt =
{
	private ["_target","_source","_result","_angle"];
	
	if (count _this == 2) then {
		_source = _this select 0;
		_target = _this select 1;
	} else {
		_source = player;
		_target = _this select 0;
	};
	
	_result = false;
	_angle = abs([_source, _target] call BIS_fnc_relativeDirTo);	
	
	if (_angle > 345 || _angle < 15) then {
		_result	= true;
	};
	
	_result
};

BIS_addToArrayUnique =
{
	private ["_array","_item","_canAdd"];
	scopename "main";
	
	_array = _this select 0;
	_item = _this select 1;
	
	_canAdd = true;
	
	{
		if (_x == _item) then {
			_canAdd = false;
			breakto "main";
		}
		
	} forEach _array;	
	
	if (_canAdd) then {
		_array = _array + [_item];
	};
	
	_array
};

BIS_isInDistance2D = {
	private["_o1","_o2","_tolerance","_r","_p1","_p2"];
	
	_o1 = _this select 0;
	_o2 = _this select 1;
	_tolerance = _this select 2;

	_p1 = getPos _o1;
	_p2 = getPos _o2;

	_p1 = [_p1 select 0, _p1 select 1, 0];
	_p2 = [_p2 select 0, _p2 select 1, 0];
	
	if (_p1 distance _p2 <= _tolerance) then {
		_r = true;
	} else {
		_r = false;
	};

	_r	
};

BIS_getPosInDistance = {
	private["_source","_target"];
	
	if (typeName(_this select 0) == "OBJECT") then {
		_source = getPosASL (_this select 0);
	} else {
		_source = _this select 0;
	};

	if (typeName(_this select 1) == "OBJECT") then {
		_target = getPosASL (_this select 1);
	} else {
		_target = _this select 1;
	};	
	
	_distance = _this select 2;
	
	_distanceAB = _source distance _target;
	
	_deltax = (_target select 0) - (_source select 0);
	_deltay = (_target select 1) - (_source select 1);
	_deltaz = (_target select 2) - (_source select 2);
	
	_deltaxm = _deltax/_distanceAB;
	_deltaym = _deltay/_distanceAB;
	_deltazm = _deltaz/_distanceAB;
	
	_pos = [
		(_source select 0) + _deltaxm * _distance, 
		(_source select 1) + _deltaym * _distance, 
		(_source select 2) + _deltazm * _distance
	];
	
	//[_pos] call BIS_debugLog;
	
	_pos
};

//finds an object (from the array of objects) that is closest to the direction player is aiming (in 2D)
BIS_getClosestObject = {
	private["_array","_closestObject","_closestAngle","_angle"];
	
	_array = _this;
	
	_closestObject = nil;
	_closestAngle = 361;
	
	{
		_angle = [player, _x] call BIS_fnc_relativeDirTo;

		if (_angle > 180) then {
			_angle = _angle - 360;
		};
		
		if (_angle < 0) then {
			_angle = abs(_angle);
		};
	
		if (isNil "_closestAngle") then {
			_closestAngle = _angle;
		};
	
		if (_angle < _closestAngle) then {
			_closestAngle = _angle;
			_closestObject = _x;
		};
	
	} forEach _array;
	
	_closestObject
};

//[_array,_item1,_item2] call BIS_getSubArray
BIS_getSubArray = {
	private["_array","_item1","_item2","_subArray"];
	
	_array = _this select 0;
	_item1 = _this select 1;
	_item2 = _this select 2;
	
	_subArray = [];

	scopename "main";

	{
		//add item in between
		if (count _subArray > 0) then {
			_subArray = _subArray + [_x];
			
			//and quit it last item (_item2) found
			if (_x == _item2) then {
				breakto "main";
			};
		} else {
			//add 1st item (_item1) to sub-array
			if (_x == _item1) then {
				_subArray = [_x];
			};			
		};
	} forEach _array;
	
	_subArray
};

BIS_endTutorial = {
	private["_task","_keys"];
	
	//kill background music loop, current track will continue to its end
	terminate bis_fnc_music_spawn;
	
	{
	
		_task = player createSimpleTask ["NewTask"];
		_task setTaskState "Succeeded";
		_task setSimpleTaskDescription ["", _x, ""];
	
	} forEach _this;
	
	player addRating 1000;

	_keys = getarray (missionconfigfile >> "doneKeys");
	{activatekey _x} foreach _keys;
	
	[objNull, objNull, rENDMISSION, 'End1'] call RE;
	
	["MISSION COMPLETED!"] call BIS_debugLog;	
};

BIS_allUnitsBoarded =
{
	private ["_vehicle","_unitList","_allBoarded"];
	
	_allBoarded = true;
	
	_vehicle = _this select 0;
	_unitList = _this select 1;

	scopename "main";

	if (isNil "_vehicle") then {
		//vehicle doesn't exist, so return FALSE
		_allBoarded = false;
	} else {

		//check if all (existing & alive) units from the list are inside given vehicle
		{
			//non-existing and dead units are ignored
			if (!isNil("_x") && alive(_x) && !(_x in _vehicle)) then {
				_allBoarded = false;
				breakto "main";
			};
		} forEach _unitList;
	};
	
	_allBoarded 
};

//[grp or unit,wpobject,speed] call BIS_addWP
BIS_addWP = {
	private["_wp","_grp","_obj","_speed"];
	
	if (isNil "BIS_WPReached") then {
		BIS_WPReached = [];
	};
	
	if (typeName (_this select 0) == "GROUP") then {
		_grp = _this select 0;
	} else {
		_grp = group(_this select 0);
	};
	
	_obj = _this select 1;
	
	if !(isNil "_this select 2") then {
		_speed = _this select 2;
	} else {
		_speed = "NORMAL";
	};
	
	_wp = _grp addWaypoint [getPosATL(_obj), 0];
	_wp setWaypointType "MOVE";
	_wp setWaypointDescription "";
	//_wp setWaypointCompletionRadius 75;	
	_wp setWaypointSpeed _speed;
	_wp setWaypointStatements ["true", format["BIS_WPReached = BIS_WPReached + [%1]",_obj]];
};

BIS_createBriefing = {
	private["_text"];
	
	_text =  localize "STR_EP1_functions.sqf3";
	
	{
		_text = _text + "<br/>- " + _x;
		
	} forEach BIS_Objectives;
	
	//_nic = [objNull, player, rCREATEDIARYRECORD, "Briefing", _text] call RE;
	//str_ep1_5po_ce0.sqf0
	_nic = [objNull, player, rCREATEDIARYRECORD, localize "str_ep1_5po_ce0.sqf0", _text] call RE;
};

//returns true if player landed successfully
//[BIS_Heli,BIS_Helipad,20] call BIS_landed;
BIS_landed =
{
	private ["_vehicle", "_landingTarget", "_landingTolerance", "_result"];
	
	_vehicle = _this select 0;
	_landingTarget = _this select 1;
	_landingTolerance = _this select 2;
	
	_result = false;
	scopename "main";
	
	if (true) then {	
		//not in correct vehicle
		if (vehicle player != _vehicle) then {
			breakto "main";
		};
	
		//flying too high
		if (round((getPos _vehicle select 2) * 10) != 0) then {
			breakto "main";
		};
	
		//too far
		if ((_vehicle distance _landingTarget) > _landingTolerance) then {
			breakto "main";
		};
		
		//moving
		if (round((velocity _vehicle select 0) * 10) != 0 || round((velocity _vehicle select 1) * 10) != 0 || round((velocity _vehicle select 2) * 10) != 0) then {
			breakto "main";
		};
	
		["Height:"+str(getPos _vehicle select 2)+", Distance:"+str(_vehicle distance _landingTarget)] call BIS_debuglog;

		_result = true;
	};

	_result	
};

BIS_saveGame = {
	
	//sleep 2;

	if (alive player && canMove player && canMove (vehicle player)) then {
		["Saving game"] call BIS_debugLog;
		saveGame;
	};	
};
