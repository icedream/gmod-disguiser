/**
 * Disguiser SWEP - Lets you disguise as any prop on a map.
 *
 * File:
 *   init.lua
 *
 * Purpose:
 *   Initializes server-side stuff including weapon information, actual weapon
 *   hooks and whatever stuff is also needed to make the server work on servers.
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

 // Weapon info for server
SWEP.Weight = 5
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false
SWEP.ShouldDropOnDie = false

// DEBUG DEBUG DEBUG
print("[Disguiser] Loading serverside...")

// Downloads for the client
// TODO: Dynamic file addition here
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_3rdperson.lua")
AddCSLuaFile("cl_obb.lua")
AddCSLuaFile("cl_fxfake.lua")
AddCSLuaFile("sh_init.lua")

// Shared stuff
include("sh_init.lua")

// Local stuff
SWEP.UndisguiseAs = nil
SWEP.UndisguiseAsMass = nil
SWEP.UndisguiseAsSkin = nil
SWEP.UndisguiseAsSolid = nil
SWEP.UndisguiseAsFullRotation = nil
SWEP.DisguisedAs = nil

// Banned prop models
SWEP.PropConfiguration = {
	["models/props/cs_assault/dollar.mdl"] = {
		Banned = true
	},
	["models/props/cs_assault/money.mdl"] = {
		Banned = true
	},
	["models/props/cs_office/snowman_arm.mdl"] = {
		Banned = true
	},
	["models/props/cs_office/computer_mouse.mdl"] = {
		Banned = true
	},
	["models/props/cs_office/projector_remote.mdl"] = {
		Banned = true
	},
	["models/props_junk/bicycle01a.mdl"] = {
		// The bicycle in cs_italy has a too big bounding box, you
		// can't even get through doors without this correction
		OBBMinsCorrection = Vector(28, -28, 0),
		OBBMaxsCorrection = Vector(-28, 28, 0)
	}
	// TODO: There is another item on cs_office which needs to be corrected. Forgot which one though.
}

// Door exploits
local ExploitableDoors = {
	"func_door",
	"prop_door_rotating",
	"func_door_rotating"
}

// The actual disguise action
function SWEP:Disguise(entity)
	
	// Make sure the model file is not banned
	if self:HasPropConfig(entity:GetModel()) && self:GetPropConfig(entity:GetModel()).Banned then
		umsg.Start("cantDisguiseAsBannedProp")
		umsg.End()
		return
	end
	
	// Make sure we are valid
	if (!IsValid(self)) then return false end
	
	// Make sure the player is alive and valid
	if (!IsValid(self.Owner) || !self.Owner:Alive()) then return false end
	
	local owner = self.Owner
	
	// Make sure we aren't already that model
	if (owner:GetModel() == entity:GetModel() && owner:GetSkin() == entity:GetSkin()) then return true end
	
	// Make sure the new model is actually marked as a prop
	if (
		string.sub(string.lower(entity:GetClass()), 1, 5) != "prop_"
		&& string.sub(string.lower(entity:GetClass()), -5, -1) != "_prop"
		&& string.find(string.lower(entity:GetClass()), "_prop_") == nil
		) then return false end
	
	local physobj = entity:GetPhysicsObject()
	local ophysobj = owner:GetPhysicsObject()
	
	// Back up model
	if (!self.UndisguiseAs) then
		self.UndisguiseAs = owner:GetModel()
		self.UndisguiseAsSkin = owner:GetSkin()
		self.UndisguiseAsMass = ophysobj:GetMass()
		self.UndisguiseAsColor = owner:GetColor()
		self.UndisguiseAsBloodColor = owner:GetBloodColor()
		self.UndisguiseAsSolid = owner:GetSolid()
		self.UndisguiseAsFullRotation = owner:GetAllowFullRotation()
	end
	
	// Disguise as given model
	self:EnableThirdPerson(owner)
	owner:DrawViewModel(false)
	owner:DrawWorldModel(false)
	owner:SetModel(entity:GetModel())
	owner:SetSolid(SOLID_BSP)
	owner:SetBloodColor(BLOOD_COLOR_RED)
	if entity:GetSkin() != nil then
		owner:SetSkin(entity:GetSkin()) // coloring
	end
	owner:SetColor(entity:GetColor())
	owner:SetPos(owner:GetPos() - Vector(0, 0, entity:OBBMins().z - 2)) // anti-stuck
	
	// Apply new physics, too
	ophysobj:SetMass(physobj:GetMass())
	self:UpdateHealth(math.Clamp(physobj:GetVolume() / 300, 1, 200))
	
	// Apply new hull
	local obbmaxs = entity:OBBMaxs()
	local obbmins = entity:OBBMins()
	/*
	local obbmargin = Vector(2, 2, 0)
	obbmaxs = obbmaxs + obbmargin
	obbmins = obbmins - obbmargin
	*/
	// Look for correction values
	local pcfg = self:GetPropConfig(entity:GetModel())
	if !!pcfg["OBBMaxsCorrection"] then
		obbmaxs = obbmaxs + pcfg["OBBMaxsCorrection"]
	end
	if !!pcfg["OBBMinsCorrection"] then
		obbmins = obbmins + pcfg["OBBMinsCorrection"]
	end
	owner:SetHull(obbmins, obbmaxs)
	owner:SetHullDuck(obbmins, obbmaxs) -- ducking shouldn't work for props
	
	// Notify all clients about the new hull so the player appears
	// correct for everyone
	umsg.Start("setBounding")
	umsg.Entity(owner)
	umsg.Vector(entity:OBBMins())
	umsg.Vector(entity:OBBMaxs())
	umsg.End()
	
	// Pop!
	owner:EmitSound("Disguiser.Disguise")
	
	// We're now disguised!
	self.DisguisedAs = entity:GetModel()
	owner.Disguised = true
	
	// DEBUG DEBUG DEBUG
	print(owner:Name() .. " switched to model " .. entity:GetModel())
	
	return true
