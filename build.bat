@echo off & setlocal enabledelayedexpansion

path %programfiles(x86)%\lua\5.1\;%path%;%programfiles(x86)%\Steam\SteamApps\common\GarrysMod\bin

if not exist builds mkdir builds
mkdir tmp

:: Optimize LUA files
::set cutofflen=
::set foo=%~dp0
:::_cl1
::if not "!foo!"=="" (
::	set /a cutofflen += 1
::	set foo=!foo:~1!
::	goto _cl1
::)
::for /R lua %%f in (*.lua) do (
::	set B=%%~ff
::	set B=!B:~%cutofflen%!
::	if not exist "!~dpB!" (
::		mkdir "!~dpB!"
::	)
::	echo Optimizing: !B!
::	pushd tools\luasrcdiet
::	LuaSrcDiet.lua ..\..\!B! --quiet -o ..\..\tmp\!B!
::	popd
::)

:: Copy over resources
robocopy . tmp *.json *.lua *.wav *.mp3 *.jpg *.png *.txt /MIR /XD tools /XD tmp /XF LICENSE.txt /NJH /NJS /NDL /NP /NS

:: Create the GMA file
gmad create -folder "tmp" -out "builds\disguiser_swep.gma"

:: Clean up
rmdir /q /s tmp
pause
