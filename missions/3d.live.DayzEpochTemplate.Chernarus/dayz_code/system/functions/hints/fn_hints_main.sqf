//--------------------------------------------------------------------------------------------------
//	ICONS & COLORS DEFINITION
//--------------------------------------------------------------------------------------------------
#include "fn_hints_icons.sqf";

//--------------------------------------------------------------------------------------------------
//	CONFIG
//--------------------------------------------------------------------------------------------------
if (isNil {BIS_MAIN_DISPLAY_ID}) then {
	BIS_MAIN_DISPLAY_ID = 46;
};

//"Press <t color='%1' shadow='1' shadowColor='%2'>%3</t> to continue."
BIS_AdvHints_NextKeySentence =  format[localize "STR_EP1_adv_hints.sqf0",BIS_COLOR_HILITE_BRIGHT,BIS_COLOR_SHADOW,"%1"];
//"Press <t color='%1' shadow='1' shadowColor='%2'>%3</t> to skip."
BIS_AdvHints_DurationSentence = format[localize "STR_EP1_adv_hints.sqf1",BIS_COLOR_HILITE_BRIGHT,BIS_COLOR_SHADOW,"%1"];

BIS_AdvHints_NextKeyTime = 0;

//countdown text
//"Closing in <t color='%1' shadow='1' shadowColor='%2'>%3</t> sec(s)."
BIS_AdvHints_ClosingInSentence =  format[localize "STR_EP1_adv_hints.sqf2",BIS_COLOR_HILITE_BRIGHT,BIS_COLOR_SHADOW,"%1"];

//--------------------------------------------------------------------------------------------------
//	INIT
//--------------------------------------------------------------------------------------------------
//feature: "Press %1 to continue"
BIS_AdvHints_NextKeyPressed = false;
BIS_AdvHints_NextKeyTracked = false;

BIS_AdvHints_NextKeyCode = 57;	//forced to [Space] key
BIS_AdvHints_NextKeyName = call compile keyName(BIS_AdvHints_NextKeyCode);
BIS_AdvHints_NextKeyName = format["'%1'",BIS_AdvHints_NextKeyName];
BIS_AdvHints_NextKeySentence = format[BIS_AdvHints_NextKeySentence,BIS_AdvHints_NextKeyName];
BIS_AdvHints_DurationSentence = format[BIS_AdvHints_DurationSentence,BIS_AdvHints_NextKeyName];

//feature: pausing
BIS_AdvHints_PausedObjects = [];
BIS_AdvHints_GamePaused = false;
BIS_AdvHints_ppColor = ppEffectCreate ["colorCorrections", 2000];
BIS_AdvHints_ppBlur = ppEffectCreate ["dynamicBlur", 1000];

//feature: input actions
BIS_AdvHints_IATracked = "";		//input action to look for
BIS_AdvHints_IADetected = false;	//result
BIS_AdvHints_IAMinTime = 0;			//min. time that the input action has to be performed

//gfx & icons
BIS_AdvHints_ImgBulletSimple = 	format["<img color='%1' shadow='1' shadowColor='%2' image='%3img\img_bullet_simple_ca.paa'	align='left' size='1.0'/> ",BIS_COLOR_HILITE,BIS_COLOR_SHADOW,BIS_AdvHints_Path];
BIS_AdvHints_ImgBullet  = 		format["<img color='%1' shadow='1' shadowColor='%2' image='%3img\img_bullet_ca.paa'			align='left' size='1.0'/> ",BIS_COLOR_HILITE,BIS_COLOR_SHADOW,BIS_AdvHints_Path];
BIS_AdvHints_ImgBullet1 = 		format["<img color='%1' shadow='1' shadowColor='%2' image='%3img\img_bullet1_ca.paa'		align='left' size='1.0'/> ",BIS_COLOR_HILITE,BIS_COLOR_SHADOW,BIS_AdvHints_Path];
BIS_AdvHints_ImgBullet2 = 		format["<img color='%1' shadow='1' shadowColor='%2' image='%3img\img_bullet2_ca.paa'		align='left' size='1.0'/> ",BIS_COLOR_HILITE,BIS_COLOR_SHADOW,BIS_AdvHints_Path];
BIS_AdvHints_ImgBullet3 = 		format["<img color='%1' shadow='1' shadowColor='%2' image='%3img\img_bullet3_ca.paa' 		align='left' size='1.0'/> ",BIS_COLOR_HILITE,BIS_COLOR_SHADOW,BIS_AdvHints_Path];
BIS_AdvHints_ImgBullet4 = 		format["<img color='%1' shadow='1' shadowColor='%2' image='%3img\img_bullet4_ca.paa' 		align='left' size='1.0'/> ",BIS_COLOR_HILITE,BIS_COLOR_SHADOW,BIS_AdvHints_Path];
BIS_AdvHints_ImgBullet5 = 		format["<img color='%1' shadow='1' shadowColor='%2' image='%3img\img_bullet5_ca.paa' 		align='left' size='1.0'/> ",BIS_COLOR_HILITE,BIS_COLOR_SHADOW,BIS_AdvHints_Path];

