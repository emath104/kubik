; Общие процедуры и константы для утилит поинт-комплекта Kubik

#Kubik_Version = "3.1"
#Kubik_SystemID = 3

; Конвертирует строку из кодировки Win1251 в OEM
Procedure.s CharToOem(String.s)
  ; http://www.cyberforum.ru/pure-basic/thread1059118.html
  CharToOem_(@String, @String)
  ProcedureReturn String
EndProcedure

; Преобразует длинное имя файла в короткое (8.3).
Procedure.s GetShortFileName(Long.s)
  ; Спасибо за процедуру ВиниПуру http://purebasic.mybb.ru/viewtopic.php?id=361
  Short.s = Long 
  GetShortPathName_(@Long, @Short, Len(Short)) 
  ProcedureReturn Short 
EndProcedure

;{ Работа с конфигом Kubik_Set.ini

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
  TextColor.l
  AutoClose.a
  Pause.i
  CloseTime.i
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

; Чтобы можно было создать конфиг из LoadConfig()
Declare SaveConfig(path.s)

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
    \TextColor            = ReadPreferenceLong("textcolor", 7)
    \AutoClose            = ReadPreferenceLong("close", 0)
    \AutoClose            = ReadPreferenceLong("AutoClose", \AutoClose)
    \Pause                = ReadPreferenceLong("pause", 3000)
    \Pause                = ReadPreferenceLong("Pause", \Pause)
    \CloseTime            = ReadPreferenceLong("ctime", 5000)
    \CloseTime            = ReadPreferenceLong("CloseTime", \CloseTime)
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
Procedure SaveConfig(path.s)
  If OpenPreferences(path.s)
    open = 1
  Else
    If CreatePreferences(path.s)
      open = 1
      create = 1
    Else
      MessageRequester( "Ошибка", "Не удалось создать конфигурационный файл Kubik_Set.ini, приложение будет закрыто.", #MB_ICONERROR)
      End
    EndIf
  EndIf

  If open = 1
    PreferenceGroup("Start")
    WritePreferenceInteger("RunInTray", Config\Start\RunInTray)
    WritePreferenceInteger("Ssetting", Config\Start\AutoSetting)
    WritePreferenceInteger("Params", Config\Start\Params)
      
    PreferenceGroup("Window")
    WritePreferenceInteger("CloseInTray", Config\Window\CloseInTray)
    WritePreferenceInteger("HideInTray", Config\Window\HideInTray)
    WritePreferenceInteger("X", Config\Window\X)
    WritePreferenceInteger("Y", Config\Window\Y)

    PreferenceGroup("Send")
    If create = 1
      PreferenceComment("Раскомментируйте следующие 2 строки для работы с Parma Tosser:")
      PreferenceComment("NewMsgInfoRegexp = [\w|.]*: toss - [\d]+[ ]")
      PreferenceComment("CropLog = 0")
    EndIf
    WritePreferenceLong("NotifyMsgsSentOnlyMe", Config\Send\NotifyMsgsSentOnlyMe)
    WritePreferenceLong("AutoSendTimer", Config\Send\AutoSendTimer)

    ClosePreferences()
  EndIf
EndProcedure

;}
; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 126
; FirstLine = 117
; Folding = u
; EnableXP