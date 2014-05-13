BIS_checkptReached =
{
	private["_tolerance","_checkpt","_r","_showObjectiveWP","_condition"];

	if (count(_this) == 2) then {
		_checkpt = _this select 0;
		_tolerance = _this select 1;
	} else {
		_checkpt = _this select 0;
		_tolerance = 3;
	};
	if (count(_this) > 2) then {
		_showObjectiveWP = _this select 2;	
	} else {
		_showObjectiveWP = true;
	};
	if (count(_this) > 3) then {
		_condition = _this select 3;	
	} else {
		_condition = {true};
	};


	_r = false;
	
	//for the waypoint navigation
	if (_showObjectiveWP && BIS_GBall distance _checkpt < 0.1) then {
		BIS_Objective = _checkpt;
	} else {
		BIS_Objective = player;
	};
	
	if !(isNil "BIS_GBall") then {
		if (([player,_checkpt,_tolerance] call BIS_isInDistance2D) && ([BIS_GBall,_checkpt,0.1] call BIS_isInDistance2D) && call _condition) then {
			_r = true;
			
			call BIS_deleteGArrow;
			
			//for the waypoint navigation
			BIS_Objective = player;
			
			//smoothly fadeout the GBall
			call BIS_deleteGBall;
		};
	};
	
	_r
};

BIS_checkptReached3d =
{
	private["_tolerance","_checkpt","_r"];

	if (count(_this) == 2) then {
		_checkpt = _this select 0;
		_tolerance = _this select 1;
	} else {
		_checkpt = _this select 0;
		_tolerance = 3;
	};

	_r = false;

	//for the waypoint navigation
	BIS_Objective = _checkpt;
	
	if ((player distance _checkpt < _tolerance) && BIS_GBall distance _checkpt < 0.1) then {
		_r = true;
		
		call BIS_deleteGArrow;
		
		//for the waypoint navigation
		BIS_Objective = player;	
		
		//smoothly fadeout the GBall
		call BIS_deleteGBall;			
	};
	
	_r
};


//[[WP1,WP2,WP3...WP999],_speed,_acceleration] call BIS_guidePlayer;
BIS_guidePlayer = 
{
	private["_source","_target","_speed","_a","_wps","_mode","_hoverHeight"];

	if !(isNil "BIS_GuidePlayer_Spawn") then {
		terminate BIS_GuidePlayer_Spawn;
	};

	//delete GArrow
	if !(isNil "BIS_GArrow") then {	
		"FAST" call BIS_deleteGArrow;
	};

	//init
	_mode = "";
	_speed = 0;
	_a = 0;

	if (typeName(_this select 0) == "ARRAY") then {
		//waypoints
		if (count (_this select 0) == 1) then {
			//player is source only if ball doesn't exist
			if !(isNil "BIS_GBall") then {
				_source = BIS_GBall;
			} else {
				_source = player;
			};
			_wps = [_source] + _this select 0;
		} else {
			_wps = _this select 0;
		};
		//speed
		if (count _this > 1) then {
			if (typeName(_this select 1) == "STRING") then {
				_mode = _this select 1;
			} else {
				_speed = _this select 1;
			};
		};
		//acceleration
		if (count _this > 2) then {
			_a = _this select 2;
		};		
		
		//hover height
		if (count _this > 3) then {
			_hoverHeight = _this select 3;
		};				
	} else {
		//hover height
		if (count _this > 4) then {
			_hoverHeight = _this select 4;
		};			
		if (count(_this) == 4) then {
			_source = _this select 0;
			_target = _this select 1;
			_speed = _this select 2;
			_a = _this select 3;
		};
		if (count(_this) == 3) then {
			if (typeName(_this select 1) == "OBJECT") then {
				_source = _this select 0;
				_target = _this select 1;
				if (typeName(_this select 2) == "STRING") then {
					_mode = _this select 2;
				} else {
					_speed = _this select 2;
				};				
			} else {
				_source = player;
				_target = _this select 0;
				_speed = _this select 1;
				_a = _this select 2;
			};			
		};
		if (count(_this) == 2) then {
			if (typeName(_this select 1) == "OBJECT") then {
				_source = _this select 0;
				_target = _this select 1;
			} else {
				_source = player;
				_target = _this select 0;
				if (typeName(_this select 1) == "STRING") then {
					_mode = _this select 1;
				} else {
					_speed = _this select 1;
				};				
			};
		};
		if (count(_this) == 1) then {
			_source = player;
			_target = _this select 0;
		};
		
		//player is source only if ball doesn't exist
		if (_source == player) then {
			if !(isNil "BIS_GBall") then {
				_source = BIS_GBall;
			};
		};	
		
		/*
		["Source", _source] call BIS_debugLog;
		["Target", _target] call BIS_debugLog;
		["Distance", _source distance _target] call BIS_debugLog;
		*/
		
		//waypoints
		_wps = [_source] + [_target];
	};
	
	//safe-check: exit if distance 0
	private["_distance","_i","_start","_end"];
	_distance = 0;
	for "_i" from 0 to ((count _wps) - 2) do {
		_start = _wps select _i;
		_end = _wps select (_i + 1);
		
		_distance = _start distance _end;
	};
	if (_distance == 0) exitwith {
		["Function 'BIS_guidePlayer'","Animation distance is 0!"] call BIS_debugLog;
		["WP:Start",_wps select 0] call BIS_debugLog;
		["WP:End",_wps select ((count _wps) - 1)] call BIS_debugLog;
	};

	switch (_mode) do {
		case "SLOW_WALK": {
			_speed = 5;
			_a = 10;
		}; 
		case "WALK" : {
			_speed = 10;
			_a = 20;
		};  
		case "RUN" : {
			_speed = 20;
			_a = 40;
		}; 		
		default {
			if (_speed == 0) then {_speed = 10;};
			if (_a == 0) then {_a = 20;};
		};
	};

	//create GBall
	call BIS_createGBall;
	
	if isNil("_hoverHeight") then {
		_handler = [BIS_GBall,_wps,_speed,_a] spawn BIS_animateMoveSmooth;
	} else {
		_handler = [BIS_GBall,_wps,_speed,_a,_hoverHeight] spawn BIS_animateMoveSmooth;
	};	
	

	_target = _wps select (count(_wps) - 1);

	BIS_GuidePlayer_Spawn = _target spawn {
		private["_minDist"];
		
		sleep 0.1;
		
		waitUntil {sleep 0.05; (BIS_GBall distance _this) < 0.1};

		sleep 0.5;

		_minDist = 2;

		//create the arrow only if player is more then 2m away		
		if (player distance _this > _minDist && (BIS_GBall distance _this) < 0.1) then {
			
			if (isNil "BIS_GBall_Size") then {
				BIS_GBall_Size = "NORMAL";
			};			
			
			if (BIS_GBall_Size == "LARGE") then {
				[_this, 0.75, "LARGE"] call BIS_createGArrow;
			} else {
				[_this, 0.3] call BIS_createGArrow;
			};
		};
	};

};