BIS_AdvHints_ImgInfo = 		format["<img color='%1' shadow='1' shadowColor='%2' image='%3img\img_info_ca.paa'/>",		BIS_COLOR_HILITE,BIS_COLOR_SHADOW,BIS_AdvHints_Path];
BIS_AdvHints_ImgImp = 		format["<img color='%1' shadow='1' shadowColor='%2' image='%3img\img_important_ca.paa'/>",	BIS_COLOR_HILITE,BIS_COLOR_SHADOW,BIS_AdvHints_Path];
BIS_AdvHints_ImgAction =	format["<img color='%1' shadow='1' shadowColor='%2' image='%3img\img_action_ca.paa'/>",		BIS_COLOR_HILITE,BIS_COLOR_SHADOW,BIS_AdvHints_Path];

BIS_AdvHints_ImgLine = 		format["<img color='%1' shadow='1' shadowColor='%2' image='%3img\img_line_thin_ca.paa' size='0.37'/> ", BIS_COLOR_HILITE,BIS_COLOR_SHADOW,BIS_AdvHints_Path];
BIS_AdvHints_ImgLineThin = 	format["<img color='%1' shadow='1' shadowColor='%2' image='%3img\img_line_thin_ca.paa' size='0.37'/> ", BIS_COLOR_HILITE,BIS_COLOR_SHADOW,BIS_AdvHints_Path];

//misc gfx
BIS_AdvHints_ImgMisc_Watch = format["<img color='%1' shadow='0' shadowColor='%2' image='%3img_misc\gfx_watch_ca.paa' align='left' size='5'/> ", BIS_COLOR_HILITE,BIS_COLOR_SHADOW,BIS_AdvHints_Path];

waitUntil {!(isNil "BIS_fnc_init")};

//--------------------------------------------------------------------------------------------------
//	NEXT KEY MONITOR
//--------------------------------------------------------------------------------------------------
//#define DISPLAY_MAIN (findDisplay 46)
#define DISPLAY_MAIN (findDisplay BIS_MAIN_DISPLAY_ID)
#define DISPLAY_GEAR (findDisplay 106)

uinamespace setVariable ["DISPLAY_MAIN",DISPLAY_MAIN];

[] spawn {
	while {true} do {
		waitUntil {!isNil{DISPLAY_GEAR} && !isNull(DISPLAY_GEAR)};
	
		["DISPLAY_GEAR","Adding 'KeyDown' event handler."] call BIS_debugLog;
		
		DISPLAY_GEAR displayAddEventHandler ["KeyDown", "_this call BIS_AdvHints_keyPressFunc"];
		
		waitUntil {isNil{DISPLAY_GEAR} || isNull(DISPLAY_GEAR)};
	};
};

//add the event handler at the start and everytime the game is loaded

