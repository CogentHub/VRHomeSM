#include <GuiToolbar.au3>
#include <GuiButton.au3>
#include <FontConstants.au3>
#include <WinAPI.au3>
#include <GuiListView.au3>
#include <GuiImageList.au3>
#include <GuiTab.au3>
#include <EventLog.au3>
#include <GuiEdit.au3>
#include <buttonconstants.au3>
#include <ProgressConstants.au3>
#include <SendMessage.au3>
#include <File.au3>
#include <GuiMenu.au3>
#include <GuiStatusBar.au3>
#include <GuiHeader.au3>
#include <GuiTreeView.au3>
#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <Constants.au3>
#include <StaticConstants.au3>
#include <EditConstants.au3>
#include <ListViewConstants.au3>
#include <TabConstants.au3>
#include <ComboConstants.au3>
#include <GUIConstants.au3>
#include <SQLite.au3>
#include <SQLite.dll.au3>
#include "_GDIPlus_WTOB.au3"
#include <GDIPlus.au3>
#include <Inet.au3>

#include <IE.au3>
#include <MsgBoxConstants.au3>

Opt("GUIOnEventMode", 1)

#Region Set Global and Local --> NEW
Global $GUI_Loading, $appid, $Universe, $name, $StateFlags, $installdir, $LastUpdated, $UpdateResult, $SizeOnDisk, $buildid, $LastOwner, $BytesToDownload
Global $BytesDownloaded, $AutoUpdateBehavior, $AllowOtherDownloadsWhileRunning, $Button_ADD_2_VRHOME
Global $GetItem_installdir, $ShortcutName, $ShortcutIcon, $Button_RemoveFromVRHOME, $Checkbox_CheckUncheck
Global $Install_Folder_Steam, $Install_Folder_VRHome, $VRHomeCustomFolders, $iStylesEx, $GetItem_AppId, $GameName
Global $OVR_Service_Check, $OVR_Service_Check_pic, $HTC_Service_Check, $HTC_Service_Check_pic
#endregion

#Region Declare Variables/Const 1
Global $Version = "0.10"
Global $config_ini = @ScriptDir & "\config.ini"
Global $Install_DIR_StringReplace = StringReplace($config_ini, 'System\config.ini', '')
Global $Install_DIR = $Install_DIR_StringReplace
IniWrite($config_ini, "Folders", "Install_Folder", $Install_DIR)
Global $Install_Folder_Steam = IniRead($Config_INI, "Folders", "Install_Folder_Steam", "")
Global $Install_Folder_VRHome = IniRead($Config_INI, "Folders", "Install_Folder_VRHome", "")
Global $VRHomeCustomFolders = IniRead($Config_INI, "Folders", "VRHomeCustomFolders", "")

Global $gfx = @ScriptDir & "\" & "gfx\"
Global $Icons = $Install_DIR & "Icons\"

Global $StartedAsAdmin = IniRead($Config_INI, "TEMP", "StartedAsAdmin", "")
#endregion

#region Erster Start Abfrage

Global $Erster_Start = IniRead($config_ini, "Settings", "First_Start", "true")

If $Erster_Start = "true" or $Erster_Start = "" Then
	Local  $Abfrage = MsgBox (4, "First time startup - VIVE Home Icon Manager - Version " & $Version, "First time startup:" & @CRLF & _
																	"The first time that you run ViveHim, it takes a few minutes as it looks for your" & @CRLF & _
																	"games and creates the file 'ApplicationList.ini'. Afterwards, when launched," & @CRLF & _
																	"it will only check for new games to add to the file." & @CRLF & @CRLF & _
																	"ViveHim looks for your Vive Home setttings folder: if it's not found," & @CRLF & _
																	"you will see a message box asking where it is. Input the location and click 'OK'." & @CRLF & @CRLF & _
																	"If you have used ViveHim to start Vive Home, then when you launch a shortcut" & @CRLF & _
																	"from within Vive Home, ViveHim will restart Vive Home after you exit your game." & @CRLF & _
																	"It does this by running a small program that resides in your tray called" & @CRLF & _
																	"'FBCheck.exe'. This file keeps an eye out for your game to end and restarts" & @CRLF & _
																	"Vive Home when it does. This can be turned off in settings by unchecking" & @CRLF & _
																	"'Use Vive Home Fallback'. It closes automatically when you exit SteamVR." & @CRLF & @CRLF & _
																	"Do you want to see this window again?" & @CRLF & _
																	"(yes/no)" & @CRLF)

	If $Abfrage = 6 Then ;Ja - Auswahl = JA
		IniWrite($config_ini, "Settings", "First_Start", "true")
	Else
		IniWrite($config_ini, "Settings", "First_Start", "false")
	EndIf
EndIf

#endregion

