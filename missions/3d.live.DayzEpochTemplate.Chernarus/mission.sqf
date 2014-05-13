activateAddons [ 
  "map_eu",
  "csj_gyroac",
  "pook_h13",
  "glt_m300t",
  "mbg_buildings_3"
];

activateAddons ["map_eu", "csj_gyroac", "pook_h13", "glt_m300t", "mbg_buildings_3"];
initAmbientLife;

_this = createCenter west;
_center_0 = _this;

_group_0 = createGroup _center_0;

_unit_1 = objNull;
if (true) then
{
  _this = _group_0 createUnit ["Camo1_DZ", [4836.269, 9969.0166], [], 0, "CAN_COLLIDE"];
  _unit_1 = _this;
  _this setDir 47.685612;
  _this setVehicleVarName "Sandbird";
  Sandbird = _this;
  _this setUnitAbility 0.60000002;
  if (true) then {_group_0 selectLeader _this;};
  if (true) then {selectPlayer _this;};
  if (true) then {setPlayable _this;};
};

_vehicle_1 = objNull;
if (true) then
{
  _this = createVehicle ["SUV_Camo_DZE3", [4962.5352, 10014.729, -0.028254064], [], 0, "CAN_COLLIDE"];
  _vehicle_1 = _this;
  _this setDir -122.54756;
  _this setVehicleLock "UNLOCKED";
  _this setPos [4962.5352, 10014.729, -0.028254064];
};

_unit_2 = objNull;
if (true) then
{
  _this = _group_0 createUnit ["BAF_Soldier_AA_W", [4968.1646, 10013.114, -6.1035156e-005], [], 0, "CAN_COLLIDE"];
  _unit_2 = _this;
  _this setDir -138.015;
  _this setVehicleVarName "Bot1";
  Bot1 = _this;
  _this setVehicleInit "botInitScript = [this] execVM ""scripts\BotInit.sqf"";";
  _this setUnitRank "CORPORAL";
  _this setUnitAbility 0.60000002;
  if (false) then {_group_0 selectLeader _this;};
};

_this = createCenter civilian;
_center_1 = _this;

_group_2 = createGroup _center_1;

_this = createCenter east;
_center_2 = _this;

_group_3 = createGroup _center_2;

_unit_7 = objNull;
if (true) then
{
  _this = _group_3 createUnit ["Ins_Villager4", [4967.3462, 10014.542], [], 0, "CAN_COLLIDE"];
  _unit_7 = _this;
  _this setDir -128.43231;
  _this setVehicleArmor 0.89999998;
  _this setVehicleAmmo 0.89999998;
  _this setVehicleInit "this setVariable [""CharacterID"", ""3"", true]; this setVariable [""playerUID"", ""333333"", true]; this setVariable [""friendlies"", [""111111""], true];";
  _this setUnitAbility 0.60000002;
  if (true) then {_group_3 selectLeader _this;};
};

processInitCommands;
runInitScript;
finishMissionInit;