[] spawn {
	private["_eventHandlerAdded"];
	
	waitUntil{!isNil{DISPLAY_MAIN} && !isNull(DISPLAY_MAIN)};
	
	["DISPLAY_MAIN","Adding 'KeyDown' event handler on mission start-up."] call BIS_debugLog;
	DISPLAY_MAIN displayAddEventHandler ["KeyDown", "_this call BIS_AdvHints_keyPressFunc"];
	
	_eventHandlerAdded = true;
	_saved = "";
	
	while {true} do {
		
		waitUntil {
			_result = format["%1|%2|%3",!isNil{DISPLAY_MAIN},!isNull(DISPLAY_MAIN),isNull(uinamespace getVariable "DISPLAY_MAIN")];
			
			if (_saved != _result) then {
				[_result] call BIS_debugLog;
				_saved = _result;
			};
				
			!isNil{DISPLAY_MAIN} && !isNull(DISPLAY_MAIN) && isNull(uinamespace getVariable "DISPLAY_MAIN")
		};

		uinamespace setVariable ["DISPLAY_MAIN",DISPLAY_MAIN];

		if (!_eventHandlerAdded) then {
			["DISPLAY_MAIN","Adding 'KeyDown' event handler in safecheck loop."] call BIS_debugLog;
			DISPLAY_MAIN displayRemoveAllEventHandlers "KeyDown";
			DISPLAY_MAIN displayAddEventHandler ["KeyDown", "_this call BIS_AdvHints_keyPressFunc"];
			
			_eventHandlerAdded = true;
		} else {
			_eventHandlerAdded = false;
		};
	};
};

BIS_AdvHints_keyPressFunc = {
	private["_keyCode","_block"];
	
	_block = false;
	_keyCode = _this select 1;
	
	//['Key pressed',str(_keyCode) + ': ' + keyName(_keyCode)] call BIS_debugLog;

	if (_keyCode == BIS_AdvHints_NextKeyCode && BIS_AdvHints_NextKeyTracked) then {
		BIS_AdvHints_NextKeyPressed = true;
		_block = true;
	};
	
	_block
};

//--------------------------------------------------------------------------------------------------
//	INPUT ACTION MONITOR
//--------------------------------------------------------------------------------------------------
[] spawn {
	private ["_action","_i","_counter","_actions","_tmp"];
	
	_counter = 0;
	
	waitUntil {
		_action = BIS_AdvHints_IATracked;
		
		if (_action == "") then {
			_counter = 0;
			sleep 0.1;
		} else {
			//more then 1 keypress defined
			if (count BIS_AdvHints_KeyPressXtra > 0) then {
				_i = 0;
				_actions = [_action] + BIS_AdvHints_KeyPressXtra;
				
				{
					_tmp = inputAction(_x);
					
					if (_tmp > _i) then {
						_i = _tmp;
					};
					
				} forEach _actions;
				
			//only 1 keypress defined	
			} else {
				_i = inputAction(_action);
			};

			if (_i > 0) then {
				_counter = _counter + 0.05;
				if (_counter >= BIS_AdvHints_IAMinTime) then {
					BIS_AdvHints_IADetected = true;
					_counter = 0;
				};
				sleep 0.05;
			} else {
				_counter = 0;
				sleep 0.0001;
			};
		};
		_action == "ABORT";
	};
};

//--------------------------------------------------------------------------------------------------
//	ADVANCED HINTS
//--------------------------------------------------------------------------------------------------
BIS_AdvHints_setDefaults = 
{
	call BIS_AdvHints_terminateHint;
	
	BIS_AdvHints_Header = "";
	BIS_AdvHints_Text = "";
	BIS_AdvHints_Footer = "";
	BIS_AdvHints_Duration = -1;
	BIS_AdvHints_DurationMin = 0;
	BIS_AdvHints_ShowCond = "true";
	BIS_AdvHints_ShowCode = "";
	BIS_AdvHints_HideCond = "";
	BIS_AdvHints_HideCode = "";
	BIS_AdvHints_Silent = false;
	BIS_AdvHints_Seamless = false;
	BIS_AdvHints_KeyPress = "";
	BIS_AdvHints_KeyPressXtra = [];
	BIS_AdvHints_CanSkip = true;
	BIS_AdvHints_NoFooter = false;
	BIS_AdvHints_Pause = false;
	BIS_AdvHints_Dynamic = [];
};

