if (dayz_combat == 1) exitWith {
	_txt = "You can't pack vehicles while in combat.";
	cutText [_txt, "PLAIN DOWN"];
};
_obj = _this select 3;
if (((damage _obj) > 0.8) || !(canMove _obj)) exitWith {
	cutText ["This "+typeOf _obj+" is too damaged to pack.","PLAIN DOWN"];
};
_objPos = getPosATL _obj;
player removeAction s_player_packOBJ;
r_interrupt = false;
player playActionNow "Medic";
sleep 1;

_sfx = "repair";
[player,_sfx,0,false,5] call dayz_zombieSpeak;
sleep 1;

deleteVehicle _obj;
if (typeOf _obj == "Old_moto_TK_Civ_EP1") then {
	_result = [player,"PartGeneric"] call BIS_fnc_invAdd;
	_result = [player,"PartGeneric"] call BIS_fnc_invAdd;
	_result = [player,"PartGeneric"] call BIS_fnc_invAdd;
	_result = [player,"PartGeneric"] call BIS_fnc_invAdd;
	_result = [player,"PartEngine"] call BIS_fnc_invAdd;
	_result = [player,"ItemJerrycan"] call BIS_fnc_invAdd;
	_result = [player,"PartFueltank"] call BIS_fnc_invAdd;
	_result = [player,"PartWheel"] call BIS_fnc_invAdd;
	_result = [player,"PartWheel"] call BIS_fnc_invAdd;
	cutText ["You have packed your Motorcycle.\nMaterials have been added to your Inventory","PLAIN DOWN"];
	motors_DEPLOYED = motos_DEPLOYED - 1;
};
if (typeOf _obj == "Old_bike_TK_CIV_EP1") then {
	_result = [player,"PartGeneric"] call BIS_fnc_invAdd;
	_result = [player,"PartGeneric"] call BIS_fnc_invAdd;
	_result = [player,"PartWheel"] call BIS_fnc_invAdd;
	_result = [player,"PartWheel"] call BIS_fnc_invAdd;
	cutText ["You have packed your Bicycle.\nMaterials have been added to your Inventory","PLAIN DOWN"];
	bikes_DEPLOYED = bikes_DEPLOYED - 1;
};
if (typeOf _obj == "CSJ_GyroC") then {
	_result = [player,"ItemTanktrap"] call BIS_fnc_invAdd;
	_result = [player,"ItemTanktrap"] call BIS_fnc_invAdd;
	_result = [player,"PartGeneric"] call BIS_fnc_invAdd;
	_result = [player,"PartGeneric"] call BIS_fnc_invAdd;
	_result = [player,"ItemCompass"] call BIS_fnc_invAdd;
	_result = [player,"PartVRotor"] call BIS_fnc_invAdd;
	_result = [player,"ItemJerrycan"] call BIS_fnc_invAdd;
	_result = [player,"PartEngine"] call BIS_fnc_invAdd;
	_result = [player,"PartFueltank"] call BIS_fnc_invAdd;
	cutText ["You have packed your Gyro Copter.\nMaterials have been added to your Inventory","PLAIN DOWN"];
	copters_DEPLOYED = copters_DEPLOYED - 1;
};
if (typeOf _obj == "CSJ_GyroP") then {
 	_result = [player,"ItemTanktrap"] call BIS_fnc_invAdd;
	_result = [player,"ItemTanktrap"] call BIS_fnc_invAdd;
	_result = [player,"PartGeneric"] call BIS_fnc_invAdd;
	_result = [player,"PartGeneric"] call BIS_fnc_invAdd;
	_result = [player,"ItemCompass"] call BIS_fnc_invAdd;
	_result = [player,"PartVRotor"] call BIS_fnc_invAdd;
	_result = [player,"ItemJerrycan"] call BIS_fnc_invAdd;
	_result = [player,"PartEngine"] call BIS_fnc_invAdd;
	_result = [player,"PartFueltank"] call BIS_fnc_invAdd;
	cutText ["You have packed your Gyro Plane.\nMaterials have been added to your Inventory","PLAIN DOWN"];
	planes_DEPLOYED = planes_DEPLOYED - 1;
};
if (typeOf _obj == "M2StaticMG") then {
 	_result = [player,"M249_DZ"] call BIS_fnc_invAdd;
	_result = [player,"ItemPole"] call BIS_fnc_invAdd;
	_result = [player,"ItemPole"] call BIS_fnc_invAdd;
	_result = [player,"ItemPole"] call BIS_fnc_invAdd;
	cutText ["You have packed your Static Gun.\nMaterials have been added to your Inventory but Ammo got lost","PLAIN DOWN"];
	guns_DEPLOYED = guns_DEPLOYED - 1;
};
