private ["_missing","_missingQty","_proceed","_itemIn","_countIn","_qty","_num_removed","_removed","_removed_total","_tobe_removed_total","_obj","_objectID","_objectUID","_classname","_location","_dir","_objectCharacterID","_object","_temp_removed_array","_textMissing","_target","_objectClasses","_range","_objects","_requirements","_count","_cost","_itemText","_option"];

if (DZE_ActionInProgress) exitWith { cutText ["Maintenance already in progress." , "PLAIN DOWN"]; };
DZE_ActionInProgress = true;

player removeAction s_player_maintain_area;
s_player_maintain_area = 1;
player removeAction s_player_maintain_area_preview;
s_player_maintain_area_preview = 1;

_target = cursorTarget; // Plastic_Pole_EP1_DZ
_objectClasses = DZE_maintainClasses;
_range = DZE_maintainRange; // set the max range for the maintain area
_objects = nearestObjects [_target, _objectClasses, _range];
//diag_log format["#######MAINTAIN objects near that can be maintained: %1", _objects];

//filter to only those that have 10% damage
_objects_filtered = [];
{
		//diag_log format["######## Maintain %1 with damage: %2 and DZE_DamageBeforeMnt",_x, (damage _x), DZE_DamageBeforeMaint];
    if (damage _x >= DZE_DamageBeforeMaint) then {
        _objects_filtered set [count _objects_filtered, _x];
   };
} forEach _objects;
_objects = _objects_filtered;
//diag_log format["#######MAINTAIN objects filtered: %1", _objects];
// TODO dynamic requirements based on used building parts?
_count = count _objects;

if (_count == 0) exitWith {
	cutText [format[(localize "STR_EPOCH_ACTIONS_22"), _count], "PLAIN DOWN"];
	DZE_ActionInProgress = false;
	s_player_maintain_area = -1;
	s_player_maintain_area_preview = -1;
};

_requirements = [];
switch true do {
	case (_count <= 10):  {_requirements = [["ItemGoldBar10oz",1]]};
	case (_count <= 20):  {_requirements = [["ItemGoldBar10oz",2]]};
	case (_count <= 35):  {_requirements = [["ItemGoldBar10oz",3]]};
	case (_count <= 50):  {_requirements = [["ItemGoldBar10oz",4]]};
	case (_count <= 75):  {_requirements = [["ItemGoldBar10oz",6]]};
	case (_count <= 100): {_requirements = [["ItemBriefcase100oz",1]]};
	case (_count <= 175): {_requirements = [["ItemBriefcase100oz",2]]};
	case (_count <= 250): {_requirements = [["ItemBriefcase100oz",3]]};
	case (_count <= 325): {_requirements = [["ItemBriefcase100oz",4]]};
	case (_count <= 400): {_requirements = [["ItemBriefcase100oz",5]]};
	case (_count <= 475): {_requirements = [["ItemBriefcase100oz",6]]};
	case (_count <= 550): {_requirements = [["ItemBriefcase100oz",7]]};
	case (_count <= 625): {_requirements = [["ItemBriefcase100oz",8]]};
	case (_count > 700):  {_requirements = [["ItemBriefcase100oz",9]]};
};

_option = _this select 3;
//diag_log format["#######MAINTAIN _option: %1", _option];
switch _option do {
	case "maintain": {
		_missing = "";
		_missingQty = 0;
		_proceed = true;
		{
			_itemIn = _x select 0;
			_countIn = _x select 1;
			_qty = { (_x == _itemIn) || (configName(inheritsFrom(configFile >> "cfgMagazines" >> _x)) == _itemIn) } count magazines player;
			if (_qty < _countIn) exitWith { _missing = _itemIn; _missingQty = (_countIn - _qty); _proceed = false; };
		} forEach _requirements;
		//diag_log format["#######MAINTAIN _requirements: %1", _requirements];	
		if (_proceed) then {
			player playActionNow "Medic";
			[player,_range,true,(getPosATL player)] spawn player_alertZombies;

			_temp_removed_array = [];
			_removed_total = 0;
			_tobe_removed_total = 0;
			
			{
				_removed = 0;
				_itemIn = _x select 0;
				_countIn = _x select 1;
				_tobe_removed_total = _tobe_removed_total + _countIn;
				
				{					
					if ((_removed < _countIn) && ((_x == _itemIn) || configName(inheritsFrom(configFile >> "cfgMagazines" >> _x)) == _itemIn)) then {
						_num_removed = ([player,_x] call BIS_fnc_invRemove);
						_removed = _removed + _num_removed;
						_removed_total = _removed_total + _num_removed;
						if (_num_removed >= 1) then {
							_temp_removed_array set [count _temp_removed_array,_x];
						};
					};
				} forEach magazines player;
			} forEach _requirements;
			// all required items removed from player gear
			// Sandbird (based on 1.0.3.1...i think it was better)
			if (_tobe_removed_total == _removed_total) then {
				cutText [format[(localize "STR_EPOCH_ACTIONS_4"), _count], "PLAIN DOWN", 5];
				PVDZE_maintainArea = [player,1,_target];
				publicVariableServer "PVDZE_maintainArea";	
				[player,1,_target] spawn server_maintainArea;
			} else {
				{player addMagazine _x;} forEach _temp_removed_array;
				cutText [format[(localize "STR_EPOCH_ACTIONS_5"),_removed_total,_tobe_removed_total], "PLAIN DOWN"];
			};
		}  else {
			_textMissing = getText(configFile >> "CfgMagazines" >> _missing >> "displayName");
			cutText [format[(localize "STR_EPOCH_ACTIONS_6"), _missingQty, _textMissing], "PLAIN DOWN"];
		};
	};
	case "preview": {
		_cost = "";
		{
			_itemIn = _x select 0;
			_countIn = _x select 1;
			_itemText = getText(configFile >> "CfgMagazines" >> _itemIn >> "displayName");
			if (_cost != "") then {
				_cost = _cost + " and ";
			};
			_cost = _cost + (str(_countIn) + " of " + _itemText);
		} forEach _requirements;
		cutText [format["%1 building parts in range, maintenance would cost %2.", _count, _cost], "PLAIN DOWN"];
	};
};

DZE_ActionInProgress = false;
s_player_maintain_area = -1;
s_player_maintain_area_preview = -1;
