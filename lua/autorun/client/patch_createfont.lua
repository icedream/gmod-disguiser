/**
 * Disguiser SWEP - Lets you disguise as any prop on a map.
 *
 * File:
 *   patch_createfont.lua
 *
 * Purpose:
 *   This code will allow any font to be checked for existence. I hope it works
 *   as it is only a function patch which should be loaded right at the beginning.
 *   Can't guarantee that it loads right at the beginning though.
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

print("[Disguiser] Loading compatibility layer for surface.CreateFont...")

local registered_fonts = {}

// Function already patched by us?
if !!surface.__createFont then
	MsgC(Color(255, 255, 0), "[Fontpatch] Can't patch surface.CreateFont, already patched. Skipping patch.\n")
	return
end

// Original function
surface.__createFont = surface.CreateFont

// Patch function
function surface.CreateFont(name, data)
	if !name || !data then return false end

	if !!registered_fonts[name] then
		MsgN("[Fontpatch] Skipping font " .. name .. ", already registered")
	else
		MsgN("[Fontpatch] Registering font " .. name .. "...")
	end
	registered_fonts[name] = true
	surface.__createFont(name, data)
end

// Check if a font exists
function surface.FontExists(name)
	return !!registered_fonts[name] // I love how all those peeps on the internet still don't use the !! thingie
end