BIS_createGBall =
{
	private["_model"];	
	
	if (isNil "BIS_GBall_Size") then {
		BIS_GBall_Size = "NORMAL";
	};
	
	switch (BIS_GBall_Size) do {
		case "SMALL": {
			_model = "sign_sphere10cm_ep1";
		}; 
		case "NORMAL" : {
			_model = "sign_sphere25cm_ep1";
		};  
		case "LARGE" : {
			_model = "Sign_sphere100cm_EP1";
		}; 		
		default {
			_model = "sign_sphere25cm_ep1";
		};
	};

	//initialize model info
	if (isNil "BIS_GBall_Model") then {
		BIS_GBall_Model = _model;
	}; 

	//reset model if changed
	if (BIS_GBall_Model != _model) then {
		deleteVehicle BIS_GBall;
		BIS_GBall = nil;	
	}; 

	//create new ball	
	if (isNil "BIS_GBall") then {
		BIS_GBall = _model createVehicle [0,0,0];
		BIS_GBall_Model = _model;
		BIS_GBall_Alpha = 0;
		BIS_GBall setObjectTexture [0,"#(argb,8,8,3)color(1,0.5,0.5," + str BIS_GBall_Alpha + ",ca)"];
		BIS_GBall allowDamage false;
	};

	if !(isNil "BIS_GBall_Spawn") then {
		terminate BIS_GBall_Spawn;
	};

	BIS_GBall_Spawn = BIS_GBall spawn {
		while{BIS_GBall_Alpha < 0.5} do {
			BIS_GBall_Alpha = BIS_GBall_Alpha + 0.025;
			BIS_GBall setObjectTexture [0,"#(argb,8,8,3)color(1,0.5,0.5," + str BIS_GBall_Alpha + ",ca)"];
			sleep 0.05;
		};
	};
};

BIS_deleteGBall =
{
	if !(isNil "BIS_GBall_Spawn") then {
		terminate BIS_GBall_Spawn;
	};

	if !(isNil "BIS_GBall") then {
		BIS_GBall_Spawn = BIS_GBall spawn {
			while{BIS_GBall_Alpha > 0} do {
				BIS_GBall_Alpha = BIS_GBall_Alpha - 0.05;
				
				if (BIS_GBall_Alpha < 0) then {
					BIS_GBall_Alpha = 0;
				};
				
				BIS_GBall setObjectTexture [0,"#(argb,8,8,3)color(1,0.5,0.5," + str BIS_GBall_Alpha + ",ca)"];
				sleep 0.05;
			};		
		};
	};
};

