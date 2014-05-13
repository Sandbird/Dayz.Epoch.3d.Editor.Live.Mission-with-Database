scriptName "Functions\misc\fn_inTrigger.sqf";
/*
	File: inTrigger.sqf
	Author: Karel Moricky

	Description:
	Detects whether is position within trigger area.

	Parameter(s):
		_this select 0: Trigger
		_this select 1: Position
		_this select 2: OPTIONAL - scalar result (distance from border)

	Returns:
	Boolean (true when position is in area, false if not).
*/
private ["_trig","_object","_posx","_posy","_tarea","_tx","_ty","_tdir","_tshape","_in"];

_trig = _this select 0;
_position = _this select 1;
_scalarresult = if (count _this > 2) then {_this select 2} else {false};

_posx = position _trig select 0;
_posy = position _trig select 1;
_tarea = triggerarea _trig;
_tx = _tarea select 0; 
_ty = _tarea select 1;
_tdir = _tarea select 2;
_tshape = _tarea select 3;
_in = false;

if (_tshape) then {

	//--- RECTANGLE
	_difx = (_position select 0) - _posx;
	_dify = (_position select 1) - _posy;
	_dir = atan (_difx / _dify);
	if (_dify < 0) then {_dir = _dir + 180};
	_relativedir = _tdir - _dir;
	_adis = abs (_tx / cos (90 - _relativedir));
	_bdis = abs (_ty / cos _relativedir);
	_borderdis = _adis min _bdis;
	_positiondis = _position distance _trig;

	_in = if (_scalarresult) then {
		_positiondis - _borderdis;
	} else {
		if (_positiondis < _borderdis) then {true} else {false};
	};

} else {
	//--- ELLIPSE
	_e = sqrt(_tx^2 - _ty^2);
	_posF1 = [_posx + (sin (_tdir+90) * _e),_posy + (cos (_tdir+90) * _e)];
	_posF2 = [_posx - (sin (_tdir+90) * _e),_posy - (cos (_tdir+90) * _e)];
	_total = 2 * _tx;

	_dis1 = _position distance _posF1;
	_dis2 = _position distance _posF2;
	_in = if (_scalarresult) then {
		(_dis1+_dis2) - _total;
	} else {
		if (_dis1+_dis2 < _total) then {true} else {false};
	};
};

_in