BIS_AdvHints_terminateHint = 
{
	//kill the hint
	if !(isNil "BIS_AdvHints_Spawn") then {
		if !(scriptDone BIS_AdvHints_Spawn) then {
			//["Terminating 'BIS_AdvHints_Spawn'"] call BIS_debugLog;
			
			terminate BIS_AdvHints_Spawn;
			hintSilent "";
		} else {	
			//["NOT terminating 'BIS_AdvHints_Spawn'"] call BIS_debugLog;
		};
		//["NOT terminating 'BIS_AdvHints_Spawn'","IT IS NILL!"] call BIS_debugLog;
	};
};

BIS_AdvHints_showHint =
{
	BIS_AdvHints_Spawn = [] spawn BIS_AdvHints_showHintSpawn;
	
	waitUntil{(scriptDone BIS_AdvHints_Spawn)};
	
	//["BIS_AdvHints_showHint","{scriptDone BIS_AdvHints_Spawn}"] call BIS_debugLog;
	
	call BIS_AdvHints_setDefaults;
};

BIS_AdvHints_showHintSpawn =
{
	private ["_countdownType","_elapsed","_html","_t","_show","_period"];
	private ["_header","_text","_footer","_duration","_showCond","_showCode","_hideCond","_hideCode","_silent","_seamless","_keyPress","_keyDownTime","_pause","_durationMin","_canSkip"];

	_countdownType = 0;		
	_elapsed = 0;
	
	//shortcuts
	_header 		= BIS_AdvHints_Header;
	_text 			= BIS_AdvHints_Text;
	_footer 		= BIS_AdvHints_Footer;
	_duration 		= BIS_AdvHints_Duration;
	_durationMin 	= BIS_AdvHints_DurationMin;
	_showCond 		= BIS_AdvHints_ShowCond;
	_showCode 		= BIS_AdvHints_ShowCode;
	_hideCond 		= BIS_AdvHints_HideCond;
	_hideCode 		= BIS_AdvHints_HideCode;
	_silent 		= BIS_AdvHints_Silent;
	_seamless 		= BIS_AdvHints_Seamless;
	_keyPress 		= BIS_AdvHints_KeyPress;
	_pause			= BIS_AdvHints_Pause;
	_canSkip		= BIS_AdvHints_CanSkip;

	//pause or un-pause the game
	if (_pause) then {
		//game not paused, pause it!
		if !BIS_AdvHints_GamePaused then {
			call BIS_AdvHints_PauseGame;
		};
	} else {
		//game paused, un-pause it!
		if BIS_AdvHints_GamePaused then {
			call BIS_AdvHints_UnPauseGame;
		};		
	};

	//minimal duration for condition driven hints
	if (_durationMin > 0) then {
		_hideTime = time + _durationMin;
		
		//add durationMin to hideCond
		if (_hideCond != "") then {
			_hideCond = _hideCond + format["&& time > %1",_hideTime];
		
		//set keyPress as the only posCond
		} else {
			_hideCond = format["time > %1",_hideTime];
		};		
	};

	//countdown style
	if (_duration > 0) then {
		_countdownType = floor(_duration/1000);
		_duration = _duration - (_countdownType * 1000);

		_period = switch (_countdownType) do {
			//progress bar
			case 0: {0.5};
			//hidden
			case 1: {1};		
			//count-down text
			case 2: {1};
		};	
	};
	
	//add countdown to "Press %1 to continue." type of hint
	if (BIS_AdvHints_NextKeyTime > 0 && _duration == -1) then {
		if (BIS_AdvHints_KeyPress == "" && BIS_AdvHints_HideCond == "") then {
			_duration = BIS_AdvHints_NextKeyTime;
			_period = 0.5;
		};
	};

	//used when you need to track that player is performing the action over some time, not only once
	if (typeName(_keyPress) == "ARRAY") then {
		_keyDownTime = _keyPress select 1;
		_keyPress = _keyPress select 0;
	} else {
		_keyDownTime = 0;
	};

	//setup vars for input action pseudo-handler
	if (_keyPress != "") then {
		//setup 4 input action monitoring
		BIS_AdvHints_IATracked = _keyPress;		//input action to look for
		BIS_AdvHints_IADetected = false;		//result
		BIS_AdvHints_IAMinTime = _keyDownTime;	//min. time that the input action has to be performed

		//set post condition
		//add keyPress to hideCond
		if (_hideCond != "") then {
			_hideCond = _hideCond + " && BIS_AdvHints_IADetected";
		//set keyPress as the only posCond
		} else {
			_hideCond = "BIS_AdvHints_IADetected";
		};
		if (typeName(_text) == "STRING") then {
			_text = format[_text,_keyPress call BIS_getKeyBind];
		};	
	} else {
		BIS_AdvHints_IATracked = "";		//input action to look for
		BIS_AdvHints_IADetected = false;	//result
	};
	
	//autofill preCond with negated postCond
	if (call compile(_showCond) && _hideCond != "") then {
		_showCond = "!(" + _hideCond + ")";
	};

	//pre-condition
	if (call compile(_showCond)) then {
		//pre-code
		if (_showCode != "") then {
			call compile(_showCode);
		};

		//seamless transition between hints
		if !_seamless then {
			hintSilent "";
			sleep 0.5;
		};

		//display hint
		_show = true;
		while {_show} do {
			//handle _text formatting (if hint text supplied as array)
			if ((typeName(BIS_AdvHints_Text) == "ARRAY") || (count(BIS_AdvHints_Dynamic) > 0)) then {
				private ["_params","_i","_param","_temp"];
		
				_params = [];

				if (count(BIS_AdvHints_Dynamic) > 0) then {
					{
						if (typeName(_x) == "CODE") then {
							_param = call _x;
						} else {
							_param = _x;
						};
						
						_params = _params + [_param];						
						
					} forEach BIS_AdvHints_Dynamic;
				};
				
				if (typeName(BIS_AdvHints_Text) == "ARRAY") then {
					for "_i" from 1 to (count(BIS_AdvHints_Text)-1) do {
						_temp = BIS_AdvHints_Text select _i;
						
						if (typeName(_temp) == "CODE") then {
							_param = call _temp;
						} else {
							_param = _temp;
						};
						
						_params = _params + [_param];
					};
				};
				
				if (typeName(BIS_AdvHints_Text) == "ARRAY") then {
					_text = format([BIS_AdvHints_Text select 0] + _params);
				} else {
					_text = format([BIS_AdvHints_Text] + _params);
				};
			};

			//compile _footer
			if (typeName(BIS_AdvHints_Footer) == "CODE") then {
				_footer = call BIS_AdvHints_Footer;
			};	
			
			//auto-fill _footer
			if (BIS_AdvHints_NoFooter) then {
				_footer = "";
			} else {
				if(_duration == -1) then {
					if (_hideCond == "" && _footer == "") then {
						_footer = BIS_AdvHints_NextKeySentence;
					};
				} else {
					//progressbar
					if (_countdownType == 0) then {
						_footer = [_elapsed,_duration] call BIS_AdvHints_createCountdownLine;
					};					
					//hidden
					if (_countdownType == 1) then {
						_footer = "";
					};						
					//'remaining x secs' text
					if (_countdownType == 2) then {
						_footer = format[BIS_AdvHints_ClosingInSentence,_duration-_elapsed];
					};
				};
			};			

			//debug
			//[_text] call BIS_debugLog;
	
			_html = "";		
			
			//add _header
			if (_header != "") then {
				
				_html = format["<t color='%1' size='0.85' shadow='0' align='left'>",BIS_COLOR_TEXT] + _header + "</t><br/><br/>";
			};
			
			//add _text
			_html = _html + "<t color='#a9b08e' size='1' shadow='0' shadowColor='#312100' align='left'>" + _text + "</t>";
			
			//add _footer
			if (_footer != "") then {
				_html = _html + format["<br/><br/><t color='%1' size='0.85' shadow='0' align='right'>",BIS_COLOR_TEXT] + _footer + "</t>";
			};				
			
			//last-line cutted fix
			_html = _html + "<br/>";
	
			//display the hint
			if (_text != "") then {
				if (_silent) then {
					hintSilent parseText(_html);
				} else {
					hint parseText(_html);
				};
			};


			//handle hint refresh or destruction
			if (_duration == -1) then {
	
				//"Press 'F' to continue."
				if (_hideCond == "") then {
					_t = time; 
					
					//tracking 'next key' pressed
					BIS_AdvHints_NextKeyPressed = false;
					BIS_AdvHints_NextKeyTracked = true;
					
					waitUntil {(BIS_AdvHints_NextKeyPressed) || (time > _t + 1)};
					
					BIS_AdvHints_NextKeyTracked = false;
					
					//the 'next key' pressed
					if (BIS_AdvHints_NextKeyPressed) then {
						_show = false;
					};				
					
				//controlled by condition
				} else {
					if (call compile(_hideCond)) then {
						_show = false;
						if (_keyPress != "") then {
							BIS_AdvHints_IATracked = "";		//input action to look for
							BIS_AdvHints_IADetected = false;	//result
						};
					} else {
						sleep 0.1;					
					};
				};		
			} else {
				if (_elapsed < _duration) then {
					
					_t = time; 
					
					if (_canSkip) then {
						//tracking 'next key' pressed
						BIS_AdvHints_NextKeyPressed = false;
						BIS_AdvHints_NextKeyTracked = true;

						waitUntil {(BIS_AdvHints_NextKeyPressed) || (time > _t + _period)};
						
						BIS_AdvHints_NextKeyTracked = false;						
						
						//save elapsed time
						_elapsed = _elapsed + _period;
	
						//the 'next key' pressed
						if (BIS_AdvHints_NextKeyPressed) then {
							_show = false;
						} else {
							_show = true;
						};						
					} else {
						waitUntil {(time > _t + _period)};
						
						//save elapsed time
						_elapsed = _elapsed + _period;						
					};
				} else {
					_show = false;
				};
			};
			
			_silent = true;
		};

		//post-code
		if (_hideCode != "") then {
			call compile(_hideCode);	
		};
	};
	
	//hide the hint, if still hanging around
	[] spawn {
		sleep 0.5;
		
		if (scriptDone BIS_AdvHints_Spawn) then {
			["Hiding obsolete hint!"] call BIS_debugLog;
			hintSilent "";
		};
	};
};

