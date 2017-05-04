
#RequireAdmin

Global $OVR_Status_Check
Global $Config_INI = @ScriptDir & "\config.ini"

$HTCService_Status_Check = IniRead($Config_INI, "TEMP", "HTCService", "")

If $HTCService_Status_Check = "" Then Exit
If $HTCService_Status_Check = "Start" Then _Button_HTCS_Service_Start()
If $HTCService_Status_Check = "Stop" Then _Button_HTCS_Service_Stop()

Exit

Func _Button_HTCS_Service_Start()
	RunWait("net start Viveport", "", @SW_HIDE)
EndFunc

Func _Button_HTCS_Service_Stop()
	_Button_HTCS_Process_Stop()
	RunWait("net stop Viveport", "", @SW_HIDE)
	RunWait("net stop HTC Account Service", "", @SW_HIDE)
EndFunc

Func _Button_HTCS_Process_Stop()
	ProcessClose("HTCVRMarketplaceUserContextHelper.exe")
	ProcessClose("HTCVRMarketplaceUserContextHelper.exe")
	ProcessClose("Htc.Identity.Authenticator.exe")
	ProcessClose("Htc.Identity.Authenticator.exe")
	ProcessClose("Vive.exe")
	ProcessClose("Vive.exe")
	ProcessClose("nw.exe")
	ProcessClose("nw.exe")
	ProcessClose("nw.exe")
	ProcessClose("nw.exe")
	ProcessClose("nw.exe")
	ProcessClose("nw.exe")
	ProcessClose("nw.exe")
	ProcessClose("nw.exe")
	ProcessClose("nw.exe")
	ProcessClose("nw.exe")
EndFunc

Exit
