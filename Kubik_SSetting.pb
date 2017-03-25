; Kubik SSetting. Автоматизация процесса настройки конф. файлов входящих в поинт-комплект Kubik приложений.
; Версия 4
; (С) 2012-2017 ragweed
; PureBasic 5.31

;{ Константы и глобальные переменные

#Kubik_Version = "3.1"
#Kubik_SystemID = 3

Enumeration
  #Window
  #Frame3D
  #String_Info
  #String_YourFullName
  #String_UplinkName
  #String_UplinkFTNAddress
  #String_YourPointNomber
  #String_YourStationName
  #String_YourLocation
  #String_UplinkServerName
  #String_Password
  #Text_Info
  #Text_YourFullName
  #Text_UplinkName
  #Text_UplinkFTNAddress
  #Text_YourPointNomber
  #Text_YourStationName
  #Text_YourLocation
  #Text_UplinkServerName
  #Text_Password
  #Button_Save
  #Button_Help
  #Button_Cancel
EndEnumeration

Enumeration
  #Info
  #Error
EndEnumeration

; Смотри описание для параметров "-a", "--auto-setting".
Global AutoSet = 0
Global BackupFolder.s

;}

;{ Работа с конфигом

Structure Version
  Sys.a
  Ver.s
EndStructure

Structure Start
  AutoSetting.a
  RunInTray.a
  Params.a
EndStructure

Structure Path
  Editor.s
  Send.s
  HideSend.s
  FTN_Set.s
  
  KubikFolder.s
  AltFidoPath.a
  FidoFolder.s
EndStructure

Structure Send
  NotifyMsgsSentOnlyMe.a
  CropLog.a
  NewMsgInfoTosLog.s
  NewMsgInfoRegexp.s
  AutoSendTimer.l
EndStructure

Structure Window
  X.i
  Y.i
  HideInTray.a
  CloseInTray.a
  WinName.s
EndStructure

Structure Other
  Site.s
  Help.s
EndStructure

Structure FTN
  FullName.s
  UplinkName.s
  PointAddress.s
  Location.s
  StationName.s
  FTNAddress.s
  ServerName.s
  Password.s  
EndStructure

Structure Config
  Version.Version
  Start.Start
  Path.Path
  Send.Send
  Window.Window
  Other.Other
  FTN.FTN
EndStructure

Global Config.Config

;{ Для сообщений, которые могут выводится в консоли в случае запуска с ключом --auto-setting

; Конвертирует строку из кодировки Win1251 в OEM
Procedure.s CharToOem(String.s)
  ; http://www.cyberforum.ru/pure-basic/thread1059118.html
  CharToOem_(@String, @String)
  ProcedureReturn String
EndProcedure

; Если приложение открыто в обычном режиме, то отображает сообщения посредством MessageRequester()
; Если запущено с ключом --auto-setting(режим автоматической настройки для инсталятора), то через консоль
Procedure Msg(message.s, type=#Info)
  If type = #Info
    Debug message.s
    If AutoSet = 1
      PrintN(CharToOem(message.s))
    Else
      MessageRequester("Сообщение", message.s)
    EndIf
  ElseIf type = #Error
    Debug "Ошибка: " + message.s
    If AutoSet = 1
      ConsoleError(CharToOem("Ошибка: " + message.s))
    Else
      MessageRequester("Ошибка", message.s, #MB_ICONERROR)
    EndIf
  EndIf
EndProcedure

;}

; Создание системы каталогов для будущий почтовой базы сообщений
; path.s - где будет созданна данная директория
Procedure CreateFidoFolder(path.s)
  fido_path.s = path.s + "\fido"
  ; Если папки с почтовыми базами не существует
  If FileSize(fido_path.s) <> -2
    If CreateDirectory(fido_path.s)
      CreateDirectory(fido_path.s + "\2uplink")
      CreateDirectory(fido_path.s + "\announce")
      CreateDirectory(fido_path.s + "\badarea")
      CreateDirectory(fido_path.s + "\carbonarea")
      CreateDirectory(fido_path.s + "\dupearea")
      CreateDirectory(fido_path.s + "\fghigetdir")
      CreateDirectory(fido_path.s + "\filebox")
      CreateDirectory(fido_path.s + "\flags")
      CreateDirectory(fido_path.s + "\inbound")
      CreateDirectory(fido_path.s + "\localinb")
      CreateDirectory(fido_path.s + "\magic")
      CreateDirectory(fido_path.s + "\msgbasedir")
      CreateDirectory(fido_path.s + "\netmailarea")
      CreateDirectory(fido_path.s + "\nodelist")
      CreateDirectory(fido_path.s + "\outbound")
      CreateDirectory(fido_path.s + "\outfile")
      CreateDirectory(fido_path.s + "\protinb")
      CreateDirectory(fido_path.s + "\public")
      CreateDirectory(fido_path.s + "\tempinb")
      CreateDirectory(fido_path.s + "\tempoutb")
      CreateDirectory(fido_path.s + "\uudecode")
      
      If CreateFile(0, fido_path.s + "\binkd.log")
        CloseFile(0)
      EndIf
      
      If CreateFile(1, fido_path.s + "\golded.log")
        CloseFile(1)
      EndIf
      
      If CreateFile(2, fido_path.s + "\hpt.log")
        CloseFile(2)
      EndIf
      
      If CreateFile(3, fido_path.s + "\htick.log")
        CloseFile(3)
      EndIf
      
      If CreateFile(4, fido_path.s + "\import.log")
        CloseFile(4)
      EndIf
      
      If CreateFile(5, fido_path.s + "\sqpack.log")
        CloseFile(5)
      EndIf
    EndIf
  EndIf
EndProcedure

; Чтобы можно было создать конфиг из LoadConfig()
Declare SaveConfig(path.s)

; Преобразует длинное имя файла в короткое (8.3).
Procedure.s GetShortFileName(Long.s)
  ; Спасибо за процедуру ВиниПуру http://purebasic.mybb.ru/viewtopic.php?id=361
  Short.s = Long 
  GetShortPathName_(@Long, @Short, Len(Short)) 
  ProcedureReturn Short 
EndProcedure

; Загружает значение переменных из конфига path.s в структуру Config
; not_create_config = 1 - не создаёт конфиг в случае его осутствия (для AutoConfiguration())
; Вернёт 1, если конфиг был успешно открыт, если же его не было и переменные были заполнены
; значениями по-умолчанию, то 0.
Procedure LoadConfig(path.s, not_create_config = 0)
  If OpenPreferences(path.s)
    open = 1
  EndIf
  
  PreferenceGroup("Version")
  With Config\Version
    \Ver         = #Kubik_Version
    \Sys         = #Kubik_SystemID
  EndWith
  
  PreferenceGroup("Start")
  With Config\Start
    \AutoSetting = ReadPreferenceLong("Ssetting", 1)
    \RunInTray   = ReadPreferenceLong("RunInTray", 0)
    \Params      = ReadPreferenceLong("Params", 1)
  EndWith
  
  PreferenceGroup("Window")
  With Config\Window
    \CloseInTray = ReadPreferenceInteger("CloseInTray", 0)
    \HideInTray  = ReadPreferenceInteger("HideInTray", 0)
    \X = ReadPreferenceLong("X", 200)
    \Y = ReadPreferenceLong("Y", 200) 
  EndWith
  
  PreferenceGroup("Path")
  With Config\Path
    \Editor      = ReadPreferenceString("Editor", "GoldED+1.1.5\ge.bat")
    \Send        = ReadPreferenceString("Send", "Kubik_Send.exe")
    \HideSend    = ReadPreferenceString("HideSend", "Kubik_Send.exe")
    \FTN_Set     = ReadPreferenceString("FTN_Set", "Kubik_SSetting.exe")
    
    \KubikFolder = ReadPreferenceString("KubikFolder", GetCurrentDirectory())
    \AltFidoPath = ReadPreferenceLong("AltFidoPath", 0)
    \FidoFolder  = ReadPreferenceString("FidoFolder", GetCurrentDirectory() + "fido\")
  EndWith
  
  PreferenceGroup("Send")
  With Config\Send
    \NotifyMsgsSentOnlyMe = ReadPreferenceLong("NotifyMsgsSentOnlyMe", 1)
    \CropLog              = ReadPreferenceLong("CropLog", 1)
    \NewMsgInfoTosLog     = ReadPreferenceString("NewMsgInfoTosLog", "HTP toss link")
    \NewMsgInfoRegexp     = ReadPreferenceString("NewMsgInfoRegexp", "[\w|.]* - [\d]+ msgs")
    \AutoSendTimer        = ReadPreferenceLong("AutoSendTimer", 0)
  EndWith
  
  PreferenceGroup("Other")
  With Config\Other
    \Site = "http://kubik-fido.blogspot.com/"
    \Help = "https://bitbucket.org/ragweed/kubik/wiki/Home"
  EndWith
  
  PreferenceGroup("FTN")
  With Config\FTN
    \FullName     = ReadPreferenceString("FullName", "Vasily Pupkin")
    \UplinkName   = ReadPreferenceString("UplinkName", "Sergey Poziturin")
    \PointAddress = ReadPreferenceString("PointAddress", "777")
    \Location     = ReadPreferenceString("Location", "Moscow, Russia")
    \StationName  = ReadPreferenceString("StationName", "MyFidoStation")
    \FTNAddress   = ReadPreferenceString("FTNAddress", "2:5020/2141")
    \ServerName   = ReadPreferenceString("ServerName", "vp.propush.ru:24555")
    \Password     = ReadPreferenceString("Password", "12345678")
  EndWith
  
  If open = 1
    ClosePreferences()
    ProcedureReturn 1
  ElseIf not_create_config = 0
    SaveConfig(path.s)
  EndIf
  
  ProcedureReturn 0
EndProcedure

; Сохраняем текущие параметры в конфиг
; Вернёт 1 в случае успеха, иначе 0
Procedure SaveConfig(path.s)
  If OpenPreferences(path.s)
    open = 1
  Else
    If CreatePreferences(path.s)
      open = 1
    Else
      Msg("Не удалось создать конфигурационный файл Kubik_Set.ini, приложение будет закрыто.", #Error)
      End
    EndIf
  EndIf

  If open = 1
    PreferenceGroup("Version")
    With Config\Version
      WritePreferenceString("Ver",   \Ver)
      WritePreferenceInteger("Sys",  \Sys)
    EndWith
    
    PreferenceGroup("Start")
    With Config\Start
      WritePreferenceInteger("RunInTray", \RunInTray)
      WritePreferenceInteger("Ssetting",  \AutoSetting)
      WritePreferenceInteger("Params",    \Params)
    EndWith

    PreferenceGroup("Window")
    With Config\Window
      WritePreferenceInteger("CloseInTray",   \CloseInTray)
      WritePreferenceInteger("HideInTray",    \HideInTray)
      WritePreferenceInteger("X",             \X)
      WritePreferenceInteger("Y",             \Y)
    EndWith
    
    PreferenceGroup("Path")
    With Config\Path
      WritePreferenceString("Editor",   \Editor)
      WritePreferenceString("Send",     \Send)
      WritePreferenceString("HideSend", \HideSend)
      WritePreferenceString("FTN_Set",  \FTN_Set)
      
      WritePreferenceString("KubikFolder", \KubikFolder)
      WritePreferenceString("FidoFolder", \FidoFolder)
      WritePreferenceLong("AltFidoPath", \AltFidoPath)
    EndWith
    
    PreferenceGroup("Send")
    With Config\Send
      WritePreferenceLong("NotifyMsgsSentOnlyMe", \NotifyMsgsSentOnlyMe)
      WritePreferenceLong("CropLog",              \CropLog)
      WritePreferenceString("NewMsgInfoTosLog",   \NewMsgInfoTosLog)
      WritePreferenceString("NewMsgInfoRegexp",   \NewMsgInfoRegexp)
      WritePreferenceLong("AutoSendTimer",        \AutoSendTimer)
    EndWith
    
    PreferenceGroup("Other")
    With Config\Other
      WritePreferenceString("Site", \Site)
      WritePreferenceString("Help", \Help)
    EndWith
    
    PreferenceGroup("FTN")
    With Config\FTN
      WritePreferenceString("FullName",     \FullName)
      WritePreferenceString("UplinkName",   \UplinkName)
      WritePreferenceString("PointAddress", \PointAddress)
      WritePreferenceString("Location",     \Location)
      WritePreferenceString("StationName",  \StationName)
      WritePreferenceString("FTNAddress",   \FTNAddress)
      WritePreferenceString("ServerName",   \ServerName)
      WritePreferenceString("Password",     \Password)
    EndWith
    
    ClosePreferences()
    ProcedureReturn open
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

;}

; Отображает окно настройки
Procedure Open_Window()
  If OpenWindow(#Window, 235, 142, 400, 350, "Настройка поинт-комплекта",  #PB_Window_SystemMenu | #PB_Window_SizeGadget | #PB_Window_TitleBar | #PB_Window_ScreenCentered)
    FontID1 = LoadFont(1, "Arial", 10)
    
    With Config\FTN
      TextGadget(#Text_Info, 10, 20, 380, 30, "Перед настройкой поинт-комплекта обязательно ознакомьтесь со справочным материалом.", #PB_Text_Center) 
      Frame3DGadget(#Frame3D, 30, 45, 340, 255, "")
      
      TextGadget(#Text_YourFullName, 45, 60, 155, 20, "Ваше имя и фамилия:")
      SetGadgetFont(#Text_YourFullName, FontID1)
      StringGadget(#String_YourFullName, 215, 60, 145, 20, \FullName)
      
      TextGadget(#Text_UplinkName, 45, 90, 155, 20, "Имя и фамилия босса:")
      SetGadgetFont(#Text_UplinkName, FontID1)
      StringGadget(#String_UplinkName, 215, 90, 145, 20, \UplinkName)
      
      TextGadget(#Text_UplinkFTNAddress, 45, 120, 155, 20, "Адрес узла:")
      SetGadgetFont(#Text_UplinkFTNAddress, FontID1)
      StringGadget(#String_UplinkFTNAddress, 215, 120, 145, 20, \FTNAddress)
      
      TextGadget(#Text_YourPointNomber, 45, 150, 155, 20, "Ваш поинт-номер:")
      SetGadgetFont(#Text_YourPointNomber, FontID1)
      StringGadget(#String_YourPointNomber, 215, 150, 145, 20, \PointAddress)
      
      TextGadget(#Text_YourLocation, 45, 180, 165, 20, "Ваше месторасположение:")
      SetGadgetFont(#Text_YourLocation, FontID1)
      StringGadget(#String_YourLocation, 215, 180, 145, 20, \Location)
      
      TextGadget(#Text_YourStationName, 45, 210, 155, 20, "Название вашей станции:")
      SetGadgetFont(#Text_YourStationName, FontID1)
      StringGadget(#String_YourStationName, 215, 210, 145, 20, \StationName)
      
      TextGadget(#Text_UplinkServerName, 45, 240, 155, 20, "DNS адрес узла:")
      SetGadgetFont(#Text_UplinkServerName, FontID1)
      StringGadget(#String_UplinkServerName, 215, 240, 145, 20, \ServerName)
      
      TextGadget(#Text_Password, 45, 270, 155, 20, "Пароль:")
      SetGadgetFont(#Text_Password, FontID1)
      StringGadget(#String_Password, 215, 270, 145, 20, \Password, #PB_String_Password)
    EndWith
    
    ButtonGadget(#Button_Save, 30, 305, 130, 25, "Сохранить", #PB_Button_Default)
    ButtonGadget(#Button_Help, 170, 305, 95, 25, "Справка")
    ButtonGadget(#Button_Cancel, 275, 305, 95, 25, "Отмена")
  EndIf
EndProcedure

; Вспомогательная процедура для CreateConfigsFromTemplates()
; Создаёт из шаблона template.s конфигурационный файл path.s с внесением необходимых изменений
; Вернёт 1 в случае успеха, иначе 0
Procedure CreateConfigFromTemplate(template.s, path.s)
  If FileSize(GetPathPart(path.s)) <> -2
    If Not CreateDirectory(GetPathPart(path.s))
      Msg("Не удалось скопировать шаблон " + path.s + ", т.к. директории " + GetPathPart(path.s) + " не существует")
      Msg("Не удалось создать директорию " + GetPathPart(path.s) + " для " + GetFilePart(path.s), #Error)
      ProcedureReturn 0
    EndIf
  EndIf
  
  If CopyFile(template.s, path.s)
    text.s = ""
    If OpenFile(0, path.s)
      size = Lof(0)
      If size > 0
        text.s = Space(size)
        ReadData(0, @text, size)
        
        With Config\FTN
          text.s = ReplaceString(text.s, "%FULL_NAME%",          \FullName)
          text.s = ReplaceString(text.s, "%UPLINK_NAME%",        \UplinkName)
          text.s = ReplaceString(text.s, "%BOSS_FTN_ADDRESS%",   \FTNAddress)
          text.s = ReplaceString(text.s, "%POINT_FTN_ADDRESS%",  \FTNAddress + "." + \PointAddress)
          text.s = ReplaceString(text.s, "%LOCATION%",           \Location)
          text.s = ReplaceString(text.s, "%STATION_NAME%",       \StationName)
          text.s = ReplaceString(text.s, "%SERVER_NAME%",        \ServerName)
          text.s = ReplaceString(text.s, "%PASSWORD%",           \Password)
        EndWith
        
        With Config\Path
          KubikPath.s = GetCurrentDirectory()
          KubikShortPath.s = GetShortFileName(KubikPath.s)
          
          ; Определяем текущее расположение почтовых баз.
          If AltFidoPath = 0
            FidoShortPath.s = KubikShortPath + "fido\"
          Else
            FidoPath.s = \FidoFolder
            FidoShortPath.s = GetShortFileName(FidoPath.s)
          EndIf

          text.s = ReplaceString(text.s, "\KUBIK_PATH\",         KubikShortPath.s)
          text.s = ReplaceString(text.s, "\FIDO_PATH\",          FidoShortPath.s)
          text.s = ReplaceString(text.s, "\\BINKD_FIDO_PATH\\",  ReplaceString(FidoShortPath.s, "\", "\\"))
        EndWith

        FileSeek(0,0)
        TruncateFile(0)
        WriteString(0, text.s)
      EndIf
      CloseFile(0)
      ProcedureReturn 1
    Else
      Msg("Не удалось открыть файл " + path, #Error)
    EndIf
  Else
    Msg("Не удалось скопировать файл " + template, #Error)
  EndIf
  ProcedureReturn 0
EndProcedure

; Создание конфигурационных файлов для программ поинт-комплекта из шаблонов папки templates\
; Вернёт 1 в случае успешного создания всех конфигов, иначе 0
Procedure CreateConfigsFromTemplates()
  
  ; Эта переменная равна 0 в случае успешного завершения создания конфигов, иначе 1
  is_error = 0
  
  ; Открываем Config_List.ini, в котором содержится описание того - 
  ; куда нужно будет скопировать тот или иной шаблон
  If OpenPreferences("templates\Config_List.ini")
    
    ; Перебираем файлы папки templates\
    If ExamineDirectory(0, "templates\", "*.template")
      While NextDirectoryEntry(0)
        If DirectoryEntryType(0) = #PB_DirectoryEntry_File
          config_path.s = ReadPreferenceString(DirectoryEntryName(0), "")
          If config_path.s <> ""
            current_template.s = "templates\" + DirectoryEntryName(0)
            If Not CreateConfigFromTemplate(current_template.s, config_path.s)
              Msg("Ошибка при создании " + config_path.s + " из шаблона " + current_template.s, #Error)
              is_error = 1
              Break
            EndIf
          EndIf
        EndIf
      Wend
      
      FinishDirectory(0)
      
      If is_error = 0
        Config\Start\AutoSetting = 0
        ProcedureReturn 1
      Else
        Config\Start\AutoSetting = 1
        ProcedureReturn 0
      EndIf
    EndIf
  Else
    Msg("Отсутствует templates\Config_List.ini", #Error)
    ProcedureReturn 0
  EndIf
  
EndProcedure

; Сохраняет текущие настройки в Kubik_Set.ini, а также создаёт из шаблонов конфиги для программ 
; поинт-комплекта с необходимыми параметрами
Procedure SaveSetting()
  
  ; Считываем значения строк из полей в структуру Config
  With Config\FTN
    \FullName       = GetGadgetText(#String_YourFullName)
    \UplinkName     = GetGadgetText(#String_UplinkName)
    \FTNAddress     = GetGadgetText(#String_UplinkFTNAddress)
    \PointAddress   = GetGadgetText(#String_YourPointNomber)
    \StationName    = GetGadgetText(#String_YourStationName)
    \Location       = GetGadgetText(#String_YourLocation)
    \ServerName     = GetGadgetText(#String_UplinkServerName)
    \Password       = GetGadgetText(#String_Password)
  EndWith
  
  ; Создаю папку fido\
  CreateFidoFolder(GetCurrentDirectory())
  
  ; Создание конфигурационных файлов для программ поинт-комплекта
  If CreateConfigsFromTemplates()
    SaveConfig("Kubik_Set.ini")
    Msg("Настройка поинт-комплекта Kubik завершена")
    End
  Else
    Msg("Не удалось завершить настройку поинт-комплекта Kubik", #Error)
  EndIf
  
EndProcedure

; Автоматическая настройка поинт-комплекта, необходимая для механизма 
; обновления посредством инсталятора Kubik (см. описание для параметров "-a", "--auto-setting")
Procedure AutoConfiguration()
  ; Проверяем, существует ли директория BackupFolder.s
  If FileSize(BackupFolder.s) = -2
    ; Копирую необходимые параметры из BackupFolder.s + "\Kubik_Set.ini" в Kubik_Set.ini
    old_config.s = BackupFolder.s + "\Kubik_Set.ini"
    If LoadConfig(old_config.s, 1)
      Msg("Cтарый конфиг. файл '" + old_config.s + "' открыт и успешно считан")
      
      ; Сохраняю полученные изменения в Kubik_Set.ini
      If SaveConfig("Kubik_Set.ini")
        Msg("Новый конфиг. файл Kubik_Set.ini успешно создан")
        
        ; Считываю описание арий из BackupFolder.s + "\husky\husky.cfg
        ;- Ещё не реализованно
        
        ; Создаю из шаблонов конфигурационные файлы для программ комплекта
        If CreateConfigsFromTemplates()
          Msg("Настройка поинт-комплекта Kubik завершена")
        Else
          Msg("Не удалось завершить настройку поинт-комплекта", #Error)
          End 3
        EndIf
      Else
        Msg("Не удалось создать конфиг. файл Kubik_Set.ini", #Error)
        End 2
      EndIf
      
      ClosePreferences()
    Else
      Msg("Не найден конфиг. файл '" + old_config.s + "'", #Error)
      End 1
    EndIf
  Else
    Msg("Указаная в параметрах директория '" + BackupFolder.s + "' не существует", #Error)
  EndIf
EndProcedure

; Проверяем наличие параметров, переданных при запуске SSetting.
For i=0 To CountProgramParameters() - 1
  Select ProgramParameter()
    ; -a backup-folder\
    Case "-a", "--auto-setting"
      BackupFolder.s = ProgramParameter()    
      ; Этот параметр заставляет Kubik SSetting:
      ; * запуститься без gui.
      ; * скопировать необходимые параметры из BackupFolder.s + "\Kubik_Set.ini"
      ; * скопировать описание арий из BackupFolder.s + "\husky\husky.cfg
      ; * настроить поинт-комплект по полученным параметрам
      ; * подробное описание процесса в stdout, код выхода 0 в случае успеха, в остальных см. AutoConfiguration()
      AutoSet = 1
  EndSelect
Next

If AutoSet = 1
  OpenConsole()
  ConsoleTitle("Kubik SSetting")
  AutoConfiguration()
  End
Else
  LoadConfig("Kubik_Set.ini")
  Open_Window()
EndIf

Repeat
  Event = WaitWindowEvent()
  GadgetID = EventGadget()
  Select Event
    Case #PB_Event_Gadget
      Select GadgetID
        Case #Button_Save
          SaveSetting()
        Case #Button_Help
          RunProgram(Config\Other\Help, "", "")
        Case #Button_Cancel
          Break
      EndSelect
  EndSelect
Until Event = #PB_Event_CloseWindow
; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 450
; FirstLine = 168
; Folding = HQ0
; EnableXP
; UseIcon = icons\32x32\set.ico
; Executable = Kubik_SSetting.exe
; IncludeVersionInfo
; VersionField0 = 2,0,0,25
; VersionField1 = 2,0,0,25
; VersionField2 = Kubik Project
; VersionField3 = Kubik
; VersionField4 = 2
; VersionField5 = 2
; VersionField6 = Р С™Р С•Р СР С—Р С•Р Р…Р ВµР Р…РЎвЂљ Kubik Modern
; VersionField7 = Kubik
; VersionField8 = Kubik_SSetting.exe
; VersionField9 = (Р РЋ) 2013 Kubik Project
; VersionField13 = de.j.rabbit@gmail.com
; VersionField14 = http://kubik-fido.blogspot.com/
; VersionField17 = 0419 Russian
; VersionField18 = Fido:
; VersionField21 = 2:5020/2140.140