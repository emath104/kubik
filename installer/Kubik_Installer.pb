; Kubik Installer
; Версия 2
; (С) 2012-2017 ragweed
; PureBasic 5.11 + PureZIP

;{ Константы и глобальные переменные

#Kubik_Version = "3.1"
#AP$ = Chr(34)

; Если равно 1 - вместо попытки распаковать архив будет предложено пользователю самому перетащить нужные файлы
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

; Здесь хранится путь, куда будет установлен поинт-комплект
Global PathForInstall.s

; Расположение бекапа со старой версией поинт-комплекта
Global BackupFolder.s

; Равно 1, если установка была успешна завершена и можно открыть Open_Window_Final(), иначе 0
Global IsOpenFinalWindow = 0

; Равно 1, если установка провалилась и нужно открыть Open_Window_Error(), иначе 0
Global IsOpenErrorWindow = 0

; Здесь запоминается причина неудачного завершения установки
Global CurrentError.s

; Равно 1 в случае успешного завершения установки
Global SuccessfulInstall = 0
  
;}

;{ Добавляем изображения
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

; Вернёт в виде строки версию устанавливаемого поинт-комплекта Kubik
Procedure.s GetInstallVersion()
  ProcedureReturn #Kubik_Version
EndProcedure

; Возращает расположение бекапа со старой версией поинт-комплекта (необх. для организ. обновления)
Procedure.s GetBackupFolder()
  ProcedureReturn BackupFolder.s
EndProcedure

; Устанавливает расположение бекапа со старой версией поинт-комплекта (необх. для организ. обновления)
Procedure SetBackupFolder(backup_folder.s)
  BackupFolder.s = backup_folder.s
EndProcedure

; Устанавливает путь, по которому будет распакован поинт-комплект
; Если по данному пути будет обнаружена '3.0.92' версия Kubik - переключится из режима 
; установки в режим обновления
Procedure SetPath(path.s)
  PathForInstall.s = path.s
  ; Проверяем, есть ли по данному пути старая версия поинт-комплекта
  If FileSize(path.s) = -2
    ; Пытаемся открыть конфиг, чтобы узнать версию поинт-комплекта
    If OpenPreferences(path.s + "Kubik_Set.ini")
      PreferenceGroup("Version")
      Select ReadPreferenceLong("Sys", -1)
        ; Версия '3.0.92'
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

; Вернёт текущий путь установки поинт-комплекта, заданный SetPath()
Procedure.s GetPath()
  ProcedureReturn PathForInstall.s
EndProcedure

;}