end

// Undisguise
function SWEP:Undisguise()
	
	// Make sure we are valid
	if (!IsValid(self)) then return false end
	
	// Make sure the player is alive and valid
	if (!IsValid(self.Owner) || !self.Owner:Alive()) then return false end
	
	// Make sure we are disguised already
	if (self.DisguisedAs == nil) then return false end
	
	// Make sure we have an old model to revert to
	if (self.UndisguiseAs == nil) then return false end
	
	local owner = self.Owner
	local ophysobj = owner:GetPhysicsObject()
	
	// Revert to old model
	owner:SetModel(self.UndisguiseAs)
	owner:SetMoveType(MOVETYPE_WALK)
	if self.UndisguiseAsSkin != nil then
		owner:SetSkin(self.UndisguiseAsSkin)
	end
	owner:SetColor(self.UndisguiseAsColor)
	owner:SetSolid(self.UndisguiseAsSolid)
	owner:SetAllowFullRotation(self.UndisguiseAsFullRotation) // up/down rotation
	owner:SetBloodColor(self.UndisguiseAsBloodColor)
	
	// Revert to old physics
	ophysobj:SetMass(self.UndisguiseAsMass)
	self:UpdateHealth(100)
	
	// Hull reset
	owner:ResetHull()
	owner:SetPos(owner:GetPos() - Vector(0, 0,owner:OBBMins().z - 2)) // anti-stuck
	umsg.Start("resetHull", owner)
	umsg.Entity(owner)
	umsg.End()
	
	// Pop!
	owner:EmitSound("Disguiser.Undisguise")
	
	// We're no longer disguised
	self:DisableThirdPerson(owner)
	owner:DrawViewModel(true)
	owner:DrawWorldModel(true)
	self.UndisguiseAs = nil
	self.DisguisedAs = nil
	owner.Disguised = false
	
	return true
end

function SWEP:UpdateHealth(ent_health)
	local player = self.Owner
	
	if (!player || !IsValid(player)) then return false end
	
	// Scale player health up to entity's maximum health
	local new_health = math.Clamp((player:Health() / player:GetMaxHealth()) * ent_health, 1, 200)
	
	// Transfer to player
	player:SetHealth(new_health)
	player:SetMaxHealth(ent_health)
end

