; Kubik Installer
; ������ 2
; (�) 2012-2017 ragweed
; PureBasic 5.11 + PureZIP

;{ ��������� � ���������� ����������

#Kubik_Version = "3.1"
#AP$ = Chr(34)

; ���� ����� 1 - ������ ������� ����������� ����� ����� ���������� ������������ ������ ���������� ������ �����
#Test_ManualUnpacking = 0

Enumeration
  #Window
  #Image_Logo
  #Image_Progress
  #Text_Info_1
  #Text_1
  #Text_Error
  #Text_ExtractFiles
  #Text_Info_2
  #Button_Path
  
  #Button_Install
  #Button_Update
  
  #Button_Exit
  #ProgressBar_Progress
  #CheckBox_Desktop
  #CheckBox_Menu_Start
  #CheckBox_Run_KStart
  #CheckBox_Web_Site
  #Hyperlink_Web
  #Hyperlink_Help
  #Hyperlink_Run
  #Directory
  #fTop
  #fTex
  #Editor_InstallLog
EndEnumeration

; ����� �������� ����, ���� ����� ���������� �����-��������
Global PathForInstall.s

; ������������ ������ �� ������ ������� �����-���������
Global BackupFolder.s

; ����� 1, ���� ��������� ���� ������� ��������� � ����� ������� Open_Window_Final(), ����� 0
Global IsOpenFinalWindow = 0

; ����� 1, ���� ��������� ����������� � ����� ������� Open_Window_Error(), ����� 0
Global IsOpenErrorWindow = 0

; ����� ������������ ������� ���������� ���������� ���������
Global CurrentError.s

; ����� 1 � ������ ��������� ���������� ���������
Global SuccessfulInstall = 0
  
;}

;{ ��������� �����������
UsePNGImageDecoder()
Global Image0
Global Image1
Image0 = CatchImage(0, ?Image0)
Image1 = CatchImage(1, ?Image1)
DataSection
  Image0:
  IncludeBinary "images/logo.png"
  Image1:
  IncludeBinary "images/rubik-original.PNG"
EndDataSection
;}

;{ get / set

; ����� � ���� ������ ������ ���������������� �����-��������� Kubik
Procedure.s GetInstallVersion()
  ProcedureReturn #Kubik_Version
EndProcedure

; ��������� ������������ ������ �� ������ ������� �����-��������� (�����. ��� �������. ����������)
Procedure.s GetBackupFolder()
  ProcedureReturn BackupFolder.s
EndProcedure

; ������������� ������������ ������ �� ������ ������� �����-��������� (�����. ��� �������. ����������)
Procedure SetBackupFolder(backup_folder.s)
  BackupFolder.s = backup_folder.s
EndProcedure

; ������������� ����, �� �������� ����� ���������� �����-��������
; ���� �� ������� ���� ����� ���������� '3.0.92' ������ Kubik - ������������ �� ������ 
; ��������� � ����� ����������
Procedure SetPath(path.s)
  PathForInstall.s = path.s
  ; ���������, ���� �� �� ������� ���� ������ ������ �����-���������
  If FileSize(path.s) = -2
    ; �������� ������� ������, ����� ������ ������ �����-���������
    If OpenPreferences(path.s + "Kubik_Set.ini")
      PreferenceGroup("Version")
      Select ReadPreferenceLong("Sys", -1)
        ; ������ '3.0.92'
        Case 2
          SetUpdateMode(path.s, "3.0.92")
        Default
          SetLockInstallMode(path.s)
      EndSelect
      ClosePreferences()
    Else
      SetInstallMode(path.s)
    EndIf
  Else
    SetInstallMode(path.s)
  EndIf
EndProcedure

; ����� ������� ���� ��������� �����-���������, �������� SetPath()
Procedure.s GetPath()
  ProcedureReturn PathForInstall.s
EndProcedure

;}

