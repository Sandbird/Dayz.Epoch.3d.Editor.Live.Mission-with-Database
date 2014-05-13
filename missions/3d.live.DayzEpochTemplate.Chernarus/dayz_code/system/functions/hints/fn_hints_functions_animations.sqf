BIS_animateMoveSmooth =
{
	private["_sleep","_object","_posStart","_posEnd","_deltax","_deltay","_deltaz","_distance","_tmax","_a","_vmax","_t","_ssaved","_animList","_animPhase","_progress","_posx","_posy","_posz","_anim","_taccel","_saccel","_sconst","_tconst"];
	private["_wps","_positions","_distancesStart","_distancesPrev","_refWP","_ghostBall","_time","_hoverHeight","_dir"];
	
	_sleep = 0.01;					//delay between each anim frame, lower values = smoother animation

	_object = _this select 0;
	_wps = _this select 1;			//array of all animation WPs

	//hover height
	if (count _this > 4) then {
		_hoverHeight = _this select 4;
	};

	//----------------------------------------------------------------------------------------------
	//positioning & animating along waypoints ------------------------------------------------------
	
	_positions = [];		//array of all WP positions
	_distancesStart = [];	//array of WPs distances from the beginning of the animation
	_distancesPrev = [];	//array of WPs distances from the previous WP
	_refWP = _wps select 0;

	private["_d","_dTotal","_tmpPos"];
	_d = 0;
	_dTotal = 0;
	
	{
		//storing position of each WP
		//it's WP object
		if (typeName(_x) == "OBJECT") then {
			_tmpPos = getPosASL _x;
			if (_x == player) then {
				_tmpPos = [_tmpPos select 0, _tmpPos select 1, (_tmpPos select 2) + 0.8]; 
			};
		//it's position			
		} else {
			_tmpPos = _x;
		};
		_positions = _positions + [_tmpPos];


		//total from the start
		_d = _x distance _refWP;
		_dTotal = _dTotal + _d;
		_distancesStart = _distancesStart + [_dTotal];

		
		//from previous WP
		_distancesPrev = _distancesPrev + [_x distance _refWP];
		_refWP = _x;		
		
	} forEach _wps;
	
	//current WPs
	_wpStart = 0;
	_wpEnd = _wpStart + 1;

	//count positions
	_posStart = _positions select _wpStart;
	_posEnd = _positions select _wpEnd;	
	
	//count delta x,y,z
	_deltax = (_posEnd select 0) - (_posStart select 0);
	_deltay = (_posEnd select 1) - (_posStart select 1);
	_deltaz = (_posEnd select 2) - (_posStart select 2);	

	_dir =  [_posStart,_posEnd] call BIS_fnc_dirTo;
	_object setDir (_dir-180);	

	//display object at start position
	if isNil("_hoverHeight") then {
		_object setPosASL (_positions select 0);
	} else {
		_object setPos [(_positions select 0) select 0, (_positions select 0) select 1,_hoverHeight];
	};
	//----------------------------------------------------------------------------------------------
	//----------------------------------------------------------------------------------------------


	//_vmax
	if (count(_this) > 2) then {
		_vmax = _this select 2;
	} else {
		_vmax = 15;
	};

	//_a
	if (count(_this) > 3) then {
		_a = _this select 3;
	} else {
		_a = 5;
	};

	//acceleration path
	_taccel = _vmax/_a;
	_saccel = 1/2 * _a * _taccel * _taccel;

	//distance (of whole animation)
	_distance = _distancesStart select (count(_distancesStart) - 1);
	//["_distance",_distance] call BIS_debugLog;
	
	//distance too short
	if (2*_saccel > _distance) then {
		//["DISTANCE IS TOO SHORT"] call BIS_debugLog;
		//["_saccel (raw)",_saccel] call BIS_debugLog;
		//["_taccel (raw)",_taccel] call BIS_debugLog;		
		
		_saccel = _distance/2;
		_taccel = sqrt(_distance/_a);

		//["_saccel (fixed)",_saccel] call BIS_debugLog;
		//["_taccel (fixed)",_taccel] call BIS_debugLog;		

		//distance is too short -> object wont reach max speed
		_vmax = _a * _taccel;
		
		//there is no constant speed part in middle
		_sconst = 0;
		_tconst = 0;
	
	//distance is fine
	} else {
		//["DISTANCE IS FINE"] call BIS_debugLog;
		
		_sconst = _distance - 2*_saccel;
		_tconst = _sconst/_vmax;
	};

	//total time
	_ttotal = 2*_taccel + _tconst;
	
	_t = 0;
	_tmax = _taccel;
	_ssaved = 0;

	_animList = [];
	_animPhase = 0;
	_animList = _animList + [{1/2 * _a * _t * _t}];
	_animList = _animList + [{_vmax * _t}];
	_animList = _animList + [{_vmax * _t - 1/2 * _a * _t * _t}];	

	_time = time;
	
	private["_sleepTime","_tover"];
	
	_tover = 0;

	while {_animPhase < count(_animList)} do {
		_t = _t + _sleep;
		
		_sleepTime = time;

		sleep _sleep;

		//real sleep time calculations
		_sleepTime = time - _sleepTime;
		_t = _t - _sleep + _sleepTime;
		if (_t > _tmax) then {
			_tover = _t - _tmax;
			_t = _tmax;
		};
		
		_anim = _animList select _animPhase;
		_s = call _anim;

		//------------------------------------------------------------------------------------------
		//positioning & animating along waypoints --------------------------------------------------
		_movedFromStart = _ssaved + _s;
		
		//searching for acctual _wpStart & _wpEnd
		while {_movedFromStart > _distancesStart select _wpEnd} do {
			_wpStart = _wpStart + 1;
			_wpEnd = _wpStart + 1;
			
			//["Current waypoints:",format["%1 -> %2",_wpStart,_wpEnd]] call BIS_debugLog;

			//count positions
			_posStart = _positions select _wpStart;
			_posEnd = _positions select _wpEnd;	
			
			//count delta x,y,z
			_deltax = (_posEnd select 0) - (_posStart select 0);
			_deltay = (_posEnd select 1) - (_posStart select 1);
			_deltaz = (_posEnd select 2) - (_posStart select 2);
			
			//set direction
			_dir =  [_posStart,_posEnd] call BIS_fnc_dirTo;
			_object setDir (_dir-180);			
		};
		
		//progress part -> object positioning
		_movedBetweenWPs = _movedFromStart - (_distancesStart select _wpStart);
		_progress = _movedBetweenWPs / (_distancesPrev select _wpEnd);
		if (_progress > 1) then {
			_progress = 1;
		};
		
		_posx = (_posStart select 0) + _deltax * _progress;
		_posy = (_posStart select 1) + _deltay * _progress;
		_posz = (_posStart select 2) + _deltaz * _progress;
		
		if isNil("_hoverHeight") then {
			_object setPosASL[_posx,_posy,_posz];
		} else {
			_object setPos[_posx,_posy,_hoverHeight];
		};
		
	
		//["_movedFromStart",_movedFromStart] call BIS_debugLog;
		//["_movedBetweenWPs",_movedBetweenWPs] call BIS_debugLog;
		//["_progress",_progress] call BIS_debugLog;
		//["_posx",_posx] call BIS_debugLog;
		
		//create a ghost-ball
		/*
		_ghostBall = "sign_sphere25cm_ep1" createVehicle [0,0,0];
		_ghostBall setObjectTexture [0,"#(argb,8,8,3)color(0.8,0.5,0.5,0.5,ca)"];
		_ghostBall setPosASL[_posx,_posy,_posz];
		*/
		
		
		//------------------------------------------------------------------------------------------
	
		
		if (_t == _tmax) then {
			_animPhase = _animPhase + 1;

			//[format["Animation ID%1 finished at distance %2 (took %3 secs)!",_animPhase-1,_ssaved + _s,_tmax]] call BIS_debugLog;
			
			//skip the middle part (animationPhase 1) if its time == 0
			if (_animPhase == 1 && _tconst == 0) then {
				_animPhase = _animPhase + 1;
				//["Animation ID1 skipped!"] call BIS_debugLog;
			};			
			
			if (_animPhase == 1) then {
				_tmax = _tconst;
			} else {
				_tmax = _taccel;
			};
			
			//_t = 0;
			_t = _tover;
			_ssaved = _ssaved + _s;
		};	
	};
	
	private["_pos"];
	
	_pos = _positions select (count(_positions) - 1);
	
	if isNil("_hoverHeight") then {
		_object setPosASL _pos;
	} else {
		_object setPos [_pos select 0, _pos select 1, _hoverHeight];
	};	
};