BIS_createGArrow =
{
	private["_object","_pos","_zoffset","_model","_size"];

	//hide previous arrow
	if !(isNil "BIS_GArrow") then {
		call BIS_deleteGArrow;
	};

	if (count _this > 2) then {
		_size = _this select 2;
	} else {
		_size = "NORMAL";
	};

	if (_size == "LARGE") then {
		_model = "Sign_arrow_down_large_EP1";
	} else {
		_model = "Sign_arrow_down_EP1";
	};

	//initialize model info
	if (isNil "BIS_GArrow_Model") then {
		BIS_GArrow_Model = _model;
	}; 

	//reset model if changed
	if (BIS_GArrow_Model != _model) then {
		deleteVehicle BIS_GArrow;
		BIS_GArrow = nil;	
	}; 

	BIS_GArrow_Alpha = 0;

	//create arrow for the 1st time
	if (isNil "BIS_GArrow") then {
		BIS_GArrow = _model createVehicle [0,0,0];
		BIS_GArrow_Model = _model;
		BIS_GArrow setdir getdir BIS_GArrow;		
		BIS_GArrow setObjectTexture [0,"#(argb,8,8,3)color(1,0.5,0.5," + str BIS_GArrow_Alpha + ",ca)"];
		BIS_GArrow allowDamage false;
	};

	//fade-in
	if !(isNil "BIS_GArrow_Spawn") then {
		terminate BIS_GArrow_Spawn;
	};
	BIS_GArrow_Spawn = BIS_GArrow spawn {
		while{BIS_GArrow_Alpha < 0.5} do {
			//BIS_GArrow_Alpha = BIS_GArrow_Alpha + 0.01;
			BIS_GArrow_Alpha = BIS_GArrow_Alpha + 0.02;
			BIS_GArrow setObjectTexture [0,"#(argb,8,8,3)color(1,0.5,0.5," + str BIS_GArrow_Alpha + ",ca)"];
			sleep 0.05;
		};
	};

	//set position	
	_object = _this select 0;
	if (count(_this) > 1) then {
		_zoffset = _this select 1;
	} else {
		_zoffset = 0;
	};
	_pos = getPosASL(_object);
	_pos = [_pos select 0,_pos select 1,(_pos select 2) + _zoffset];
	BIS_GArrow setPosASL _pos;

	//start animations
	BIS_GArrow_Anim1 = [BIS_GArrow,0.04,0.7] spawn BIS_animateUpDown;
	BIS_GArrow_Anim2 = [BIS_GArrow] spawn BIS_animateRotate;
};

BIS_deleteGArrow =
{
	private["_speed","_alphaStep"];
	
	if !(isNil "BIS_GArrow_Spawn") then {
		terminate BIS_GArrow_Spawn;
	};
	if !(isNil "BIS_GArrow_Anim1") then {
		terminate BIS_GArrow_Anim1;
	};
	if !(isNil "BIS_GArrow_Anim2") then {
		terminate BIS_GArrow_Anim2;
	};	
	
	if !(isNil "_this") then {
		_speed = _this;
	} else {
		_speed = "NORMAL";
	};
	
	switch (_speed) do {
		case "SLOW": {
			_alphaStep = 0.01;
		}; 
		case "NORMAL" : {
			_alphaStep = 0.05;
		};  
		case "FAST" : {
			_alphaStep = 0.1;
		}; 		
		default {
			_alphaStep = 0.05;
		};
	};
	
	BIS_GArrow_Spawn = BIS_GArrow spawn {
		while{BIS_GArrow_Alpha > 0} do {
			BIS_GArrow_Alpha = BIS_GArrow_Alpha - _alphaStep;
			
			if (BIS_GArrow_Alpha < 0) then {
				BIS_GArrow_Alpha = 0;
			};
			
			BIS_GArrow setObjectTexture [0,"#(argb,8,8,3)color(1,0.5,0.5," + str BIS_GArrow_Alpha + ",ca)"];
			sleep 0.05;
		};		
	};
};

