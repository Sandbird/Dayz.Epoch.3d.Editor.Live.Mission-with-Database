//--------------------------------------------------------------------------------------------------
// TARGET ICON
//--------------------------------------------------------------------------------------------------

//OBJECT call BIS_targetIconInit;
//[OBJECT,POSITION,YOFFSET,LABEL] call BIS_targetIconInit;
BIS_targetIconInit = {
	private["_target","_color","_grp","_iconPosition","_iconOffset","_iconOffsetAdj","_label","_icon","_color","_holder"];

	//enable group icons
	setGroupIconsVisible[false,true];

	//defaults
	_iconPosition = "CENTER";
	_iconOffset = 0;
	_label = "";
	_icon = "selector_selectedEnemy";
	_color = [1,0,0,0];
	
	if (typeName _this != "ARRAY") then {
		_target = _this;
	} else {
		_target = _this select 0;

		if (count _this > 0) then {
			if !(isNil{_this select 1}) then {
				_iconPosition = _this select 1;
			};
		};

		if (count _this > 1) then {
			if !(isNil{_this select 2}) then {
				_iconOffset = _this select 2;
			};
		};

		if (count _this > 2) then {
			if !(isNil{_this select 3}) then {
				_label = _this select 3;
			};
		};
		
		if (count _this > 3) then {
			if !(isNil{_this select 4}) then {
				_icon = _this select 4;
			};
		};
		
		if (count _this > 4) then {		
			if !(isNil{_this select 5}) then {
				_color = _this select 5;
				
				//if alpha is not defined, set it to 0
				if (count _color == 3) then {
					_color = _color + [0];
				};
			};
		};
	};

	_iconOffsetAdj = switch (typeOf _target) do {
		case "V3S_TK_GUE_EP1": {3.5};
		case "TargetEpopup": {1.7};
		case "TargetE_EP1": {1.6};
		
		//wooden tank
		case "TargetFakeTank_Lockable_EP1": {2.5};
		case "TargetFakeTank_EP1": {2.5};
		
		//placeholder
		case "Training_target_EP1": {0};
			
		default 
		{
			["[BIS_targetIconInit]","target 'classname' (" + (typeOf _target) + ") not defined!"] call BIS_debugLog;
			0
		};
	};
	
	if (_iconPosition == "CENTER") then {
		_iconOffset = _iconOffset + (_iconOffsetAdj/2);
	} else {
		_iconOffset = _iconOffset + _iconOffsetAdj;
	};
	
	if (side _target == west) then {
		_grp = createGroup west;
		_holder = _grp createUnit ["US_Soldier_EP1",getPos _target,[],0,"none"];		
	} else {
		_eastside = createCenter east;
		 east setFriend [west, 0];
		
		_grp = createGroup east;
		_holder = _grp createUnit ["TK_INS_Soldier_4_EP1",getPos _target,[],0,"none"];			
	};

	_holder setPosASL [getPosASL _target select 0,getPosASL _target select 1,(getPosASL _target select 2) - 4.3 + _iconOffset];
	_holder enableSimulation false;
	_holder setvariable ["bis_noccoreconversations",true];

	hideObject _holder;

	//["_target",_target] call BIS_debugLog;
	//["_iconPosition",_iconPosition] call BIS_debugLog;
	//["_iconOffset",_iconOffset] call BIS_debugLog;
	//["_label",_label] call BIS_debugLog;
	//["_icon",_icon] call BIS_debugLog;
	//["_color",_color] call BIS_debugLog;

	
	_grp addGroupIcon [_icon,[0,0]];
	_grp setGroupIconParams [_color,_label,1.2,true];
	
	_target setVariable ["icon",_grp];
	_target setVariable ["holder",_holder];
	_target setVariable ["offset",- 4.3 + _iconOffset];
	_target setVariable ["icon_state","hidden"];
};