//_sqf = this spawn {_i=0;while {true} do {_i=_i+2;if(_i>360)then{_i=_i-360;};_this setDir _i;sleep 0.01;};};
BIS_animateRotate =
{
	private["_object","_dir","_i"];
	
	_object = _this select 0;
	_dir = getDir(_object);
	
	_i = _dir;
	
	while {true} do {
		_i = _i + 2;
		if (_i > 360) then {_i = _i-360;};
		_object setDir _i;
		sleep 0.02;
	};
};


BIS_animateUpDown  =
{
	private["_object","_s","_t","_v","_a","_pos","_sleep","_smax","_tmax","_vmax","_startPos"];
	
	_sleep = 0.02;	//delay between each anim frame, lower values = smoother animation
	
	_object = _this select 0;
	
	_smax = _this select 1;			//animation length [m]
	_tmax = _this select 2;			//animation time [sec]
	
	_a = 2*_smax/(_tmax*_tmax);		//_acceleration
	_vmax = _a * _tmax;				//animation speed [m/sec]

	_t = 0;
	
	_pos = getPosASL(_object);
	_startPos = _pos;
	
	_animList = [];
	_animPhase = 0;

	//move-up and decelerate
	_animList = _animList + [{+1 * (_vmax * _t - 1/2 * _a * _t * _t)}];

	//move-down and accelerate
	_animList = _animList + [{-1 * (1/2 * _a * _t * _t)}];

	//move-down and decelerate
	_animList = _animList + [{-1 * (_vmax * _t - 1/2 * _a * _t * _t)}];	
	
	//move-up and accelerate
	_animList = _animList + [{+1 * (1/2 * _a * _t * _t)}];
	
	while {true} do {
		_t = _t + _sleep;
		
		if (_t > _tmax) then {
			_t = _tmax;
		};
		sleep _sleep;

		_anim = _animList select _animPhase;
		_s = call _anim;

		_object setPosASL[_pos select 0,_pos select 1,(_pos select 2) + _s];
		
		if (_t == _tmax) then {
			_animPhase = _animPhase + 1;
			_t = 0;

			if (_animPhase == count(_animList)) then {
				_animPhase = 0;
			};

			_pos = [_pos select 0,_pos select 1,(_pos select 2) + _s];
		};	
	};

	//reposition bact to start pos
	_object setPosASL _startPos;
};