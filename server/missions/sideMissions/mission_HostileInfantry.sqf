// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Version: 1.0
//	@file Name: mission_HostileInfantry.sqf
//	@file Author: [404] Deadbeat, [404] Costlyy, JoSchaap, AgentRev, Zenophon
//	@file Created: 08/12/2012 15:19
//  @file Information: JoSchaap's Lite version of 'Infantry Occupy House' Original was made by: Zenophon

if (!isServer) exitwith {};
#define I(X) X = X + 1;
#define EYE_HEIGHT 1.53
#define CHECK_DISTANCE 5
#define FOV_ANGLE 15
#define ROOF_CHECK 4
#define ROOF_EDGE 2

#include "sideMissionDefines.sqf"

private ["_nbUnits", "_units", "_box1", "_box2", "_ExtendPosition", "_townName", "_missionPos", "_buildingRadius", "_putOnRoof", "_fillEvenly", "_buildingsArray", "_buildingPosArray", "_buildingPositions", "_posArray", "_unitIndex", "_j", "_building", "_posArray", "_randomIndex", "_housePos", "_startAngle", "_i", "_checkPos", "_hitCount", "_isRoof", "_edge", "_k", "_unUsedUnits"];

_setupVars =
{
	_missionType = "Town Invasion";
	_locationsArray = nil;
	_nbUnits = if (missionDifficultyHard) then { AI_GROUP_LARGE } else { AI_GROUP_MEDIUM };
};

_ExtendPosition = 
{
    private ["_missionPos", "_dist", "_phi"];
    _missionPos = _this select 0;
    _dist = _this select 1;
    _phi = _this select 2;
    ([(_missionPos select 0) + (_dist * (cos _phi)),(_missionPos select 1) + (_dist * (sin _phi)), (_this select 3)])
};

