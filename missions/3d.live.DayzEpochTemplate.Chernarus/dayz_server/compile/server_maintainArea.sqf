/* Maintain Area - written by Skaronator */
private ["_player","_ObjArray","_uniqueID","_objects","_key"];
_player = _this select 0;
_option = _this select 1;
/*
1: PVDZE_maintainArea = [player,1,_target];
2: PVDZE_maintainArea = [player,2,_object];
*/
_targetObj = _this select 2;
if (_option == 1) then {
	DZE_maintainClasses = DZE_maintainClasses;
	_objects = nearestObjects [_targetObj, DZE_maintainClasses, DZE_maintainRange];
	{
		//diag_log format["#######MAINTAIN _x: %1 has damage %2", _x, (damage _x)];
		if (damage _x >= DZE_DamageBeforeMaint) then {
			_objectID = _x getVariable ["ObjectID","0"];
			if (_objectID == "0") then {
				_objectUID = _x getVariable ["ObjectUID","0"];
				if (_objectUID != "0") then {
					//diag_log format["######## option 1 objectID is 0, x: %1",_x];
					_x setDamage 0;
					//_key = format["CHILD:397:%1:", _objectUID]; // use UID if not "0" and ID is "0"
					_key = format["UPDATE `object_data` SET `Datestamp` = CURRENT_TIMESTAMP, `Damage` = '0' WHERE `ObjectUID` = '%1' AND `Instance` = '%2'", _objectUID, dayZ_instance]; // use UID if not "0" and ID is "0"
					_key call server_hiveWrite;
				};
			} else {
				//diag_log format["######## option 1, objectID is NOT 0, x: %1",_x];
				_x setDamage 0;
				//_key = format["CHILD:396:%1:", _objectID]; //Use ID instead of UID because ID is shorter
				_key = format["UPDATE `object_data` SET `Datestamp` = CURRENT_TIMESTAMP, `Damage` = '0' WHERE `ObjectID` = '%1' AND `Instance` = '%2'", _objectID, dayZ_instance]; // use UID if not "0" and ID is "0"
				_key call server_hiveWrite;
			};
		};
	} forEach _objects;
	//diag_log format["#######MAINTAIN Option 1 fucking objects %1", _objects];

	//diag_log format ["MAINTAIN AREA BY %1 - %2 Objects at %3", name _player, count _objects, position _player];
};
if (_option == 2) then {
	if (damage _targetObj >= DZE_DamageBeforeMaint) then {
		_objectID = _targetObj getVariable ["ObjectID","0"];
		if (_objectID == "0") then {
			_objectUID = _targetObj getVariable ["ObjectUID","0"];
			if (_objectUID != "0") then {
				_targetObj setDamage 0;
				//_key = format["CHILD:397:%1:", _objectUID]; // use UID if not "0" and ID is "0"
				_key = format["UPDATE `object_data` SET `Datestamp` = CURRENT_TIMESTAMP, `Damage` = '0' WHERE `ObjectUID` = '%1' AND `Instance` = '%2'", _objectUID, dayZ_instance]; // use UID if not "0" and ID is "0"
				_key call server_hiveWrite;
			};
		} else {
			_targetObj setDamage 0;
			//_key = format["CHILD:396:%1:", _objectID]; //Use ID instead of UID because ID is shorter
				_key = format["UPDATE `object_data` SET `Datestamp` = CURRENT_TIMESTAMP, `Damage` = '0' WHERE `ObjectID` = '%1' AND `Instance` = '%2'", _objectID, dayZ_instance]; // use UID if not "0" and ID is "0"
				_key call server_hiveWrite;
			
		};
	};
};