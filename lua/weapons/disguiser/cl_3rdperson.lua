/**
 * Disguiser SWEP - Lets you disguise as any prop on a map.
 *
 * File:
 *   cl_3rdperson.lua
 *
 * Purpose:
 *   Implements proper third-person view for disguised players. Yes, not
 *   all of this code is done by my hands, it's rather shortened and moved
 *   around (read: "optimized") especially for props.
 *   Not sure if this was where I got the code from, but you can find at
 *   least old code here: http://garrysmod.org/downloads/?a=view&id=120806
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

hook.Add("CalcView", "Disguiser.ThirdPersonCalcView", function(player, pos, angles, fov)
	local smoothscale = 1
	
	if !IsValid(player) then return end
	
	if player:GetNetworkedBool("thirdperson") then
		angles = player:GetAimVector():Angle()

		local targetpos = Vector(0, 0, player:OBBMaxs().z)
		if player:KeyDown(IN_DUCK) then
			if player:GetVelocity():Length() > 0 then
				targetpos.z = targetpos.z / 1.33
		 	else
				targetpos.z = targetpos.z / 2
			end
		end

		player:SetAngles(angles)
		
		local targetfov = fov
		if player:GetVelocity():DotProduct(player:GetForward()) > 10 then
			if player:KeyDown(IN_SPEED) then
				targetpos = targetpos + player:GetForward() * -10
			else
				targetpos = targetpos + player:GetForward() * -5
			end
		end 
		
		// smoothing - approaches a bit more slowly to the actual target position
		pos = Vector(
			math.Approach(pos.x, targetpos.x, math.abs(targetpos.x - pos.x) * smoothscale),
			math.Approach(pos.y, targetpos.y, math.abs(targetpos.y - pos.y) * smoothscale),
			math.Approach(pos.z, targetpos.z, math.abs(targetpos.z - pos.z) * smoothscale)
		)
		
		// offset it by the stored amounts, but trace so it stays outside walls
		// we don't smooth this so the camera feels like its tightly following the mouse
		local offset = Vector(50 + (player:OBBMaxs().z - player:OBBMins().z), 0, 10)
		local t = {
			start = player:GetPos() + pos,
			endpos = (player:GetPos() + pos)
				+ (angles:Forward() * -offset.x)
				+ (angles:Right() * offset.y)
				+ (angles:Up() * offset.z),
			filter = player
		}
		if player:GetVehicle():IsValid() then
			pos = t.endpos
		else
			local tr = util.TraceLine(t)
			pos = tr.HitPos
			if tr.Fraction < 1.0 then
				pos = pos + tr.HitNormal
			end
		end

		// Smoothing FOV change
		fov = targetfov
		fov = math.Approach(fov, targetfov, math.abs(targetfov - fov) * smoothscale)
		
		return GAMEMODE:CalcView(player, pos, angles, fov)
	end
end)

hook.Add("HUDPaint", "Disguiser.ThirdPersonHUDPaint", function()
	local player = LocalPlayer()
	if !IsValid(player) then
		return
	end

	if player:GetNetworkedBool("thirdperson") && player:Alive() then
		// trace from muzzle to hit pos
		local t = {}
		t.start = player:GetShootPos()
		t.endpos = t.start + player:GetAimVector() * 9000
		t.filter = player
		local tr = util.TraceLine(t)
		local pos = tr.HitPos:ToScreen()
		local fraction = math.min((tr.HitPos - t.start):Length(), 1024) / 1024
		local size = 10 + 20 * (1.0 - fraction)
		local offset = size * 0.5
		local offset2 = offset - (size * 0.1)
		local hit = tr.HitNonWorld

		// trace from camera to hit pos, if blocked, red crosshair
		local tr = util.TraceLine({
			start = player:GetPos(),
			endpos = tr.HitPos + tr.HitNormal * 5,
			filter = player,
			mask = MASK_SHOT
		})
		surface.SetDrawColor(255, 255, 255, 255)
		if (hit) then
			surface.SetDrawColor(0, 192, 24, 255)
		end
		surface.DrawLine(pos.x - offset, pos.y, pos.x - offset2, pos.y)
		surface.DrawLine(pos.x + offset, pos.y, pos.x + offset2, pos.y)
		surface.DrawLine(pos.x, pos.y - offset, pos.x, pos.y - offset2)
		surface.DrawLine(pos.x, pos.y + offset, pos.x, pos.y + offset2)
		surface.DrawLine(pos.x - 1, pos.y, pos.x + 1, pos.y)
		surface.DrawLine(pos.x, pos.y - 1, pos.x, pos.y + 1)
	end
end)

hook.Add("HUDShouldDraw", "Disguiser.ThirdPersonHUDShouldDraw", function(name)
	if name == "CHudCrosshair" and LocalPlayer():GetNetworkedInt("thirdperson") == 1 then
		return false
	end
end)