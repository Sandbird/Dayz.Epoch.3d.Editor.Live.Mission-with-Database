private ["_class","_uid","_charID","_object","_worldspace","_key","_code","_fuel","_allowed"];
//[dayz_characterID,_tent,[_dir,_location],"TentStorage"]
_charID = _this select 0;
_object = _this select 1;
_worldspace = _this select 2;
_class = _this select 3;
  
_allowed = [_object, "Server"] call check_publishobject;
if (!_allowed) exitWith { deleteVehicle _object; };

//diag_log ("PUBLISH: Attempt " + str(_object));

//get UID
_uid = _worldspace call dayz_objectUID2;

//Send request
//
//_key = format["CHILD:308:%1:%2:%3:%4:%5:%6:%7:%8:%9:",dayZ_instance, _class, 0 , _charID, _worldspace, [], [], 0,_uid];
	_key = format["insert into object_data (ObjectUID, Instance, Classname, CharacterID, Worldspace, Inventory, Hitpoints, Fuel, Damage) values ('%1','%2','%3','%4','%5','%6','%7','%8','%9')",_uid,dayZ_instance,_class,_charID,_worldspace,'[]','[]',0,0];
	diag_log ("HIVE: WRITE: "+ str(_key)); 
	_key call server_hiveWrite;

_object setVariable ["lastUpdate",time];
_object setVariable ["ObjectUID", _uid,true];
// _object setVariable ["characterID",_charID,true];

if (DZE_GodModeBase) then {
	_object addEventHandler ["HandleDamage", {false}];
}else{
	_object addMPEventHandler ["MPKilled",{_this call object_handleServerKilled;}];
};
// Test disabling simulation server side on buildables only.
_object enableSimulation false;

PVDZE_serverObjectMonitor set [count PVDZE_serverObjectMonitor,_object];

//diag_log ("PUBLISH: Created " + (_class) + " with ID " + _uid);
