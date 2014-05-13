/*
[_objectID,_objectUID] call server_deleteObj;
*/
private["_id","_uid","_key"];
_id 	= _this select 0;
_uid 	= _this select 1;
_activatingPlayer 	= _this select 2;

if (isServer) then {
	//remove from database
	if (parseNumber _id > 0) then {
		//Send request
		//_key = format["CHILD:304:%1:",_id];
		_key = format["DELETE FROM object_data WHERE `ObjectID` = '%1' AND `Instance` = '%2'",_id, dayZ_instance];
		_key call server_hiveWrite;
		diag_log format["DELETE: %1 Deleted by ID: %2",_activatingPlayer,_id];
	} else  {
		//Send request
		//_key = format["CHILD:310:%1:",_uid];
		_key = format["DELETE FROM object_data WHERE `ObjectUID` = '%1' AND `Instance` = '%2'",_uid, dayZ_instance];
		_key call server_hiveWrite;
		diag_log format["DELETE: %1 Deleted by UID: %2",_activatingPlayer,_uid];
	};
};