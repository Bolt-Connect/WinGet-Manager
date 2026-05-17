; WinGet Manager - Inno Setup script
; Requires Inno Setup 6+ : https://jrsoftware.org/isdl.php
;
; Build locally:
;   ISCC.exe installer\WinGetManager.iss
;
; In CI: GitHub Actions installs ISCC and runs that command.

#define MyAppName        "WinGet Manager"
#define MyAppShort       "WinGetManager"
#define MyAppPublisher   "Bolt-Connect"
#define MyAppURL         "https://github.com/Bolt-Connect/WinGet-Manager"
#define MyAppExeName     "WinGetManager.exe"

; Version can be set externally via /DMyAppVersion=x.y.z
#ifndef MyAppVersion
  #define MyAppVersion "0.1.0"
#endif

[Setup]
AppId={{A4F8D2E3-1B5C-4A9D-8E7F-2C3B5D6E7F8A}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}/issues
AppUpdatesURL={#MyAppURL}/releases
DefaultDirName={autopf}\{#MyAppShort}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
LicenseFile=..\LICENSE
OutputDir=..\release
OutputBaseFilename={#MyAppShort}-Setup-{#MyAppVersion}
SetupIconFile=..\assets\icon.ico
UninstallDisplayIcon={app}\{#MyAppExeName}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0.17763
DisableProgramGroupPage=yes
DisableReadyPage=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "dutch";   MessagesFile: "compiler:Languages\Dutch.isl"

[CustomMessages]
english.ScheduledTaskDesc=Enable daily auto-update task (Task Scheduler)
dutch.ScheduledTaskDesc=Dagelijkse auto-update taak inschakelen (Task Scheduler)

[Tasks]
Name: "desktopicon";   Description: "{cm:CreateDesktopIcon}";        GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunch";   Description: "{cm:CreateQuickLaunchIcon}";    GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "scheduledtask"; Description: "{cm:ScheduledTaskDesc}"; Flags: unchecked

[Files]
Source: "..\build\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\config\*";        DestDir: "{app}\config"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\README.md";             DestDir: "{app}"; Flags: ignoreversion
Source: "..\LICENSE";               DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}";  Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: quicklaunch

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
Filename: "schtasks.exe"; Parameters: "/Create /TN ""{#MyAppShort}-AutoUpdate"" /TR ""'{app}\{#MyAppExeName}' -UpdateAll -Silent"" /SC DAILY /ST 03:00 /F"; Flags: runhidden; Tasks: scheduledtask

[UninstallRun]
Filename: "schtasks.exe"; Parameters: "/Delete /TN ""{#MyAppShort}-AutoUpdate"" /F"; Flags: runhidden; RunOnceId: "DelTask"

[UninstallDelete]
Type: filesandordirs; Name: "{app}\logs"
Type: filesandordirs; Name: "{app}\config"
