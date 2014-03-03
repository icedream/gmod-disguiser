Disguiser SWEP
==============

[![YouTube: [gmod] Derping around with the Disguiser ](http://img.youtube.com/vi/IvMkNIm4Ro0/0.jpg)](http://www.youtube.com/watch?v=IvMkNIm4Ro0&feature=github)

So you always wanted to be able to disguise as another item on the map in Sandbox or
any other game mode than Prop Hunt? You were always annoyed by how you were able to
see yourself being able to rotate but without knowing you were still standing all the
wrong way?

That's over now with this independent weapon code. It let's you have a (somewhat)
tool gun with which you can experience being a prop while not essentially playing
Prop Hunt (or you can play Prop Hunt with your friends without the usual rules).

Requirements
------------

- A properly working Garry's Mod 13 installation

Installation
------------

This inside the addons folder. You can compile this as a `.gma` file or you can put this into a subdirectory, both works.
This addon will also be downloadable via the Steam Workshop, so if you're too lazy to do it now, wait for the release.

How to use?
-----------

Spawn the weapon by any means (in Sandbox via your spawn menu key, usually hold Q for that).
The use your fire/primary attack key (usually left mouse key) while pointing at any thing (prop) on the map.
Pop! You are now that prop, that is if you aimed properly.
With the secondary attack key (usually right mouse key) you can switch back to a human being.

FAQ
---

### When I get killed, a warning "Something is creating errors" (or similar) pops up on the top left of GMod and I get stuck outside the map. I also disappear from the player list. What is happening?
You triggered a bug of Garry's Mod. For some reason some internal code isn't properly able to handle player death events in some cases (like when you get killed while
holding something) and it will bug out. As a security measurement, the server fakes a player disconnection. All you can do is reconnect and hope for the bug to not
reappear for now. Note that this is not an addon-specific issue.

### The addon is not loading!
Try following the [installation instructions](#installation) once again.

### Can I change the weapon sounds?
Only do that if you're okay with changing Lua code (actual programming). You can look into the `sh_init.lua` and you will find SWEP.Sounds pointing at the default
sound paths. Make sure you also put the sounds onto the server into the "sounds/" folder or else you will end up having no sound at all and seeing the error message
"can not find sound" in the debug console instead.

### Will there be a gamemode based on this weapon?
There already is the old and traditional "Prop Hunt" code which got ported to Garry's Mod 13 by xSpaceSoft, though I am going to make a re-implementation based on this
weapon for bug fixes.

License
-------

This piece of code is licensed under the [GNU Affero General Public License Version 3](http://www.gnu.org/licenses/agpl-3.0).
Why GPL? Because it's the standard license for open-source programs. Why Affero? Because Garry's Mod lets you steal the lua code
(at least for the client).