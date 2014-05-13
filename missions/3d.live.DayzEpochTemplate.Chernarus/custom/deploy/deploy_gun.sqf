_maxGuns = 1;
if (isNil "guns_DEPLOYED") then {guns_DEPLOYED = 0;};
if (guns_DEPLOYED > _maxGuns) exitWith {
	_txt = format ["You have built %1 out of a maximum of %2 Static Guns.",guns_DEPLOYED,_maxGuns];
	cutText [_txt,"PLAIN DOWN"];
};
if (dayz_combat == 1) exitWith {
	_txt = "You can't deploy Static Guns while in combat.";
	cutText [_txt, "PLAIN DOWN"];
};
_sgaQTY = {_x == "200Rnd_556x45_M249"} count magazines player;
_sgQTY = {_x == "M249_DZ"} count weapons player;
_mpQTY = {_x == "ItemPole"} count magazines player;
if ((_sgaQTY >= 2) && (_sgQTY >= 1) && (_mpQTY >= 3)) then {
	r_interrupt = false;
	player playActionNow "Medic";
	player removeMagazine "200Rnd_556x45_M249";
	player removeMagazine "200Rnd_556x45_M249";
	player removeMagazine "ItemPole";
	player removeMagazine "ItemPole";
	player removeMagazine "ItemPole";
	player removeWeapon "M249_DZ";			
	
	[player,"repair",0,false,10] call dayz_zombieSpeak;
	[player,10,true,(getPosATL player)] spawn player_alertZombies;
	sleep 6;
	
	_pos = getPosATL player;
	_object = "M2StaticMG" createVehicle _pos;
	sleep 1;
	_object setVariable ["ObjectID", "1", true];
	_object setVariable ["ObjectUID", "1", true];
	_object setVariable ["Deployed", true, true];
	_object setVariable ["DZAI","1",true];
	sleep 1;
	_object setVariable ["Deployed",true,true];
	
	if (isNil "guns_DEPLOYED") then {guns_DEPLOYED = 1;} else {guns_DEPLOYED = guns_DEPLOYED + 1;};
	cutText ["You've used your toolbox to build a Static Gun!", "PLAIN DOWN"];
	
	r_interrupt = false;
	player switchMove "";
	player playActionNow "stop";
	sleep 5;
	cutText ["WARNING: "+name player+"! Deployed Static Guns do Not Save after server restart !", "PLAIN DOWN"];
} else {
	_txt = "You need: "+str(1 - _sgQTY)+"x(M249), "+str(2 - _sgaQTY)+"x(M249 Ammo) and "+str(3 - _mpQTY)+"x(Metal Pole) to build this.";
	cutText [_txt, "PLAIN DOWN"];
};