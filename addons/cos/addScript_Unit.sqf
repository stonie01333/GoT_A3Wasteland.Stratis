/*
Add Script to individual units spawned by COS.
_unit = unit. Refer to Unit as _unit.
*/

_unit =(_this select 0);
_unit addAction ["Hello", {hint "Civillian units (even when armed) will not attack you unless they are threatened."}];// EXAMPLE SCRIPT