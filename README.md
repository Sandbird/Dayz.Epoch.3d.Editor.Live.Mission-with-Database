Dayz.Epoch.3d.Editor.Live.Mission with Database interaction
=================

[![ScreenShot](http://oi58.tinypic.com/2s0fde8.jpg)](http://youtu.be/e4DKLVoBQgA)

A custom mission file for the purpose of testing/writing scripts for [DayZ Epoch](https://github.com/vbawol/DayZ-Epoch) without the need of a server.
It emulates the dayz_server and dayz_mission files, so you can write scripts using the 3d editor. No need to use a dayz_server for debugging anymore. We all know how time consuming that is.

## Features:
* Database integration (yes thats right... [:)]
* I would suggest to have a maximum of 200 objects in your object_data table for faster results. Took 5min to load 10000 obsj from my real database.
* Fully working GUI, zombies, hit registration, addactions, everything!
* Write code and execute it on the fly. No need to start a server and join with a client to test things.
* 100% of your scripts will work! (dynamic weather, default loadouts, custom scripts etc)
* 2 setups. A default 3d editor player with a default loadout from init.sqf or a Real database character based on your UID
* Includes most of BIS_fnc functions, so actions like BIS_fn_invAdd will work (i've added most common ones...more included though...check details bellow.)
* Everything works...when i say everything i mean EVERYTHING !. (Spawning objects on mission start, traders (buy/sell), maintenance, character update, stats...etc)

## Requirements:

* A mysql server on the same machine as your Arma2 editor. Well...a remote PC would work as well...just make sure YOU ARE NOT using your original database. Make a copy of it!. This mission will interact with your database !
If you dont have a mysql server on your pc...i suggest you get WampServer. Its the easiest php/mysql server out there.


## Installation

### 3d.live.DayzEpochTemplate.Chernarus:
1. Click Download on the right sidebar, and extract the rar file.
2. Copy the ***3d.live.DayzEpochTemplate.Chernarus*** mission file in your ***\My Documents\ArmA 2\missions\*** folder
3. Copy everything inside ***"Arma2OA root folder"*** into your root Arma2OA folder (the same folder where @Dayz_Epoch, MPMissions are)
4. The ***real_date.dll***...(Thanks to killzonekid) is used to get your machine's date/time to be used for live day/night cycles inside the game (...you can set a fixed day if you want...details bellow)
5. Open ***ArmaOA\Arma2NETMySQLPlugin\Databases.txt*** and add your test database data there. 
Example:
~~~~java
mysql,dayz_epoch,127.0.0.1,3306,dayz,mydbpass

# dayz_epoch is the name of the database
# 127.0.0.1   is your local computer
# 3306        your mysql port
# dayz        is your database username
# mydbpass    is your database password
~~~~
6. Make a folder called ***Arma2NETMySQL*** inside C:\Users\YOURWINPROFILE\AppData\Local\
7. Inside that folder copy your modified ***Databases.txt*** you edited above (keep it also there dont move it) and also make a new folder called logs
8. Copy the ***3d.live.mission.Arma2Net.bat*** file (included in the .zip) in your Arma2 OA root directory and execute it
9. When the game launches, press Alt+E, select Chernarus, then Load and select mission ***3d.live.DayzEpochTemplate.Chernarus***
10. Open ***\My Documents\ArmA 2\missions\3d.live.DayzEpochTemplate.Chernarus\init.sqf*** and at the top of the file...put your database name. The one you put in Databases.txt
~~~~java
DB_NAME = "dayz_epoch";
~~~~
11. Start editing your files located in \My Documents\ArmA 2\missions\3d.live.DayzEpochTemplate.Chernarus with your customizations.
12. If you want to use my default fn_selfactions.sqf...i wrote some functions in it that will unlock vehicles, give plotpole IDs etc...All you need to do to activate them is put your fake/or real UID (depending on which initialization you prefer), in the superadmins.sqf.

## Initialize player and customizing the mission

### Default setup vs Database setup
There are 2 ways of initializing your player.
1. A default 3d editor player with a basic loadout (like the one you set in your init.sqf) [The mission is set with this selection by default]
2. A live database player based on his UID in the character_data table (coordinates, medical states, inventory etc)

### Default setup
The 1st way is the easiest thing you could start with. This setup DOES NOT initialize the character based on a database entry. Instead it uses some premade stats that you set.
The loadout of the player is set in the init.sqf.
But everything else should work fine with the database....like traders, salvaging, etc...Basically anything that doesnt require a legit UID.
Just open the ***dayz_code\init\setupChar.sqf*** and at the bottom of the file change the values to your liking.
Make sure in the ***init.sqf***, ***DefaultTruePreMadeFalse*** is set to ***true***; and also from there you can change the Default loadout of the player.

### Database setup (Arma2Net)
The 2nd option is a bit more complicated.
I left the PlayerUID in the debug monitor...so IF you see that it is set to 0 then you know something went wrong...Just reload the mission file and you should be fine.
To setup your character with the second method open ***dayz_code\init\variables.sqf***.
On line 8 is where the magic happens.
~~~~java
player setIdentity "My_Player";    //check description.ext file....There is no other way to get the name of the player in the editor.
player setVariable ["playerUID", "22222222", true];    // <<<<<<<<<< Change this to your playerUID (your real database UID)
~~~~

The ***description.ext*** has your character's name in it. If you ever need to check player name...it will get it from there.
~~~~
	class My_Player
	{
		name="DemoPlayer";
		face="Face20";
		glasses="None";
		speaker="Dan";
		pitch=1.1;
	};
~~~~
This 2nd option NEEDS your real playerUID, otherwise all hell will break lose. IF you want you can use another player's UID..The mission will initialize with his details then.
As long as that playerUID exists on the character_data table...and the player is alive....it will start the mission with that player.
Everything is database based..so no need to do anything else. The mission will start with all your stats, inventory, conditions and spawn you where your world coordinates are.


## Important info

### Init.sqf values [Important !]
1. DB_NAME = "dayz_epoch";              // At the top of the init.sqf....set your database name there as well.
2. DefaultTruePreMadeFalse = true;   // false: Read player's data from the database (based on UID), true: the normal player the editor has
3. StaticDayOrDynamic = true;              // A static date is set at the bottom of \dayz_server\init\server_function.sqf.  Set this to false if you want real time/date inside the mission.
4. DZEdebug = false;                             // Set to true if you want a more detailed log file

### Related to coding
* Since this is an emulation of the dayz_server some things will never work. For example:
***_playerUID = getPlayerUID player;*** will never work in the editor. 
To get the _playerUID you have to do this: ***_playerUID = player getVariable ["CharacterID","0"];***
This is the most important thing to remember. Lots of scripts use ***getPlayerUID***. You have to remember to change it every time you want to use it.

* ***findDisplay 46*** does not work in the editor :/ so scripts like the CCTV wont work
* Some BIS_fnc functions have to be included in the dayz_code\init\compiles.sqf for them to work.
For example i had to include:
~~~~
BIS_fnc_invAdd = 				compile preprocessFileLineNumbers "dayz_code\system\functions\inventory\fn_invAdd.sqf";	
~~~~ 
If your code has BIS_fnc functions in it then check the folder ***dayz_code\system\functions*** for the function and include it in the compiles.sqf.
I am sure there is a way to parse the folder and add a BIS_ infront of all the files, like epoch does it...but i didnt want to waste time and ran into problems,so manually adding the files is fine by me.

* You can activate a debug in the init.sqf if you are using the 2nd method. And ALWAYS check your RPT log file for debugging. Its located at : %AppData%\Local\ArmA 2 OA
To enable the debug value change this in your init.sqf:
~~~~
DZEdebug = true;  // Debug messages on log file
~~~~

### Related to mission file included
You'll notice when you start the mission there are 2 bots standing there. If you double click the soldier you'll see that he initiates this script scripts\BotInit.sqf.
I left that in purpose in case you want to do some scripting that requires 'another player', and you want to initialize the fake player like that.
The other bot can be deleted. I just left it there because i was testing a Tag Friendly script, and needed a 3rd 'player' that has me as a friend. (i got no friends lol).
 
In most of my scripts i use the playerUID to validate checks between owner and objects. Some default Epoch files use the characterID...meaning if you die...you lose ownership.
Thats why i changed most of the stuff to playerUID instead...If for some reason you are using scripts that check CharacterID instead of playerUID, i would suggest you change that, because some things (with the 2nd method) might not work...due to the fact that my files are checking playerUID for validation. Worst case scenario if you cant edit the files....just use the same CharacterID and playerUID...so its always the same [:)]
 
Example on how to use the superadmins.sqf (for actions restricted to admins only, just add your fake UID in the array)
(In your fn_self_actions.sqf)
~~~~java
//_adminList = call compile preProcessFileLineNumbers "superadmins.sqf";  // This line is already at the top of the file.

 _cursorTarget = cursorTarget;
 _typeOfCursorTarget = typeOf _cursorTarget;
 _ownerID = _cursorTarget getVariable ["CharacterID","0"];
 _playerUID = player getVariable ["playerUID", 0];

     // Example on how to use _adminList
  if((typeOf(cursortarget) == "Plastic_Pole_EP1_DZ") and _ownerID != "0" and (player distance _cursorTarget < 2)) then {
  if (_playerUID in _adminList) then {
     cutText [format["Plot Pole Owner PUID is: %1",_playerUID], "PLAIN DOWN"];
   };
  };
~~~~

### Bugs

* Using the 1st method there is a small change the player will spawn twice. That's because when you Preview the map you are also the Server and the Player. The code runs twice....hence the bugs with the 2nd method with the fake database.
* There are no .fsm files so dont try to include them. 3d editor will not work with them, thats why i broke the player_monitor.fsm into 2 .sqf files...One emulates 'login to the server', and one 'setup of player'.

## Final Notes
These are heavily modified files...Dont overwrite them with your own files. Add to them instead of replacing them.

These files took me alot of time to make. It wasnt easy, and i am sure you'll find bugs or some things could have been writen a better way.
The whole purpose of this project was to not waste any more time trying to code on this god forsaken Arma engine. I cant believe that there isnt an option to write 'on the fly'. With a proper debugger...
Sure there are little tricks and hacks you can add to ***diag_log*** variables, but to write an actual script that requires interaction with the environment or beta testing custom script ??? Forget it.
I've included the Deploy bike and Self bloodbag scripts in the pack...just to see how easy it is to add/run/debug them. (Check the youtube video).

And a personal note....You will NEVER find an easier way to code stuff for Dayz....period. I've been begging both at the Epoch forum and on Opendayz for a Guru to point me to the right direction for fast coding/debugging code in  Dayz and i got nothing.
This is the fastest way to write code and see it in action. 

Hope this code will help you write code faster and easier :)
