/**
 * Disguiser SWEP - Lets you disguise as any prop on a map.
 *
 * File:
 *   cl_worldtips.lua
 *
 * Purpose:
 *   First, yes, this is a ripoff from the GMod lua code repository. Yes, this
 *   is thought as a compatibility layer for non-sandbox gamemodes as I'm sick
 *   and tired of text-only warnings. So this will fill the empty space called
 *   "world tips" if they aren't already existing yet.
 *   The original code has been written by GMod creator Garry Newman himself.
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

// We use the font patch from autostart here
if !surface.FontExists then
	MsgC(Color(255, 255, 0), "The font patch did not load yet. Might make trouble with surface.CreateFont. Look out for errors!")
end
if !surface:FontExists("GModWorldtip") then
	surface.CreateFont( "GModWorldtip",
	{
		font = "Helvetica",
		size = 20,
		weight = 700
	})
end

local need_AddWorldTip = !AddWorldTip
local need_GM_PaintWorldTips = false

// Let's hope the gamemode is patchable
GM = GM or GAMEMODE or nil
if need_AddWorldTip then
	if GM == nil then
		GM = {}
		MsgC(Color(255, 255, 0), "Can not apply worldtip patch to GAMEMODE! Will not display any balloon tips!")
	else
		need_GM_PaintWorldTips = !GAMEMODE.PaintWorldTips
	end
end

local needPatch = need_AddWorldTip || need_GM_PaintWorldTips

// Check if we have to create the compatibility layer
if !needPatch then
	local cl_drawworldtooltips = CreateConVar( "cl_drawworldtooltips", "1", { FCVAR_ARCHIVE } )
	local WorldTip = nil

	local TipColor = Color( 250, 250, 200, 255 )

	function AddWorldTip(_1, text, _2, pos, entity)
		WorldTip = {
			dietime = SysTime() + 0.05,
			["text"] = text,
			["pos"] = pos,
			["ent"] = ent
		}
	end

	if !!GM then
		local function DrawWorldTip( tip )
			if ( IsValid( tip.ent ) ) then        
					tip.pos = tip.ent:GetPos()
			end
				
			local pos = tip.pos:ToScreen()
				
			local black = Color( 0, 0, 0, 255 )
			local tipcol = Color( TipColor.r, TipColor.g, TipColor.b, 255 )
			
			local x = 0
			local y = 0
			local padding = 10
			local offset = 50
				
			surface.SetFont( "GModWorldtip" )
			local w, h = surface.GetTextSize( tip.text )
				
			x = pos.x - w
			y = pos.y - h
				
			x = x - offset
			y = y - offset

			draw.RoundedBox( 8, x-padding-2, y-padding-2, w+padding*2+4, h+padding*2+4, black )
				
			local verts = {}
			verts[1] = { x=x+w/1.5-2, y=y+h+2 }
			verts[2] = { x=x+w+2, y=y+h/2-1 }
			verts[3] = { x=pos.x-offset/2+2, y=pos.y-offset/2+2 }
				
			draw.NoTexture()
			surface.SetDrawColor( 0, 0, 0, tipcol.a )
			surface.DrawPoly( verts )
			
			
			draw.RoundedBox( 8, x-padding, y-padding, w+padding*2, h+padding*2, tipcol )
			
			local verts = {}
			verts[1] = { x=x+w/1.5, y=y+h }
			verts[2] = { x=x+w, y=y+h/2 }
			verts[3] = { x=pos.x-offset/2, y=pos.y-offset/2 }
			
			draw.NoTexture()
			surface.SetDrawColor( tipcol.r, tipcol.g, tipcol.b, tipcol.a )
			surface.DrawPoly( verts )
			
			
			draw.DrawText( tip.text, "GModWorldtip", x + w/2, y, black, TEXT_ALIGN_CENTER )
		end

		function GM:PaintWorldTips()
				if ( !cl_drawworldtooltips:GetBool() ) then return end
				
				if ( WorldTip && WorldTip.dietime > SysTime() ) then
						DrawWorldTip( WorldTip )                
				end
		end
	end
end