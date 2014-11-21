// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Version: 1.0
//	@file Name: mission_HostileInfantry.sqf
//	@file Author: [404] Deadbeat, [404] Costlyy, JoSchaap, AgentRev, Zenophon
//	@file Created: 08/12/2012 15:19
//  @file Information: JoSchaap's Lite version of 'Infantry Occupy House' Original was made by: Zenophon

if (!isServer) exitwith {};

#include "sideMissionDefines.sqf"

private ["_nbUnits", "_box1", "_box2", "_townName", "_missionPos", "_buildingRadius", "_putOnRoof", "_fillEvenly"];

_setupVars =
{
	_missionType = "Town Invasion";
	_nbUnits = if (missionDifficultyHard) then { AI_GROUP_LARGE } else { AI_GROUP_MEDIUM };
	
	// settings for this mission
	_locArray = ((call cityList) call BIS_fnc_selectRandom);
	_missionPos = markerPos (_locArray select 0);
	_buildingRadius = _locArray select 1;
	_townName = _locArray select 2;
	_putOnRoof = true;
	_fillEvenly = true;
};

_setupObjects =
{
	// spawn some crates in the middle of town (Town marker position)	
	_box1 = createVehicle ["Box_NATO_Wps_F", _missionPos, [], 5, "None"];
	_box1 setDir random 360;
	[_box1, "mission_USSpecial"] call fn_refillbox;
	
	_box2 = createVehicle ["Box_East_Wps_F", _missionPos, [], 5, "None"];
	_box2 setDir random 360;
	[_box2, "mission_USLaunchers"] call fn_refillbox;
	
	{ _x setVariable ["R3F_LOG_disabled", true, true] } forEach [_box1, _box2];
	
	// spawn some rebels/enemies :)
	_aiGroup = createGroup CIVILIAN;
	[_aiGroup, _missionPos, _nbUnits] call createCustomGroup2;
	
	// move them into buildings
	[_aiGroup, _missionPos, _buildingRadius, _fillEvenly, _putOnRoof] call moveIntoBuildings;
		
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