#Region Check Variables if empty
If $Install_Folder_Steam = "" Then
	Global $Install_Folder_Steam_Search_Folder = "C:\Program Files (x86)\Steam\Steam.exe"
	Global $Install_Folder_Steam_Folder = StringReplace($Install_Folder_Steam_Search_Folder, 'Steam.exe', '')

	If FileExists($Install_Folder_Steam_Search_Folder) Then
		IniWrite($Config_INI, "Folders", "Install_Folder_Steam", $Install_Folder_Steam_Folder)
	Else
		MsgBox(0, "Steam folder", "Steam folder was not found." & @CRLF & _
						"Choose the folder before continue." & @CRLF)

		Local $FileSelectFolder = FileSelectFolder("Choose Steam folder", $Install_Folder_Steam_Folder)
		IniWrite($Config_INI, "Folders", "Install_Folder_Steam", $FileSelectFolder & "\")
	EndIf
	$Install_Folder_Steam = IniRead($Config_INI, "Folders", "Install_Folder_Steam", "")
EndIf


If $Install_Folder_VRHome = "" Then
	Global $VRHome_Search_Folder = $Install_Folder_Steam_Folder & "SteamApps\common\VR Home\vrhome.exe"
	Global $VRHome_ApplicationList_Folder = StringReplace($VRHome_Search_Folder, 'vrhome.exe', '')

	If FileExists($VRHome_Search_Folder) Then
		IniWrite($Config_INI, "Folders", "Install_Folder_VRHome", $VRHome_ApplicationList_Folder)
	Else
		MsgBox(0, "VRHome folder", "VRHome install folder was not found." & @CRLF & _
						"Choose the folder before continue." & @CRLF)

		$FileSelectFolder = FileSelectFolder("Choose VIVE Home folder", $VRHome_ApplicationList_Folder)
		IniWrite($Config_INI, "Folders", "Install_Folder_VRHome", $FileSelectFolder & "\")
	EndIf
	$Install_Folder_VRHome = IniRead($Config_INI, "Folders", "Install_Folder_VRHome", "")
EndIf

If $VRHomeCustomFolders = "" Then
	Global $VRHomeCustomFolders_Search_Folder = "C:\Users\" & @UserName & "\Documents\VRHomeCustomFolders\AppShortcuts\tutorial.txt"
	Global $VRHomeCustomFolders_Settings_Folder = StringReplace($VRHomeCustomFolders_Search_Folder, 'AppShortcuts\tutorial.txt', '')

	If FileExists($VRHomeCustomFolders_Search_Folder) Then
		IniWrite($Config_INI, "Folders", "VRHomeCustomFolders", $VRHomeCustomFolders_Settings_Folder)
	Else
		MsgBox(0, "VRHome settings folder", "VRHome settings folder was not found." & @CRLF & _
						"Choose the folder before continue." & @CRLF)

		$FileSelectFolder = FileSelectFolder("Choose VIVE Home folder", $VRHomeCustomFolders_Settings_Folder)
		IniWrite($Config_INI, "Folders", "VRHomeCustomFolders", $FileSelectFolder & "\")
	EndIf
	$VRHomeCustomFolders = IniRead($Config_INI, "Folders", "VRHomeCustomFolders", "")
EndIf

#endregion



#Region Declare Variables/Const 2
Global $Install_DIR = IniRead($config_ini, "Folders", "Install_Folder", "")
Global $System_DIR = $Install_DIR & "System\"
Global $Icons_DIR = $Install_DIR & "Icons\"
Global $Install_Folder_VIVE_Software = IniRead($Config_INI, "Folders", "Install_Folder_VIVE_Software", "")
Global $Install_Folder_VIVE_HOME = IniRead($Config_INI, "Folders", "Install_Folder_VIVE_HOME", "")
Global $Shortcuts_INI = $System_DIR & "Shortcuts.ini"
Global $ApplicationList_INI = $System_DIR & "ApplicationList.ini"
Global $VIVE_HOME_Folder = IniRead($config_ini, "Folders", "VIVE_HOME", "")
Global $VIVE_HOME_VRAPP_Folder = IniRead($config_ini, "Folders", "VIVE_HOME_VRAPP", "")
Global $VIVE_HOME_ApplicationList_Folder = $VIVE_HOME_Folder & "ApplicationList\"
Global $Steam_Shortcut_File = "C:\Program Files (x86)\Steam\userdata\193523507\config\shortcuts.vdf"
Global $Steam_Shortcut_File = "C:\Program Files (x86)\Steam\userdata\193523507\config\shortcuts_temp.vdf"
#endregion


#region Declare Names
Global $Name_TAB_1 = "SETTINGS"
Global $Name_TAB_2 = "VRHomeSM GAME Database"

Global $font = "arial"
Global $font_arial = "arial"
#endregion

#region GUI Erstellen
Local $hGUI, $hGraphic, $hPen
Local $GUI, $aSize, $aStrings[5]
Local $btn, $chk, $rdo, $Msg
Local $GUI_List_Auswahl, $tu_Button0, $to_button1, $to_button2, $to_button3, $to_button4
Local $Wow64 = ""
If @AutoItX64 Then $Wow64 = "\Wow6432Node"
Local $sPath = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE" & $Wow64 & "\AutoIt v3\AutoIt", "InstallDir") & "\Examples\GUI\Advanced\Images"

; Erstellen der GUI
$GUI = GUICreate("VR HOME Shortcut Manager [VRHomeSM]", 643, 545, -1, -1, BitOR($WS_MINIMIZEBOX, $WS_CAPTION, $WS_POPUP, $WS_EX_CLIENTEDGE, $WS_EX_TOOLWINDOW))

; PROGRESS
Global $Anzeige_Fortschrittbalken = GUICtrlCreateProgress(0, 520, 644, 5)

;Status Bar $Anzeige_Fortschrittbalken
Global $Statusbar = _GUICtrlStatusBar_Create($GUI)
_GUICtrlStatusBar_SetSimple($Statusbar, True)

GUISetState()

; Darstellung Icon Preview Rahmen
Global $Linie_oben = GUICtrlCreatePic($gfx & "Frame.jpg", 515, 4, 117, 3, BitOR($SS_NOTIFY, $WS_GROUP, $WS_CLIPSIBLINGS))
Global $Linie_unten = GUICtrlCreatePic($gfx & "Frame.jpg", 515, 62, 117, 3, BitOR($SS_NOTIFY, $WS_GROUP, $WS_CLIPSIBLINGS))
Global $Linie_rechts = GUICtrlCreatePic($gfx & "Frame.jpg", 512, 4, 3, 61, BitOR($SS_NOTIFY, $WS_GROUP, $WS_CLIPSIBLINGS))
Global $Linie_links = GUICtrlCreatePic($gfx & "Frame.jpg", 632, 4, 3, 61, BitOR($SS_NOTIFY, $WS_GROUP, $WS_CLIPSIBLINGS))

; Darstellung Icon Preview
Global $Icon_Preview_Image = GUICtrlCreatePic($gfx & "Icon_Preview.jpg", 515, 7, 117, 55)

; Toolbar oben
GUICtrlCreateLabel("VRHomeSM - ", 10, 6, 160, 40)
GUICtrlSetFont(-1, 20, 400, 2, $font_arial)
GUICtrlCreateLabel("VR Home Shortcut Manager", 175, 7, 330, 40) ;
GUICtrlSetFont(-1, 19, 400, 2, $font_arial)

; Toolbar unten
Global $Button_Start_VIVEHOME = GUICtrlCreateButton("Start VIVE HOME", 261, 480, 120, 35, $BS_BITMAP)
_GUICtrlButton_SetImage($Button_Start_VIVEHOME, $gfx & "Start_VRHome.bmp")
GuiCtrlSetTip(-1, "Starts VIVE HOME VR APP." & @CRLF & @CRLF & "If 'Load Online Players Count on StartUp' is enabled in settings TAB then it also starts adding Online Players Info to the icons." & @CRLF & _
					"It stops automatically one 'pause loop' after SteamVR was closed." & @CRLF & _
					"Time for the 'pause loop' can be set in TAB '" & $Name_TAB_1 & "'.")

Global $Button_INFO = GUICtrlCreateButton("INFO", 525, 480, 35, 35, $BS_BITMAP)
_GUICtrlButton_SetImage($Button_INFO, "shell32.dll", 23, True)
GuiCtrlSetTip(-1, "Shows some Information and, if selected, opens the ViveHim VIVEHIM_StartUp_Guide.pdf.")

Global $Button_Restart = GUICtrlCreateButton("Restart", 565, 480, 35, 35, $BS_BITMAP) ;
_GUICtrlButton_SetImage($Button_Restart, $gfx & "Restart.bmp")
GuiCtrlSetTip(-1, "Restarts VIVEHIM.")

Global $Button_Exit = GUICtrlCreateButton("Exit", 602, 480, 35, 35, $BS_BITMAP)
_GUICtrlButton_SetImage($Button_Exit, $gfx & "Exit.bmp")
GuiCtrlSetTip(-1, "Closes VIVEHIM.")

If $StartedAsAdmin <> "true" Then _GUICtrlStatusBar_SetText($Statusbar, "LOADING, please wait..." & @TAB & @TAB & "'VR Home Shortcut Manager - Version " & $Version & "'")
If $StartedAsAdmin = "true" Then _GUICtrlStatusBar_SetText($Statusbar, "LOADING, please wait..." & @TAB & "[ADMIN]" & @TAB & "'VR Home Shortcut Manager - Version " & $Version & "'")


; TABS ERSTELLEN
Global $TAB_NR = GUICtrlCreateTab(2, 50, 1095, 575, BitOR($TCS_BUTTONS, $TCS_FLATBUTTONS))
GUICtrlSetOnEvent($TAB_NR, "_Tab")

Global $TAB_NR_1 = GUICtrlCreateTab(70, 105, 420, 380)
Global $TAB_NR_1_1 = GUICtrlCreateTabItem($Name_TAB_1)

Global $Button_Install_Folder_save, $Button_Install_Folder_VIVE_Software_save, $Button_Install_Folder_VIVE_HOME_save, $Button_VIVE_HOME_save, $Button_VIVE_HOME_VRAPP_save
Global $Button_VIVE_HOME_delete, $Button_VIVE_HOME_VRAPP_delete, $Button_Install_Folder_open, $Button_Install_Folder_VIVE_Software_open
Global $Button_Install_Folder_VIVE_HOME_open, $Button_VIVE_HOME_open, $Button_VIVE_HOME_VRAPP_open

#Region Folders
GUICtrlCreateGroup("Folders", 5, 75, 390, 200)
DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle(-1), "wstr", "Explorer", "wstr", 0)
GUICtrlSetColor(-1, "0x0000FF")
GUICtrlSetFont(-1, 11, 400, 6, $font_arial)

GUICtrlCreateLabel("VRHomeSM Install path:", 10, 97, 270, 20)
GUICtrlSetFont(-1, 11, 400, 1, $font_arial)
Global $Input_Install_Folder = GUICtrlCreateInput($install_dir, 10, 114, 265, 20)
GuiCtrlSetTip(-1, "Enter Folder path.")
Global $Button_Install_Folder = GUICtrlCreateButton("...", 280, 113, 25, 22, 0)
GuiCtrlSetTip(-1, "Choose Folder.")
$Button_Install_Folder_open = GUICtrlCreateButton("Open", 308, 113, 25, 22, $BS_BITMAP)
GuiCtrlSetTip(-1, "Opens Folder in Explorer.")
$Button_Install_Folder_save = GUICtrlCreateButton("Save", 338, 113, 22, 22, $BS_BITMAP)
GuiCtrlSetTip(-1, "Saves Folder Path.")
_GUICtrlButton_SetImage($Button_Install_Folder_open, $gfx & "Folder_small.bmp")
_GUICtrlButton_SetImage($Button_Install_Folder_save, $gfx & "Save.bmp")

GUICtrlCreateLabel("Steam Install path:", 10, 137, 265, 20)
GUICtrlSetFont(-1, 11, 400, 1, $font_arial)
Global $Input_Install_Folder_Steam = GUICtrlCreateInput($Install_Folder_Steam, 10, 154, 265, 20)
GuiCtrlSetTip(-1, "Enter Folder path.")
Global $Button_Install_Folder_Steam = GUICtrlCreateButton("...", 280, 153, 25, 22, 0)
GuiCtrlSetTip(-1, "Choose Folder.")
Global $Button_Install_Folder_Steam_open = GUICtrlCreateButton("Open", 308, 153, 25, 22, $BS_BITMAP)
GuiCtrlSetTip(-1, "Opens Folder in Explorer.")
Global $Button_Install_Folder_Steam_save = GUICtrlCreateButton("Save", 338, 153, 22, 22, $BS_BITMAP)
GuiCtrlSetTip(-1, "Saves Folder Path.")
_GUICtrlButton_SetImage($Button_Install_Folder_Steam_open, $gfx & "Folder_small.bmp")
_GUICtrlButton_SetImage($Button_Install_Folder_Steam_save, $gfx & "Save.bmp")

GUICtrlCreateLabel("VR Home Install path:", 10, 177, 265, 20)
GUICtrlSetFont(-1, 11, 400, 1, $font_arial)
Global $Input_Install_Folder_VRHome = GUICtrlCreateInput($Install_Folder_VRHome, 10, 194, 265, 20)
GuiCtrlSetTip(-1, "Enter Folder path.")
Global $Button_Install_Folder_VRHome = GUICtrlCreateButton("...", 280, 193, 25, 22, 0)
GuiCtrlSetTip(-1, "Choose Folder.")
Global $Button_Install_Folder_VRHome_open = GUICtrlCreateButton("Open", 308, 193, 25, 22, $BS_BITMAP)
GuiCtrlSetTip(-1, "Opens Folder in Explorer.")
Global $Button_Install_Folder_VRHome_save = GUICtrlCreateButton("Save", 338, 193, 22, 22, $BS_BITMAP)
GuiCtrlSetTip(-1, "Saves Folder Path.")
_GUICtrlButton_SetImage($Button_Install_Folder_VRHome_open, $gfx & "Folder_small.bmp")
_GUICtrlButton_SetImage($Button_Install_Folder_VRHome_save, $gfx & "Save.bmp")


GUICtrlCreateLabel("VR HOME Custom Folder path", 10, 227, 265, 20)
GUICtrlSetFont(-1, 11, 400, 1, $font_arial)
GUICtrlCreateLabel("[Settings]:", 210, 227, 80, 20)
GUICtrlSetColor(-1, "0x0000FF")
GUICtrlSetFont(-1, 11, 400, 1, $font_arial)
Global $Input_VRHomeCustomFolders_Path = GUICtrlCreateInput($VRHomeCustomFolders, 10, 244, 265, 20)
GuiCtrlSetTip(-1, "Enter Folder path.")
Global $Button_VRHomeCustomFolders_Path = GUICtrlCreateButton("...", 280, 243, 25, 22, 0)
GuiCtrlSetTip(-1, "Choose Folder.")
Global $Button_VRHomeCustomFolders_Path_open = GUICtrlCreateButton("Open", 308, 243, 25, 22, $BS_BITMAP)
GuiCtrlSetTip(-1, "Opens Folder in Explorer.")
Global $Button_VRHomeCustomFolders_Path_save = GUICtrlCreateButton("Save", 338, 243, 22, 22, $BS_BITMAP)
GuiCtrlSetTip(-1, "Saves Folder Path.")
Global $Button_VRHomeCustomFolders_Path_delete = GUICtrlCreateButton("Delete", 362, 243, 22, 22, $BS_BITMAP)
GuiCtrlSetTip(-1, "Deletes '.appinfo' Files in ApplicationList Folder." & @CRLF & _
					"These Files are automatically created the next time Vive Home starts.")
_GUICtrlButton_SetImage($Button_VRHomeCustomFolders_Path_open, $gfx & "Folder_small.bmp")
_GUICtrlButton_SetImage($Button_VRHomeCustomFolders_Path_save, $gfx & "Save.bmp")
_GUICtrlButton_SetImage($Button_VRHomeCustomFolders_Path_delete, $gfx & "Delete_small.bmp")

#endregion

#Region Processes and Services
GUICtrlCreateGroup("Processes and Services", 410, 75, 228, 240)
DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle(-1), "wstr", "Explorer", "wstr", 0)
GUICtrlSetColor(-1, "0x0000FF")
GUICtrlSetFont(-1, 11, 400, 6, $font_arial)

GUICtrlCreateLabel("Oculus Rift", 420, 105, 200, 20)
GUICtrlSetColor(-1, "0x0000FF")
GUICtrlSetFont(-1, 11, 400, 6, $font_arial)

;Check if ORV Service / process are running
If ProcessExists("OVRServiceLauncher.exe") Then
   Global  $OVR_Service_Check = "true"
Else
	$OVR_Service_Check = "false"
EndIf

If $OVR_Service_Check = "true" Then
	Global $OVR_Service_Check_pic = GUICtrlCreatePic($gfx & "OVRS_running.bmp", 608, 138, 20, 20)

	If IniRead($config_ini,"Settings", "StopOVRS_on_StartUp", "") = "true" Then
		RunWait("net stop OVRService", "", @SW_HIDE)
		_Button_OVR_Service_Stop()
		Sleep(100)
		GUICtrlSetImage($OVR_Service_Check_pic, $gfx & "OVRS_stoped.bmp")
	EndIf
Else
	$OVR_Service_Check_pic = GUICtrlCreatePic($gfx & "OVRS_stoped.bmp", 608, 138, 20, 20)
EndIf

Global $Button_OVR_Service_Start = GUICtrlCreateButton("", 420, 125, 86, 46, $BS_BITMAP)
_GUICtrlButton_SetImage($Button_OVR_Service_Start, $gfx & "StartORS.bmp")
GuiCtrlSetTip(-1, "Starts the Oculus Service, if it was not running, so that you can use it again.")

Global $Button_OVR_Service_Stop = GUICtrlCreateButton("", 515, 125, 86, 46, $BS_BITMAP)
_GUICtrlButton_SetImage($Button_OVR_Service_Stop, $gfx & "StopORS.bmp")
GuiCtrlSetTip(-1, "Stops the Oculus Service. Start it again if you want to use your Ouclus Rift.")

Global $Status_Checkbox_Minimize_OVRS = IniRead($config_ini,"Settings", "Minimize_OVRS", "")
Global $Checkbox_Minimize_OVRS = GUICtrlCreateCheckbox(" Minimize Store Window at Startup", 420, 170, 205, 20)
If $Status_Checkbox_Minimize_OVRS = "True" Then GUICtrlSetState(-1, $GUI_CHECKED)
GuiCtrlSetTip(-1, "Automatically minimizes Oculus Rift Shop Window after it was started." & @CRLF & @CRLF)
GUICtrlSetFont(-1, 9, 400, 1, $font_arial)

Global $Status_Checkbox_StopOVRS_on_StartUp = IniRead($config_ini,"Settings", "StopOVRS_on_StartUp", "")
Global $Checkbox_StopOVRS_on_StartUp = GUICtrlCreateCheckbox(" Stop Service at StartUp", 420, 187, 180, 20)
If $Status_Checkbox_StopOVRS_on_StartUp = "True" Then GUICtrlSetState(-1, $GUI_CHECKED)
GuiCtrlSetTip(-1, "Stops Oculus Rift Service on VRHomeSM StartUp." & @CRLF & @CRLF)
GUICtrlSetFont(-1, 9, 400, 1, $font_arial)

GUICtrlCreateLabel("HTC Vive", 420, 220, 200, 20)
GUICtrlSetColor(-1, "0x0000FF")
GUICtrlSetFont(-1, 11, 400, 6, $font_arial)

;Check if ORV Service / process are running
If ProcessExists("Vive.exe") Then
    $HTC_Service_Check = "true"
Else
	$HTC_Service_Check = "false"
EndIf

If $HTC_Service_Check = "true" Then
	$HTC_Service_Check_pic = GUICtrlCreatePic($gfx & "OVRS_running.bmp", 608, 248, 20, 20)

	If IniRead($config_ini,"Settings", "StopHTCS_on_StartUp", "") = "true" Then
		RunWait("net stop Viveport", "", @SW_HIDE)
		RunWait("net stop HTC Account Service", "", @SW_HIDE)
		_Button_HTC_Service_Stop()
		Sleep(100)
		GUICtrlSetImage($HTC_Service_Check_pic, $gfx & "OVRS_stoped.bmp")
	EndIf
Else
	$HTC_Service_Check_pic = GUICtrlCreatePic($gfx & "OVRS_stoped.bmp", 608, 248, 20, 20)
EndIf

Global $Button_HTCS_Service_Start = GUICtrlCreateButton("", 420, 240, 86, 36, $BS_BITMAP)
_GUICtrlButton_SetImage($Button_HTCS_Service_Start, $gfx & "StartHTCS.bmp")
GuiCtrlSetTip(-1, "Starts the HTC Service, if it was not running, so that you can use it again.")

Global $Button_HTCS_Service_Stop = GUICtrlCreateButton("", 515, 240, 86, 36, $BS_BITMAP)
_GUICtrlButton_SetImage($Button_HTCS_Service_Stop, $gfx & "StopHTCS.bmp")
GuiCtrlSetTip(-1, "Stops the HTC Service. Start it again if you want to use your HTC VIVE.")

Global $Status_Checkbox_StopHTCS_on_StartUp = IniRead($config_ini,"Settings", "StopHTCS_on_StartUp", "")
Global $Checkbox_StopHTCS_on_StartUp = GUICtrlCreateCheckbox(" Stop Service at StartUp", 420, 275, 180, 20)
If $Status_Checkbox_StopHTCS_on_StartUp = "True" Then GUICtrlSetState(-1, $GUI_CHECKED)
GuiCtrlSetTip(-1, "Stops HTC VIVE Service on VRHomeSM StartUp." & @CRLF & @CRLF)
GUICtrlSetFont(-1, 9, 400, 1, $font_arial)


GUICtrlCreateGroup("VRHomeSM StartUP", 5, 280, 390, 125)
DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle(-1), "wstr", "Explorer", "wstr", 0)
GUICtrlSetColor(-1, "0x0000FF")
GUICtrlSetFont(-1, 11, 400, 6, $font_arial)

