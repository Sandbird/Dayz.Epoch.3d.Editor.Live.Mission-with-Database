_maxMotos = 2;
if (isNil "motors_DEPLOYED") then {motors_DEPLOYED = 0;};
if (motors_DEPLOYED > _maxMotos) exitWith {
	_txt = format ["You have built %1 out of a maximum of %2 Motorcycles.",motors_DEPLOYED,_maxMotos];
	cutText [_txt,"PLAIN DOWN"];
};
if (dayz_combat == 1) exitWith {
	_txt = "You can't deploy vehicles while in combat.";
	cutText [_txt, "PLAIN DOWN"];
};
_smQTY = {_x == "PartGeneric"} count magazines player;
_peQTY = {_x == "PartEngine"} count magazines player;
_jcQTY = {_x == "ItemJerrycan"} count magazines player;
_ftQTY = {_x == "PartFueltank"} count magazines player;
_pwQTY = {_x == "PartWheel"} count magazines player;
if ((_smQTY >= 4)&&(_peQTY >= 1)&&(_jcQTY >= 1)&&(_ftQTY >= 1)&&(_pwQTY >= 2)) then {
	r_interrupt = false;
	player playActionNow "Medic";
	player removeMagazine "PartGeneric";
	player removeMagazine "PartGeneric";
	player removeMagazine "PartGeneric";
	player removeMagazine "PartGeneric";
	player removeMagazine "PartEngine";
	player removeMagazine "ItemJerrycan";
	player removeMagazine "PartFueltank";
	player removeMagazine "PartWheel";
	player removeMagazine "PartWheel";
	
	[player,"repair",0,false,10] call dayz_zombieSpeak;
	[player,10,true,(getPosATL player)] spawn player_alertZombies;
	sleep 6;
	
	_pos = getPos player;
	_pos = [(_pos select 0)+4,(_pos select 1)+4,0];
	_object = "Old_moto_TK_Civ_EP1" createVehicle (_pos);
	sleep 1;
	_object setVariable ["ObjectID", "1", true];
	_object setVariable ["ObjectUID", "1", true];
	_object setVariable ["Deployed", true, true];
	_object setVariable ["DZAI","1",true];
	
	if (isNil "motors_DEPLOYED") then {motors_DEPLOYED = 1;} else {motors_DEPLOYED = motors_DEPLOYED + 1;};
	cutText ["You've used your toolbox to build a Motorcycle!", "PLAIN DOWN"];
	
	r_interrupt = false;
	player switchMove "";
	player playActionNow "stop";
	sleep 5;
	cutText ["WARNING: "+name player+"! Deployed vehicles do Not Save after server restart!", "PLAIN DOWN"];
} else {
	_txt = "You need: "+str(4 - _smQTY)+"x(Scrap Metal), "+str(1 - _peQTY)+"x(Engine Part), "+str(1 - _jcQTY)+"x(Jerry Can), "+str(1 - _ftQTY)+"x(Fuel Tank) and "+str(2 - _pwQTY)+"x(Wheel) to build this.";
	cutText [_txt, "PLAIN DOWN"];
};