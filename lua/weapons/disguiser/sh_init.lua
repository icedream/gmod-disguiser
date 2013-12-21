/**
 * Disguiser SWEP - Lets you disguise as any prop on a map.
 *
 * File:
 *   sh_init.lua
 *
 * Purpose:
 *   Initializes all the stuff and data that client and server share.
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
print("[Disguiser] Loading shared...")

// Weapon info
SWEP.Author = "Icedream"
SWEP.Contact = "icedream@modernminas.de"
SWEP.Category = "Fun"
SWEP.Purpose = "Lets you disguise as a map model."
SWEP.Instructions =
	"Aim at a model on the map and press the left mouse button to disguise."
	.. " Undisguise with right mouse button."
SWEP.Spawnable  = true
SWEP.AdminSpawnable = true
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_toolgun.mdl"
SWEP.WorldModel = "models/weapons/w_toolgun.mdl"

// Disable ammo system
SWEP.DrawAmmo = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none" // lasers would be nice :3
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

// Precache models
util.PrecacheModel(SWEP.ViewModel)
util.PrecacheModel(SWEP.WorldModel)

// Sounds
SWEP.Sounds = {
	Disguise = {
		"garrysmod/balloon_pop_cute.wav"
	},
	Undisguise = {
		"garrysmod/balloon_pop_cute.wav"
	},
	Shot = {
		"weapons/disguiser/shot1.mp3" // original sound by http://freesound.org/people/ejfortin/sounds/49678/
	}
}
SWEP.ChannelMapping = {
	Disguise = {
		Channel = CHAN_BODY,
		Volume = 1.0,
		Level = 85,
		Pitch = { 70, 130 }
	},
	Undisguise = {
		Channel = CHAN_BODY,
		Volume = 1.0,
		Level = 85,
		Pitch = { 70, 130 }
	},
	Shot = {
		Channel = CHAN_WEAPON,
		Volume = 0.5,
		Level = 60,
		Pitch = { 80, 160 }
	}
}

// Load the sounds
for soundName, soundPaths in pairs(SWEP.Sounds) do
	local internalSoundName = "Disguiser." .. soundName
	for k, soundPath in pairs(soundPaths) do
		if SERVER then
			resource.AddFile("sound/" .. soundPath)
		end
		if !file.Exists("sound/" .. soundPath, "GAME") then
			print("[Disguiser] WARNING: Sound not found: " .. soundPath)
		end
		util.PrecacheSound(soundPath)
	end
	print("[Disguiser] Loading sound " .. internalSoundName .. "...")
	sound.Add({
		name = internalSoundName,
		channel = SWEP.ChannelMapping[soundName].Channel,
		volume = SWEP.ChannelMapping[soundName].Volume,
		soundlevel = SWEP.ChannelMapping[soundName].Level,
		pitchstart = SWEP.ChannelMapping[soundName].Pitch[0],
		pitchend = SWEP.ChannelMapping[soundName].Pitch[1],
		sound = soundPaths
	})
end

function SWEP:DoShootEffect(hitpos, hitnormal, entity, physbone, bFirstTimePredicted)

	if SERVER then
		umsg.Start("disguiserShootFX", self.Owner)
		umsg.Vector(hitpos)
		umsg.VectorNormal(hitnormal)
		umsg.Entity(entity)
		umsg.Long(physbone)
		umsg.Bool(bFirstTimePredicted)
		umsg.End()
	end

	self.Weapon:EmitSound("Disguiser.Shot")
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )         -- View model animation

	-- There's a bug with the model that's causing a muzzle to
	-- appear on everyone's screen when we fire this animation.
	self.Owner:SetAnimation( PLAYER_ATTACK1 )                        -- 3rd Person Animation

	if ( !bFirstTimePredicted ) then return end

	local effectdata = EffectData()
	effectdata:SetOrigin( hitpos )
	effectdata:SetNormal( hitnormal )
	effectdata:SetEntity( entity )
	effectdata:SetAttachment( physbone )
	util.Effect( "selection_indicator", effectdata )        

	local effectdata = EffectData()
	effectdata:SetOrigin( hitpos )
	effectdata:SetStart( self.Owner:GetShootPos() )
	effectdata:SetAttachment( 1 )
	effectdata:SetEntity( self.Weapon )
	util.Effect( "ToolTracer", effectdata )

end

function SWEP:OnRemove()
	// Do you want to get stuck as a prop forever? NO.
	self:Undisguise()
end

function SWEP:PreDrawViewModel(vm, ply, wep)
	if self.Owner:GetNWBool("isDisguised", false) then
		vm:SetRenderMode(RENDERMODE_TRANSALPHA)
		vm:SetColor(Color(0,  0,  0,  0))
	else
		vm:SetRenderMode(RENDERMODE_TRANSALPHA)
		vm:SetColor(Color(255,255,255,255))
	end
end

function SWEP:DrawWorldModel()
	if !self.Owner:GetNWBool("isDisguised", false) then
		self.Weapon:DrawModel()
	end
end

function SWEP:DrawWorldModelTranslucent()
	if !self.Owner:GetNWBool("isDisguised", false) then
		self.Weapon:DrawModel()
	end
end

function SWEP:DrawIfNotDisguised()
	self.Owner:DrawViewModel(!self.Owner:GetNWBool("isDisguised", false))
	if !!self.Owner.DrawWorldModel then
		self.Owner:DrawWorldModel(!self.Owner:GetNWBool("isDisguised", false))
	end
end

function SWEP:Think()
	self:DrawIfNotDisguised()
end

function SWEP:Deploy()
	self:DrawIfNotDisguised()
end