BIS_animateObject =
{
	private["_source","_target","_speed","_a","_wps","_hoverHeight","_handler"];

	//defaults
	_speed = 5;
	_a = 20;
	
	_object = _this select 0;

	if (typeName(_this select 1) == "ARRAY") then {
		//waypoints
		if (count (_this select 1) == 1) then {
			//player is source only if the object doesn't exist
			if !(isNil "_object") then {
				_source = _object;
			} else {
				_source = player;
			};
			_wps = [_source] + _this select 1;
		} else {
			_wps = _this select 1;
		};
		//speed
		if (count _this > 2) then {
			_speed = _this select 2;
		};
		//acceleration
		if (count _this > 3) then {
			_a = _this select 3;
		};
		//hover height
		if (count _this > 4) then {
			_hoverHeight = _this select 4;
		};				
	} else {
		//hover height
		if (count _this > 5) then {
			_hoverHeight = _this select 5;
		};
		if (count(_this) > 4) then {
			_source = _this select 1;
			_target = _this select 2;
			_speed = _this select 3;
			_a = _this select 4;
		};
		if (count(_this) == 4) then {
			if (typeName(_this select 2) == "OBJECT") then {
				_source = _this select 1;
				_target = _this select 2;
				_speed = _this select 3;
			} else {
				_source = player;
				_target = _this select 1;
				_speed = _this select 2;
				_a = _this select 3;
			};			
		};
		if (count(_this) == 3) then {
			if (typeName(_this select 2) == "OBJECT") then {
				_source = _this select 1;
				_target = _this select 2;
			} else {
				_source = player;
				_target = _this select 1;
				_speed = _this select 2;
			};
		};
		if (count(_this) == 2) then {
			_source = player;
			_target = _this select 1;
		};
		
		//player is source only if ball doesn't exist
		if (_source == player) then {
			if !(isNil "_object") then {
				_source = _object;
			};
		};	
		
		//waypoints
		_wps = [_source] + [_target];
	};

	if isNil("_hoverHeight") then {
		_handler = [_object,_wps,_speed,_a] spawn BIS_animateMoveSmooth;
	} else {
		_handler = [_object,_wps,_speed,_a,_hoverHeight] spawn BIS_animateMoveSmooth;
	};
	
	_object setVariable ["BIS_MainAnim_Spawn",_handler];
};

//--------------------------------------------------------------------------------------------------
// AIRPLANE/CHOPPER NAVIGATION CIRCLES
//--------------------------------------------------------------------------------------------------

//BIS_WP_Path1_1 spawn BIS_SelectCircle;
BIS_activateCheckpointCircle = {
	private["_r","_g","_b","_a","_tex","_i","_circle"];
	
	//BIS_WP_Path1_1 getVariable "Circle" setObjectTexture [0,"#(argb,8,8,3)color(0.5,1.0,1.0,0.5,ca)"];
	//BIS_WP_Path1_1 getVariable "Circle" setObjectTexture [0,"#(argb,8,8,3)color(1.0,0.5,0.5,0.5,ca)"];
	
	//set the objective
	BIS_Objective = _this;

	if (isNil{_this getVariable "Circle"}) then {
		_circle = _this;
	} else {
		_circle = _this getVariable "Circle";
	};

	//change to red
	for "_i" from 0 to 50 do {
		
		_r = 0.5 + _i/100;
		_g = 1.0 - _i/100;
		_b = 1.0 - _i/100;
		_a = 0.5;
		
		_tex = format["#(argb,8,8,3)color(%1,%2,%3,%4,ca)",_r,_g,_b,_a];
		
		_circle setObjectTexture [0,_tex];
		
		sleep 0.05;		
	};
	
	//pulse
	_i = 0;
	while {BIS_Objective == _this} do {
		_i = _i + 10;
		
		if (_i >= 360) then {
			_i = _i - 360;
		};
		
		_a = 0.5 + ((sin _i) * 0.25);
		
		_tex = format["#(argb,8,8,3)color(1.0,0.5,0.5,%1,ca)",_a];
		_circle setObjectTexture [0,_tex];		
		
		sleep 0.05;
	};
	
	//fade-out
	while {_a > 0} do {
		_a = _a - 0.05;
		
		if (_a < 0) then {
			_a = 0;
		};
		
		_tex = format["#(argb,8,8,3)color(1.0,0.5,0.5,%1,ca)",_a];
		_circle setObjectTexture [0,_tex];		
		
		sleep 0.05;		
	};
};

BIS_fadeInCheckpointCircle = {
	private["_a","_tex","_i","_circle"];
	
	if (isNil{_this getVariable "Circle"}) then {
		_circle = _this;
	} else {
		_circle = _this getVariable "Circle";
	};

	//change to red
	for "_i" from 0 to 100 do {
		
		_a = _i/200;
		
		_tex = format["#(argb,8,8,3)color(0.5,1.0,1.0,%1,ca)",_a];
		
		_circle setObjectTexture [0,_tex];
		
		sleep 0.05;		
	};	
};

BIS_fadeInCheckpointCircleFast = {
	private["_a","_tex","_i","_circle"];
	
	if (isNil{_this getVariable "Circle"}) then {
		_circle = _this;
	} else {
		_circle = _this getVariable "Circle";
	};

	//change to red
	for "_i" from 0 to 25 do {
		
		_a = _i/50;
		
		_tex = format["#(argb,8,8,3)color(0.5,1.0,1.0,%1,ca)",_a];
		
		_circle setObjectTexture [0,_tex];
		
		sleep 0.05;		
	};	
};