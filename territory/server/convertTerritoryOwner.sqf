//	@file Name: convertTerritoryOwner.sqf
//	@file Author: AgentRev

private ["_territory", "_oldGroup", "_newGroup", "_currentTeam"];

_territory = _this select 0;
_oldGroup = _this select 1;
_newGroup = _this select 2;

{
	_currentTeam = _x select 2;
	
	if (typeName _currentTeam == typeName _oldGroup && {_currentTeam == _oldGroup}) then
	{
		_x set [2, _newGroup];
		_x set [3, 0]; // reset chrono
	};
} forEach currentTerritoryDetails;