; Checkbox
Global $Status_Checkbox_Overwrite_ApplicationList_INI_on_StartUp = IniRead($config_ini,"Settings", "Overwrite_ApplicationList_INI_on_StartUp", "")
Global $Checkbox_Overwrite_ApplicationList_INI_on_StartUp = GUICtrlCreateCheckbox(" Delete 'ApplicationList.ini' at StartUp", 11, 300, 315, 20)
If $Status_Checkbox_Overwrite_ApplicationList_INI_on_StartUp = "True" Then GUICtrlSetState(-1, $GUI_CHECKED)
GuiCtrlSetTip(-1, "Deletes '...\VIVEHIM\System\ApplicationList.ini' File on every StartUp. " & @CRLF & @CRLF & _
					"This function will increase the load time when VIHEHIM is started." & @CRLF & @CRLF)
GUICtrlSetFont(-1, 11, 400, 1, $font_arial)

; Button
Global $Button_Delete_ApplicationList_INI = GUICtrlCreateButton("Delete", 330, 300, 55, 21)
GUICtrlSetTip(-1, "Deletes ApplicationList.ini File in '...\VIVEHIM\System\' Folder.")
Global $hImagebtn = _GUIImageList_Create(13, 13, 5, 3)
_GUIImageList_AddIcon($hImagebtn, "shell32.dll", 131, True)
_GUICtrlButton_SetImageList($Button_Delete_ApplicationList_INI, $hImagebtn)


Global $Status_Checkbox_AutoDownload_Missing_Icons = IniRead($config_ini,"Settings", "AutoDownload_Missing_Icons", "")
Global $Checkbox_AutoDownload_Missing_Icons = GUICtrlCreateCheckbox(" Download missing Icons at StartUp", 11, 320, 315, 20)
If $Status_Checkbox_AutoDownload_Missing_Icons = "True" Then GUICtrlSetState(-1, $GUI_CHECKED)
GuiCtrlSetTip(-1, "Automatically tries to Download missing Icons on StartUp if Icon cannot be found." & @CRLF & @CRLF)
GUICtrlSetFont(-1, 11, 400, 1, $font_arial)
#endregion

#Region VIVEHIM Background Processes
GUICtrlCreateGroup("VRHomeSM Processes", 410, 320, 228, 155)
DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle(-1), "wstr", "Explorer", "wstr", 0)
GUICtrlSetColor(-1, "0x0000FF")
GUICtrlSetFont(-1, 11, 400, 6, $font_arial)


Global $Status_Checkbox_FB_Check = IniRead($config_ini,"Settings", "FB_Check", "")
Global $Checkbox_FB_Check = GUICtrlCreateCheckbox(" Use Vive Home Fallback", 420, 340, 215, 20) ; 430
If $Status_Checkbox_FB_Check = "True" Then GUICtrlSetState(-1, $GUI_CHECKED)
GuiCtrlSetTip(-1, "Starts Fallback Check together with VIVE HOME and automatically loads VIVE HOME again after game is closed." & @CRLF & @CRLF)
GUICtrlSetFont(-1, 11, 400, 1, $font_arial)

Global $Status_Checkbox_USE_FB_GUI = IniRead($config_ini,"Settings", "USE_FB_GUI", "")
Global $Checkbox_USE_FB_GUI = GUICtrlCreateCheckbox(" Use Fallback Status Window", 420, 360, 200, 20) ; 11, 430, 220, 20
If $Status_Checkbox_USE_FB_GUI = "True" Then GUICtrlSetState(-1, $GUI_CHECKED)
GuiCtrlSetTip(-1, "Shows a GUI Window while the File 'FBCheck' is running in the Background." & @CRLF & @CRLF)
GUICtrlSetFont(-1, 11, 400, 1, $font_arial)

#endregion

#Region Experimental
GUICtrlCreateGroup("Misc.", 5, 410, 390, 65)
DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle(-1), "wstr", "Explorer", "wstr", 0)
GUICtrlSetColor(-1, "0x0000FF")
GUICtrlSetFont(-1, 11, 400, 6, $font_arial)

Global $Status_Checkbox_CloseVIVEHIM_after_Start = IniRead($config_ini,"Settings", "CloseVIVEHIM_after_Start", "")
Global $Checkbox_CloseVIVEHIM_after_Start = GUICtrlCreateCheckbox(" Close VIVEHIM after Vive Home Start", 11, 430, 260, 20) ; 11, 430, 220, 20
If $Status_Checkbox_CloseVIVEHIM_after_Start = "True" Then GUICtrlSetState(-1, $GUI_CHECKED)
GuiCtrlSetTip(-1, "Shows a GUI Window while the File 'FBCheck' is running in the Background." & @CRLF & @CRLF)
GUICtrlSetFont(-1, 11, 400, 1, $font_arial)
#endregion

GUICtrlCreateTabItem("")



Global $TAB_NR_2 = GUICtrlCreateTabItem($Name_TAB_2)

Global $listview = GUICtrlCreateListView("", 0, 70, 644, 404, BitOR($LVS_SHOWSELALWAYS, $LVS_NOSORTHEADER, $LVS_REPORT), $TAB_NR_1)
_GUICtrlListView_SetExtendedListViewStyle($listview, BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_GRIDLINES, $LVS_EX_DOUBLEBUFFER, $iStylesEx, $LVS_EX_CHECKBOXES))
GUICtrlSetFont($listview, 12, 500, 1, $font_arial)

; Load images
Global $ListView_Favorite_Image = _GUIImageList_Create(20, 20)
_GUIImageList_AddBitmap($ListView_Favorite_Image, $gfx & "Favorite_1.bmp")

; Add columns
_GUICtrlListView_AddColumn($listview, "NR", 45)
_GUICtrlListView_AddColumn($listview, "App ID", 70)
_GUICtrlListView_AddColumn($listview, "Name", 230)
_GUICtrlListView_AddColumn($listview, "Install dir", 215)
_GUICtrlListView_AddColumn($listview, "Online", 65, 2)


$Checkbox_CheckUncheck = GUICtrlCreateCheckbox(" All", 5, 480, 34, 34)
GuiCtrlSetTip(-1, "Selects all games in Listview." & @CRLF & @CRLF)
GUICtrlSetFont(-1, 11, 400, 1, $font_arial)

Global $Button_Synch = GUICtrlCreateButton("Synch.", 50, 480, 87, 35, $BS_BITMAP)
_GUICtrlButton_SetImage($Button_Synch, $gfx & "Synch..bmp")
GuiCtrlSetTip(-1, "Synchronize games with vr home." & @CRLF & _
					"This can take some time, depending on how many games are installed and selected as Favorites." & @CRLF & @CRLF & _
					"If Favorites or Online Players count on Icons does not work then delete 'ApplicationList.ini in SETTINGS TAB and reselect Favorites.")

GUICtrlCreateTabItem("")

#endregion

_Loading_GUI()

#Region Funktionen Verknüpfen