BIS_AdvHints_createCountdownLine =
{
	private ["_elapsed","_max","_line","_char","_i","_segments","_segmentsElapsed","_segmentsRemaining"];
	
	_elapsed = _this select 0;

	if (count(_this) > 1) then {
		_max = _this select 1;
	};	
	if isNil("_max") then {
		_max = 10;
	};

	//number of countdown segments
	_segments = 20;

	_segmentsElapsed = round(_elapsed/_max * _segments);
	_segmentsRemaining = _segments - _segmentsElapsed;

	if (_segmentsElapsed > _segments) then {
		_segmentsElapsed = _segments;
		_segmentsRemaining = 0;
	};
	
	_char = "|";
	
	_line = (["timer",BIS_COLOR_TEXT,"x_"] call BIS_getIcon) + format["<t color='%1'>",BIS_COLOR_TEXT];

	for "_i" from 1 to _segmentsElapsed do 
	{
		_line = _line + _char;
	};
	_line = _line + "</t>";
	
	if (_segmentsRemaining > 0) then {
		_line = _line + "<t color='#000000'>";
		for "_i" from 1 to _segmentsRemaining do 
		{
			_line = _line + _char;
		};
		_line = _line + "</t>";
	};

	//_line = _line + "<br/>" + BIS_AdvHints_ImgLineThin + "<br/>" +  BIS_AdvHints_DurationSentence;
	//_line = _line + "  ";

	_line
};


