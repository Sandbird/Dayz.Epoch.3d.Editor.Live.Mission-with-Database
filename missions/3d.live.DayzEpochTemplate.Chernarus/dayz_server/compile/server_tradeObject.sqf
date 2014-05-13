private ["_traderid","_buyorsell","_data","_result","_key","_outcome","_clientID","_player","_classname","_traderCity","_currency","_qty","_price","_key2","_data2"];

_player =		_this select 0;
_traderID = 	_this select 1;
_buyorsell = 	_this select 2;	//0 > Buy // 1 > Sell
_classname =	_this select 3;
_traderCity = 	_this select 4;
_currency =	_this select 5;
_qty =		_this select 6;
_clientID = 	owner _player;
_price = format ["%2x %1",_currency,_qty];

if (_buyorsell == 0) then { //Buy
diag_log format["EPOCH SERVERTRADE: Player: %1 (%2) bought a %3 in/at %4 for %5", (name _player), (_player getVariable ["playerUID", "0"]), _classname, _traderCity, _price];
} else { //SELL
diag_log format["EPOCH SERVERTRADE: Player: %1 (%2) sold a %3 in/at %4 for %5",(name _player), (_player getVariable ["playerUID", "0"]), _classname, _traderCity, _price];
};

if (DZE_ConfigTrader) then {
	_outcome = "PASS";
} else {
	//Send request
	//_key = format["CHILD:398:%1:%2:",_traderID,_buyorsell];
	_key 		= format["SELECT `qty` FROM `Traders_DATA` WHERE `id`=%1",_traderID];
	_data = _key call server_hiveRead;
	_result = _data select 0 select 0;
	_result = parseNumber(_result);
	
	if (_buyorsell == 0) then {
			if (_result !=0) then {
				_key = format["UPDATE Traders_DATA SET qty = qty - 1 WHERE id= '%1'",_traderID];
				diag_log ("HIVE: WRITE: "+ str(_key)); 
				_key call server_hiveWrite;	
				_outcome = "PASS";
			} else {
				_outcome = "ERROR";
			};
	}else{
		_key = format["UPDATE Traders_DATA SET qty = qty + 1 WHERE id= '%1'",_traderID];
		diag_log ("HIVE: WRITE: "+ str(_key)); 
		_key call server_hiveWrite;	
		_outcome = "PASS";
	};
	
	//_result = _data select 0;
	//_result = call compile format ["%1",_result];
	// diag_log ("TRADE: RES: "+ str(_result));
	//_outcome = _result select 0;
};

dayzTradeResult = _outcome;
if(!isNull _player) then {
	_clientID publicVariableClient "dayzTradeResult";
};
