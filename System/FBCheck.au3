#include <MsgBoxConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <Array.au3>
#include <GuiButton.au3>

Opt("GUIOnEventMode", 1)

Global $SteamVR_Status, $Title_1, $Title_2, $Handle_1, $Handle_2, $Title_Array_1, $Title_Array_2, $Handle_Array_1, $Handle_Array_2, $NR_Handle_1, $NR_Handle_2
Global $GameStarted, $LOOP_VIVEHOMECheck, $OldWindowExists

Global $config_ini = @ScriptDir & "\config.ini"
Global $Install_DIR = IniRead($config_ini, "Folders", "Install_Folder", "")
Global $System_DIR = $Install_DIR & "System\"
Global $Install_Folder_VIVE_HOME = IniRead($Config_INI, "Folders", "Install_Folder_VIVE_HOME", "")
Global $VIVE_HOME_EXE = $Install_Folder_VIVE_HOME & "ViveHome.exe"
Global $Status_Checkbox_Minimize_OVRS = IniRead($config_ini,"Settings", "Minimize_OVRS", "")
Global $gfx = @ScriptDir & "\" & "gfx\"

Global $LimeGreen = "0x32CD32"
Global $Blue = "0x00BFFF"
Global $Yellow = "0xFFFF00"

Global $USE_FB_GUI = IniRead($Config_INI, "Settings", "USE_FB_GUI", "")

$DesktopWidth = @DesktopWidth / 2
$DesktopHeight = @DesktopHeight

$Width = $DesktopWidth - 118
$Height = $DesktopHeight - 5

$X = $Width
$Y = $DesktopHeight - $Height

$font_arial = "arial"

$SteamVR_Status = "true"

Local Const $PG_WS_POPUP = 0x80000000
Local Const $PG_WS_DLGFRAME = 0x00400000

$font_arial = "arial"

If $USE_FB_GUI = "true" Then
	$GUI = GUICreate("FBCheck", 230, 35, $X, $Y, BitOR($PG_WS_DLGFRAME, $PG_WS_POPUP))
	GUISetIcon(@AutoItExe, -2, $GUI)
	GUISetBkColor($Yellow)

	$GUI_Label = GUICtrlCreateLabel("...Loading...", 50, 19, 127, 20)
	GUICtrlSetFont(-1, 11, 600, 2, $font_arial, 2)
	GUISetBkColor($Yellow)

	Global $Button_Close_Current_Running = GUICtrlCreateButton("Close current running APP", 35, 0, 160, 20, $BS_BITMAP)
	GUICtrlSetOnEvent($Button_Close_Current_Running, "_Close_CurrentRunning")

	Global $Button_Restart = GUICtrlCreateButton("Restart", 0, 0, 35, 35, $BS_BITMAP)
	_GUICtrlButton_SetImage($Button_Restart, $gfx & "Restart.bmp")
	GUICtrlSetOnEvent($Button_Restart, "_Restart_FBCheck")

	Global $Button_Exit = GUICtrlCreateButton("Exit", 195, 0, 35, 35, $BS_BITMAP)
	_GUICtrlButton_SetImage($Button_Exit, $gfx & "Exit.bmp")
	GUICtrlSetOnEvent($Button_Exit, "_Exit")

	GUISetState(@SW_SHOW, $GUI)
	WinActivate("Vive Home")
EndIf

_Check_Open_Windows_1()

