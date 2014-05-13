private ["_clientID","_character","_traderid","_retrader","_data","_result","_status","_val","_key","_key2","_data2"];
//[dayz_characterID,_tent,[_dir,_location],"TentStorage"]
_character = _this select 0;
_traderid = _this select 1;

_clientID = owner _character;
//diag_log ("HIVE: Menu Request by ClientID: "+ str(_clientID));

// add cacheing
_retrader = call compile format["ServerTcache_%1;",_traderid];

if(isNil "_retrader") then {
	
	_retrader = [];

	//_key = format["CHILD:399:%1:",_traderid];
	//_data = "HiveEXT" callExtension _key;
	_key2 		= format["SELECT COUNT(*) FROM `traders_data` WHERE `tid`=%1",_traderid];
	_data2 = _key2 call server_hiveRead;
	_val = _data2 select 0 select 0;
	
	_key 		= format["SELECT `id`, `item`, `qty`, `buy`, `sell`, `order`, `tid`, `afile` FROM `Traders_DATA` WHERE `tid`=%1",_traderid];
	_data = _key call server_hiveReadWriteLarge;
	_result = _data select 0;
	//diag_log format["----------%1",_result];
	diag_log "HIVE: Request sent";
		
	//Process result
	//_result = call compile _result select 0;
	
	//diag_log format["val: %1", _val];
	 _val = parseNumber(_val);
		//_val = _result select 2;
		//_val = parseNumber(_val);
		//Stream Objects
		//diag_log ("HIVE: Commence Menu Streaming...");
		call compile format["ServerTcache_%1 = [];",_traderid];
		for "_i" from 0 to (_val -1) do {
			//diag_log format["----result: %1", _result select _i];
			format["ServerTcache_%1 set [count ServerTcache_%1,%2]",_traderid,_result select _i];
			_retrader set [count _retrader,_result];
		};
		diag_log ("HIVE: Streamed " + str(_val) + " objects");

};

// diag_log(_retrader);
PVDZE_plr_TradeMenuResult = _retrader select 0;
if(!isNull _character) then {
	_clientID publicVariableClient "PVDZE_plr_TradeMenuResult";
};