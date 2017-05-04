
#RequireAdmin

Global $OVR_Status_Check
Global $Config_INI = @ScriptDir & "\config.ini"

$OVR_Status_Check = IniRead($Config_INI, "TEMP", "OVRService", "")

If $OVR_Status_Check = "" Then Exit
If $OVR_Status_Check = "Start" Then _Button_OVR_Service_Start()
If $OVR_Status_Check = "Stop" Then _Button_OVR_Service_Stop()


Func _Button_OVR_Service_Start()
	RunWait("net start OVRService", "", @SW_HIDE)
EndFunc

Func _Button_OVR_Service_Stop()
	RunWait("net stop OVRService", "", @SW_HIDE)
EndFunc