BIS_AdvHints_createProgressBar =
{
	private["_completed","_max","_line","_char"];

	_completed = floor (_this select 0);
	_max = _this select 1;
	
	if (_completed > _max) then {
		_completed = _max;
	};
	
	
	_char = "|";
	
	_line = format["<t color='%1'>",BIS_COLOR_TEXT];
	for "_i" from 1 to _completed do 
	{
		_line = _line + _char;
	};
	_line = _line + "</t>";
	
	if (_max > _completed) then {
		_line = _line + "<t color='#000000'>";
		for "_i" from (_completed+1) to _max do 
		{
			_line = _line + _char;
		};
		_line = _line + "</t>";
	};

	_line
};

//'SwitchCommand' call BIS_getKeyBind
BIS_getKeyBind =
{
	private ["_key","_action2press","_r","_binds"];

	if (typeName(_this) == "STRING") then {
		_binds = actionKeysNamesArray _this;		
	} else {
		_binds = [];
		
		if (typeName(_this) == "ARRAY") then {
			{
				_binds = _binds + [call compile (keyName _x)];

			} forEach _this;
		};
	};
	
	//the key we are waiting for
	_action2press = BIS_AdvHints_IATracked;	
	
	//return string
	_r = "";
	
	if (count _binds == 0) then {
		_r = "'Not assigned!'";
	} else {

		//loop through all assigned bindings
		{
			if (_r != "") then {
				_r = _r + " " + localize "STR_EP1_adv_hints.sqf43" + " ";
			};
				
			_key = "'" + _x + "'";		

			//add yellow hilite
			_r = _r + "<t color='#fed886' shadow='1' shadowColor='#312100'>"+_key+"</t>";
	
		} forEach _binds;		
	};	
	
	_r
};

