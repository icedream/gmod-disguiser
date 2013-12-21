/**
 * Disguiser SWEP - Lets you disguise as any prop on a map.
 *
 * File:
 *   cl_init.lua
 *
 * Purpose:
 *   Initializes client-side stuff like display information and server-side
 *   trigger hooks.
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

 // DEBUG DEBUG DEBUG
print("[Disguiser] Loading clientside...")

// Shared stuff
include("sh_init.lua")

// Weapon info for client
SWEP.PrintName = "Disguiser"
SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.DrawCrosshair = true
SWEP.WepSelectIcon = surface.GetTextureID("vgui/gmod_tool" )
SWEP.Gradient = surface.GetTextureID("gui/gradient" )
SWEP.InfoIcon = surface.GetTextureID("gui/info")

local BannedPropError_Entity = nil
local BannedPropError_Time = 5
local function BannedPropError()
	AddWorldTip(
		BannedPropError_Entity:EntIndex(),
		"You can not use this prop, it has been banned by the server.",
		0.02,
		BannedPropError_Entity:GetPos(),
		BannedPropError_Entity)
	if BannedPropError_Time < 5 then
		BannedPropError_Time = BannedPropError_Time + 0.02
		timer.Simple(0.02, BannedPropError)
	end
end

usermessage.Hook("cantDisguiseAsBannedProp", function(um)
	local entity = um:ReadEntity()
	surface.PlaySound("resource/warning.wav")
	
	// Fallback to raw print if we can't have our beloved sandbox AddWorldTip
	if !!AddWorldTip then
		// I hate how AddWorldTip hardcodes the worldtip time to 0.05 seconds.
		// Let's make a timer to avoid additional graphic hooks.
		BannedPropError_Entity = entity
		if (BannedPropError_Time or 5) >= 5 then
			BannedPropError_Time = 0
			BannedPropError()
		end
		BannedPropError_Time = 0
	else
		chat.AddText(Color(255, 0, 0), "You can not use this prop, it has been banned by the server.")
	end
end)

// this is usually triggered on left mouse click
function SWEP:PrimaryAttack()
end

// this is usually triggered on right mouse click
function SWEP:SecondaryAttack()
end

include("cl_fxfake.lua")
include("cl_3rdperson.lua")
include("cl_obb.lua")