private ["_textCity","_nearestCity","_vehicle","_inVehicle","_unitSpeed","_vehicleType"];

_vehicle = vehicle player;
_inVehicle = (_vehicle != player);
_unitSpeed = round(speed (vehicle player));
_vehicleType = (typeOf (vehicle player));

_nearestCity = nearestLocations [getPos player, ["NameCityCapital","NameCity","NameVillage","NameLocal"],750]; _textCity = "Wilderness";
if (count _nearestCity > 0) then {_textCity = text (_nearestCity select 0)};

hintSilent parseText format ["
<t size='1'	font='Bitstream' align='center'	color='#5882FA'>Survived %1 Days</t><br/>
<t size='1' font='Bitstream' align='left' color='#FFBF00'>Location:</t> <t size='1' font='Bitstream' align='right' color='#FFFAF0'>%2</t><br/>
<t size='1' font='Bitstream' align='left'	color='#FFBF00'>Blood Left:</t>				<t size='1' 	font='Bitstream'align='right'>%3</t><br/>
<t size='1'	font='Bitstream' align='left' color='#FFBF00'>Humanity:</t>				<t size='1'		font='Bitstream'align='right'>%4</t><br/>
<t size='1'	font='Bitstream' align='left' color='#FFBF00'>Heroes Killed:</t>			<t size='1'		font='Bitstream'align='right'>%5</t><br/>
<t size='1'	font='Bitstream' align='left' color='#FFBF00'>Bandits Killed:</t>			<t size='1'		font='Bitstream'align='right'>%6</t><br/>
<t size='1'	font='Bitstream' align='left' color='#FFBF00'>Zombies Killed:</t>			<t size='1'		font='Bitstream'align='right'>%7</t><br/>
<t size='1'	font='Bitstream' align='left' color='#FFBF00'>Zomb.(alive/total):</t>	<t size='1'		font='Bitstream'align='right'>%8/%9</t><br/>
<t size='1'	font='Bitstream' align='left' color='#FFBF00'>Speed:</t> <t size='1'font='Bitstream'align='right'>%10</t><br/>
<t size='1'	font='Bitstream' align='left' color='#FFBF00'>PlayerUID:</t> <t size='1'font='Bitstream'align='right'>%11</t><br/>
<t size='1' font='Bitstream' align='left' color='#FFBF00'>FPS:</t> <t size='1' font='Bitstream' align='right' color='#FFFAF0'>%12</t><br/>
<t size='1'	font='Bitstream' align='left' color='#0080FF'>www.grof.gr</t>
",
dayz_Survived,
_textCity,
r_player_blood,
round (player getVariable["humanity", 0]),
player getVariable["humanKills", 0],
player getVariable["banditKills", 0],
player getVariable["zombieKills", 0],
{alive _x} count (entities "zZombie_Base"),
count (entities "zZombie_Base"),
_unitSpeed,
player getVariable["PlayerUID", 0],
round diag_FPS
];	