;{ UI � �������������� � ���

Procedure Open_Window_Start()
  If OpenWindow(#Window, 0, 0, 400, 350, "��������� Kubik " + GetInstallVersion(),  #PB_Window_SystemMenu | #PB_Window_TitleBar | #PB_Window_ScreenCentered)
    SetWindowColor(#Window, RGB(255, 255, 255))
    ImageGadget(#Image_Logo, 70, 75, 270, 81, Image0)
    TextGadget(#Text_Info_1, 0, 170, WindowWidth(#Window), 20, "Kubik ����� ���������� �:", #PB_Text_Center)
      SetGadgetFont(#Text_Info_1, LoadFont(0, "Arial", 10))
      SetGadgetColor(#Text_Info_1, #PB_Gadget_BackColor, RGB(255, 255, 255))
    TextGadget(#Text_Info_2, 70, 190, 270, 20, "", #PB_Text_Center)
      SetGadgetFont(#Text_Info_2, LoadFont(1, "Arial", 10))
      SetGadgetColor(#Text_Info_2, #PB_Gadget_BackColor, RGB(255, 255, 255))
      
    If ButtonGadget(#Button_Install, 110, 215, 190, 50, "����������")
      SetGadgetFont(#Button_Install, LoadFont(3, "Arial", 16))
      HideGadget(#Button_Install, 1)
    EndIf
    
    If ButtonGadget(#Button_Update, 110, 215, 190, 50, "��������")
      SetGadgetFont(#Button_Update, LoadFont(4, "Arial", 16))
      HideGadget(#Button_Update, 1)
    EndIf
    
    ButtonGadget(#Button_Path, 140, 270, 130, 35, "��������...")
      SetGadgetFont(#Button_Path, LoadFont(9, "Arial", 11))
  EndIf
EndProcedure

Procedure Open_Window_Prog()
  If IsGadget(#Image_Logo) : FreeGadget(#Image_Logo) : EndIf
  If IsGadget(#Text_Info_1) : FreeGadget(#Text_Info_1) : EndIf
  If IsGadget(#Text_Info_2) : FreeGadget(#Text_Info_2) : EndIf
  If IsGadget(#Button_Install) : FreeGadget(#Button_Install) : EndIf
  If IsGadget(#Button_Update) : FreeGadget(#Button_Update) : EndIf
  If IsGadget(#Button_Path) : FreeGadget(#Button_Path) : EndIf
  ; ImageGadget(#Image_Progress, 137, 90, 130, 130, Image1)
  ProgressBarGadget(#ProgressBar_Progress, 105, 250, 190, 10, 0, 10, #PB_ProgressBar_Smooth)
  EditorGadget(#Editor_InstallLog, 0, 0, WindowWidth(#Window), 220, #PB_Editor_ReadOnly | #PB_Editor_WordWrap)
EndProcedure
 
Procedure Open_Window_Final()
  If IsGadget(#ProgressBar_Progress) : FreeGadget(#ProgressBar_Progress) : EndIf
  SetWindowColor(#Window, -1)
  TextGadget(#Text_ExtractFiles, 110, 230, 180, 25, "��������� ���������!", #PB_Text_Center)
    SetGadgetFont(#Text_ExtractFiles, LoadFont(7, "Arial", 12))
  ButtonGadget(#Button_Exit, 250, 285, 130, 35, "�����", #PB_Button_Default)
    SetGadgetFont(#Button_Exit, LoadFont(3, "Arial", 13))
  CheckBoxGadget(#CheckBox_Desktop, 25, 260, 195, 20, "������� ����� �� ������� �����")
    SetGadgetState(#CheckBox_Desktop, 1) 
  CheckBoxGadget(#CheckBox_Menu_Start, 25, 280, 185, 15, "������� ����� � ���� "+#AP$+"����"+#AP$+"")
    SetGadgetState(#CheckBox_Menu_Start, 1) 
  CheckBoxGadget(#CheckBox_Run_KStart, 25, 300, 185, 15, "��������� Kubik Start")
    SetGadgetState(#CheckBox_Run_KStart, 1)
  CheckBoxGadget(#CheckBox_Web_Site, 25, 320, 185, 15, "�������� ���� �������")
    SetGadgetState(#CheckBox_Web_Site, 1)  
  Frame3DGadget(#fTop ,225, 260, 1, 80, "")
EndProcedure

Procedure Open_Window_Error()
  If IsGadget(#Image_Progress) : FreeGadget(#Image_Progress) : EndIf
  If IsGadget(#ProgressBar_Progress) : FreeGadget(#ProgressBar_Progress) : EndIf
  SetWindowColor(#Window, -1)
  TextGadget(#Text_1, 110, 230, 180, 25, "��������� ��������!", #PB_Text_Center)
  SetGadgetFont(#Text_1, LoadFont(7, "Arial", 12))
  TextGadget(#Text_Error, 20, 170, 360, 100, "", #PB_Text_Center)
  HideGadget(#Text_Error, 1)
  Frame3DGadget(#fTex, 10, 155, 250, 120, "�������:")
  HideGadget(#fTex, 1)
  ButtonGadget(#Button_Exit, 250, 285, 130, 35, "�����", #PB_Button_Default)
    SetGadgetFont(#Button_Exit, LoadFont(3, "Arial", 13))
EndProcedure

; ����� ��������� � ���� ��������� (Open_Window_Prog())
Procedure Msg(text.s)
  text.s = FormatDate("[%hh:%ii:%ss] ", Date()) + text.s
  AddGadgetItem(#Editor_InstallLog, -1, text.s)
EndProcedure

; ��������� ������� ���������� ���������� ���������
Procedure SetCurrentError(message.s)
  CurrentError.s = message.s
EndProcedure

; ���������� ������� ���������� ���������� ���������
Procedure.s GetCurrentError()
  ProcedureReturn CurrentError.s
EndProcedure

; ����������� ���������� � ����� ������� ���������
Procedure SetInstallMode(path.s)
  HideGadget(#Button_Install, 0)
  DisableGadget(#Button_Install, 0)
  HideGadget(#Button_Update, 1)
  SetGadgetText(#Text_Info_1, "Kubik ����� ���������� �:")
  SetGadgetText(#Text_Info_2, path.s)
EndProcedure

; ����������� ���������� � ����� ���������� �����-���������
Procedure SetUpdateMode(path.s, version.s)
  HideGadget(#Button_Install, 1)
  HideGadget(#Button_Update, 0)
  SetGadgetText(#Text_Info_1, "� '" + path.s + "' ��� ��������� Kubik ������ " + version.s + ".")
  SetGadgetText(#Text_Info_2, "�������� ��� �� ������ " + GetInstallVersion() + "?")
EndProcedure

; ����� SetInstallMode(), �� ��������� �������������
; ������������ ��� ������ � �������� ���� ��������� ��� ������������� �����-�������� ��������� ������
Procedure SetLockInstallMode(path.s)
  SetInstallMode(path.s)
  DisableGadget(#Button_Install, 1)
  SetGadgetText(#Text_Info_1, "�� ���������� ���� ���������� ��������� ������ Kubik:")
EndProcedure

Procedure Error(comment.s)
  Open_Window_Error()
  Msg(comment.s)
  SetGadgetText(#Text_Error, comment)
EndProcedure

;}

;{ SFX
Global DoneFiles, ProgName.s=ProgramFilename()

; ����������� � ���� ������ ��������� ���������� ������
Procedure PureSFXCallback(File.s, PerCent)
  Result=0
  ProgressText$ = File
  Msg(ProgressText$)
  SetGadgetState(#ProgressBar_Progress, DoneFiles*100/PerCent)
  DoneFiles+1
  ProcedureReturn Result
EndProcedure

; ���������� ������ � ����� ExtractPath.s
; ��������� 1 � ������ �����, ����� 0
Procedure ExtractArchive(ExtractPath.s)
  GlobalInfo.unz_global_info
  FileInfo.PureZIP_FileInfo
  PureZIP_SetArchivePassword("")
  CountFiles=PureZIP_GetFileCount(ProgName) ; ����� ������ � ������
  
  For i=0 To CountFiles-1 ; �������� ����������� �� �����
    If PureZIP_GetFileInfo(ProgName,i,@FileInfo) = #True 
      If FileInfo\flag & 1 = 1
        Pass.s=InputRequester(GetFilePart(ProgName)+" - ����� ������� �������!", "������� ������ ������","")
        PureZIP_SetArchivePassword(Pass)
        Break
      EndIf
    EndIf
  Next i
  
  ; ��������� ����� (����������� ���� ������������)
  If PureZIP_Archive_Read(ProgName)
    DoneFiles=1
    PureZIP_Archive_GlobalInfo(@GlobalInfo) 
    NrOfCompressed.l = GlobalInfo\number_entry
    ReturnValue.l = PureZIP_Archive_FindFirst()
    While ReturnValue = #UNZ_OK
      ; ������ � ����� (������, ����, ������� ������, CRC � �. �.)
      If PureZIP_Archive_FileInfo(@FileInfo) = #UNZ_OK
        
        ; ������������� �����
        If PureZIP_Archive_Extract(ExtractPath, #True) = #UNZ_OK 
          
          ; ���������� �������� �������������
          If PureSFXCallback(FileInfo\FileName, NrOfCompressed) = 1
            Break 
          EndIf
          
          ; ���������� � ���������� ���������� �����
          ReturnValue = PureZIP_Archive_FindNext()
        Else
          SetCurrentError("��������� ������ ��� ���������� �����: " + Chr(10) + FileInfo\FileName)
          PureZIP_Archive_Close()
          ProcedureReturn 0
        EndIf
      EndIf
    Wend
    
    PureZIP_Archive_Close()
    
    If ReturnValue = #UNZ_END_OF_LIST_OF_FILE
      ProcedureReturn 1
    EndIf
  Else
    SetCurrentError("������ ��� ������� � ������")
    ProcedureReturn 0
  EndIf
EndProcedure

;}

;{ �������� �������
; ������������ ������: http://purebasic.info/phpBB2/viewtopic.php?t=892
Interface _IPersistFile 
   QueryInterface(a, b) : AddRef() : Release() : GetClassID(a) : IsDirty() 
   Load(a, b) : Save(a.p-unicode, b) : SaveCompleted(a) : GetCurFile(a) 
 EndInterface 
 Interface _IShellLinkW 
   QueryInterface(a, b) : AddRef() : Release() : GetPath(a.p-unicode, b, c, d) 
   GetIDList(a) : SetIDList(a) : GetDescription(a.p-unicode, b) : SetDescription(a.p-unicode) 
   GetWorkingDirectory(a.p-unicode, b) : SetWorkingDirectory(a.p-unicode) : GetArguments(a.p-unicode, b) 
   SetArguments(a.p-unicode) : GetHotkey(a) : SetHotkey(a) : GetShowCmd(a) : SetShowCmd(a) 
   GetIconLocation(a.p-unicode, b, c) : SetIconLocation(a.p-unicode, b) : SetRelativePath(a, b) 
   Resolve(a, b) : SetPath(a.p-unicode) 
 EndInterface 
 
 Procedure CreateShortcut_all(Path.s, LINK.s, Argument.s, DESCRIPTION.s, WorkingDirectory.s, ShowCommand.l, IconFile.s, IconIndexInFile.l) 
   CoInitialize_(0) 
   If CoCreateInstance_(?CLSID_ShellLink,0,1,?IID_IShellLinkW,@psl._IShellLinkW) = 0 
     Set_ShellLink_preferences: 
     psl\SetPath(Path) : psl\SetArguments(Argument) : psl\SetWorkingDirectory(WorkingDirectory) : psl\SetDescription(DESCRIPTION) 
     psl\SetShowCmd(ShowCommand) : psl\SetHotkey(HotKey) : psl\SetIconLocation(IconFile, IconIndexInFile) 
     ShellLink_SAVE: 
     If psl\QueryInterface(?IID_IPersistFile,@ppf._IPersistFile) = 0 
       hres = ppf\Save(LINK,#True) : Result = 1 : ppf\Release() 
     EndIf : psl\Release() : EndIf : CoUninitialize_() : ProcedureReturn Result 
   DataSection 
   CLSID_ShellLink: 
   Data.l $00021401 : Data.w $0000,$0000 : Data.b $C0,$00,$00,$00,$00,$00,$00,$46 
   IID_IShellLink: 
   Data.l $000214EE : Data.w $0000,$0000 : Data.b $C0,$00,$00,$00,$00,$00,$00,$46 
   IID_IPersistFile: 
   Data.l $0000010B : Data.w $0000,$0000 : Data.b $C0,$00,$00,$00,$00,$00,$00,$46 
   IID_IShellLinkW: 
     Data.l $000214F9 : Data.w $0000, $0000 : Data.b $C0, $00, $00, $00, $00, $00, $00, $46 
   EndDataSection 
 EndProcedure 
;}

;- ��������� ��� ����������� ������������ ��������� ���������
Procedure$ GetSysFolder(Value)
Protected *Item.ITEMIDLIST = #Null
Protected$ St = Space(#MAX_PATH)
 If SHGetSpecialFolderLocation_(0, Value, @*Item) = #NOERROR
  If SHGetPathFromIDList_(*Item, @St)
   If Right(St, 1) <> "\" : St +"\" : EndIf
   ProcedureReturn St
  EndIf
 EndIf
EndProcedure

; ����� 1, ���� ����� folder.s ��������� ��� ��������, ����� 0
Procedure CheckFolder(folder.s)
  Select folder.s
    Case ".", "..", "fido" 
      ProcedureReturn 0 
  EndSelect
  
  If Not FindString(DirectoryEntryName(0), "backup", 0, #PB_String_NoCase)
    ProcedureReturn 1
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

; ���������������� ��������� ��� RunAutoSetting()
Procedure.s OemToChar(String.s)
  ; http://www.cyberforum.ru/pure-basic/thread1059118.html
  OemToChar_(@String, @String)
  ProcedureReturn String
EndProcedure

; ��������� ���������� ���������� � ���� � �� ��� ���������� ���������� ����� �� ����.
Procedure RunAutoSetting(null)
  name.s = GetPath() + "Kubik_SSetting.exe"
  parameter.s = "-a " + GetFilePart(GetBackupFolder())
  work_dir.s = GetPath()
  program_id = RunProgram(name.s, parameter.s, work_dir.s, #PB_Program_Open | #PB_Program_Hide | #PB_Program_Read | #PB_Program_Error)
  output.s = ""
  
  If program_id  
    While ProgramRunning(program_id)
      temp_string.s = ReadProgramError(program_id)
      If temp_string.s <> ""
        ;Debug "���� ������: " + OemToChar(temp_string.s)
        Msg(OemToChar(temp_string.s))
      EndIf

      temp_string.s = ReadProgramString(program_id)
      If temp_string.s <> ""
        ;Debug "���� ������: " + OemToChar(temp_string.s)
        Msg(OemToChar(temp_string.s))
      EndIf
    Wend
  
    Select ProgramExitCode(program_id)
      Case 0
        IsOpenFinalWindow = 1
      Default
        Error("Kubik SSetting ���������� � �������")
    EndSelect
  Else
    Error("�� ������� ��������� Kubik SSetting")
  EndIf
EndProcedure

; ������ ExtractArchive() � ��������� ������
; ���� RunAutoSetting = 1, ����� ���������� ����� ������� Kubik SSetting
Procedure RunExtractArchiveForThread(RunAutoSetting)
  path.s = GetPath()
  
  If #Test_ManualUnpacking = 1
    MessageRequester("���������", "�������� ����� ����� ��������� � " + path.s + " ��� ����������� ������������")
    CreateThread(@RunAutoSetting(), #PB_Ignore)
  Else
    If ExtractArchive(path.s)
      If RunAutoSetting = 1
        ; ��������� Kubik_Setting.exe � ������ --auto-install � ������� ��� ����������
        ; ���� Kubik_Setting �������� ���� ������ �������, ���������� �� �������� ���������� ����������
        CreateThread(@RunAutoSetting(), #PB_Ignore)
      Else
        IsOpenFinalWindow = 1
      EndIf
    Else
      Msg(GetCurrentError())
      IsOpenErrorWindow = 1
    EndIf
  EndIf
EndProcedure

; ������ ���������� �����-���������
Procedure RunUpdate()
  
  ; ���� ���������
  install_folder.s = GetPath()
  
  ; ��������� ���� ����������� ���������
  Open_Window_Prog()
  Msg("�������! :D")
  
  ; ������� �����, � ������� ����� ���������� ����� ���������� ������ �����-���������
  backup_folder.s = install_folder.s + "backup-" + FormatDate("%yyyy-%mm-%dd", Date())
  temp_backup_folder.s = backup_folder.s
  count.l = 0
  While(FileSize(temp_backup_folder.s) <> -1)
    count + 1
    temp_backup_folder.s = backup_folder.s + "_" + Str(count)
  Wend
  backup_folder.s = temp_backup_folder.s
  If CreateDirectory(backup_folder.s)
    SetBackupFolder(backup_folder.s)
    Msg("������� ���������� '" + backup_folder.s + "' ��� ��������� ����� ���������� ������ �����-���������")
    
    ; ��������� ����� ������ ������ �����-��������� � ����� backup-*/, ����� fido
    If ExamineDirectory(0, install_folder.s, "*.*")  
      While NextDirectoryEntry(0)
        If CheckFolder(DirectoryEntryName(0))
          If Not RenameFile(install_folder.s + "\" + DirectoryEntryName(0), backup_folder.s + "\" + DirectoryEntryName(0))
            Error("������ ��� �������� " + DirectoryEntryName(0))
            Break
          EndIf
        EndIf
      Wend
      FinishDirectory(0)
      Msg("������ ������ �����-��������� ���������� � ���������� " + backup_folder.s)
    EndIf
    
    ; ������������� ����� ������ �����-��������� � ��������� Kubik SSetting -a backup_*/
    CreateThread(@RunExtractArchiveForThread(), 1)
  Else
    Error("�� ������� ������� ���������� '" + backup_folder.s + "'")
  EndIf
  
EndProcedure

; ������ ��������� �����-���������
Procedure RunInstall()
  path.s = GetPath()
  Open_Window_Prog()
  
  ; ���� ����� �� ���������� - ������ �
  If FileSize(path.s) <> -2
    If Not CreateDirectory(path.s)
      Error("������ ������������ ���� ��������� (" + path.s + ")")
      ProcedureReturn
    EndIf
  EndIf
  
  CreateThread(@RunExtractArchiveForThread(), 0)
EndProcedure

; ���������� ����������� �������� (� ������ ������� ���������) � ����� �� ���������
Procedure Exit()
  If SuccessfulInstall = 1
    path.s = GetPath()
    path_kubik_start.s = path.s + "\Kubik_Start.exe"
    comment.s = "����� �������? ��� ����!"
    
    If GetGadgetState(#CheckBox_Desktop)
      desktop.s = GetSysFolder(0)
      CreateShortcut_all(path_kubik_start.s, desktop.s + "Kubik.lnk", "", comment.s, path.s, #SW_SHOWNORMAL, "", 0)
    EndIf
    
    If GetGadgetState(#CheckBox_Menu_Start)
      menu.s = GetSysFolder(2)
      CreateShortcut_all(path_kubik_start.s, menu.s + "Kubik.lnk", "", comment.s, path.s, #SW_SHOWNORMAL, "", 0)
    EndIf
  
    If GetGadgetState(#CheckBox_Run_KStart)
      RunProgram(path_kubik_start.s, "", path.s)
    EndIf
  
    If GetGadgetState(#CheckBox_Web_Site)
      RunProgram("http://kubik-fido.blogspot.com/")
    EndIf
    
    End
  Else
    title.s = "����� �� ��������� ��������� Kubik"
    text.s = "��������� �� ���������. ���� �� �������, ��������� �� ����� �����������. "
    text.s + "�� ������������� ������ �������� ��������� Kubik?"
    
    If MessageRequester(title.s, text.s, #PB_MessageRequester_YesNo | #MB_ICONQUESTION) = #PB_MessageRequester_Yes
      End
    EndIf
  EndIf
EndProcedure

Open_Window_Start()
SetPath("C:\Kubik3\")

Repeat
  Event = WaitWindowEvent(100)
  GadgetID = EventGadget()
  
  If IsOpenFinalWindow = 1
    IsOpenFinalWindow = 0
    SuccessfulInstall = 1
    Open_Window_Final()
  EndIf
  
  If IsOpenErrorWindow = 1
    IsOpenErrorWindow = 0
    Error(GetCurrentError())
  EndIf

  Select Event
    Case #PB_Event_Gadget
      Select GadgetID
        ; �������� ���� ��������� (...)
        Case #Button_Path
          temp_path.s = PathRequester("�������� ���� ���������:", GetPath())
          If temp_path.s <> ""
            SetPath(temp_path.s)
          EndIf
        ; ��������
        Case #Button_Update
          RunUpdate()
        ; ����������
        Case #Button_Install
          RunInstall()
        ; �����
        Case #Button_Exit
          Exit()
      EndSelect
    Case #PB_Event_CloseWindow
      Exit()
  EndSelect
ForEver
; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 5
; Folding = BAAAC5
; EnableXP
; UseIcon = ..\icons\128x128\rubik.ico
; Executable = SFX.exe
; IncludeVersionInfo
; VersionField0 = 3,0,92,6
; VersionField1 = 3,0,92,6
; VersionField2 = Molotki Developed
; VersionField3 = Kubik Modern
; VersionField4 = 3.0
; VersionField5 = 3.0
; VersionField6 = IP Р С—Р С•Р С‘Р Р…РЎвЂљ-Р С”Р С•Р СР С—Р В»Р ВµР С”РЎвЂљ Р Т‘Р В»РЎРЏ РЎР‚Р В°Р В±Р С•РЎвЂљРЎвЂ№ Р Р† РЎРѓР ВµРЎвЂљР С‘ Р В¤Р С‘Р Т‘Р С•.
; VersionField7 = Kubik
; VersionField8 = Kubik_Modern_3.0.92.6RC.exe
; VersionField9 = (C) Kubik Project 2010-2013
; VersionField14 = http://kubik-fido.blogspot.com/
; VersionField17 = 0419 Russian
; VersionField18 = Fido:
; VersionField21 = 2:5020/2140.140