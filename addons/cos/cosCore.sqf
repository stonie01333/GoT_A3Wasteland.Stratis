if (!isServer) exitWith {};
private ["_groupCount","_localGrpCount","_grp","_rdCount","_n","_r","_tempUnit"];
_mkr= (_this select 0);

// Get trigger status
_trigID=format["trig%1", _mkr];
_isActive=server getvariable _trigID;

// Get stored town variables
_popVar=format["population%1", _mkr];
_information=server getvariable _popVar;
	_civilians=(_information select 0);
	_roadPosArray=(_information select 1);


_showRoads=false;				
_glbGrps=server getvariable "cosGrpCount";
_townGrp=createGroup DefaultSide;
_localGrps=1;

waituntil {!populating_COS};
populating_COS=true;
_glbGrps=server getvariable "cosGrpCount";


//SPAWN CIVILIANS NOW
_civilianArray=[];

_roadPosArray=_roadPosArray call BIS_fnc_arrayShuffle;	
_UnitList=COScivPool call BIS_fnc_arrayShuffle;	
_countPool=count _UnitList;
_n=0;
_rdCount=0;

// SPAWN PEDESTRIANS
for "_i" from 1 to _civilians do {
	if (!(server getvariable _trigID)) exitwith {_isActive=false;};
		
		if (_i >= _countPool) 
			then {
				if (_n >= _countPool) then {_n=0;};
					_tempUnit=_UnitList select _n;
					_n=_n+1;
				};
		if (_i < _countPool) 
			then {
			_tempUnit=_UnitList select _i;
				};						
						
		_tempPos=_roadPosArray select _rdCount;
		_rdCount=_rdCount+1;
		
		if (COSmaxGrps < (_glbGrps+_localGrps+1)) 
					then {
			_grp=_townGrp;	
					}else{
				_grp=createGroup DefaultSide;
				_localGrps=_localGrps+1;
						};

		_unit = [_grp, _tempPos] call createArmedCiv;
		_civilianArray set [count _civilianArray,_grp];
									
				null =[_unit] execVM "addons\cos\addScript_Unit.sqf";
					
					IF (debugCOS) then {
				_txt=format["INF%1,MKR%2",_i,_mkr];
				_debugMkr=createMarker [_txt,getpos _unit];
				_debugMkr setMarkerShape "ICON";
				_debugMkr setMarkerType "hd_dot";
				_debugMkr setMarkerText "Civ Spawn";
						};
					};
			
// Apply Patrol script to all units
null =[_civilianArray,_roadPosArray] execVM "addons\cos\CosPatrol.sqf";

if (debugCOS) then {player sidechat  (format ["Roads used:%1. Roads Stored %2",_rdCount,count _roadPosArray])};		
			
// Count groups 		
_glbGrps=server getvariable "cosGrpCount";
_glbGrps=_glbGrps+_localGrps;
server setvariable ["cosGrpCount",_glbGrps];
populating_COS=false;

// Show town label if town still active
if (showTownLabel and (server getvariable _trigID)) 
	then {
	
	COSTownLabel=[(_civilians),_mkr];PUBLICVARIABLE "COSTownLabel";
	_population=format ["Population: %1",_civilians];
		0=[markerText _mkr,_population] spawn BIS_fnc_infoText;// FOR USE IN SINGLEPLAYER
		};

		
// Check every second until trigger is deactivated
 while {_isActive} do
		{
	_isActive=server getvariable _trigID;
		if (!_isActive) exitwith {};
		sleep 1;
		};

// If another town is populating wait until it has finished before deleting population
waituntil {!populating_COS};

// Delete all pedestrians
 _counter=0;		
			{
	_grp=_x;
	_counter=_counter+1;
		if (debugCOS) then { deletemarker (format["INF%1,MKR%2",_counter,_mkr]);};
		{ deleteVehicle _x } forEach units _grp;
		deleteGroup _grp;  
				}foreach _civilianArray;

deletegroup _townGrp;

// Update global groups
_glbGrps=server getvariable "cosGrpCount";
_glbGrps=_glbGrps-_localGrps;
server setvariable ["cosGrpCount",_glbGrps];
