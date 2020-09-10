@ECHO off
ECHO ____________________________________________________ & echo.
ECHO Welcome to the Flutter Engine Setup Helper
ECHO Developed by Auties00
ECHO ____________________________________________________ & echo. & echo.

:dependency
IF NOT EXIST "C:\Program Files\Git\git-bash.exe" (
    ECHO Missing dependency: Please install git bash before starting
    ECHO https://gitforwindows.org/
    goto pause
)

where /q gclient
IF ERRORLEVEL 1 (
    set /p install=Missing dependency: Chromium's depot tools are not installed. Do you want to install them automatically[y/n]? 
    IF /i "%install%"=="y" goto gclientauto
    IF /i "%installl%"=="n" goto gclientnormal
    goto gclienterror
)

IF NOT DEFINED GYP_MSVS_OVERRIDE_PATH (
    ECHO Missing dependency: Visual studio isn't installed or GYP_MSVS_OVERRIDE_PATH isn't set
    goto vsinstalltutorial
)

IF NOT DEFINED GYP_MSVS_VERSION (
    ECHO Missing dependency: Visual studio isn't installed or GYP_MSVS_VERSION isn't set
    goto vsinstalltutorial
)

IF NOT EXIST "C:\Program Files (x86)\Windows Kits\10" (
    goto windowsdktutorial
)

IF NOT EXIST "C:\Program Files (x86)\Windows Kits\10\Debuggers" (
    goto windowsdktutorial
)

ECHO In order to start the setup process, please fork the Flutter engine repository(https://github.com/flutter/engine) & echo Once you're done, click any key...
set /p a=
echo.

:ssh
set /p ssh=To continue an ssh key is required, have you already generated one[y/n]? 
IF /i "%ssh%"=="y" goto github
IF /i "%ssh%"=="n" goto generatessh
goto invalidssh

:github
ssh-add %userprofile%\.ssh\id_rsa
set /p add=The ssh key needs to be added to your Github account, have already added it[y/n]? 
IF /i "%add%"=="y" goto clone
IF /i "%add%"=="n" goto add
goto invalidgithub

:generatessh
set /p email=To generate an ssh key, please provide the email that you use for your Github account: 
ssh-keygen -t rsa -b 4096 -C "%email%" -f %userprofile%\.ssh\id_rsa
ssh-add %userprofile%\.ssh\id_rsa
echo.
goto github

:add
clip < %userprofile%\.ssh\id_rsa.pub
ECHO To add the ssh key to your github account:
ECHO 1) Visit https://github.com/settings/keys
ECHO 2) Click on NEW SSH KEY
ECHO 3) Enter a title in the title section
ECHO 4) Paste the key that is now in your clip in the key section 
ECHO 5) Click on ADD SSH KEY
set /p b=Once you're done, click any key & echo.
goto clone

:clone
cd %userprofile%
set /p repo=Please enter the name of your Github account: 
git clone https://github.com/%repo%/engine
cd %userprofile%/engine
mkdir engine
cd engine
echo.solutions = [{"managed": False, "name": "src/flutter", "url": "git@github.com:%repo%/engine.git", "custom_deps": {}, "deps_file": "DEPS", "safesync_url": "",},]>.gclient
gclient sync
cd src/flutter
git remote add upstream git@github.com:flutter/engine.git
where /q felt
IF ERRORLEVEL 1 (
    SETX PATH "%PATH%;%userprofile%/engine/engine/src/flutter/lib/web_ui/dev"
)
goto pause

:invalidssh
ECHO Please enter either y for yes or n for no
goto ssh

:invalidgithub
ECHO Please enter either y for yes or n for no
goto github

:gclientauto
cd %userprofile%
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
SETX PATH "%userprofile%\depot_tools\bootstrap-3_8_0_chromium_8_bin\python\bin;%userprofile%\depot_tools;%userprofile%;%PATH%"
goto dependency

:gclientnormal
echo Follow the instructions here: http://commondatastorage.googleapis.com/chrome-infra-docs/flat/depot_tools/docs/html/depot_tools_tutorial.html#_setting_up
goto pause

:gclienterror
ECHO Please enter either y for yes or n for no
goto dependency

:vsinstalltutorial
ECHO If Visual studio is installed, set GYP_MSVS_OVERRIDE_PATH to where it's installed and GYP_MSVS_VERSION to its version
ECHO If Visual studio isn't installed, download it from https://visualstudio.microsoft.com/it/downloads/, then in the installer add the C++ desktop app component and the MFC component and finally set the path variables as explained above
goto pause

:windowsdktutorial
ECHO Missing Dependency: Please install the Windows 10 SDK
ECHO https://developer.microsoft.com/it-it/windows/downloads/windows-10-sdk/
goto pause

:pause
pause >nul
exit