BIS_AdvHints_formatText = {

	private["_header","_text","_count","_format","_i","_r","_params","_addLine"];

	//init
	if (isNil "BIS_AdvHints_TImp") then {
		BIS_AdvHints_TImp = "";
	};

	_r = "";
	_addLine = false;

	//header + line	
	_r = format["<t color='#e6b448'>%1</t><br/>%2<br/>",BIS_AdvHints_THeader,BIS_AdvHints_ImgLine];

	//info
	if (BIS_AdvHints_TInfo != "") then {
		_r = _r + BIS_AdvHints_ImgInfo + " " + BIS_AdvHints_TInfo;
		
		_addLine = true;
	};

	//info: important 
	if (BIS_AdvHints_TImp != "") then {
		//add an empty line
		if (_addLine) then {
			_r = _r + "<br/><br/>";
		};		
		
		_r = _r + BIS_AdvHints_ImgImp + " " + BIS_AdvHints_TImp;
		_addLine = true;
	};	

	//action
	if (BIS_AdvHints_TAction != "") then {
		//add an empty line
		if (_addLine) then {
			_r = _r + "<br/><br/>";
		};		
		
		_r = _r + BIS_AdvHints_ImgAction + " <t color='#e6b448' shadow='1' shadowColor='#312100'>" + BIS_AdvHints_TAction + "</t>";
		_addLine = true;
	};
	
	//binds
	if (typeName(BIS_AdvHints_TBinds) == "STRING") then {
		if (BIS_AdvHints_TBinds != "") then {
			//add an empty line
			if (_addLine) then {
				_r = _r + "<br/><br/>";
			};
			
			_r = _r +  localize "STR_EP1_adv_hints.sqf55" + BIS_AdvHints_ImgLineThin + "<br/>" + BIS_AdvHints_TBinds;
		};
	} else {
		//add an empty line
		if (_addLine) then {
			_r = _r + "<br/><br/>";
		};
		
		_r = _r +  localize "STR_EP1_adv_hints.sqf58" + BIS_AdvHints_ImgLineThin + "<br/>";			
		
		_count = count(BIS_AdvHints_TBinds) - 1;
		_params = [];

		_format = [_r + (BIS_AdvHints_TBinds select 0)];

		for "_i" from 1 to _count do {
			_params = _params + [BIS_AdvHints_TBinds select _i];
			_format = _format + ["%" + str(_i)];
		};

		_r = [format _format] + _params;
	};
	
	//reset optional parameters
	BIS_AdvHints_TImp = "";
	
	_r
};