BIS_targetIconShow = {

	if (isNil {_this}) exitWith {
		["[BIS_targetIconShow]","target not initialized!"] call BIS_debugLog;
	};
	
	if (isNil {_this getVariable "icon"}) exitWith {
		["[BIS_targetIconShow]","icon not initialized!"] call BIS_debugLog;
	};
	
	//stop if already showing
	if (_this getVariable "icon_state" == "showing" || _this getVariable "icon_state" == "shown") exitWith {
		//["[BIS_targetIconShow]","icon already shown or showing!"] call BIS_debugLog;
	};
	
	//["Showing an icon!"] call BIS_debugLog;
	
	//set the status
	_this setVariable ["icon_state","showing"];
	
	private["_icon","_alpha","_i","_params"];
	private["_color","_text","_scale","_visible"];
	
	_icon = _this getVariable "icon";
	
	//[color,text,scale,visible]
	_params = getGroupIconParams _icon;
	_color 		= _params select 0;
	_text 		= _params select 1;
	_scale 		= _params select 2;
	//_visible 	= _params select 3;
	_visible = true;

	_r = _color select 0;
	_g = _color select 1;
	_b = _color select 2;
	_a = _color select 3;

	while{(_a < 1) && (_this getVariable "icon_state" == "showing")} do {
	
		_a = _a + 0.05;
		
		if(_a > 1) then {_a = 1};
		
		_color = [_r,_g,_b,_a];

		//["---------------------------------"] call BIS_debugLog;
		//["_color",_color] call BIS_debugLog;
		//["_text",_text] call BIS_debugLog;
		//["_scale",_scale] call BIS_debugLog;
		//["_visible",_visible] call BIS_debugLog;
		
		//update text param during fade-in
		_text = (getGroupIconParams _icon) select 1;
		_icon setGroupIconParams [_color,_text,_scale,_visible];		
		
		sleep 0.05;		
	};

	//set final state	
	if (_this getVariable "icon_state" == "showing") then {
		_this setVariable ["icon_state","shown"];
	};
};

BIS_targetIconHide = {
	
	if (isNil {_this}) exitWith {
		["[BIS_targetIconHide]","target not initialized!"] call BIS_debugLog;
	};
	
	if (isNil {_this getVariable "icon"}) exitWith {
		["[BIS_targetIconHide]","icon not initialized!"] call BIS_debugLog;
	};	
	
	//stop if already hidden or hiding
	if (_this getVariable "icon_state" == "hidden" || _this getVariable "icon_state" == "hiding") exitWith {
		//["[BIS_targetIconHide]","icon already hidden or hiding!"] call BIS_debugLog;
	};	

	//["Hiding an icon!"] call BIS_debugLog;

	//set the status
	_this setVariable ["icon_state","hiding"];
	
	private["_icon","_alpha","_i","_params"];
	private["_color","_text","_scale","_visible"];
	
	_icon = _this getVariable "icon";
	
	//[color,text,scale,visible]
	_params = getGroupIconParams _icon;
	_color 		= _params select 0;
	_text 		= _params select 1;
	_scale 		= _params select 2;
	//_visible 	= _params select 3;
	_visible = true;

	_r = _color select 0;
	_g = _color select 1;
	_b = _color select 2;
	_a = _color select 3;

	while{(_a > 0)  && (_this getVariable "icon_state" == "hiding")} do {
		
		_a = _a - 0.2;
		
		if(_a < 0) then {_a = 0};
		
		_color = [_r,_g,_b,_a];

		//["---------------------------------"] call BIS_debugLog;
		//["_color",_color] call BIS_debugLog;
		//["_text",_text] call BIS_debugLog;
		//["_scale",_scale] call BIS_debugLog;
		//["_visible",_visible] call BIS_debugLog;
		
		//update text param during fade-out
		_text = (getGroupIconParams _icon) select 1;
		
		_icon setGroupIconParams [_color,_text,_scale,_visible];		

		sleep 0.05;		
	};
	
	//set final state
	if (_this getVariable "icon_state" == "hiding") then {
		_this setVariable ["icon_state","hidden"];
		_icon setGroupIconParams [_color,_text,_scale,false];
	};	
};

BIS_targetIconUpdatePos = {
	private ["_target","_holder","_posX","_posY","_posZ","_offset"];
	
	_target = _this;

	_holder = _target getVariable "holder";
	_offset = _target getVariable "offset";
	
	_posX = getPosASL _target select 0;
	_posY = getPosASL _target select 1;
	_posZ = (getPosASL _target select 2) + _offset;
	
	_holder setPosASL [_posX,_posY,_posZ];
};

BIS_targetIconUpdateText = {
	private["_target","_text","_params","_icon"];
	
	_target = _this select 0;
	_text = _this select 1;
	
	_icon = _target getVariable "icon";
	
	_params = getGroupIconParams _icon;
	_icon setGroupIconParams [_params select 0,_text,_params select 2,_params select 3];
};

BIS_targetIconUpdateColor = {
	private["_target","_color","_params","_icon","_alpha"];
	
	_target = _this select 0;
	_color = _this select 1;
	
	_icon = _target getVariable "icon";
	_params = getGroupIconParams _icon;
	
	_alpha = (_params select 0) select 3;
	_color = _color + [_alpha];
	
	_icon setGroupIconParams [_color,_params select 1,_params select 2,_params select 3];
};