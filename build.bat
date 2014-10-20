@echo off & setlocal enabledelayedexpansion

path %programfiles(x86)%\lua\5.1\;%path%;%programfiles(x86)%\Steam\SteamApps\common\GarrysMod\bin

if not exist builds mkdir builds
mkdir tmp

:: Root path
set workspace=%cd%
set workspacelentmp=%workspace%
set workspacelen=1
:workspacelencalc
set /a workspacelen=!workspacelen!+1
set workspace=!workspace:~1!
if "%workspace%"=="" goto compile
goto workspacelencalc

:compileerr
echo ERROR: Compilation failed.
exit /B -1

:compile
echo Workspace: %workspace% (%workspacelen%)
:: Compile LUA files
pushd lua
for /r %%i in (.) do (
	set absdir=%%i
	set directory=!absdir:~%workspacelen%,-2!

	echo Creating !directory!...
	mkdir "..\tmp\!directory!"
)
for /r %%i in (*.lua) do (
	set absfile=%%i
	set file=!absfile:~%workspacelen%!

	echo Compiling !file!...
	luac52 -o "..\tmp\!file!" "!absfile!"
	if %errorlevel% NEQ 0 (
		echo Could not compile !file!, only copying...
		copy !absfile! "..\tmp\!file!"
	)
)
popd

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
::pause