GUISetOnEvent($GUI_EVENT_CLOSE, "_Beenden")
GUICtrlSetOnEvent($Button_Exit, "_Beenden")
GUICtrlSetOnEvent($Button_INFO, "_Button_INFO")
GUICtrlSetOnEvent($Button_Restart, "_Restart")

GUICtrlSetOnEvent($Checkbox_CheckUncheck, "_Checkbox_CheckUncheck")
GUICtrlSetOnEvent($Button_Synch, "_Button_Synch")
GUICtrlSetOnEvent($Button_Delete_ApplicationList_INI, "_Button_Delete_ApplicationList_INI")

GUICtrlSetOnEvent($Button_OVR_Service_Start, "_Button_OVR_Service_Start")
GUICtrlSetOnEvent($Button_OVR_Service_Stop, "_Button_OVR_Service_Stop")
GUICtrlSetOnEvent($Button_HTCS_Service_Start, "_Button_HTC_Service_Start")
GUICtrlSetOnEvent($Button_HTCS_Service_Stop, "_Button_HTC_Service_Stop")

GUICtrlSetOnEvent($Checkbox_StopOVRS_on_StartUp, "_Checkbox_StopOVRS_on_StartUp")
GUICtrlSetOnEvent($Checkbox_Minimize_OVRS, "_Checkbox_Minimize_OVRS")
GUICtrlSetOnEvent($Checkbox_StopHTCS_on_StartUp, "_Checkbox_StopHTCS_on_StartUp")


GUICtrlSetOnEvent($Button_Install_Folder, "_Button_Install_Folder")
GUICtrlSetOnEvent($Button_Install_Folder_Steam, "_Button_Install_Folder_Steam")
GUICtrlSetOnEvent($Button_Install_Folder_VRHome, "_Button_Install_Folder_VRHome")
GUICtrlSetOnEvent($Button_VRHomeCustomFolders_Path, "_Button_VRHomeCustomFolders_Path")

GUICtrlSetOnEvent($Button_Install_Folder_open, "_Button_Install_Folder_open")
GUICtrlSetOnEvent($Button_Install_Folder_Steam_open, "_Button_Install_Folder_Steam_open")
GUICtrlSetOnEvent($Button_Install_Folder_VRHome_open, "_Button_Install_Folder_VRHome_open")
GUICtrlSetOnEvent($Button_VRHomeCustomFolders_Path_open, "_Button_VRHomeCustomFolders_Path_open")

GUICtrlSetOnEvent($Button_Install_Folder_save, "_Button_Install_Folder_save")
GUICtrlSetOnEvent($Button_Install_Folder_Steam_save, "_Button_Install_Folder_Steam_save")
GUICtrlSetOnEvent($Button_Install_Folder_VRHome_save, "_Button_Install_Folder_VRHome_save")
GUICtrlSetOnEvent($Button_VRHomeCustomFolders_Path_save, "_Button_VRHomeCustomFolders_Path_save")

GUICtrlSetOnEvent($Button_VRHomeCustomFolders_Path_delete, "_Button_VRHomeCustomFolders_Path_delete")


GUICtrlSetOnEvent($Checkbox_Overwrite_ApplicationList_INI_on_StartUp, "_Checkbox_Overwrite_ApplicationList_INI_on_StartUp")
GUICtrlSetOnEvent($Checkbox_AutoDownload_Missing_Icons, "_Checkbox_AutoDownload_Missing_Icons")
GUICtrlSetOnEvent($Checkbox_FB_Check, "_Checkbox_FB_Check")
GUICtrlSetOnEvent($Checkbox_USE_FB_GUI, "_Checkbox_USE_FB_GUI")
GUICtrlSetOnEvent($Checkbox_CloseVIVEHIM_after_Start, "_Checkbox_CloseVIVEHIM_after_Start")


GUICtrlSetOnEvent($Button_Start_VIVEHOME, "_Button_Start_VRHome")


Sleep(500)
GUICtrlSetData($Anzeige_Fortschrittbalken, 0)
#endregion


_Search_Files()
_Read_from_INI_ADD_2_ListView()
GUICtrlSetData($Anzeige_Fortschrittbalken, 90)
_Update_CheckUncheck_ListView_Checkbox()
GUICtrlSetData($Anzeige_Fortschrittbalken, 100)
_Tab()
GUICtrlSetData($Anzeige_Fortschrittbalken, 0)
If $StartedAsAdmin <> "true" Then _GUICtrlStatusBar_SetText($Statusbar, "Program loaded and can now be used." & @TAB & @TAB & "'VR Home Shortcut Manager - Version " & $Version & "'")
If $StartedAsAdmin = "true" Then _GUICtrlStatusBar_SetText($Statusbar, "Program loaded and can now be used." & @TAB & "[ADMIN]" & @TAB & "'VR Home Shortcut Manager - Version " & $Version & "'")

GUIDelete($GUI_Loading)

#Region While 1
While 1
	Sleep(100)
    Global $nMsg = GUIGetMsg()

    Switch $nMsg

        Case $GUI_EVENT_CLOSE
            Exit

	EndSwitch
WEnd
#endregion



#Region Start Funktionen

#Region Func MAIN
Func _Loading_GUI()
	Local Const $PG_WS_POPUP = 0x80000000 ; same as the $WS_POPUP constant in WindowsConstants.au3
	Local Const $PG_WS_DLGFRAME = 0x00400000 ; same as the $WS_DLGFRAME constant in WindowsConstants.au3

	$GUI_Loading = GUICreate("Loading...please wait...", 250, 65, -1, -1, BitOR($PG_WS_DLGFRAME, $PG_WS_POPUP))  ; $WS_EX_TOPMOST
	GUISetIcon(@AutoItExe, -2, $GUI_Loading)
	GUISetBkColor("0x00BFFF")

	$font = "arial"
	GUICtrlCreateLabel("...Loading...", 66, 5, 160, 25)
	GUICtrlSetFont(-1, 17, 800, 1, $font)
	GUICtrlSetColor(-1, $COLOR_RED)
	GUICtrlCreateLabel("...Please wait...", 49, 32, 160, 25)
	GUICtrlSetFont(-1, 17, 800, 1, $font)
	GUICtrlSetColor(-1, $COLOR_RED)

	GUISetState(@SW_SHOW, $GUI_Loading)
	;WinSetOnTop("Loading...please wait...", "", $WINDOWS_ONTOP)
EndFunc