_setupObjects =
{
		_locArray = ((call cityList) call BIS_fnc_selectRandom);
		_missionPos = markerPos (_locArray select 0);
		_buildingRadius = _locArray select 1;
		_townName = _locArray select 2;
		_putOnRoof = true;
		_fillEvenly = true;
		_buildingsArray = nearestObjects [_missionPos, ["house"], _buildingRadius];
		
		_buildingPosArray = [];
		{
			_buildingPositions = 0;
			for "_i" from 0 to 100 do 
			{
				if ((_x buildingPos _buildingPositions) isEqualTo [0,0,0]) exitWith {};
				I(_buildingPositions)
			};

			_posArray = [];
			for "_i" from 0 to (_buildingPositions - 1) do 
			{
				_posArray set [_i, _i];
			};

			_buildingPosArray set [_forEachIndex, _posArray];
		} forEach _buildingsArray;

		_box1 = createVehicle ["Box_NATO_Wps_F", _missionPos, [], 5, "None"];
		_box1 setDir random 360;
		[_box1, "mission_USSpecial"] call fn_refillbox;

		_box2 = createVehicle ["Box_East_Wps_F", _missionPos, [], 5, "None"];
		_box2 setDir random 360;
		[_box2, "mission_USLaunchers"] call fn_refillbox;

		{ _x setVariable ["R3F_LOG_disabled", true, true] } forEach [_box1, _box2];

		_aiGroup = createGroup CIVILIAN;
		[_aiGroup, _missionPos, _nbUnits] call createCustomGroup2;
		
		_units = units _aiGroup;
		_unitIndex = 0;
		for [{_j = 0}, {(_unitIndex < count _units) && {(count _buildingPosArray > 0)}}, {I(_j)}] do {
		scopeName "for";

		_building = _buildingsArray select (_j % (count _buildingsArray));
		_posArray = _buildingPosArray select (_j % (count _buildingsArray));

		if (count _posArray == 0) then 
		{
			_buildingsArray set [(_j % (count _buildingsArray)), 0];
			_buildingPosArray set [(_j % (count _buildingPosArray)), 0];
			_buildingsArray = _buildingsArray - [0];
			_buildingPosArray = _buildingPosArray - [0];
		};

		while {(count _posArray) > 0} do 
		{
			scopeName "while";
			if (_unitIndex >= count _units) exitWith {};

			_randomIndex = floor random count _posArray;
			_housePos = _building buildingPos (_posArray select _randomIndex);
			_housePos = [(_housePos select 0), (_housePos select 1), (_housePos select 2) + (getTerrainHeightASL _housePos) + EYE_HEIGHT];

			_posArray set [_randomIndex, _posArray select (count _posArray - 1)];
			_posArray resize (count _posArray - 1);

			_startAngle = (round random 10) * (round random 36);
			for "_i" from _startAngle to (_startAngle + 350) step 10 do 
			{
				_checkPos = [_housePos, CHECK_DISTANCE, (90 - _i), (_housePos select 2)] call _ExtendPosition;
				if !(lineIntersects [_checkPos, [_checkPos select 0, _checkPos select 1, (_checkPos select 2) + 25], objNull, objNull]) then 
				{
					if !(lineIntersects [_housePos, _checkPos, objNull, objNull]) then 
					{
						_checkPos = [_housePos, CHECK_DISTANCE, (90 - _i), (_housePos select 2) + (CHECK_DISTANCE * sin FOV_ANGLE / cos FOV_ANGLE)] call _ExtendPosition;
						if !(lineIntersects [_housePos, _checkPos, objNull, objNull]) then 
						{
							_hitCount = 0;
							for "_k" from 30 to 360 step 30 do 
							{
								_checkPos = [_housePos, 20, (90 - _k), (_housePos select 2)] call _ExtendPosition;
								if (lineIntersects [_housePos, _checkPos, objNull, objNull]) then 
								{
									I(_hitCount)
								};

								if (_hitCount >= ROOF_CHECK) exitWith {};
							};

							_isRoof = (_hitCount < ROOF_CHECK) && {!(lineIntersects [_housePos, [_housePos select 0, _housePos select 1, (_housePos select 2) + 25], objNull, objNull])};
							if (!(_isRoof) || {((_isRoof) && {(_putOnRoof)})}) then 
							{
								if (_isRoof) then 
								{
									_edge = false;
									for "_k" from 30 to 360 step 30 do 
									{
										_checkPos = [_housePos, ROOF_EDGE, (90 - _k), (_housePos select 2)] call _ExtendPosition;
										_edge = !(lineIntersects [_checkPos, [(_checkPos select 0), (_checkPos select 1), (_checkPos select 2) - EYE_HEIGHT - 1], objNull, objNull]);

										if (_edge) exitWith 
										{
											_i = _k;
										};
									};
								};

								if (!(_isRoof) || {_edge}) then 
								{
									(_units select _unitIndex) setPosASL [(_housePos select 0), (_housePos select 1), (_housePos select 2) - EYE_HEIGHT];
									(_units select _unitIndex) setDir (_i );

									if (_isRoof) then 
									{
										(_units select _unitIndex) setUnitPos "MIDDLE";
									} else {
										(_units select _unitIndex) setUnitPos "UP";
									};

									(_units select _unitIndex) lookAt ([_housePos, CHECK_DISTANCE, (90 - _i), (_housePos select 2) - (getTerrainHeightASL _housePos)] call _ExtendPosition);
									doStop (_units select _unitIndex);

									I(_unitIndex)
									if (_fillEvenly) then 
									{
										breakTo "for";
									} else {
										breakTo "while";
									};
								};
							};
						};
					};
				};
			};
		};	
	};

	_missionHintText = format ["Hostiles have taken over <t color='%1'>%2</t> There seem to be <t color='%1'>%3 enemies</t> hiding inside or on top of buildings. Get rid of them and you can take their supplies!.<br/>Watch out for those windows!", sideMissionColor, _townName, _nbUnits];
};

_waitUntilMarkerPos = nil;
_waitUntilExec = nil;
_waitUntilCondition = nil;

_failedExec =
{
	// Mission failed
	{ deleteVehicle _x } forEach [_box1, _box2];
};

_successExec =
{
	// Mission completed
	{ _x setVariable ["R3F_LOG_disabled", false, true] } forEach [_box1, _box2];

	_successHintMessage = format ["Nice work!<br/><t color='%1'>%2</t> is a safe place again!", sideMissionColor, _townName];
};

_this call sideMissionProcessor;