Do
	If $USE_FB_GUI = "true" Then
		GUICtrlSetData($GUI_Label, "...Loading...")
		GUISetBkColor($Yellow)
	EndIf

	$Status_Checkbox_Minimize_OVRS = IniRead($config_ini,"Settings", "Minimize_OVRS", "")
	If $Status_Checkbox_Minimize_OVRS = "true" Then
		If WinExists("Oculus") Then WinSetState("Oculus", "", @SW_MINIMIZE)
	EndIf

	If ProcessExists("vrmonitor.exe") or WinExists("SteamVR-Status") or WinExists("SteamVR Status") Then
		;_Check_Open_Windows_1()
		$VIVEHOMECheck = "false"
		For $LOOP_VIVEHOMECheck = 0 To $NR_Handle_1
			If $Title_Array_1[$LOOP_VIVEHOMECheck] = "VR Home" or $Title_Array_1[$LOOP_VIVEHOMECheck] = "VRHome" Then
				$VIVEHOMECheck = "true"
			EndIf
		Next

		If $VIVEHOMECheck = "true" Then
			If $USE_FB_GUI = "true" Then
				GUICtrlSetData($GUI_Label, "VR Home")
				GUISetBkColor($Blue)
			EndIf
			If $USE_FB_GUI = "true" Then WinSetOnTop("FBCheck", "", $WINDOWS_ONTOP)
			Do
				$GameStarted = ""
				;_Check_Open_Windows_1()
				Sleep(5000)
				If $Status_Checkbox_Minimize_OVRS = "true" Then
					If WinExists("Oculus") Then WinSetState("Oculus", "", @SW_MINIMIZE)
				EndIf
			Until Not WinExists("VR Home")
			If $USE_FB_GUI = "true" Then WinSetState("FBCheck", "", @SW_DISABLE)
			Sleep(3000)
		Else
			Sleep(5000)
		EndIf

		_Check_Open_Windows_2()

		If $NR_Handle_1 <> $NR_Handle_2 Then
			_Check_Windows_Title()
			$OldWindowExists = "false"
			For $i = 1 To $NR_Handle_1
				If $Title_Array_1[$i] = $GameStarted Then
					$OldWindowExists = "true"
				EndIf
			Next
		EndIf

		If $GameStarted <> "" and $GameStarted <> "Oculus" and $GameStarted <> "VR Home" and $GameStarted <> "SteamVR-Status" and $GameStarted <> "SteamVR Status" and $GameStarted <> "SteamVR-Running..." and $OldWindowExists <> "true" and $GameStarted <> "FBCheck" Then
			If $USE_FB_GUI = "true" Then WinSetOnTop("FBCheck", "", $WINDOWS_ONTOP)
			Do
				If $USE_FB_GUI = "true" Then
					GUICtrlSetData($GUI_Label, $GameStarted)
					GUISetBkColor($LimeGreen)
				EndIf
				If $Status_Checkbox_Minimize_OVRS = "true" Then
					If WinExists("Oculus") Then WinSetState("Oculus", "", @SW_MINIMIZE)
				EndIf
				Sleep(5000)
				If Not ProcessExists("vrmonitor.exe") Then Exit
			Until Not WinExists($GameStarted)
			If $USE_FB_GUI = "true" Then WinSetState("FBCheck", "", @SW_DISABLE)

			If Not WinExists($GameStarted) Then
				If FileExists($System_DIR & "1_ViveHome.exe") Then
					ShellExecute($System_DIR & "1_ViveHome.exe", "", $System_DIR)
				Else
					ShellExecute($System_DIR & "1_ViveHome.au3", "", $System_DIR)
				EndIf
				Sleep(500)
				If FileExists($System_DIR & "FBCheck.exe") Then
					ShellExecute($System_DIR & "FBCheck.exe", "", $System_DIR)
				Else
					ShellExecute($System_DIR & "FBCheck.au3", "", $System_DIR)
				EndIf
				Exit
			EndIf
		EndIf

	Else
		$SteamVR_Status = "false"
	EndIf

	If $USE_FB_GUI = "true" Then
		GUICtrlSetData($GUI_Label, $GameStarted & "...Loading...")
		GUISetBkColor($Yellow)
	EndIf
Until $SteamVR_Status = "false"


Func _Check_Open_Windows_1()
    ; Retrieve a list of window handles.
	Global $Title_1
	Global $Handle_1
    Local $aList = WinList()

    ; Loop through the array displaying only visable windows with a title.
    For $i = 1 To $aList[0][0]
        If $aList[$i][0] <> "" And BitAND(WinGetState($aList[$i][1]), 2) Then
			$Title_1 = $Title_1 & "," & $aList[$i][0]
			$Handle_1 = $Handle_1 & "," & $aList[$i][1]
        EndIf
    Next

	$Title_1 = StringTrimLeft($Title_1, "1")
	$Handle_1 = StringTrimLeft($Handle_1, "1")
	$Title_Array_1 = StringSplit($Title_1, ',')
	$Handle_Array_1 = StringSplit($Handle_1, ',')

	$NR_Handle_1 = $Handle_Array_1[0]
EndFunc

Func _Check_Open_Windows_2()
    ; Retrieve a list of window handles.
	Global $Title_2
	Global $Handle_2
    Local $aList = WinList()

    ; Loop through the array displaying only visable windows with a title.
    For $i = 1 To $aList[0][0]
        If $aList[$i][0] <> "" And BitAND(WinGetState($aList[$i][1]), 2) Then
			$Title_2 = $Title_2 & "," & $aList[$i][0]
			$Handle_2 = $Handle_2 & "," & $aList[$i][1]
        EndIf
    Next

	$Title_2 = StringTrimLeft($Title_2, "1")
	$Handle_2 = StringTrimLeft($Handle_2, "1")
	$Title_Array_2 = StringSplit($Title_2, ',')
	$Handle_Array_2 = StringSplit($Handle_2, ',')

	$NR_Handle_2 = $Handle_Array_2[0]
EndFunc

Func _Check_Windows_Title()
	Opt("WinTitleMatchMode",4)
	$WinTitle = WinGetTitle("[ACTIVE]")
	WinActivate($WinTitle)
	$GameStarted = $WinTitle
EndFunc

Func _Restart_FBCheck()
	If FileExists($System_DIR & "FBCheck.exe") Then
		ShellExecute($System_DIR & "FBCheck.exe", "", $System_DIR)
	Else
		ShellExecute($System_DIR & "FBCheck.au3", "", $System_DIR)
	EndIf
	If WinExists("VR Home") Then WinActivate("VR Home")
	If WinExists($GameStarted) Then WinActivate($GameStarted)
	Exit
EndFunc

Func _Close_CurrentRunning()
	WinClose($GameStarted)
	_Restart_FBCheck()
	If WinExists("VR Home") Then WinActivate("VR Home")
	Exit
EndFunc

Func _Exit()
	Exit
EndFunc



