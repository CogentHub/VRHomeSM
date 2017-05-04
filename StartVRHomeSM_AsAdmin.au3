
#RequireAdmin

$config_ini = @ScriptDir & "\System\" & "config.ini"
$Install_DIR = @ScriptDir & "\"
IniWrite($config_ini, "Folders", "Install_Folder", $Install_DIR)
IniWrite($Config_INI, "TEMP", "StartedAsAdmin", "true")

Global $VIVE_HOME_VRAPP_Folder = IniRead($Config_INI, "Folders", "VIVE_HOME_VRAPP", "")

If FileExists($Install_DIR & "System\VRHomeSM.exe") Then
	ShellExecute($Install_DIR & "System\VRHomeSM.exe", $Install_DIR & "System\")
Else
	ShellExecute($Install_DIR & "System\VRHomeSM.au3", $Install_DIR & "System\")
EndIf

Exit