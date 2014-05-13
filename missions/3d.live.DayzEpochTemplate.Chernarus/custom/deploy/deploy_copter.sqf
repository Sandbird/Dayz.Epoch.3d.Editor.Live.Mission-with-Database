_maxCopters = 1;
if (isNil "copters_DEPLOYED") then {copters_DEPLOYED = 0;};
if (copters_DEPLOYED > _maxCopters) exitWith {
	_txt = format ["You have built %1 out of a maximum of %2 Gyro Copters.",copters_DEPLOYED,_maxCopters];
	cutText [_txt,"PLAIN DOWN"];
};
if (dayz_combat == 1) exitWith {
	_txt = "You can't deploy vehicles while in combat.";
	cutText [_txt, "PLAIN DOWN"];
};
_smQTY = {_x == "PartGeneric"} count magazines player;
_ttQTY = {_x == "ItemTankTrap"} count magazines player;
_icQTY = {_x == "ItemCompass"} count weapons player;
_mrQTY = {_x == "PartVRotor"} count magazines player;
_jcQTY = {_x == "ItemJerrycan"} count magazines player;
_peQTY = {_x == "PartEngine"} count magazines player;
_pfQTY = {_x == "PartFueltank"} count magazines player;
if ((_smQTY >= 2) && (_ttQTY >= 2) && (_icQTY >= 1) && (_mrQTY >= 1) && (_jcQTY >= 1) && (_peQTY >= 1) && (_pfQTY >= 1)) then {
	r_interrupt = false;
	player playActionNow "Medic";
	player removeMagazine "PartGeneric";
	player removeMagazine "PartGeneric";
	player removeMagazine "ItemTankTrap";
	player removeMagazine "ItemTankTrap";
	player removeMagazine "ItemJerrycan";
	player removeMagazine "PartVRotor";			
	player removeWeapon "ItemCompass";			
	player removeMagazine "PartEngine";
	player removeMagazine "PartFueltank";
	
	[player,"repair",0,false,10] call dayz_zombieSpeak;
	[player,10,true,(getPosATL player)] spawn player_alertZombies;
	sleep 6;
	
	_pos = getPos player;
	_pos = [(_pos select 0)+6,(_pos select 1)+6,0];
	_object = "CSJ_GyroC" createVehicle (_pos);
	sleep 1;
	_object setVariable ["ObjectID", "1", true];
	_object setVariable ["ObjectUID", "1", true];
	_object setVariable ["Deployed", true, true];
	_object setVariable ["DZAI","1",true];
	_object removeWeapon "GyroGrenadeLauncher";

	sleep 1;
	_object setVariable ["Deployed",true,true];
	
	if (isNil "copters_DEPLOYED") then {copters_DEPLOYED = 1;} else {copters_DEPLOYED = copters_DEPLOYED + 1;};
	cutText ["You've used your toolbox to build a Gyro Copter!", "PLAIN DOWN"];
	
	r_interrupt = false;
	player switchMove "";
	player playActionNow "stop";
	sleep 5;
	cutText ["WARNING: "+name player+"! Deployed vehicles do Not Save after server restart!", "PLAIN DOWN"];
} else {
	_txt = "You need: "+str(2 - _smQTY)+"x(Scrap Metal), "+str(2 - _ttQTY)+"x(Trank trap), "+str(1 - _icQTY)+"x(Compass), "+str(1 - _mrQTY)+"x(Main Rotor), "+str(1 - _jcQTY)+"x(Jerrycan), "+str(1 - _peQTY)+"x(Engine) and "+str(1 - _pfQTY)+"x(Fueltank) to build this.";
	cutText [_txt, "PLAIN DOWN"];
};