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

hook.Add("CalcView", "Disguiser.ThirdPersonCalcView", function(ply, pos, angles, fov)
	smoothscale = 1
	
	if IsValid(ply) && ply:Alive() && ply:GetNetworkedBool("thirdperson") then
		av = ply:GetAimVector()
		
		if !av then return end
		
		angles = av:Angle()

		local targetpos = Vector(0, 0, ply:OBBMaxs().z)
		if ply:KeyDown(IN_DUCK) then
			if ply:GetVelocity():Length() > 0 then
				targetpos.z = targetpos.z / 1.33
		 	else
				targetpos.z = targetpos.z / 2
			end
		end

		ply:SetAngles(angles)
		
		local targetfov = fov
		if ply:GetVelocity():DotProduct(ply:GetForward()) > 10 then
			if ply:KeyDown(IN_SPEED) then
				targetpos = targetpos + ply:GetForward() * -10
			else
				targetpos = targetpos + ply:GetForward() * -5
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
		local offset = Vector(50 + (ply:OBBMaxs().z - ply:OBBMins().z), 0, 10)
		local t = {
			start = ply:GetPos() + pos,
			endpos = (ply:GetPos() + pos)
				+ (angles:Forward() * -offset.x)
				+ (angles:Right() * offset.y)
				+ (angles:Up() * offset.z),
			filter = ply
		}
		if ply:GetVehicle():IsValid() then
			pos = t.endpos
		else
			local tr = util.TraceLine(t)
			pos = tr.HitPos
			if tr.Fraction < 1.0 then
				pos = pos + tr.HitNormal
			end
		end

		// Smoothing FOV change
		fov = targetfov -- comment or remove this to enable smoothing
		fov = math.Approach(fov, targetfov, math.abs(targetfov - fov) * smoothscale)
		
		return GAMEMODE:CalcView(ply, pos, angles, fov)
	end
end)

hook.Add("HUDPaint", "Disguiser.ThirdPersonHUDPaint", function()
	local ply = LocalPlayer()
	
	if IsValid(ply) && !!ply["GetAimVector"] && ply:Alive() && ply:GetNetworkedBool("thirdperson") then
		// trace from muzzle to hit pos
		local t = {}
		t.start = ply:GetShootPos()
		t.endpos = t.start + ply:GetAimVector() * 9000
		t.filter = ply
		local tr = util.TraceLine(t)
		local pos = tr.HitPos:ToScreen()
		local fraction = math.min((tr.HitPos - t.start):Length(), 1024) / 1024
		local size = 10 + 20 * (1.0 - fraction)
		local offset = size * 0.5
		local offset2 = offset - (size * 0.1)
		local hit = tr.HitNonWorld

		// trace from camera to hit pos, if blocked, red crosshair
		local tr = util.TraceLine({
			start = ply:GetPos(),
			endpos = tr.HitPos + tr.HitNormal * 5,
			filter = ply,
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
	if name == "CHudCrosshair" and IsValid(LocalPlayer()) and LocalPlayer():Alive() and LocalPlayer():GetNetworkedBool("thirdperson") then
		return false
	end
end)