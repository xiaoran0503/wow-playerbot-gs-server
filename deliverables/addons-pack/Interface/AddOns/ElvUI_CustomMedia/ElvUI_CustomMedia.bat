@echo off
echo ADDING THE FILE/S...
if exist ..\ElvUI_CustomMedia goto has_folder
echo Creating the folders...
mkdir ..\ElvUI_CustomMedia
mkdir ..\ElvUI_CustomMedia\font
mkdir ..\ElvUI_CustomMedia\statusbar
echo You can now put your media files into the subfolders found at World of Warcraft\Interface\Addons\ElvUI_CustomMedia
goto end_of_file
:has_folder
echo local LSM = LibStub("LibSharedMedia-3.0") > ..\ElvUI_CustomMedia\ElvUI_CustomMedia.lua
echo.
echo    FONTS
echo.>> ..\ElvUI_CustomMedia\ElvUI_CustomMedia.lua
for %%F in (..\ElvUI_CustomMedia\Fonts\*.ttf) do (
echo       %%~nF
echo LSM:Register("font", "%%~nF", [[Interface\Addons\ElvUI_CustomMedia\Fonts\%%~nxF]], 255^) >> ..\ElvUI_CustomMedia\ElvUI_CustomMedia.lua
)
echo.>> ..\ElvUI_CustomMedia\ElvUI_CustomMedia.lua
for %%F in (..\ElvUI_CustomMedia\Fonts\*.otf) do (
echo       %%~nF
echo LSM:Register("font", "%%~nF", [[Interface\Addons\ElvUI_CustomMedia\Fonts\%%~nxF]], 255^) >> ..\ElvUI_CustomMedia\ElvUI_CustomMedia.lua
)
echo.
echo    STATUSBAR
echo.>> ..\ElvUI_CustomMedia\ElvUI_CustomMedia.lua
for %%F in (..\ElvUI_CustomMedia\Statusbar\*.*) do (
echo       %%~nF
echo LSM:Register("statusbar", "%%~nF", [[Interface\Addons\ElvUI_CustomMedia\Statusbar\%%~nxF]]^) >> ..\ElvUI_CustomMedia\ElvUI_CustomMedia.lua
)
:end_of_file
pause