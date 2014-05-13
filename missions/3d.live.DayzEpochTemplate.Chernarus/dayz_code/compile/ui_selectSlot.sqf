private ["_control","_button","_parent","_group","_pos","_item","_conf","_name","_cfgActions","_numActions","_height","_menu","_config","_type","_script","_outputOriented","_compile","_array","_outputClass","_outputType"];
disableSerialization;
_control 	= _this select 0;
_button 	= _this select 1;
_parent 	= findDisplay 106;

if (_button == 1) then {
	_group = _parent displayCtrl 6902;
	_pos = ctrlPosition _group;
	_pos set [0,((_this select 2) + 0.48)];
	_pos set [1,((_this select 3) + 0.07)];
	_item = gearSlotData _control;
	_conf = configFile >> "cfgMagazines" >> _item;
	if (!isClass _conf) then {_conf = configFile >> "cfgWeapons" >> _item;};
	_name = getText(_conf >> "displayName");
	_cfgActions = _conf >> "ItemActions";
	_numActions = (count _cfgActions);
	_height = 0;
	if (_item == "ItemToolbox") then {
		_menu = _parent displayCtrl (1600 + 2);
		_menu ctrlShow true;
		_type = "Deploy Bicycle";
		_script = "custom\deploy\deploy_bike.sqf";
		_height = _height + (0.025 * safezoneH);
		_compile = format["_id = '%2' execVM '%1';closeDialog 0;",_script,_item];
		uiNamespace setVariable ['uiControl', _control];
		_menu ctrlSetText format[_type,_name];
		_menu ctrlSetTextColor [1,0,0,1];
		_menu ctrlSetEventHandler ["ButtonClick",_compile];
		
		_menu = _parent displayCtrl (1600 + 3);
		_menu ctrlShow true;
		_type = "Deploy Motorcycle";
		_script = "custom\deploy\deploy_moto.sqf";
		_height = _height + (0.025 * safezoneH);
		_compile = format["_id = '%2' execVM '%1';closeDialog 0;",_script,_item];
		uiNamespace setVariable ['uiControl', _control];
		_menu ctrlSetText format[_type,_name];
		_menu ctrlSetTextColor [1,0,0,1];
		_menu ctrlSetEventHandler ["ButtonClick",_compile];
		
		_menu = _parent displayCtrl (1600 + 4);
		_menu ctrlShow true;
		_type = "Deploy Gyro Copter";
		_script = "custom\deploy\deploy_copter.sqf";
		_height = _height + (0.025 * safezoneH);
		_compile = format["_id = '%2' execVM '%1';closeDialog 0;",_script,_item];
		uiNamespace setVariable ['uiControl', _control];
		_menu ctrlSetText format[_type,_name];
		_menu ctrlSetTextColor [1,0,0,1];
		_menu ctrlSetEventHandler ["ButtonClick",_compile];

		_menu = _parent displayCtrl (1600 + 5);
		_menu ctrlShow true;
		_type = "Deploy Gyro Plane";
		_script = "custom\deploy\deploy_plane.sqf";
		_height = _height + (0.025 * safezoneH);
		_compile = format["_id = '%2' execVM '%1';closeDialog 0;",_script,_item];
		uiNamespace setVariable ['uiControl', _control];
		_menu ctrlSetText format[_type,_name];
		_menu ctrlSetTextColor [1,0,0,1];
		_menu ctrlSetEventHandler ["ButtonClick",_compile];

		_menu = _parent displayCtrl (1600 + 6);
		_menu ctrlShow true;
		_type = "Deploy Static Gun";
		_script = "custom\deploy\deploy_gun.sqf";
		_height = _height + (0.025 * safezoneH);
		_compile = format["_id = '%2' execVM '%1';closeDialog 0;",_script,_item];
		uiNamespace setVariable ['uiControl', _control];
		_menu ctrlSetText format[_type,_name];
		_menu ctrlSetTextColor [1,0,0,1];
		_menu ctrlSetEventHandler ["ButtonClick",_compile];
	};
	for "_i" from 0 to (_numActions - 1) do 
	{
		_menu = _parent displayCtrl (1600 + _i);
		_menu ctrlShow true;
		_config = (_cfgActions select _i);
		_type = getText	(_config >> "text");
		_script = getText	(_config >> "script");
		_outputOriented = 	getNumber	(_config >> "outputOriented") == 1;
		_height = _height + (0.025 * safezoneH);
		_compile =  format["_id = '%2' %1;",_script,_item];
		uiNamespace setVariable ['uiControl', _control];
		if (_outputOriented) then {
			_array = getArray	(_config >> "output");
			_outputClass = _array select 0;
			_outputType = _array select 1;
			_name = getText (configFile >> _outputType >> _outputClass >> "displayName");
			_compile = format["_id = ['%2',%3] %1;",_script,_item,_array];
		};
		_menu ctrlSetText format[_type,_name];
		_menu ctrlSetTextColor [1,0.25,0.25,1];
		_menu ctrlSetEventHandler ["ButtonClick",_compile];
	};
	/*
	 // Weapon Attachements script
	 // Also in description.ext
		// Add extra context menus
		_erc_cfgActions = (missionConfigFile >> "OWS" >> _item);
		_erc_numActions = (count _erc_cfgActions);
		if (isClass _erc_cfgActions) then {
			for "_j" from 0 to (_erc_numActions - 1) do 
				{
				_menu =  _parent displayCtrl (1600 + _j + _numActions);
				_menu ctrlShow true;
				_config =  (_erc_cfgActions select _j);
				_text =  getText (_config >> "text");
				_script =  getText (_config >> "script");
				_height = _height + (0.025 * safezoneH);
				uiNamespace setVariable ['uiControl', _control];
				_menu ctrlSetText _text;
				_menu ctrlSetEventHandler ["ButtonClick",_script];
			};
		};
	*/	
	_pos set [3,_height];
	_group ctrlShow true;
	ctrlSetFocus _group;
	_group ctrlSetPosition _pos;
	_group ctrlCommit 0;
};