;{ UI и взаимодействие с ним

Procedure Open_Window_Start()
  If OpenWindow(#Window, 0, 0, 400, 350, "Установка Kubik " + GetInstallVersion(),  #PB_Window_SystemMenu | #PB_Window_TitleBar | #PB_Window_ScreenCentered)
    SetWindowColor(#Window, RGB(255, 255, 255))
    ImageGadget(#Image_Logo, 70, 75, 270, 81, Image0)
    TextGadget(#Text_Info_1, 0, 170, WindowWidth(#Window), 20, "Kubik будет установлен в:", #PB_Text_Center)
      SetGadgetFont(#Text_Info_1, LoadFont(0, "Arial", 10))
      SetGadgetColor(#Text_Info_1, #PB_Gadget_BackColor, RGB(255, 255, 255))
    TextGadget(#Text_Info_2, 70, 190, 270, 20, "", #PB_Text_Center)
      SetGadgetFont(#Text_Info_2, LoadFont(1, "Arial", 10))
      SetGadgetColor(#Text_Info_2, #PB_Gadget_BackColor, RGB(255, 255, 255))
      
    If ButtonGadget(#Button_Install, 110, 215, 190, 50, "Установить")
      SetGadgetFont(#Button_Install, LoadFont(3, "Arial", 16))
      HideGadget(#Button_Install, 1)
    EndIf
    
    If ButtonGadget(#Button_Update, 110, 215, 190, 50, "Обновить")
      SetGadgetFont(#Button_Update, LoadFont(4, "Arial", 16))
      HideGadget(#Button_Update, 1)
    EndIf
    
    ButtonGadget(#Button_Path, 140, 270, 130, 35, "Изменить...")
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
  TextGadget(#Text_ExtractFiles, 110, 230, 180, 25, "Установка завершена!", #PB_Text_Center)
    SetGadgetFont(#Text_ExtractFiles, LoadFont(7, "Arial", 12))
  ButtonGadget(#Button_Exit, 250, 285, 130, 35, "Выход", #PB_Button_Default)
    SetGadgetFont(#Button_Exit, LoadFont(3, "Arial", 13))
  CheckBoxGadget(#CheckBox_Desktop, 25, 260, 195, 20, "Создать ярлык на рабочем столе")
    SetGadgetState(#CheckBox_Desktop, 1) 
  CheckBoxGadget(#CheckBox_Menu_Start, 25, 280, 185, 15, "Создать ярлык в меню "+#AP$+"Пуск"+#AP$+"")
    SetGadgetState(#CheckBox_Menu_Start, 1) 
  CheckBoxGadget(#CheckBox_Run_KStart, 25, 300, 185, 15, "Запустить Kubik Start")
    SetGadgetState(#CheckBox_Run_KStart, 1)
  CheckBoxGadget(#CheckBox_Web_Site, 25, 320, 185, 15, "Посетить сайт проекта")
    SetGadgetState(#CheckBox_Web_Site, 1)  
  Frame3DGadget(#fTop ,225, 260, 1, 80, "")
EndProcedure

Procedure Open_Window_Error()
  If IsGadget(#Image_Progress) : FreeGadget(#Image_Progress) : EndIf
  If IsGadget(#ProgressBar_Progress) : FreeGadget(#ProgressBar_Progress) : EndIf
  SetWindowColor(#Window, -1)
  TextGadget(#Text_1, 110, 230, 180, 25, "Установка прервана!", #PB_Text_Center)
  SetGadgetFont(#Text_1, LoadFont(7, "Arial", 12))
  TextGadget(#Text_Error, 20, 170, 360, 100, "", #PB_Text_Center)
  HideGadget(#Text_Error, 1)
  Frame3DGadget(#fTex, 10, 155, 250, 120, "Причина:")
  HideGadget(#fTex, 1)
  ButtonGadget(#Button_Exit, 250, 285, 130, 35, "Выход", #PB_Button_Default)
    SetGadgetFont(#Button_Exit, LoadFont(3, "Arial", 13))
EndProcedure

; Вывод сообщения в окне прогресса (Open_Window_Prog())
Procedure Msg(text.s)
  text.s = FormatDate("[%hh:%ii:%ss] ", Date()) + text.s
  AddGadgetItem(#Editor_InstallLog, -1, text.s)
EndProcedure

; Сохраняет причину неудачного завершения установки
Procedure SetCurrentError(message.s)
  CurrentError.s = message.s
EndProcedure

; Возвращает причину неудачного завершения установки
Procedure.s GetCurrentError()
  ProcedureReturn CurrentError.s
EndProcedure

; Переключает инсталятор в режим обычной установки
Procedure SetInstallMode(path.s)
  HideGadget(#Button_Install, 0)
  DisableGadget(#Button_Install, 0)
  HideGadget(#Button_Update, 1)
  SetGadgetText(#Text_Info_1, "Kubik будет установлен в:")
  SetGadgetText(#Text_Info_2, path.s)
EndProcedure

; Переключает инсталятор в режим обновления поинт-комплекта
Procedure SetUpdateMode(path.s, version.s)
  HideGadget(#Button_Install, 1)
  HideGadget(#Button_Update, 0)
  SetGadgetText(#Text_Info_1, "В '" + path.s + "' был обнаружен Kubik версии " + version.s + ".")
  SetGadgetText(#Text_Info_2, "Обновить его до версии " + GetInstallVersion() + "?")
EndProcedure

; Режим SetInstallMode(), но установка заблокирована
; Активируется при выборе в качестве пути установки уже установленный поинт-комплект последней версии
Procedure SetLockInstallMode(path.s)
  SetInstallMode(path.s)
  DisableGadget(#Button_Install, 1)
  SetGadgetText(#Text_Info_1, "По выбранному пути обнаружена последняя версия Kubik:")
EndProcedure

Procedure Error(comment.s)
  Open_Window_Error()
  Msg(comment.s)
  SetGadgetText(#Text_Error, comment)
EndProcedure

;}

;{ SFX
Global DoneFiles, ProgName.s=ProgramFilename()

; Отображение в окне общего прогресса распаковки файлов
Procedure PureSFXCallback(File.s, PerCent)
  Result=0
  ProgressText$ = File
  Msg(ProgressText$)
  SetGadgetState(#ProgressBar_Progress, DoneFiles*100/PerCent)
  DoneFiles+1
  ProcedureReturn Result
EndProcedure

; Распаковка архива в папку ExtractPath.s
; Возращает 1 в случае удачи, иначе 0
Procedure ExtractArchive(ExtractPath.s)
  GlobalInfo.unz_global_info
  FileInfo.PureZIP_FileInfo
  PureZIP_SetArchivePassword("")
  CountFiles=PureZIP_GetFileCount(ProgName) ; Число файлов в архиве
  
  For i=0 To CountFiles-1 ; Выясняем запараролен ли архив
    If PureZIP_GetFileInfo(ProgName,i,@FileInfo) = #True 
      If FileInfo\flag & 1 = 1
        Pass.s=InputRequester(GetFilePart(ProgName)+" - Архив защищён паролем!", "Введите пароль архива","")
        PureZIP_SetArchivePassword(Pass)
        Break
      EndIf
    EndIf
  Next i
  
  ; Открываем архив (исполняемый файл распаковщика)
  If PureZIP_Archive_Read(ProgName)
    DoneFiles=1
    PureZIP_Archive_GlobalInfo(@GlobalInfo) 
    NrOfCompressed.l = GlobalInfo\number_entry
    ReturnValue.l = PureZIP_Archive_FindFirst()
    While ReturnValue = #UNZ_OK
      ; Данные о файле (размер, дата, степень сжатия, CRC и т. д.)
      If PureZIP_Archive_FileInfo(@FileInfo) = #UNZ_OK
        
        ; Распаковываем файлы
        If PureZIP_Archive_Extract(ExtractPath, #True) = #UNZ_OK 
          
          ; Распаковка прервана пользователем
          If PureSFXCallback(FileInfo\FileName, NrOfCompressed) = 1
            Break 
          EndIf
          
          ; Подготовка к распаковке следующего файла
          ReturnValue = PureZIP_Archive_FindNext()
        Else
          SetCurrentError("Произошла ошибка при распаковке файла: " + Chr(10) + FileInfo\FileName)
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
    SetCurrentError("Ошибка при доступе к архиву")
    ProcedureReturn 0
  EndIf
EndProcedure

;}

;{ Создание ярлыков
; Скопированно отсюда: http://purebasic.info/phpBB2/viewtopic.php?t=892
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

;- ПРОЦЕДУРА ДЛЯ ОПРЕДЕЛЕНИЯ РАСПОЛОЖЕНИЯ СИСТЕМНЫХ КАТАЛОГОВ
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

; Вернёт 1, если папка folder.s разрешена для переноса, иначе 0
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

; Вспомогалтельная процедура для RunAutoSetting()
Procedure.s OemToChar(String.s)
  ; http://www.cyberforum.ru/pure-basic/thread1059118.html
  OemToChar_(@String, @String)
  ProcedureReturn String
EndProcedure

; Запускает консольное приложение в фоне и по его завершению возвращает вывод из него.
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
        ;Debug "Тест вывода: " + OemToChar(temp_string.s)
        Msg(OemToChar(temp_string.s))
      EndIf

      temp_string.s = ReadProgramString(program_id)
      If temp_string.s <> ""
        ;Debug "Тест вывода: " + OemToChar(temp_string.s)
        Msg(OemToChar(temp_string.s))
      EndIf
    Wend
  
    Select ProgramExitCode(program_id)
      Case 0
        IsOpenFinalWindow = 1
      Default
        Error("Kubik SSetting завершился с ошибкой")
    EndSelect
  Else
    Error("Не удалось запустить Kubik SSetting")
  EndIf
EndProcedure

; Запуск ExtractArchive() в отдельном потоке
; Если RunAutoSetting = 1, после распаковки будет запущен Kubik SSetting
Procedure RunExtractArchiveForThread(RunAutoSetting)
  path.s = GetPath()
  
  If #Test_ManualUnpacking = 1
    MessageRequester("Сообщение", "Перенеси файлы поинт комплекта в " + path.s + " для продолжения тестирования")
    CreateThread(@RunAutoSetting(), #PB_Ignore)
  Else
    If ExtractArchive(path.s)
      If RunAutoSetting = 1
        ; Запускаем Kubik_Setting.exe с ключём --auto-install и ожидаем его завершения
        ; Если Kubik_Setting завершил свою работу успешно, уведомляем об успешном завершении обновления
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

; Запуск обновления поинт-комплекта
Procedure RunUpdate()
  
  ; Путь установки
  install_folder.s = GetPath()
  
  ; Открываем окно отображения прогресса
  Open_Window_Prog()
  Msg("Поехали! :D")
  
  ; Создаем папку, в которую будут перенесены файлы предыдущей версии поинт-комплекта
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
    Msg("Создана директория '" + backup_folder.s + "' для резервной копии предыдущей версии поинт-комплекта")
    
    ; Переносим папки старой версии поинт-комплекта в папку backup-*/, кроме fido
    If ExamineDirectory(0, install_folder.s, "*.*")  
      While NextDirectoryEntry(0)
        If CheckFolder(DirectoryEntryName(0))
          If Not RenameFile(install_folder.s + "\" + DirectoryEntryName(0), backup_folder.s + "\" + DirectoryEntryName(0))
            Error("Ошибка при переносе " + DirectoryEntryName(0))
            Break
          EndIf
        EndIf
      Wend
      FinishDirectory(0)
      Msg("Старая версия поинт-комплекта перенесена в директорию " + backup_folder.s)
    EndIf
    
    ; Распаковываем новую версию поинт-комплекта и запускаем Kubik SSetting -a backup_*/
    CreateThread(@RunExtractArchiveForThread(), 1)
  Else
    Error("Не удалось создать директорию '" + backup_folder.s + "'")
  EndIf
  
EndProcedure

; Запуск установки поинт-комплекта
Procedure RunInstall()
  path.s = GetPath()
  Open_Window_Prog()
  
  ; Если папки не существует - создаём её
  If FileSize(path.s) <> -2
    If Not CreateDirectory(path.s)
      Error("Указан некорректный путь установки (" + path.s + ")")
      ProcedureReturn
    EndIf
  EndIf
  
  CreateThread(@RunExtractArchiveForThread(), 0)
EndProcedure

; Выполнение завершающих действий (в случае удачной установки) и выход из программы
Procedure Exit()
  If SuccessfulInstall = 1
    path.s = GetPath()
    path_kubik_start.s = path.s + "\Kubik_Start.exe"
    comment.s = "Нужен Фидонет? Жми сюда!"
    
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
    title.s = "Выход из программы установки Kubik"
    text.s = "Установка не завершена. Если Вы выйдете, программа не будет установлена. "
    text.s + "Вы действительно хотите прервать установку Kubik?"
    
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
        ; Изменить путь установки (...)
        Case #Button_Path
          temp_path.s = PathRequester("Выберите путь установки:", GetPath())
          If temp_path.s <> ""
            SetPath(temp_path.s)
          EndIf
        ; Обновить
        Case #Button_Update
          RunUpdate()
        ; Установить
        Case #Button_Install
          RunInstall()
        ; Выход
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
; VersionField6 = IP Р В РЎвЂ”Р В РЎвЂўР В РЎвЂР В Р вЂ¦Р РЋРІР‚С™-Р В РЎвЂќР В РЎвЂўР В РЎВР В РЎвЂ”Р В Р’В»Р В Р’ВµР В РЎвЂќР РЋРІР‚С™ Р В РўвЂР В Р’В»Р РЋР РЏ Р РЋР вЂљР В Р’В°Р В Р’В±Р В РЎвЂўР РЋРІР‚С™Р РЋРІР‚в„– Р В Р вЂ  Р РЋР С“Р В Р’ВµР РЋРІР‚С™Р В РЎвЂ Р В Р’В¤Р В РЎвЂР В РўвЂР В РЎвЂў.
; VersionField7 = Kubik
; VersionField8 = Kubik_Modern_3.0.92.6RC.exe
; VersionField9 = (C) Kubik Project 2010-2013
; VersionField14 = http://kubik-fido.blogspot.com/
; VersionField17 = 0419 Russian
; VersionField18 = Fido:
; VersionField21 = 2:5020/2140.140