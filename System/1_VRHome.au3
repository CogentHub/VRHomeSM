#include <MsgBoxConstants.au3>
#include <Array.au3>

Global $config_ini = @ScriptDir & "\config.ini"
Global $Install_DIR = IniRead($config_ini, "Folders", "Install_Folder", "")
Global $System_DIR = $Install_DIR & "System\"
Global $Install_Folder_VIVE_HOME = IniRead($Config_INI, "Folders", "Install_Folder_VIVE_HOME", "")
Global $VR_HOME_SteamID = "575430"

If ProcessExists("vrmonitor.exe") Then
	IniWrite($Config_INI, "TEMP", "Use_VIVEHOME_lnk", "true")
	_Start()
	IniWrite($Config_INI, "TEMP", "Use_VIVEHOME_lnk", "false")
	Exit
Else
	IniWrite($Config_INI, "TEMP", "Use_VIVEHOME_lnk", "true")
	Do
		Sleep(1000)
	Until ProcessExists("vrmonitor.exe")
	_Start()
	IniWrite($Config_INI, "TEMP", "Use_VIVEHOME_lnk", "false")
	Exit
EndIf

Func _Start()

	Sleep(100)
	If Not WinExists("VR Home") Then
		ShellExecute("steam://rungameid/" & $VR_HOME_SteamID)
	Else
		WinClose("VR Home")
		Sleep(500)
		ShellExecute("steam://rungameid/" & $VR_HOME_SteamID)
	EndIf
	Sleep(1000)
EndFunc

Exit

