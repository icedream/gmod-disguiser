/**
 * Disguiser SWEP - Lets you disguise as any prop on a map.
 *
 * File:
 *   cl_fxfake.lua
 *
 * Purpose:
 *   Fake client-side effects via a user message trigger from server-side, as for some
 *   reason these effects are not rendered on client-side automatically.
 *
 * Copyright (C) 2013 Carl Kittelberger (Icedream)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

usermessage.Hook("disguiserShootFX", function(um)
	local hitpos = um:ReadVector()
	local hitnormal = um:ReadVectorNormal()
	local entity = um:ReadEntity()
	local physbone = um:ReadLong()
	local bFirstTimePredicted = um:ReadBool()
	
	-- Can we trigger shoot effect yet?
	swep = LocalPlayer():GetActiveWeapon()
	if !swep.DoShootEffect then return false end
	
	-- Render shoot effect
	swep:DoShootEffect(
		hitpos, hitnormal, entity, physbone, bFirstTimePredicted)
end)