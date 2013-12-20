/**
 * Disguiser SWEP - Lets you disguise as any prop on a map.
 *
 * File:
 *   cl_obb.lua
 *
 * Purpose:
 *   Apply correct object bounding box to the player from the prop it is
 *   going to disguise as.
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

// Fun fact: "ResetHull" was the old name for the usermessage trigger
// to reset the hull as it was also implemented in the Prop Hunt code.
// I didn't bother changing it to "setBounding". It would just take up
// more bytes for string pooling (and I'm too lazy to change it and I
// like to write comments about this instead).
usermessage.Hook("resetHull", function(um)
	// message input
	local player = um:ReadEntity()
	
	// actually reset the hull
	player:ResetHull()
end)

// Triggers right after server-side disguise action so the player has correct
// bounding box.
usermessage.Hook("setBounding", function(um)
	// message input
	local player = um:ReadEntity()
	local obbmins = um:ReadVector()
	local obbmaxs = um:ReadVector()

	// hull from given vectors
	player:SetHull(obbmins, obbmaxs)
	player:SetHullDuck(obbmins, obbmaxs) -- ducking shouldn't work for props
end)