BIS_AdvHints_createWelcome = {
	private["_mission","_objectives","_title","_content","_gfxWelcome"];
	
	//set hint defaults
	call BIS_AdvHints_setDefaults;
	
	//hack
	//call BIS_runIconDemo;
	
	_gfxWelcome = "<img color='#ffffff' image='img\gfx_welcome_ca.paa' align='center' size='6.25'/>";
	
	_mission = _this select 0;
	_objectives = _this select 1;

	_title = "<t color='#e6b448' shadow='1' shadowColor='#312100' size='1.6' align='center'>"+_mission+"</t><br/>";
	_content =  "<t color='#e6b448'>" + localize "STR_EP1_fcuk15" + "</t>" + "<br/>" + BIS_AdvHints_ImgLine;
	
	{
		
		_content = _content + "<br/>" + BIS_AdvHints_ImgBullet + _x;
	
	} forEach _objectives;

	
	BIS_AdvHints_Header =  localize "STR_EP1_adv_hints.sqf64";
	BIS_AdvHints_Text = _title + "<br/>" + _gfxWelcome + "<br/><br/>" + _content;
	BIS_AdvHints_Pause = true;
	BIS_AdvHints_Duration = 10;
	call BIS_AdvHints_showHint;
};


BIS_AdvHints_PauseGame = {
	private["_length"];
	
	_length = 1;
	
	//["Paused!"] call BIS_debugLog;
	
	//color: desaturate
	BIS_AdvHints_ppColor ppEffectAdjust [1, 1.02, -0.005, [0.0, 0.0, 0.0, 0.0], [1, 1, 1, 0],  [0.199, 0.587, 0.114, 0.0]];
	BIS_AdvHints_ppColor ppEffectCommit _length;
	BIS_AdvHints_ppColor ppEffectEnable true;	
	
	//dynamic blur
	BIS_AdvHints_ppBlur ppEffectAdjust [0.75];
	BIS_AdvHints_ppBlur ppEffectCommit _length;
	BIS_AdvHints_ppBlur ppEffectEnable true;	

	//radial blur: apply
	//"radialBlur" ppEffectAdjust [0.0075, 0.0075, 0.005, 0.005];
	//"radialBlur" ppEffectCommit _length;
	//"radialBlur" ppEffectEnable true;
	
	//film grain: turn off
	//"filmGrain" ppEffectAdjust [0.8,10,1,1,1,true];
	//"filmGrain" ppEffectCommit 2;
	//"filmGrain" ppEffectEnable true;	
	
	[] spawn {
		private["_objects"];
		
		if (vehicle player != player) then {
			_objects = crew vehicle player;
			_objects = _objects + [vehicle player];
		} else {
			_objects = [player];
		};
		
		{
			//["Paused object",_x] call BIS_debugLog;
			
			_x enableSimulation false;
			
		} forEach _objects;
		
		BIS_AdvHints_PausedObjects = _objects;
		BIS_AdvHints_GamePaused = true;
	};
};

BIS_AdvHints_UnPauseGame = {
	private["_length"];
	
	_length = 1;	
	
	//["UnPaused!"] call BIS_debugLog;

	//color: revert back from B/W
	BIS_AdvHints_ppColor ppEffectAdjust [1, 1.02, -0.005, [0.0, 0.0, 0.0, 0.0], [1, 1, 0.7, 0.65],  [0.199, 0.587, 0.114, 0.0]];
	BIS_AdvHints_ppColor ppEffectCommit _length;
	BIS_AdvHints_ppColor ppEffectEnable true;

	//dynamic blur
	BIS_AdvHints_ppBlur ppEffectAdjust [0.0];
	BIS_AdvHints_ppBlur ppEffectCommit _length;
	BIS_AdvHints_ppBlur ppEffectEnable true;

	_length spawn {
		sleep _this;
		BIS_AdvHints_ppColor ppEffectEnable false;
		BIS_AdvHints_ppBlur ppEffectEnable false;
	};
		
	//radial blur: remove
	//"radialBlur" ppEffectAdjust [0.0, 0.0, 0, 0];
	//"radialBlur" ppEffectCommit _length;
	//"radialBlur" ppEffectEnable true;
		
	//film grain: turn off
	//"filmGrain" ppEffectAdjust [0,10,1,1,1,true];
	//"filmGrain" ppEffectCommit 2;
	//"filmGrain" ppEffectEnable true;	
	
	{
		//["Un-paused object",_x] call BIS_debugLog;
		
		_x enableSimulation true;
		
	} forEach BIS_AdvHints_PausedObjects;	
	
	BIS_AdvHints_PausedObjects = [];
	BIS_AdvHints_GamePaused = false;
};