Func _Read_from_INI_ADD_2_ListView()

	_GUICtrlListView_BeginUpdate($ListView)
	_GUICtrlListView_DeleteAllItems($ListView)

	Global $NR_Applications = IniRead($ApplicationList_INI, "ApplicationList", "NR_Applications", "")

	For $NR = 1 To $NR_Applications

		Global $Application_NR = IniRead($ApplicationList_INI, "Application_" & $NR, "NR", "")
		Global $Application_appid = IniRead($ApplicationList_INI, "Application_" & $NR, "appid", "")
		Global $Application_name = IniRead($ApplicationList_INI, "Application_" & $NR, "name", "")
		Global $Application_StateFlags = IniRead($ApplicationList_INI, "Application_" & $NR, "StateFlags", "")
		Global $Application_installdir = IniRead($ApplicationList_INI, "Application_" & $NR, "installdir", "")
		Global $Application_IconPath = IniRead($ApplicationList_INI, "Application_" & $NR, "IconPath", "")
		Global $Application_right_now = IniRead($ApplicationList_INI, "Application_" & $NR, "right_now", "")
		Global $Application_24h_peak = IniRead($ApplicationList_INI, "Application_" & $NR, "24h_peak", "")
		Global $Application_all_time_peak = IniRead($ApplicationList_INI, "Application_" & $NR, "all_time_peak", "")

		Local $Ebene_temp = $NR - 1

		_GUICtrlListView_AddItem($listview, "", $Application_NR)

		_GUICtrlListView_AddSubItem($ListView, $Ebene_temp, $Application_appid, 1)
		_GUICtrlListView_AddSubItem($ListView, $Ebene_temp, $Application_name, 2)
		_GUICtrlListView_AddSubItem($ListView, $Ebene_temp, $Application_installdir, 3)
		_GUICtrlListView_AddSubItem($ListView, $Ebene_temp, $Application_right_now, 4)

		;_GUIImageList_AddBitmap($ListView_Favorite_Image, $gfx & "Favorite_1.bmp")
		_GUIImageList_AddBitmap($ListView_Favorite_Image, $Icons & "32x32\" & "steam.app." & $Application_appid & ".bmp")
		_GUICtrlListView_SetImageList($listview, $ListView_Favorite_Image, 1)

		Local $ApplicationNR_TEMP = ""
	Next

	_GUICtrlListView_EndUpdate($ListView)

EndFunc

Func _Search_Files()
	Local $s_LocalFolder = $Install_Folder_Steam & "SteamApps\"
	Local $FileList = _FileListToArray($s_LocalFolder , "*.acf" , 1)
	Local $Status_Checkbox_Overwrite_ApplicationList_INI_on_StartUp = IniRead($config_ini,"Settings", "Overwrite_ApplicationList_INI_on_StartUp", "")
	Local $Check_NR_Applications = IniRead($ApplicationList_INI, "ApplicationList", "NR_Applications", "")
	Global $Application_NR = 1

	If Not FileExists($ApplicationList_INI) Then $Status_Checkbox_Overwrite_ApplicationList_INI_on_StartUp = "true"

	If $Status_Checkbox_Overwrite_ApplicationList_INI_on_StartUp = "true" Then
		If $FileList <> "" Then
			FileDelete($ApplicationList_INI)
			For $NR = 1 To $FileList[0]
				Global $FileList_NR = $FileList[0]
				Global $File_Name = $FileList[$NR]
				Global $File_Path = $Install_Folder_Steam  & "SteamApps\" & $File_Name
				Global $ProcessBar_Status = $NR * 100 / $FileList[0]
				$ProcessBar_Status = $ProcessBar_Status - 15
				GUICtrlSetData($Anzeige_Fortschrittbalken, $ProcessBar_Status)
				If StringLeft(FileRead($File_Path), 3) <> "0x0" Then
					_ApplicationList_Update()
					$Application_NR = $Application_NR + 1
				EndIf

				$File_Path =  ""
			Next
			Sleep(500)
		EndIf
	Else
		If $FileList[0] > $Check_NR_Applications Then
			If $FileList <> "" Then
				For $NR = 1 To $FileList[0]
					$Application_NR = $NR
					$FileList_NR = $FileList[0]
					Global $File_Name = $FileList[$NR]
					Global $File_Path = $Install_Folder_Steam & "SteamApps\" & $File_Name
					$ProcessBar_Status = $NR * 100 / $FileList[0]
					$ProcessBar_Status = $ProcessBar_Status - 15
					GUICtrlSetData($Anzeige_Fortschrittbalken, $ProcessBar_Status)
					If StringLeft(FileRead($File_Path), 3) <> "0x0" Then
						_ApplicationList_Update()
						$Application_NR = $Application_NR + 1
					EndIf
					$File_Path =  ""
				Next
				Sleep(500)
			EndIf
		EndIf
	EndIf

EndFunc

Func _ApplicationList_Update()
	Global $File = $File_Path
	Global $Wert_Zeile = ""

	If $File <> "" Then
			For $iCount_1 = 3 To 7
				Local $Wert_Zeile_komplett = FileReadLine($File, $iCount_1)

				Local $iPosition = StringInStr($Wert_Zeile_komplett, "appid")
				If $iPosition <> 0 Then
					Global $appid = StringReplace($Wert_Zeile_komplett, '	"appid"		"', '')
					$appid = StringReplace($appid, '"', '')
				EndIf


				Local $iPosition = StringInStr($Wert_Zeile_komplett, "Universe")
				If $iPosition <> 0 Then
					Global $Universe = StringReplace($Wert_Zeile_komplett, '	"Universe"		"', '')
					$Universe = StringReplace($Universe, '"', '')
				EndIf

				Local $iPosition = StringInStr($Wert_Zeile_komplett, "name")
				If $iPosition <> 0 Then
					$name = StringReplace($Wert_Zeile_komplett, '	"name"		"', '')
					$name = StringReplace($name, '"', '')
				EndIf

				Local $iPosition = StringInStr($Wert_Zeile_komplett, "StateFlags")
				If $iPosition <> 0 Then
					Global $StateFlags = StringReplace($Wert_Zeile_komplett, '	"StateFlags"		"', '')
					$StateFlags = StringReplace($StateFlags, '"', '')
				EndIf

				Local $iPosition = StringInStr($Wert_Zeile_komplett, "installdir")
				If $iPosition <> 0 Then
					Global $installdir = StringReplace($Wert_Zeile_komplett, '	"installdir"		"', '')
					$installdir = StringReplace($installdir, '"', '')
				EndIf

				Local $iPosition = StringInStr($Wert_Zeile_komplett, "LastUpdated")
				If $iPosition <> 0 Then
					Global $LastUpdated = StringReplace($Wert_Zeile_komplett, '	"LastUpdated"		"', '')
					$LastUpdated = StringReplace($LastUpdated, '"', '')
				EndIf

				Local $iPosition = StringInStr($Wert_Zeile_komplett, "UpdateResult")
				If $iPosition <> 0 Then
					Global $UpdateResult = StringReplace($Wert_Zeile_komplett, '	"UpdateResult"		"', '')
					$UpdateResult = StringReplace($UpdateResult, '"', '')
				EndIf

				Local $iPosition = StringInStr($Wert_Zeile_komplett, "SizeOnDisk")
				If $iPosition <> 0 Then
					Global $SizeOnDisk = StringReplace($Wert_Zeile_komplett, '	"SizeOnDisk"		"', '')
					$SizeOnDisk = StringReplace($SizeOnDisk, '"', '')
				EndIf

				Local $iPosition = StringInStr($Wert_Zeile_komplett, "buildid")
				If $iPosition <> 0 Then
					Global $buildid = StringReplace($Wert_Zeile_komplett, '	"buildid"		"', '')
					$buildid = StringReplace($buildid, '"', '')
				EndIf

				Local $iPosition = StringInStr($Wert_Zeile_komplett, "LastOwner")
				If $iPosition <> 0 Then
					Global $LastOwner = StringReplace($Wert_Zeile_komplett, '	"LastOwner"		"', '')
					$LastOwner = StringReplace($LastOwner, '"', '')
				EndIf

				Local $iPosition = StringInStr($Wert_Zeile_komplett, "BytesToDownload")
				If $iPosition <> 0 Then
					Global $BytesToDownload = StringReplace($Wert_Zeile_komplett, '	"BytesToDownload"		"', '')
					$BytesToDownload = StringReplace($BytesToDownload, '"', '')
				EndIf

				Local $iPosition = StringInStr($Wert_Zeile_komplett, "BytesDownloaded")
				If $iPosition <> 0 Then
					Global $BytesDownloaded = StringReplace($Wert_Zeile_komplett, '	"BytesDownloaded"		"', '')
					$BytesDownloaded = StringReplace($BytesDownloaded, '"', '')
				EndIf

				Local $iPosition = StringInStr($Wert_Zeile_komplett, "AutoUpdateBehavior")
				If $iPosition <> 0 Then
					Global $AutoUpdateBehavior = StringReplace($Wert_Zeile_komplett, '	"AutoUpdateBehavior"		"', '')
					$AutoUpdateBehavior = StringReplace($AutoUpdateBehavior, '"', '')
				EndIf

				Local $iPosition = StringInStr($Wert_Zeile_komplett, "AllowOtherDownloadsWhileRunning")
				If $iPosition <> 0 Then
					Global $AllowOtherDownloadsWhileRunning = StringReplace($Wert_Zeile_komplett, '	"AllowOtherDownloadsWhileRunning"		"', '')
					$AllowOtherDownloadsWhileRunning = StringReplace($AllowOtherDownloadsWhileRunning, '"', '')
				EndIf
			Next

			IniWrite($ApplicationList_INI, "ApplicationList", "NR_Applications", $Application_NR)
			IniWrite($ApplicationList_INI, "Application_" & $Application_NR, "NR", $Application_NR)
			IniWrite($ApplicationList_INI, "Application_" & $Application_NR, "appid", $appid)
			IniWrite($ApplicationList_INI, "Application_" & $Application_NR, "name", $name)
			IniWrite($ApplicationList_INI, "Application_" & $Application_NR, "installdir", $installdir)

			If $appid <> "" Then
				IniWrite($ApplicationList_INI, "Application_" & $Application_NR, "IconPath", $Icons_DIR & "steam.app." & $appid & ".jpg")
			Else
				IniWrite($ApplicationList_INI, "Application_" & $Application_NR, "IconPath", "")
			EndIf

			If Not FileExists($Icons_DIR & "steam.app." & $appid & ".jpg") Then
				_Download_Icon_for_SteamGameID()
			EndIf

			If Not FileExists($Icons_DIR & "32x32\" & "steam.app." & $appid & ".bmp") Then
				_Get_SteamGame_Icon_32x32()
			EndIf

			If $appid <> "" Then
				_Get_ADD_PlayersOnline_DATA()
			EndIf
	EndIf
EndFunc

Func _Get_ADD_PlayersOnline_DATA()
	Global $Check_AppId = $appid
	Global $sHTML = _INetGetSource('https://steamdb.info/app/' & $Check_AppId & '/graphs/')

	Local $iPosition_1 = StringInStr($sHTML, '<li><strong>')
	Local $iPosition_2 = StringInStr($sHTML, '</strong><em>all-time peak')
	Local $iPosition_3 = $iPosition_2 - $iPosition_1

	Local $sString = StringMid($sHTML, $iPosition_1, $iPosition_3)
	Global $aArray = StringSplit($sString, '<li><strong>', $STR_ENTIRESPLIT)

	If $aArray[0] > 1 Then
		Global $PlayersOnline_right_now = StringSplit($aArray[2], '<')
		$PlayersOnline_right_now = $PlayersOnline_right_now[1]
		Global $PlayersOnline_24h_peak = StringSplit($aArray[3], '<')
		$PlayersOnline_24h_peak = $PlayersOnline_24h_peak[1]
		Global $PlayersOnline_all_time_peak = $aArray[4]

		IniWrite($ApplicationList_INI, "Application_" & $Application_NR, "right_now", $PlayersOnline_right_now)
		IniWrite($ApplicationList_INI, "Application_" & $Application_NR, "24h_peak", $PlayersOnline_24h_peak)
		IniWrite($ApplicationList_INI, "Application_" & $Application_NR, "all_time_peak", $PlayersOnline_all_time_peak)

		$PlayersOnline_right_now = ""
		$PlayersOnline_24h_peak = ""
		$PlayersOnline_all_time_peak = ""
	EndIf
EndFunc

Func _Get_SteamGame_Icon_32x32()
	Global $Steam_AppId = $appid

	Global $sHTML = _INetGetSource('https://steamdb.info/app/' & $appid & '/info/')

	Local $iPosition_1 = StringInStr($sHTML, 'clienttga</td>', $STR_CASESENSE, 1, 1000)
	Local $iPosition_2 = StringInStr($sHTML, '.jpg" rel="nofollow">', $STR_CASESENSE, 1, 1000)
	Local $iPosition_3 = $iPosition_2 - $iPosition_1
	Local $sString = StringMid($sHTML, $iPosition_1, $iPosition_3)

	Local $iPosition_1_2 = StringInStr($sString, '<td class="span3">icon</td>', $STR_CASESENSE, 1, 1)
	Local $iPosition_2_2 = StringLen($sString) + 1
	Local $iPosition_3_2 = $iPosition_2_2 - $iPosition_1_2
	Local $sString_2 = StringMid($sString, $iPosition_1_2, $iPosition_3_2)

	Global $HTML_IconLink = StringReplace($sString_2, '<td class="span3">icon</td>', '')
	$HTML_IconLink = StringReplace($HTML_IconLink, '<td><a href="', '')

	If $HTML_IconLink <> "" Then
		Local $URL = $HTML_IconLink & ".jpg"
		Local $Download = InetGet($URL, $Icons & "32x32\" & "steam.app." & $Steam_AppId & ".jpg", 16, 0)
		If $Download = 0 Then FileCopy($Icons & "32x32\" & "default.bmp", $Icons & "32x32\" & "steam.app." & $Steam_AppId & ".bmp", $FC_OVERWRITE)
		If $Download <> 0 Then _Convert_Icon_32x32()
		FileDelete($Icons & "32x32\" & "steam.app." & $Steam_AppId & ".jpg")
	EndIf
EndFunc

Func _Get_SteamGame_Icon_256x256()
	Global $Steam_AppId = $GetItem_AppId

	Global $sHTML = _INetGetSource('https://steamdb.info/app/' & $Steam_AppId & '/info/')

	Local $iPosition_1 = StringInStr($sHTML, 'clienticon</td>')
	Local $iPosition_2 = StringInStr($sHTML, '.ico" rel="nofollow')
	Local $iPosition_3 = $iPosition_2 - $iPosition_1

	Local $sString = StringMid($sHTML, $iPosition_1, $iPosition_3)

	Global $HTML_IconLink = StringReplace($sString, 'clienticon</td>', '')
	$HTML_IconLink = StringReplace($HTML_IconLink, '<td><a href="', '')

	If $HTML_IconLink <> "" Then
		Local $URL = $HTML_IconLink & ".ico"
		InetGet($URL, $Icons & "256x256\" & "steam.app." & $Steam_AppId & ".ico", 16, 0)
	EndIf
EndFunc

Func _Convert_Icon_32x32()
	_GDIPlus_Startup()

	Local $sFile = $Icons & "32x32\" & "steam.app." & $Steam_AppId & ".jpg"
    If @error Or Not FileExists($sFile) Then Return

    Local $hImage = _GDIPlus_ImageLoadFromFile($sFile)

    Local $iWidth = 600
    Local $iHeight = _GDIPlus_ImageGetHeight($hImage) * 600 / _GDIPlus_ImageGetWidth($hImage)

    Local $tPalette = _GDIPlus_PaletteInitialize(16, $GDIP_PaletteTypeFixedHalftone27, 16, False, $hImage)
    _GDIPlus_BitmapConvertFormat($hImage, "", $GDIP_DitherTypeDualSpiral8x8, $GDIP_PaletteTypeFixedHalftone27, $tPalette)

	_GDIPlus_ImageSaveToFile($hImage, $Icons & "32x32\" & "steam.app." & $Steam_AppId & ".bmp")

    _GDIPlus_ImageDispose($hImage)
    _GDIPlus_Shutdown()
EndFunc

Func _Download_Icons()
	Global $NR_of_Files = IniRead($ApplicationList_INI, "ApplicationList", "NR_Applications", "")

	For $LOOP_Files_1 = 1 To $NR_of_Files
		Local $Application_appid = IniRead($ApplicationList_INI, "Application_" & $LOOP_Files_1, "appid", "")
		Local $Download_Icon_path_jpg = $Icons_DIR & "steam.app." & $Application_appid & '.jpg'

		If $Application_appid <> "" Then
			Local $URL = 'http://cdn.akamai.steamstatic.com/steam/apps/' & $Application_appid & '/header.jpg'
			InetGet($URL, $Download_Icon_path_jpg, 16, 0)
		EndIf
	Next
EndFunc

Func _Download_Icon_for_SteamGameID()
	Local $Application_appid = $appid
	Local $Download_Icon_path_jpg = $Icons_DIR & "steam.app." & $Application_appid & '.jpg'

	Local $URL = 'http://cdn.akamai.steamstatic.com/steam/apps/' & $Application_appid & '/header.jpg'
	InetGet($URL, $Download_Icon_path_jpg, 16, 0)
EndFunc

Func _Update_CheckUncheck_ListView_Checkbox()
	Local $NR_GameNames = IniRead($ApplicationList_INI, "ApplicationList", "NR_Applications", "")

	Local $FileList_GameNames = _FileListToArray($VRHomeCustomFolders & "AppShortcuts\", "*.lnk" , 1)

	For $LOOP_CheckUncheck_1 = 0 To $NR_GameNames
		Local $Check_GameName = IniRead($ApplicationList_INI, "Application_" & $LOOP_CheckUncheck_1, "name", "") & ".lnk"
		Local $Check_Exist_GameName = _ArraySearch($FileList_GameNames, $Check_GameName, 0, $NR_GameNames)

		If $Check_Exist_GameName <> "-1" Then
			_GUICtrlListView_SetItemChecked($ListView, $LOOP_CheckUncheck_1 - 1, true)
		EndIf
	Next
EndFunc

Func _Tab()
	Global $TAB_Name = GUICtrlRead($TAB_NR)

	If $TAB_Name = "0" Then
		_GUICtrlStatusBar_SetText($Statusbar, $Name_TAB_1 & @TAB & "" & @TAB & "'VR Home Shortcut Manager - Version " & $Version & "'")
	EndIf

	If $TAB_Name = "1" Then
		GUIRegisterMsg($WM_notify, "_ClickOnListView")
		_GUICtrlStatusBar_SetText($Statusbar, $Name_TAB_2 & @TAB & "" & @TAB & "'VR Home Shortcut Manager - Version " & $Version & "'")
	EndIf

EndFunc
#endregion

#Region Func TAB 1

Func _Button_Install_Folder()
	Local $FileSelectFolder = FileSelectFolder($install_dir, "")
	If $FileSelectFolder <> "" Then
		GUICtrlSetData($Input_Install_Folder, $FileSelectFolder & "\")
		IniWrite($config_ini, "Folders", "Install_Folder", $FileSelectFolder & "\")
	EndIf
EndFunc

Func _Button_Install_Folder_Steam()
	Local $FileSelectFolder = FileSelectFolder($install_dir, "")
	If $FileSelectFolder <> "" Then
		GUICtrlSetData($Input_Install_Folder_Steam, $FileSelectFolder & "\")
		IniWrite($config_ini, "Folders", "Install_Folder_Steam", $FileSelectFolder & "\")
	EndIf
EndFunc

Func _Button_Install_Folder_VRHome()
	Local $FileSelectFolder = FileSelectFolder($install_dir, "")
	If $FileSelectFolder <> "" Then
		GUICtrlSetData($Input_Install_Folder_VRHome, $FileSelectFolder & "\")
		IniWrite($config_ini, "Folders", "Install_Folder_VRHome", $FileSelectFolder & "\")
	EndIf
EndFunc

Func _Button_VRHomeCustomFolders_Path()
	Local $FileSelectFolder = FileSelectFolder($install_dir, "")
	If $FileSelectFolder <> "" Then
		GUICtrlSetData($Input_VRHomeCustomFolders_Path, $FileSelectFolder & "\")
		IniWrite($config_ini, "Folders", "VRHomeCustomFolders", $FileSelectFolder & "\")
	EndIf
EndFunc


Func _Button_Install_Folder_open()
	Local $Value_Input = GUICtrlRead($Input_Install_Folder)
	If $Value_Input <> "" Then
		ShellExecute($Value_Input)
	EndIf
EndFunc

Func _Button_Install_Folder_Steam_open()
	Local $Value_Input = GUICtrlRead($Input_Install_Folder_Steam)
	If $Value_Input <> "" Then
		ShellExecute($Value_Input)
	EndIf
EndFunc

Func _Button_Install_Folder_VRHome_open()
	Local $Value_Input = GUICtrlRead($Input_Install_Folder_VRHome)
	If $Value_Input <> "" Then
		ShellExecute($Value_Input)
	EndIf
EndFunc

Func _Button_VRHomeCustomFolders_Path_open()
	Local $Value_Input = GUICtrlRead($Input_VRHomeCustomFolders_Path)
	If $Value_Input <> "" Then
		ShellExecute($Value_Input)
	EndIf
EndFunc


Func _Button_Install_Folder_save()
	Local $Value_Input = GUICtrlRead($Input_Install_Folder)
	Local $Check_Value_Input = StringRight($Value_Input, 1)
	If $Check_Value_Input <> "" and $Check_Value_Input <> "\" Then $Value_Input = $Value_Input & "\"
	IniWrite($config_ini, "Folders", "Install_Folder", $Value_Input)
EndFunc

Func _Button_Install_Folder_Steam_save()
	Local $Value_Input = GUICtrlRead($Input_Install_Folder_Steam)
	Local $Check_Value_Input = StringRight($Value_Input, 1)
	If $Check_Value_Input <> "" and $Check_Value_Input <> "\" Then $Value_Input = $Value_Input & "\"
	IniWrite($config_ini, "Folders", "Install_Folder_Steam", $Value_Input)
EndFunc

Func _Button_Install_Folder_VRHome_save()
	Local $Value_Input = GUICtrlRead($Input_Install_Folder_VRHome)
	Local $Check_Value_Input = StringRight($Value_Input, 1)
	If $Check_Value_Input <> "" and $Check_Value_Input <> "\" Then $Value_Input = $Value_Input & "\"
	IniWrite($config_ini, "Folders", "Install_Folder_VRHome", $Value_Input)
EndFunc

Func _Button_VRHomeCustomFolders_Path_save()
	Local $Value_Input = GUICtrlRead($Input_VRHomeCustomFolders_Path)
	Local $Check_Value_Input = StringRight($Value_Input, 1)
	If $Check_Value_Input <> "" and $Check_Value_Input <> "\" Then $Value_Input = $Value_Input & "\"
	IniWrite($config_ini, "Folders", "VRHomeCustomFolders", $Value_Input)
EndFunc


Func _Button_VRHomeCustomFolders_Path_delete()
	Local $Value_Input = GUICtrlRead($Input_VRHomeCustomFolders_Path)
	Local $Check_Value_Input = StringRight($Value_Input, 1)
	If $Check_Value_Input <> "\" Then $Value_Input = $Value_Input & "\"


	$Abfrage = MsgBox(4, "Information", "Do you realy want to Delete the following Files? " & @CRLF & @CRLF & _
											"- " & $Value_Input & "ApplicationList\" & @CRLF & "[VIVE HOME Desktop APP settings folder]" & @CRLF & @CRLF & _
											"Delete all '.appinfo' Files  manually if they were not deleted." & @CRLF & _
											"These Files will be created again automatically on next start." & @CRLF)

	If $Abfrage = 6 Then ;Ja - Auswahl = JA
		FileDelete($VIVE_HOME_ApplicationList_Folder)
		DirCreate($VIVE_HOME_ApplicationList_Folder)
		ShellExecute($VIVE_HOME_ApplicationList_Folder)
	EndIf
EndFunc

Func _Button_Delete_ApplicationList_INI()
	If FileExists($ApplicationList_INI) Then
		FileDelete($ApplicationList_INI)
	EndIf
	If FileExists($ApplicationList_INI) Then MsgBox(0, "Error", "ApplicationList.ini was not deleted, delete the File manually in '...\VIVEHIM\System\' Folder.", 5)
	If Not FileExists($ApplicationList_INI) Then MsgBox(0, "Deleted", "ApplicationList.ini Deleted", 3)
EndFunc


Func _Button_OVR_Service_Start()
	Local $Time = @HOUR & ":" & @MIN & ":" & @SEC
	GUICtrlSetData($Anzeige_Fortschrittbalken, 5)
	_GUICtrlStatusBar_SetText($Statusbar, "Starting Oculus Service." & @TAB & "...working..." &  @TAB & "'VR Home Shortcut Manager - Version " & $Version & "'")
	IniWrite($Config_INI, "TEMP", "OVRService", "Start")

	If FileExists($System_DIR & "StartStopOVRS.exe") Then
		ShellExecuteWait($System_DIR & "StartStopOVRS.exe", "", $System_DIR)
	Else
		ShellExecuteWait($System_DIR & "StartStopOVRS.au3", "", $System_DIR)
	EndIf
	GUICtrlSetData($Anzeige_Fortschrittbalken, 100)

	Sleep(500)
	IniWrite($Config_INI, "TEMP", "OVRService", "")
	_Check_OVR_Service()
	GUICtrlSetData($Anzeige_Fortschrittbalken, 0)
	_GUICtrlStatusBar_SetText($Statusbar, "Oculus Service running." & @TAB & "OVRS Running: " & $Time &  @TAB & "'VR Home Shortcut Manager - Version " & $Version & "'")
EndFunc

Func _Button_OVR_Service_Stop()
	Local $Time = @HOUR & ":" & @MIN & ":" & @SEC
	GUICtrlSetData($Anzeige_Fortschrittbalken, 5)
	_GUICtrlStatusBar_SetText($Statusbar, "Stopping Oculus Service." & @TAB & "...working..." &  @TAB & "'VR Home Shortcut Manager - Version " & $Version & "'")
	IniWrite($Config_INI, "TEMP", "OVRService", "Stop")

	If FileExists($System_DIR & "StartStopOVRS.exe") Then
		ShellExecuteWait($System_DIR & "StartStopOVRS.exe", "", $System_DIR)
	Else
		ShellExecuteWait($System_DIR & "StartStopOVRS.au3", "", $System_DIR)
	EndIf
	GUICtrlSetData($Anzeige_Fortschrittbalken, 100)

	Sleep(500)
	IniWrite($Config_INI, "TEMP", "OVRService", "")
	Sleep(1000)
	_Check_OVR_Service()
	GUICtrlSetData($Anzeige_Fortschrittbalken, 0)
	_GUICtrlStatusBar_SetText($Statusbar, "Oculus Service stopped." & @TAB & "OVRS Stopped: " & $Time &  @TAB & "'VR Home Shortcut Manager - Version " & $Version & "'")
EndFunc

Func _Check_OVR_Service()
	Sleep(1000)
	$OVR_Service_Check = "false"

	If ProcessExists("OVRServiceLauncher.exe") Then
		GUICtrlSetImage($OVR_Service_Check_pic, $gfx & "OVRS_running.bmp")
	Else
		GUICtrlSetImage($OVR_Service_Check_pic, $gfx & "OVRS_stoped.bmp")
	EndIf

	If Not ProcessExists("OVRServiceLauncher.exe") Then
		GUICtrlSetImage($OVR_Service_Check_pic, $gfx & "OVRS_stoped.bmp")
	EndIf
EndFunc

Func _Button_HTC_Service_Start()
	Local $Time = @HOUR & ":" & @MIN & ":" & @SEC
	GUICtrlSetData($Anzeige_Fortschrittbalken, 5)
	_GUICtrlStatusBar_SetText($Statusbar, "Starting HTC Service." & @TAB & "...working..." &  @TAB & "'VR Home Shortcut Manager - Version " & $Version & "'")
	IniWrite($Config_INI, "TEMP", "HTCService", "Start")

	If FileExists($System_DIR & "StartStopHTCS.exe") Then
		ShellExecuteWait($System_DIR & "StartStopHTCS.exe", "", $System_DIR)
	Else
		ShellExecuteWait($System_DIR & "StartStopHTCS.au3", "", $System_DIR)
	EndIf

	GUICtrlSetData($Anzeige_Fortschrittbalken, 100)

	If FileExists($Install_Folder_VIVE_Software & "PCClient\Vive.exe") Then
		ShellExecute($Install_Folder_VIVE_Software & "PCClient\Vive.exe", "", $System_DIR)
	EndIf

	Sleep(1000)
	IniWrite($Config_INI, "TEMP", "HTCService", "")
	_Check_HTC_Service()
	GUICtrlSetData($Anzeige_Fortschrittbalken, 0)
	_GUICtrlStatusBar_SetText($Statusbar, "HTC Vive Service running." & @TAB & "HTCS Running: " & $Time &  @TAB & "'VR Home Shortcut Manager - Version " & $Version & "'")
EndFunc

Func _Button_HTC_Service_Stop()
	Local $Time = @HOUR & ":" & @MIN & ":" & @SEC
	GUICtrlSetData($Anzeige_Fortschrittbalken, 5)
	_GUICtrlStatusBar_SetText($Statusbar, "Stopping HTC Service." & @TAB & "...working..." &  @TAB & "'VR Home Shortcut Manager - Version " & $Version & "'")
	IniWrite($Config_INI, "TEMP", "HTCService", "Stop")

	If FileExists($System_DIR & "StartStopHTCS.exe") Then
		ShellExecuteWait($System_DIR & "StartStopHTCS.exe", "", $System_DIR)
	Else
		ShellExecuteWait($System_DIR & "StartStopHTCS.au3", "", $System_DIR)
	EndIf
	GUICtrlSetData($Anzeige_Fortschrittbalken, 100)

	Sleep(500)
	IniWrite($Config_INI, "TEMP", "HTCService", "")
	Sleep(1000)
	_Check_HTC_Service()
	GUICtrlSetData($Anzeige_Fortschrittbalken, 0)
	_GUICtrlStatusBar_SetText($Statusbar, "HTC Service stopped." & @TAB & "HTCS Stopped: " & $Time &  @TAB & "'VR Home Shortcut Manager - Version " & $Version & "'")
EndFunc

Func _Check_HTC_Service()
	Sleep(1000)
	$HTC_Service_Check = "false"

	If ProcessExists("Vive.exe") Then
		GUICtrlSetImage($HTC_Service_Check_pic, $gfx & "OVRS_running.bmp")
	Else
		GUICtrlSetImage($HTC_Service_Check_pic, $gfx & "OVRS_stoped.bmp")
	EndIf

	If Not ProcessExists("Vive.exe") Then
		GUICtrlSetImage($HTC_Service_Check_pic, $gfx & "OVRS_stoped.bmp")
	EndIf
EndFunc

Func _Checkbox_StopOVRS_on_StartUp()
	Local $Status_Checkbox = GUICtrlRead($Checkbox_StopOVRS_on_StartUp)

	If $Status_Checkbox = 1 Then
		IniWrite($config_ini, "Settings", "StopOVRS_on_StartUp", "true")
		MsgBox(0, "Attention", "VIVEHIM needs to be started as Admin to be able to stop Processes and Services." & @CRLF & "Use 'StartVIVEHIM_AsAdmin.exe' in VIVEHIM install folder.", 10)
	EndIf

	If $Status_Checkbox = 4 Then
		IniWrite($config_ini, "Settings", "StopOVRS_on_StartUp", "false")
	EndIf
EndFunc

Func _Checkbox_Minimize_OVRS()
	Local $Status_Checkbox = GUICtrlRead($Checkbox_Minimize_OVRS)

	If $Status_Checkbox = 1 Then
		IniWrite($config_ini, "Settings", "Minimize_OVRS", "true")
	EndIf

	If $Status_Checkbox = 4 Then
		IniWrite($config_ini, "Settings", "Minimize_OVRS", "false")
	EndIf
EndFunc

Func _Checkbox_StopHTCS_on_StartUp()
	Local $Status_Checkbox = GUICtrlRead($Checkbox_StopHTCS_on_StartUp)

	If $Status_Checkbox = 1 Then
		IniWrite($config_ini, "Settings", "StopHTCS_on_StartUp", "true")
		MsgBox(0, "Attention", "VIVEHIM needs to be started as Admin to be able to stop Processes and Services." & @CRLF & "Use 'StartVIVEHIM_AsAdmin.exe' in VIVEHIM install folder.", 10)
	EndIf

	If $Status_Checkbox = 4 Then
		IniWrite($config_ini, "Settings", "StopHTCS_on_StartUp", "false")
	EndIf
EndFunc


Func _Checkbox_Overwrite_ApplicationList_INI_on_StartUp()
	Local $Status_Checkbox = GUICtrlRead($Checkbox_Overwrite_ApplicationList_INI_on_StartUp)

	If $Status_Checkbox = 1 Then
		IniWrite($config_ini, "Settings", "Overwrite_ApplicationList_INI_on_StartUp", "true")
	EndIf

	If $Status_Checkbox = 4 Then
		IniWrite($config_ini, "Settings", "Overwrite_ApplicationList_INI_on_StartUp", "false")
	EndIf
EndFunc

Func _Checkbox_AutoDownload_Missing_Icons()
	Local $Status_Checkbox = GUICtrlRead($Checkbox_AutoDownload_Missing_Icons)

	If $Status_Checkbox = 1 Then
		IniWrite($config_ini, "Settings", "AutoDownload_Missing_Icons", "true")
	EndIf

	If $Status_Checkbox = 4 Then
		IniWrite($config_ini, "Settings", "AutoDownload_Missing_Icons", "false")
	EndIf
EndFunc

Func _Checkbox_FB_Check()
	Local $Status_Checkbox = GUICtrlRead($Checkbox_FB_Check)

	If $Status_Checkbox = 1 Then
		IniWrite($config_ini, "Settings", "FB_Check", "true")
	EndIf

	If $Status_Checkbox = 4 Then
		IniWrite($config_ini, "Settings", "FB_Check", "false")
	EndIf
EndFunc

Func _Checkbox_USE_FB_GUI()
	Local $Status_Checkbox = GUICtrlRead($Checkbox_USE_FB_GUI)

	If $Status_Checkbox = 1 Then
		IniWrite($config_ini, "Settings", "USE_FB_GUI", "true")
		GUICtrlSetState($Checkbox_FB_Check, $GUI_CHECKED)
	EndIf

	If $Status_Checkbox = 4 Then
		IniWrite($config_ini, "Settings", "USE_FB_GUI", "false")
	EndIf
EndFunc

Func _Checkbox_CloseVIVEHIM_after_Start()
	Local $Status_Checkbox = GUICtrlRead($Checkbox_CloseVIVEHIM_after_Start)

	If $Status_Checkbox = 1 Then
		IniWrite($config_ini, "Settings", "CloseVIVEHIM_after_Start", "true")
		GUICtrlSetState($Checkbox_FB_Check, $GUI_CHECKED)
	EndIf

	If $Status_Checkbox = 4 Then
		IniWrite($config_ini, "Settings", "CloseVIVEHIM_after_Start", "false")
	EndIf
EndFunc
#endregion

#Region Func TAB 2
Func _ClickOnListView($hWndGUI, $MsgID, $wParam, $lParam)
    Local $tagNMHDR, $event, $hwndFrom, $code
    $tagNMHDR = DllStructCreate("int;int;int", $lParam)
    If @error Then Return
    $event = DllStructGetData($tagNMHDR, 3)
    If $wParam = $ListView Then
        If $event = $NM_CLICK Then
			_Change_Preview_Icon_ListView()
        EndIf

        If $event = $NM_DBLCLK Then
			_DB_Click_Listview()
        EndIf
    EndIf

    $tagNMHDR = 0
    $event = 0
    $lParam = 0
EndFunc

Func _DB_Click_Listview()
	Sleep(200)
	_Create_HTMLView_GUI()
	Sleep(200)
EndFunc

Func _Change_Preview_Icon_ListView()
	Local  $ListView_Selected_Row_Index = _GUICtrlListView_GetSelectedIndices($ListView)
	$ListView_Selected_Row_Index = Int($ListView_Selected_Row_Index)
	Local $ListView_Selected_Row_Nr = $ListView_Selected_Row_Index + 1

	Local $Check_AppID = _GUICtrlListView_GetItemText($ListView, $ListView_Selected_Row_Nr - 1, 1)
	Local $CheckImagePath = $Icons & "steam.app." & $Check_AppID & ".jpg"

	If $CheckImagePath = "" or $CheckImagePath = $Icons_DIR & "" & ".jpg" or Not FileExists($CheckImagePath) Then $CheckImagePath = $gfx & "Icon_Preview.jpg"
	GUICtrlSetImage($Icon_Preview_Image, $CheckImagePath)
EndFunc

Func _Create_HTMLView_GUI()
	Local $Button_Exit_HTML_GUI, $TreeView_Steam_app_NR, $TreeView_Steam_app_Name, $TreeView_Steam_app_ID, $TreeView_Steam_app_IS_Favorite
	Local $TreeView_Steam_app_PO_right_now, $TreeView_Steam_app_PO_24h_peak, $TreeView_Steam_app_PO_all_time_peak, $Text_SplitNR
	Local $Handle_2, $Text_2

	Local $ListView_Selected_Row_Index = _GUICtrlListView_GetSelectedIndices($ListView)
	$ListView_Selected_Row_Index = Int($ListView_Selected_Row_Index)
	Local $ListView_Selected_Row_Nr = $ListView_Selected_Row_Index + 1

    Local $ListView_Item_Array = _GUICtrlListView_GetItemTextArray($ListView, $ListView_Selected_Row_Index)
	;$ListView_Item_Name_ID = $ListView_Item_Array[2] & " - " & $ListView_Item_Array[3]
	Local $Steam_app_Name = $ListView_Item_Array[3]
	Local $Game_ID = $ListView_Item_Array[2]

	Local $oIE = ObjCreate("Shell.Explorer.2")

	Global $HTML_GUI = GUICreate($TreeView_Steam_app_Name & " - " & $Game_ID, 980, 600, (@DesktopWidth - 980) / 2, (@DesktopHeight - 600) / 2, BitOR($WS_MINIMIZEBOX, $WS_CAPTION, $WS_POPUP, $WS_EX_CLIENTEDGE, $WS_EX_TOOLWINDOW))
	GUICtrlCreateObj($oIE, 0, 0, 979, 550)

	Global $Button_Exit_HTML_GUI = GUICtrlCreateButton("Exit", 940, 560, 35, 35, $BS_BITMAP)
	GUICtrlSetOnEvent(- 1, "_Button_Exit_HTML_GUI")
	_GUICtrlButton_SetImage(- 1, $gfx & "Exit2.bmp")
	GuiCtrlSetTip(-1, "Closes HTML GUI.")

	Local $IE_Adresse = "https://steamdb.info/app/" & $Game_ID & "/graphs/"
	$oIE.navigate($IE_Adresse)

	GUISetState()
	$Game_ID = ""
EndFunc

Func _Button_Exit_HTML_GUI()
	GUIDelete($HTML_GUI)
EndFunc


Func _StartGame()
	Local $ListView_Selected_Row_Index = _GUICtrlListView_GetSelectedIndices($ListView)
	$ListView_Selected_Row_Index = Int($ListView_Selected_Row_Index)
	Local $ListView_Selected_Row_Nr = $ListView_Selected_Row_Index + 1

	Local $ListView_Item_Array = _GUICtrlListView_GetItemTextArray($ListView, $ListView_Selected_Row_Index)
	Local $ListView_Item_Name = $ListView_Item_Array[2]
	Local $ListView_Item_SteamID = $ListView_Item_Array[3]

	Local $Check_IF_Steam_APP = StringLeft($ListView_Item_SteamID, 10)
	Local $GameID = StringReplace($ListView_Item_SteamID, 'steam.app.', '')

	Sleep(500)

	If $Check_IF_Steam_APP = "steam.app." Then
		_GUICtrlStatusBar_SetText($Statusbar, "Starting Game: " & $ListView_Item_Name  & " - " & $ListView_Item_SteamID & @TAB & @TAB & "'VRHomeSM - Version " & $Version & "'")
		ShellExecute("steam://launch/" & $GameID & "/VR\")
	EndIf

	Sleep(10000)

	_Tab()
EndFunc

Func _Checkbox_CheckUncheck()
	Local $Status_Checkbox = GUICtrlRead($Checkbox_CheckUncheck)

	If $Status_Checkbox = 1 Then
		_GUICtrlListView_SetItemChecked($ListView, -1)
	EndIf

	If $Status_Checkbox = 4 Then
		Local $NR_GameNames = IniRead($ApplicationList_INI, "ApplicationList", "NR_Applications", "")
		For $LOOP_Checkbox = 0 To $NR_GameNames
			_GUICtrlListView_SetItemChecked($ListView, $LOOP_Checkbox, false)
		Next
	EndIf
EndFunc

Func _Button_Synch()
	Local $NR_GameNames = IniRead($ApplicationList_INI, "ApplicationList", "NR_Applications", "")

	_GUICtrlStatusBar_SetText($Statusbar, "Start adding Shortcuts and Icons..." & @TAB  & $GameName &  @TAB & "'VR Home Shortcut Manager - Version " & $Version & "'")

	For $LOOP_Checkbox_1 = 0 To $NR_GameNames
		Local $GameName_ListView = _GUICtrlListView_GetItemText($listview, $LOOP_Checkbox_1, 3)

		Local $CheckboxStatus =  _GUICtrlListView_GetItemChecked($ListView, $LOOP_Checkbox_1)

		If $CheckboxStatus = "True" Then
			Local $GetItem_NR = IniRead($ApplicationList_INI, "Application_" & $LOOP_Checkbox_1 + 1, "NR", "")
			$GetItem_AppId = IniRead($ApplicationList_INI, "Application_" & $LOOP_Checkbox_1 + 1, "AppId", "")
			Local $GetItem_Name = IniRead($ApplicationList_INI, "Application_" & $LOOP_Checkbox_1 + 1, "Name", "")
			$GetItem_installdir = IniRead($ApplicationList_INI, "Application_" & $LOOP_Checkbox_1 + 1, "installdir", "")
			Local $GetItem_IconPath = IniRead($ApplicationList_INI, "Application_" & $LOOP_Checkbox_1 + 1, "IconPath", "")

			Global $GameName = $GetItem_Name
			Local $Check_ImagePath = $GetItem_IconPath

			If $GetItem_AppId <> "" Then
				_GUICtrlStatusBar_SetText($Statusbar, "Working...Adding Shortcuts and Icons: " & @TAB & $GameName & @TAB & "'VR Home Shortcut Manager - Version " & $Version & "'")

				_Get_SteamGame_Icon_256x256()

				$ShortcutName = $GetItem_Name & ".lnk"
				$ShortcutIcon = $Icons & "256x256\" & "steam.app." & $GetItem_AppId & ".ico"
				If Not FileExists($ShortcutIcon) Then $ShortcutIcon = ""

				FileCreateShortcut("steam://rungameid/" & $GetItem_AppId, $VRHomeCustomFolders & "AppShortcuts\" & $ShortcutName, $Install_Folder_Steam & "common\" & $GetItem_installdir, "", _
						"Tooltip description of the shortcut.", $ShortcutIcon, "", "", @SW_SHOWNORMAL)
				FileCopy($Icons & "steam.app." & $GetItem_AppId & ".jpg", $VRHomeCustomFolders & "AppShortcuts\" & $GetItem_Name & ".jpg", $FC_OVERWRITE)

				_GUICtrlStatusBar_SetText($Statusbar, "Shortcuts and Icons successful added: " & @TAB  & $GameName &  @TAB & "'VR Home Shortcut Manager - Version " & $Version & "'")
			EndIf
			$GameName = ""
			$Check_ImagePath = ""
		Else
			Local $GetItem_NR = IniRead($ApplicationList_INI, "Application_" & $LOOP_Checkbox_1 + 1, "NR", "")
			$GetItem_AppId = IniRead($ApplicationList_INI, "Application_" & $LOOP_Checkbox_1 + 1, "AppId", "")
			Local $GetItem_Name = IniRead($ApplicationList_INI, "Application_" & $LOOP_Checkbox_1 + 1, "Name", "")
			$GetItem_installdir = IniRead($ApplicationList_INI, "Application_" & $LOOP_Checkbox_1 + 1, "installdir", "")
			Local $GetItem_IconPath = IniRead($ApplicationList_INI, "Application_" & $LOOP_Checkbox_1 + 1, "IconPath", "")

			$GameName = $GetItem_Name
			Local $Check_ImagePath = $GetItem_IconPath

			If $GetItem_AppId <> "" Then
				_GUICtrlStatusBar_SetText($Statusbar, "Working...Removing Shortcuts and Icons: " & @TAB & $GameName & @TAB & "'VR Home Shortcut Manager - Version " & $Version & "'")

				$ShortcutName = $GetItem_Name & ".lnk"
				$ShortcutIcon = $Icons & "256x256\" & "steam.app." & $GetItem_AppId & ".ico"
				If Not FileExists($ShortcutIcon) Then $ShortcutIcon = ""

				FileDelete($VRHomeCustomFolders & "AppShortcuts\" & $ShortcutName)
				FileDelete($VRHomeCustomFolders & "AppShortcuts\" & $GetItem_Name & ".jpg")

				_GUICtrlStatusBar_SetText($Statusbar, "Shortcuts and Icons successful removed: " & @TAB  & $GameName &  @TAB & "'VR Home Shortcut Manager - Version " & $Version & "'")
			EndIf
			$GameName = ""
			$Check_ImagePath = ""
		EndIf

		$ProcessBar_Status = $LOOP_Checkbox_1 * 100 / $NR_GameNames
		$ProcessBar_Status = $ProcessBar_Status
		GUICtrlSetData($Anzeige_Fortschrittbalken, $ProcessBar_Status)

	Next
	Sleep(500)
	Local $Time = @HOUR & ":" & @MIN & ":" & @SEC
	_GUICtrlStatusBar_SetText($Statusbar, "Finished adding Shortcuts and Icons" & @TAB & $Time &  @TAB & "'VR Home Shortcut Manager - Version " & $Version & "'")
	GUICtrlSetData($Anzeige_Fortschrittbalken, 0)
EndFunc

Func _Button_Start_VRHome()
	Local $Check_Checkbox_FB_Check = IniRead($config_ini,"Settings", "FB_Check", "")
	_GUICtrlStatusBar_SetText($Statusbar, "Starting VIVE HOME: " & @TAB & @TAB & "'VRHomeSM - Version " & $Version & "'")

	If Not ProcessExists("vrmonitor.exe") Then
		ShellExecute("steam://rungameid/250820")
		Local $NR_TEMP = 0
		Do
			$NR_TEMP = $NR_TEMP + 1
			Sleep(1000)
			If $NR_TEMP = 45 Then
				MsgBox(0, "Attention", "Unable to start SteamVR." & @CRLF & @CRLF & "Please try again.")
				_Restart()
			EndIf
		Until ProcessExists("vrmonitor.exe")
	EndIf

	Sleep(500)

	If FileExists($System_DIR & "1_VRHome.exe") Then
		ShellExecuteWait($System_DIR & "1_VRHome.exe", "", $System_DIR)
	Else
		ShellExecuteWait($System_DIR & "1_VRHome.au3", "", $System_DIR)
	EndIf

	Sleep(2000)

	If $Check_Checkbox_FB_Check = "true" Then
		If FileExists($System_DIR & "FBCheck.exe") Then
			ShellExecute($System_DIR & "FBCheck.exe", "", $System_DIR)
		Else
			ShellExecute($System_DIR & "FBCheck.au3", "", $System_DIR)
		EndIf
	EndIf

	Sleep(100)

	Exit
EndFunc
#endregion

#Region Func VRHomeSM
Func _Button_INFO()
	$Abfrage = MsgBox(4, "INFO", "VR Home Shortcut Manager [VRHomeSM]" & @CRLF & @CRLF & _
						"GitHub:" & @CRLF & _
						"https://github.com/CogentHub/VRHomeSM" & @CRLF & @CRLF & _
						"22.04.2017 made by:" & @CRLF & _
						"Cogent, Stridyr" & @CRLF & @CRLF & _
						"Do you want to open 'VRHomeSM_StartUp_Guide.pdf'?" & @CRLF & @CRLF, 20)

	If $Abfrage = 6 Then
		ShellExecute($Install_DIR & "VRHomeSM_StartUp_Guide.pdf")
	EndIf
EndFunc

Func _Restart()
	$StartedAsAdmin = IniRead($Config_INI, "TEMP", "StartedAsAdmin", "")

	If $StartedAsAdmin = "true" Then
		If FileExists($Install_DIR & "StartVRHomeSM_AsAdmin.exe") Then
			ShellExecute($Install_DIR & "StartVRHomeSM_AsAdmin.exe")
		Else
			ShellExecute($Install_DIR & "StartVRHomeSM_AsAdmin.au3")
		EndIf
	Else
		If FileExists($Install_DIR & "StartVRHomeSM.exe") Then
			ShellExecute($Install_DIR & "StartVRHomeSM.exe")
		Else
			ShellExecute($Install_DIR & "StartVRHomeSM.au3")
		EndIf
	EndIf
	Exit
EndFunc

Func _Beenden()
	IniWrite($config_ini, "TEMP", "StartedAsAdmin", "")
	IniWrite($config_ini, "TEMP", "TEMP_1", "")
	IniWrite($config_ini, "TEMP", "TEMP_2", "")
	IniWrite($config_ini, "TEMP", "TEMP_3", "")
	Exit
EndFunc
#endregion

#endregion