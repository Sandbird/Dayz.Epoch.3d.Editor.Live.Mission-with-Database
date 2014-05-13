_maxBikes = 2;
if (isNil "bikes_DEPLOYED") then {bikes_DEPLOYED = 0;};
if (bikes_DEPLOYED > _maxBikes) exitWith {
	_txt = format ["You have built %1 out of a maximum of %2 Bicycles.",bikes_DEPLOYED,_maxBikes];
	cutText [_txt,"PLAIN DOWN"];
};
if (dayz_combat == 1) exitWith {
	_txt = "You cant deploy vehicles while in combat.";
	cutText [_txt, "PLAIN DOWN"];
};
_smQTY = {_x == "PartGeneric"} count magazines player;
_pwQTY = {_x == "PartWheel"} count magazines player;
if ((_smQTY >= 2)&&(_pwQTY >= 2)) then {
	r_interrupt = false;
	player playActionNow "Medic";
	player removeMagazine "PartGeneric";
	player removeMagazine "PartGeneric";
	player removeMagazine "PartWheel";
	player removeMagazine "PartWheel";
	
	[player,"repair",0,false,10] call dayz_zombieSpeak;
	[player,10,true,(getPosATL player)] spawn player_alertZombies;
	sleep 6;
	
	_pos = getPos player;
	_pos = [(_pos select 0)+4,(_pos select 1)+4,0];
	_object = "Old_bike_TK_CIV_EP1" createVehicle (_pos);
	sleep 1;
	_object setVariable ["ObjectID", "1", true];
	_object setVariable ["ObjectUID", "1", true];
	_object setVariable ["Deployed", true, true];
	_object setVariable ["DZAI","1",true];
	
	if (isNil "bikes_DEPLOYED") then {bikes_DEPLOYED = 1;} else {bikes_DEPLOYED = bikes_DEPLOYED + 1;};
	cutText ["You used your toolbox to build a Bicycle!", "PLAIN DOWN"];
	
	r_interrupt = false;
	player switchMove "";
	player playActionNow "stop";
	sleep 5;
	cutText ["WARNING: "+name player+"! Deployed vehicles do Not Save after server restart!", "PLAIN DOWN"];
} else {
	_txt = "You need: "+str(2 - _smQTY)+"x(Scrap Metal) and "+str(2 - _pwQTY)+"x(Wheel) to build this.";
	cutText [_txt, "PLAIN DOWN"];
};