// this is usually triggered on left mouse click
function SWEP:PrimaryAttack()
	local trace = util.TraceLine({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + (self.Owner:GetAimVector() * 900 /* pretty cheaty */),
		filter = self.Owner,
		mask = MASK_SHOT
	})
	
	// Are we aiming at an actual prop?
	local entity = trace.Entity
	if !trace.HitNonWorld
		|| !trace.Entity
		|| !entity:GetModel()
		|| table.HasValue(ExploitableDoors, entity:GetClass()) // banned door exploit
		then
		return false
	end
	
	// Make sure the model is not banned
	if self:GetPropConfig(entity:GetModel()).Banned then
		umsg.Start("cantDisguiseAsBannedProp")
		umsg.Entity(entity)
		umsg.End()
		return false
	end
	
	// Now let's disguise, shall we?
	self:DoShootEffect(trace.HitPos, trace.HitNormal, trace.Entity, trace.PhysicsBone, IsFirstTimePredicted())
	self:Disguise(entity)
	
end

// this is usually triggered on right mouse click
function SWEP:SecondaryAttack()
	self:Undisguise()
end

function SWEP:DisableThirdPerson(player)
	if !player:GetNetworkedBool("thirdperson") then
		return
	end
	
	local entity = player:GetViewEntity()
	player:SetNetworkedBool("thirdperson", false)
	entity:Remove()
	
	player:SetViewEntity(player)
end

function SWEP:EnableThirdPerson(player)
	
	if player:GetNetworkedBool("thirdperson") then
		return
	end
	
	local entity = ents.Create("prop_dynamic")
	entity:SetModel(player:GetModel())
	entity:Spawn()
	entity:SetAngles(player:GetAngles())
	entity:SetMoveType(MOVETYPE_NONE)
	entity:SetParent(player)
	entity:SetOwner(player)
	entity:SetPos(player:GetPos() + Vector(0, 0, 60))
	entity:SetRenderMode(RENDERMODE_NONE)
	entity:SetSolid(SOLID_NONE)
	player:SetViewEntity(entity)
	
	player:SetNetworkedBool("thirdperson", true)
end

hook.Add("PlayerDeath", "Disguiser.ThirdPersonDeath", function(victim, inflictor, killer)

	victim:SetNetworkedBool("thirdperson", false)
	local ventity = victim:GetViewEntity()
	
	// Escape third-person mode
	if (IsValid(ventity)) then
		ventity:Remove()
		victim:SetViewEntity(victim)
	end
	
	if (!!victim.Disguised) then
		// fake entity for spectacular death!
		local dentity = ents.Create("prop_physics")
		dentity:SetModel(victim:GetModel())
		dentity:SetAngles(victim:GetAngles())
		dentity:SetPos(victim:GetPos())
		dentity:SetVelocity(victim:GetVelocity())
		local physics = victim:GetPhysicsObject()
		dentity:SetBloodColor(BLOOD_COLOR_RED) -- this thing was alive, ya know? :(
		dentity:Spawn()
		local dphysics = dentity:GetPhysicsObject()
		dphysics:SetAngles(physics:GetAngles())
		dphysics:SetVelocity(physics:GetVelocity())
		dphysics:SetDamping(physics:GetDamping())
		dphysics:SetInertia(physics:GetInertia())
		dentity:Fire("break", "", 0)
		dentity:Fire("kill", "", 2)
		dentity:Fire("enablemotion","",0)
		
		// Manually draw additional blood (for some reason setting the blood color has no effect)
		local traceworld = {}
		traceworld.start = victim:GetPos() + Vector(0, 0, 20)
		traceworld.endpos = traceworld.start + (Vector(0,0,-1) * 8000) // aim max. 8000 units down
		local trw = util.TraceLine(traceworld) // Send the trace and get the results.
		local edata = EffectData()
		edata:SetStart(victim:GetPos() - physics:GetVelocity())
		edata:SetOrigin(victim:GetPos())
		edata:SetNormal(trw.Normal)
		edata:SetEntity(dentity)
		util.Effect("BloodImpact", edata)
		util.Decal("Splash.Large", trw.HitPos + trw.HitNormal, trw.HitPos - trw.HitNormal)
	end
end)

function SWEP:HasPropConfig(name)
	return !!self.PropConfiguration && !!self.PropConfiguration[name]
end

function SWEP:GetPropConfig(name)
	return self.PropConfiguration[name] or {}
end
