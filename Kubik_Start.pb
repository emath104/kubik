; Kubik Start. Лаунчер поинт-комплекта Kubik.
; Версия 3.1
; (С) 2012-2017 ragweed
; PureBasic 5.31

;- DATA, СТРУКТУРЫ, ГЛОБ. ПЕРЕМЕННЫЕ
;{

DataSection
  DefaultIcon: 
  IncludeBinary "icons\16x16\tray.ico"
  NewMsgIcon: 
  IncludeBinary "icons\16x16\new-msg.ico"
  SendIcon: 
  IncludeBinary "icons\16x16\send.ico"
EndDataSection

Enumeration
  #TimerSend
  
  #TrayImage
  #TrayIcon
  
  #Window
  #ButtonImage_Editor
  #ButtonImage_Send
  #ButtonImage_Help
  #ButtonImage_KubikFolder
  #ButtonImage_SSetting
  #ButtonImage_Menu
  #Menu
  #TrayMenu
  #MenuItem_HideInTray
  
  #MenuItem_AutoSend_Off
  #MenuItem_AutoSend_5min
  #MenuItem_AutoSend_10min
  #MenuItem_AutoSend_15min
  #MenuItem_AutoSend_30min
  #MenuItem_AutoSend_60min
  
  #MenuItem_Setting_Notify_OnlyMe
  #MenuItem_Setting_RunInTray
  #MenuItem_Setting_CloseInTray
  
  #MenuItem_Menu
  #MenuItem_Editor
  #MenuItem_Send
  #MenuItem_RestoreFromTray
  #MenuItem_OpenKubikFolder
  #MenuItem_OpenFidoFolder
  #MenuItem_OpenSSetting
  #MenuItem_OpenReadMe
  #MenuItem_OpenHelp
  #MenuItem_OpenWebSite
  #MenuItem_OpenBlog
  #MenuItem_Exit
EndEnumeration

Enumeration
  #Send_Lock
  #Send_Unlock
EndEnumeration

Enumeration
  #Tray_Default
  #Tray_NewMsg
  #Tray_Send
EndEnumeration

;{

; Структуры для переменных из конфига Kubik_Set.ini

Structure Start
  RunInTray.a
  Params.a
  AutoSetting.a
EndStructure

Structure Path
  Editor.s
  Send.s
  HideSend.s
  Help.s
  About.s
  KubikFolder.s
  FidoFolder.s
  FTN_Set.s
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
  PointAddress.s
EndStructure

Structure Config
  Start.Start
  Path.Path
  Send.Send
  Window.Window
  Other.Other
  FTN.FTN
EndStructure

Global Config.Config

; Структуры для описания окна

; Размер и позиция
Structure SaP
  w.i
  h.i
  x.i
  y.i
EndStructure

Structure SkinWindow
  SaP.SaP
  color.i
EndStructure

Structure Gadget
  SaP.SaP
  image.i
EndStructure

Structure Skin
  Window.SkinWindow
  Map Gadgets.Gadget()
EndStructure

Global Skin.Skin

; Чтобы можно было создать конфиг из LoadConfig()
Declare SaveConfig(path.s)

; Загружаем настройки из конфига
; Если конфиг не существует - создаст новый с настройками по-умолчанию.
Procedure LoadConfig(path.s)
  If OpenPreferences(path.s)
    open = 1
  EndIf
  
  PreferenceGroup("Start")
  With Config\Start
    \RunInTray   = ReadPreferenceLong("RunInTray", 0)
    \Params      = ReadPreferenceLong("Params", 1)
    \AutoSetting = ReadPreferenceLong("Ssetting", 1)
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
    \About       = ReadPreferenceString("About", "Kubik_About.exe")
    
    \KubikFolder = ReadPreferenceString("KubikFolder", GetCurrentDirectory())
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
    \Site = ReadPreferenceString("Site", "http://kubik-fido.blogspot.com/")
    \Help = ReadPreferenceString("Help", "http://kubik-fido.blogspot.ru/p/blog-page_1.html")
  EndWith
  
  PreferenceGroup("FTN")
  With Config\FTN
    \PointAddress = ReadPreferenceString("FTNAddress", "") + "." +
                      ReadPreferenceString("PointAddress", "")
  EndWith
  
  If open = 1
    ClosePreferences()
  Else
    SaveConfig(path.s)
  EndIf
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

; Загружает в структуру Skin необходимую информацию для отрисовки окна
Procedure LoadSkin()
  
  ; Название стандартного скина
  name.s = "default"
  
  ; Расположение скинов
  skin_folder.s = "extensions\skins\"
  
  If OpenPreferences(skin_folder.s + "\Set.ini")
    PreferenceGroup("Skin")
    name.s = ReadPreferenceString("name", "")
    ClosePreferences()
  EndIf
  
  path.s = skin_folder.s + name.s

  If OpenPreferences(path.s + "\description.ini")
    open = 1
  EndIf
  
  PreferenceGroup("Size")
  With Skin\Window\SaP
    \W = ReadPreferenceLong("InnerWidth", 276)
    \H = ReadPreferenceLong("InnerHeight", 271)
  EndWith
  
  PreferenceGroup("WinColor")
  Skin\Window\color = RGB(ReadPreferenceLong("R", 255), 
                          ReadPreferenceLong("G", 255), 
                          ReadPreferenceLong("B", 255))
  
  UsePNGImageDecoder()
  
  PreferenceGroup("Images")
  If ReadPreferenceLong("logo", 0)
    With Skin\Gadgets("logo")
      \image = LoadImage(#PB_Any, path.s + "\logo.png")
      \SaP\x = ReadPreferenceLong("i1x", 5)
      \SaP\y = ReadPreferenceLong("i1y", 15)
      \SaP\w = ReadPreferenceLong("i1w", 270)
      \SaP\h = ReadPreferenceLong("i1h", 81)
    EndWith
  EndIf
  
  If ReadPreferenceLong("image", 0)
    With Skin\Gadgets("image")
      \image = LoadImage(#PB_Any, path.s + "\image.png")
      \SaP\x = ReadPreferenceLong("i2x", 5)
      \SaP\y = ReadPreferenceLong("i2y", 15)
      \SaP\w = ReadPreferenceLong("i2w", 270)
      \SaP\h = ReadPreferenceLong("i2h", 81)
    EndWith
  EndIf
  
  PreferenceGroup("Buttons")
  
  With Skin\Gadgets("editor")
    \image = LoadImage(#PB_Any, path.s + "\editor.png")
    \SaP\x = ReadPreferenceLong("B1X", 10)
    \SaP\y = ReadPreferenceLong("B1Y", 105)
    \SaP\w = ReadPreferenceLong("B1W", 125)
    \SaP\h = ReadPreferenceLong("B1H", 80)
  EndWith
  
  With Skin\Gadgets("send")
    \image = LoadImage(#PB_Any, path.s + "\send.png")
    \SaP\x = ReadPreferenceLong("B2X", 140)
    \SaP\y = ReadPreferenceLong("B2Y", 105)
    \SaP\w = ReadPreferenceLong("B2W", 125)
    \SaP\h = ReadPreferenceLong("B2H", 80)
  EndWith
  
  With Skin\Gadgets("ftn_set")
    \image = LoadImage(#PB_Any, path.s + "\set.png")
    \SaP\x = ReadPreferenceLong("B5X", 10)
    \SaP\y = ReadPreferenceLong("B5Y", 190)
    \SaP\w = ReadPreferenceLong("B5W", 60)
    \SaP\h = ReadPreferenceLong("B5H", 60)
  EndWith
  
  With Skin\Gadgets("help")
    \image = LoadImage(#PB_Any, path.s + "\help.png")
    \SaP\x = ReadPreferenceLong("B3X", 75)
    \SaP\y = ReadPreferenceLong("B3Y", 190)
    \SaP\w = ReadPreferenceLong("B3W", 60)
    \SaP\h = ReadPreferenceLong("B3H", 60)
  EndWith
  
  With Skin\Gadgets("folder")
    \image = LoadImage(#PB_Any, path.s + "\folder.png")
    \SaP\x = ReadPreferenceLong("B4X", 140)
    \SaP\y = ReadPreferenceLong("B4Y", 190)
    \SaP\w = ReadPreferenceLong("B4W", 60)
    \SaP\h = ReadPreferenceLong("B4H", 60)
  EndWith
  
  With Skin\Gadgets("menu")
    \image = LoadImage(#PB_Any, path.s + "\menu.png")
    \SaP\x = ReadPreferenceLong("B6X", 205)
    \SaP\y = ReadPreferenceLong("B6Y", 190)
    \SaP\w = ReadPreferenceLong("B6W", 60)
    \SaP\h = ReadPreferenceLong("B6H", 60)
  EndWith
EndProcedure

;}

; В WaitCloseEditorThread хранится id потока ожидания закрытия почтового редактора, см. RunEditorProgram()
Global WaitCloseEditorThread

; В HideSendThread хранится id потока фоновой отправки сообщений, см. RunHideSend().
; Если HideSendActive равна #Send_Lock, необходимо заблокировать кнопку проверки почты,
; если равна #Send_Unlock - нужно разблокировать, в противном случае равна #PB_Ignore.
Global HideSendThread, HideSendActive = #PB_Ignore

; HideSend_NewMsgs, равна 1, если есть новые сообщения. 
; HideSend_Info.s содержит в себе список - где и сколько новых сообщений.
; См. HideSend()
Global HideSend_NewMsgs = 0, HideSend_Info.s = ""


; Всё необходимое для всплывающего сообщения из трея посредством Shell_NotifyIcon_().
; Взял отсюда: http://purebasic.info/phpBB3ex/viewtopic.php?f=1&t=4526#p84905
;{
Structure NOTIFYICONDATA_95 
  cbSize.l 
  hwnd.l 
  uID.l 
  uFlags.l 
  uCallbackMessage.l 
  hIcon.l 
  szTip.c[64] 
EndStructure 
Structure NOTIFYICONDATA_2K Extends NOTIFYICONDATA_95 
  szTipEx.c[64] 
  dwState.l 
  dwStateMask.l 
  szInfo.c[256] 
  StructureUnion 
  uTimeout.l 
  uVersion.l 
  EndStructureUnion 
  szInfoTitle.c[64] 
  dwInfoFlags.l 
EndStructure 
Structure NOTIFYICONDATA_XP Extends NOTIFYICONDATA_2K 
  guid.GUID
EndStructure

; процедура построения уведомления в систем трее юникод
Procedure SysTrayIcon_Balloon(Tray, WindowID, Title.s, Message.s, TimeOut, TypeIcon) 
; Tray     - идентификатор значка в трее 
; WindowID - Системный идентификатор окна 
; Title    - текст в заголовке баллона 
; Message  - текст в баллоне 
; TimeOut  - Время (в миллисекундах) отображения баллона 
; TypeIcon - тип значка #NIIF_NONE #NIIF_INFO #NIIF_WARNING #NIIF_ERROR #NIIF_USER 
 
  Protected nid.NOTIFYICONDATA_2K
  nid\cbSize      = SizeOf(NOTIFYICONDATA_2K)
  nid\uVersion = #NOTIFYICON_VERSION 
  Shell_NotifyIcon_(#NIM_SETVERSION, @nid) 
  nid\uCallbackMessage = #PB_Event_SysTray 
  nid\uID              = Tray 
  nid\hwnd             = WindowID 
  nid\dwInfoFlags      = TypeIcon ;#NIIF_INFO 
  nid\uFlags           = #NIF_INFO 
  nid\uTimeout         = TimeOut 
  nid\dwState          = #NIS_SHAREDICON 
  PokeS(@nid\szInfo, message, 256)
  PokeS(@nid\szInfoTitle, title, 64) 
  
  ProcedureReturn Shell_NotifyIcon_(#NIM_MODIFY, @nid) 
  
EndProcedure
;}

;}

;- ПРОЦЕДУРЫ
;{

; Выводит всплывающее уведомление с заголовком title и текстом info.
Procedure NotifyMessage(title.s, info.s)
  If Len(info.s) = 0
    info.s = " "
  ElseIf Len(info.s) > 200
    info.s = Left(info.s, 200)
  EndIf
  
  SysTrayIcon_Balloon(#TrayIcon, WindowID(#Window), title.s, info.s, 10000, #NIIF_NONE)
EndProcedure

; Вернёт заголовок для всплывающего уведомления
Procedure.s NotifyTitle()
  If Config\Send\NotifyMsgsSentOnlyMe = 1
    ProcedureReturn "У вас есть новые сообщения"
  Else
    ProcedureReturn "Есть новые сообщения"
  EndIf
EndProcedure

; Запускает программу Name.s, сворачивая Kubik Start, и разворачивая его обратно после закрытия этой программы.
Procedure HideRunProgram(Name.s)
  SetWindowState(#Window, #PB_Window_Minimize)
  HideWindow(#Window, 1)
  RunProgram(Name, "", "", #PB_Program_Wait)
  HideWindow(#Window, 0)
  SetWindowState(#Window, #PB_Window_Normal)
EndProcedure

; Вспомогательная процедура для Menu()
Procedure SubMenu_Setting(menu_id)
  If OpenSubMenu("Настройка")
    ;- Новые пункты - сюда 
    MenuItem(#MenuItem_Setting_Notify_OnlyMe, "Уведомлять только о Netmail и CarbonArea")
    If Config\Send\NotifyMsgsSentOnlyMe = 1
      SetMenuItemState(menu_id, #MenuItem_Setting_Notify_OnlyMe, 1)
    EndIf
    
    MenuItem(#MenuItem_Setting_RunInTray, "Всегда запускать свёрнутым в трей")
    If Config\Start\RunInTray = 1
      SetMenuItemState(menu_id, #MenuItem_Setting_RunInTray, 1)
    EndIf
    
    MenuItem(#MenuItem_Setting_CloseInTray, "Закрывать окно в трей")
    If Config\Window\CloseInTray = 1
      SetMenuItemState(menu_id, #MenuItem_Setting_CloseInTray, 1)
    EndIf
    
    MenuBar()
    
    MenuItem(#MenuItem_OpenSSetting, "Настройка поинт-комплекта" + Chr(9) + "Ctrl+S")
    
    CloseSubMenu()
  EndIf
EndProcedure

; Вспомогательная процедура для Menu()
Procedure SubMenu_AutoSend()
  If OpenSubMenu("Автоматическая проверка почты")
    MenuItem(#MenuItem_AutoSend_Off, "Выкл.")
    MenuBar()
    MenuItem(#MenuItem_AutoSend_5min, "Каждые 5 минут")
    MenuItem(#MenuItem_AutoSend_10min, "Каждые 10 минут")
    MenuItem(#MenuItem_AutoSend_15min, "Каждые 15 минут")
    MenuItem(#MenuItem_AutoSend_30min, "Каждые 30 минут")
    MenuItem(#MenuItem_AutoSend_60min, "Каждый час")
    CloseSubMenu()
  EndIf
EndProcedure

; Вспомогательная процедура для Window()
Procedure Menu()
  If CreatePopupMenu(#Menu)
    MenuItem(#MenuItem_HideInTray, "Свернуть в трей")
    MenuBar()
    SubMenu_AutoSend()
    MenuBar()
    MenuItem(#MenuItem_OpenKubikFolder, "Открыть папку "+Config\Path\KubikFolder + Chr(9) + "K")
    MenuItem(#MenuItem_OpenFidoFolder, "Открыть папку "+Config\Path\FidoFolder + Chr(9) + "F")
    MenuBar()
    SubMenu_Setting(#Menu)
    MenuBar()
    MenuItem(#MenuItem_OpenReadMe, "Описание поинт-комплекта")
    MenuItem(#MenuItem_OpenHelp, "Справка" + Chr(9) + "F1")
    MenuItem(#MenuItem_OpenWebSite, "Веб-сайт проекта")
    MenuBar()
    MenuItem(#MenuItem_Exit, "Выход" + Chr(9) + "Ctrl+Q")
  EndIf
  
  If CreatePopupImageMenu(#TrayMenu)
    MenuItem(#MenuItem_RestoreFromTray, "Развернуть из трея")
    MenuBar()
    MenuItem(#MenuItem_Editor, "Почтовый редактор")
    MenuItem(#MenuItem_Send, "Отправить и принять почту")
    SubMenu_AutoSend()
    MenuBar()
    MenuItem(#MenuItem_OpenKubikFolder, "Открыть папку "+Config\Path\KubikFolder+"")
    MenuItem(#MenuItem_OpenFidoFolder, "Открыть папку "+Config\Path\FidoFolder+"")
    MenuBar()
    SubMenu_Setting(#TrayMenu)
    MenuBar()
    MenuItem(#MenuItem_OpenReadMe, "Описание поинт-комплекта")
    MenuItem(#MenuItem_OpenHelp, "Справка")
    MenuItem(#MenuItem_OpenWebSite, "Веб-сайт проекта")
    MenuBar()
    MenuItem(#MenuItem_Exit, "Выход")
  EndIf
EndProcedure

; Создаёт горячие клавиши для важных функций.
Procedure Shortcuts()
  AddKeyboardShortcut(#Window, #PB_Shortcut_E, #MenuItem_Editor)
  AddKeyboardShortcut(#Window, #PB_Shortcut_S, #MenuItem_Send)
  AddKeyboardShortcut(#Window, #PB_Shortcut_Control | #PB_Shortcut_S, #MenuItem_OpenSSetting)
  AddKeyboardShortcut(#Window, #PB_Shortcut_M, #MenuItem_Menu)
  AddKeyboardShortcut(#Window, #PB_Shortcut_F1, #MenuItem_OpenHelp)
  AddKeyboardShortcut(#Window, #PB_Shortcut_K, #MenuItem_OpenKubikFolder)
  AddKeyboardShortcut(#Window, #PB_Shortcut_F, #MenuItem_OpenFidoFolder)
  AddKeyboardShortcut(#Window, #PB_Shortcut_Control | #PB_Shortcut_Q, #MenuItem_Exit)
EndProcedure

; Уберет галочки со всех пунктов подменю атомотической проверки почты.
Procedure UncheckedAutoSendMenuItems()
  For num = #MenuItem_AutoSend_Off To #MenuItem_AutoSend_60min
    SetMenuItemState(#TrayMenu, num, 0)
    SetMenuItemState(#Menu, num, 0)
  Next
EndProcedure

; Заблокирует все пункты подменю атомотической проверки почты.
Procedure LockAutoSendMenuItems()
  For num = #MenuItem_AutoSend_Off To #MenuItem_AutoSend_60min
    DisableMenuItem(#TrayMenu, num, 1)
    DisableMenuItem(#Menu, num, 1)
  Next
EndProcedure

; Разблокирует все пункты подменю атомотической проверки почты.
Procedure UnlockAutoSendMenuItems()
  For num = #MenuItem_AutoSend_Off To #MenuItem_AutoSend_60min
    DisableMenuItem(#TrayMenu, num, 0)
    DisableMenuItem(#Menu, num, 0)
  Next
EndProcedure

; Отметит галочкой пункт menu_item в подменю автом. отправки почты.
Procedure SelectAutoSendMenuItem(menu_item)
  UncheckedAutoSendMenuItems()
  SetMenuItemState(#TrayMenu, menu_item, 1)
  SetMenuItemState(#Menu, menu_item, 1)
EndProcedure

; Процедура возвращает будущий заголовок окна
Procedure.s GetWindowName()
  ProcedureReturn Config\FTN\PointAddress + " - Kubik"
EndProcedure

; Создаёт ButtonImageGadget из следующего описания: 
; name.s - название кнопки в структуре Skin\Gadgets()
; const_id - константа, по которой потом будем отлавливать эту кнопку
; tooltip.s - всплывающая подсказка
Procedure CreateButton(name.s, const_id, tooltip.s)
  With Skin\Gadgets(name.s)
    If \image
      ButtonImageGadget(const_id, \SaP\x, \SaP\y, \SaP\w, \SaP\h, ImageID(\image))
      GadgetToolTip(const_id, tooltip.s)
    EndIf
  EndWith
EndProcedure

; Отобразит окно программы.
Procedure Window()
  If OpenWindow(#Window, Config\Window\X, Config\Window\Y, Skin\Window\SaP\W, Skin\Window\SaP\H, GetWindowName(),  
                #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_TitleBar | #PB_Window_Invisible)
    
    SetWindowColor(#Window, Skin\Window\color)
    
    With Skin\Gadgets("logo")
      If \image
        ImageGadget(#PB_Any, \SaP\x, \SaP\y, \SaP\w, \SaP\h, ImageID(\image))
      EndIf
    EndWith
    
    With Skin\Gadgets("image")
      If \image
        ImageGadget(#PB_Any, \SaP\x, \SaP\y, \SaP\w, \SaP\h, ImageID(\image))
      EndIf
    EndWith
    
    CreateButton("editor", #ButtonImage_Editor, "Чтение почты [E]")
    CreateButton("send", #ButtonImage_Send, "Доставить почту в Фидонет [S]")
    
    CreateButton("ftn_set", #ButtonImage_SSetting, "Настройка поинт-комплекта [Ctrl+S]")
    CreateButton("help", #ButtonImage_Help, "Справочный материал [F1]")
    CreateButton("folder", #ButtonImage_KubikFolder, "Открыть папку \Kubik\ [K]")
    
    CreateButton("menu", #ButtonImage_Menu, "Меню [M]")
    
  EndIf
EndProcedure  

; Запускает консольное приложение в фоне и по его завершению возвращает вывод из него.
Procedure.s RunSendProgram(name.s, parameter.s, work_dir.s)
  program_id = RunProgram(name.s, parameter.s, work_dir.s, #PB_Program_Open | #PB_Program_Hide | #PB_Program_Read | #PB_Program_Error)
  output.s = ""
  
  If program_id  
    While ProgramRunning(program_id)
      temp_string.s = ReadProgramError(program_id)
      If temp_string.s <> ""
        output.s + Trim(temp_string.s) + Chr(13)
        ;Debug Trim(temp_string.s)
      EndIf
      
      temp_string.s = ReadProgramString(program_id)
      If temp_string.s <> ""
        output.s + Trim(temp_string.s) + Chr(13)
        ;Debug Trim(temp_string.s)
      EndIf
    Wend
  
    Repeat
      temp_error_string.s = ReadProgramError(program_id)
      temp_string.s = ReadProgramString(program_id)
      If temp_string.s = "" And temp_error_string = ""
        Break
      Else
        If temp_error_string.s <> ""
          output.s + Trim(temp_error_string.s) + Chr(13)
        EndIf
        
        If temp_string.s <> ""
          output.s + Trim(temp_string.s) + Chr(13)
        EndIf
      EndIf
    ForEver
    
    ProcedureReturn output.s
  EndIf
EndProcedure

; Генерация текста для всплывающего сообщения из трея
; для генерации уведомления обо всех пришедших сообщений (Config\Send\NotifyMsgsSentOnlyMe = 0)
Procedure.s CreateNotifyText(Array AreasInfo.s(1), Length)
  msg.s = ""
  etc.s = "и др."
  max = 200
  
  For k = 0 To Length - 1
    current.s = AreasInfo(k) + Chr(10)
    If Len(msg.s + etc.s + current.s) <= max
      msg.s + current.s
    Else
      msg.s + etc.s
      Break
    EndIf
  Next

  ProcedureReturn msg.s
EndProcedure

; Генерация текста для всплывающего сообщения из трея
; для генерации уведомления с сообщениями из Netmail or CarbonArea (Config\Send\NotifyMsgsSentOnlyMe = 1)
Procedure.s CreateNotifyOnlyMeText(Array AreasInfo.s(1), Length)
  msg.s = ""
  For k = 0 To Length - 1
    current.s = AreasInfo(k) + Chr(10)
    If FindString(current.s, "Netmail", 0, #PB_String_NoCase) + 
            FindString(current.s, "CarbonArea", 0, #PB_String_NoCase) <> 0
      msg.s + current.s
    EndIf
  Next
  ProcedureReturn msg.s
EndProcedure

; Ищем вывод об итогах тоссинга входящей почты, если находим - возращаем текст для всплывающего сообщения
Procedure.s ParseLogTossing(log.s)
  regexp = CreateRegularExpression(#PB_Any, Config\Send\NewMsgInfoRegexp, #PB_RegularExpression_AnyNewLine | #PB_RegularExpression_NoCase)
  If regexp
    If Config\Send\CropLog = 1
      position = FindString(log.s, Config\Send\NewMsgInfoTosLog)
    Else
      position = -1
    EndIf
    
    If position <> 0
      ; ... вычленяем эту часть лога, будем анализаровать её regexp'ом.
      ; end_position = FindString(log.s, "End tossing", position, #PB_String_NoCase)
      log.s = Mid(log.s, position) ; , end_position)
      Dim TempArray.s(0)
      NbFound = ExtractRegularExpression(regexp, log.s, TempArray())
      If Config\Send\NotifyMsgsSentOnlyMe = 0
        result.s = CreateNotifyText(TempArray(), NbFound)
      Else
        result.s = CreateNotifyOnlyMeText(TempArray(), NbFound)
      EndIf
      result.s = ReplaceString(result.s, ": toss ", " ") ; Для Parma Tosser
      result.s = LCase(result.s)
    EndIf
    FreeRegularExpression(regexp)
  Else
    MessageRequester( "Ошибка", "Невозможно проанализировать вывод обмена почтой: " + 
                                     "допущена ошибка при написании регулярного выражения - " + 
                                     RegularExpressionError(), #MB_ICONERROR)
  EndIf
  ProcedureReturn result.s
EndProcedure

; Тестовая процедура для проверки ParseLogTossing()
Procedure.s Test_ParseLogTossing()
  test.s = "HTP toss link" + Chr(10)
  test.s + "4 21:14:37  Areas summary:" + Chr(10)
  test.s + "4 21:14:37  Netmail - 1 msgs" + Chr(10)
  test.s + "4 21:14:37  pushkin.local - 83 msgs" + Chr(10)
  test.s + "4 21:14:37  pushkin.stat - 4 msgs" + Chr(10)
  test.s + "4 21:14:37  ru.fidonet.digest - 1 msgs" + Chr(10)
  test.s + "4 21:14:37  CarbonArea - 4 msgs" + Chr(10)
  ProcedureReturn ParseLogTossing(test.s)
EndProcedure

; Тестовая процедура для проверки ParseLogTossing()
Procedure.s Test_PartossParseLogTossing()
  test.s = "12 Nov 16  19:03:44 ALT.RUSSIAN.Z1: toss - 1 (4535 bytes)" + Chr(10)
  test.s + "12 Nov 16  19:03:44 SU.POL.NEWS: toss - 2 (2159 bytes)" + Chr(10)
  test.s + "12 Nov 16  19:03:44 SU.TALKS: toss - 1 (1224 bytes)" + Chr(10)
  test.s + "12 Nov 16  19:03:44 SU.FORMULA1.INFO: toss - 2 (2001 bytes)" + Chr(10)
  test.s + "12 Nov 16  19:03:44 Total: toss - 6" + Chr(10)
  test.s + "12 Nov 16  19:03:44 End, ParToss 1.10.073/ZOO/W32" + Chr(10)
  ProcedureReturn ParseLogTossing(test.s)
EndProcedure

; Отправит и примет почту в фоновом режиме.
; О получении новых сообщениях можно узнать из HideSend_NewMsgs и HideSend_Info.s
Procedure HideSend(null)
  Debug "Начинается проверка почты"
  HideSendActive = #Send_Lock
  out.s = RunSendProgram(Config\Path\HideSend, "-a", "") ; Ключ -a отключает приветствие и ожидание пользователя по завершению обмена почтой для Kubik_Send.exe.
  result.s = ParseLogTossing(out.s)
  If result.s <> ""
    Debug "Есть новые сообщения!"
    Debug result.s
    HideSend_NewMsgs = 1
    HideSend_Info.s = result.s
  EndIf
  HideSendActive = #Send_Unlock
  Debug "Проверка почты завершена"
EndProcedure

; Тестовая процедура для проверки уведомлений из трея
Procedure Test_FakeHideSend(null)
  HideSendActive = #Send_Lock
  HideSend_NewMsgs = 1
  HideSend_Info.s = Test_ParseLogTossing()
  ;- HideSend_Info.s = Test_PartossParseLogTossing()
  HideSendActive = #Send_Unlock
EndProcedure

; Проверка сообщений в фоне (запуск HideSend() в потоке).
Procedure RunHideSend()
  If Not IsThread(HideSendThread)
    HideSendThread = CreateThread(@HideSend(), #PB_Ignore)
  EndIf
EndProcedure

; Создаёт/заменяет иконку (и подпись) в трее.
; #Tray_Default - обычная иконка.
; #Tray_NewMsg - есть новые сообщения.
; #Tray_Send - идёт проверка почты.
Procedure SetTrayIcon(type = #Tray_Default)
  Select type
    Case #Tray_Default
      If CatchImage(#TrayImage, ?DefaultIcon)
        AddSysTrayIcon(#TrayIcon, WindowID(#Window), ImageID(#TrayImage))
        SysTrayIconToolTip(#TrayIcon, GetWindowName())
      EndIf
    Case #Tray_NewMsg
      If CatchImage(#TrayImage, ?NewMsgIcon)
        AddSysTrayIcon(#TrayIcon, WindowID(#Window), ImageID(#TrayImage))
        SysTrayIconToolTip(#TrayIcon, GetWindowName() + Chr(10) + NotifyTitle())
      EndIf
    Case #Tray_Send
      If CatchImage(#TrayImage, ?SendIcon)
        AddSysTrayIcon(#TrayIcon, WindowID(#Window), ImageID(#TrayImage))
        SysTrayIconToolTip(#TrayIcon, GetWindowName() + Chr(10) + "Идёт обмен почтой, пожалуйста подождите...")
      EndIf
  EndSelect
EndProcedure

; Свернет окно Kubik Start, отобразит иконку в трее.
Procedure HideWindowInTray()
  Config\Window\HideInTray = 1
  HideWindow(#Window, 1)
  SetTrayIcon()
EndProcedure

; Развернет окно Kubik Start, удалит иконку из трея.
Procedure RestoreWindowFromTray()
  Config\Window\HideInTray = 0
  ; Отображаем окно
  HideWindow(#Window, 0)
  ; Удаляем иконку из трея
  RemoveSysTrayIcon(#TrayIcon)
EndProcedure

; Запускает таймер #TimerSend, благодаря которому будет работать автоматическая отправка сообщений в фоне.
; timeout - количество минут, через которые будет срабатывать таймер.
Procedure StartAutoSend(timeout)
  ; Если это действительно старт таймера, а не просто изменение его timeout, то проверим почту.
  If GetMenuItemState(#TrayMenu, #MenuItem_AutoSend_Off)
    RunHideSend()
  EndIf
  Config\Send\AutoSendTimer = timeout
  ; Запуск таймера
  AddWindowTimer(#Window, #TimerSend, timeout * 60 * 1000)
EndProcedure

; Останавливает таймер #TimerSend.
Procedure StopAutoSend()
  Config\Send\AutoSendTimer = 0
  RemoveWindowTimer(#Window, #TimerSend)
EndProcedure

; Вспомогательная процедура для RunEditor().
Procedure RunAndWaitCloseEditor(null)
  ; Запоминаем периодичность таймера
  timer = Config\Send\AutoSendTimer
  
  ; Отключаем автоматическую отправку почты
  StopAutoSend()
  
  ; Заблокируем пункты подменю автоматической отправки
  LockAutoSendMenuItems()
  
  ; Запускаем редактор
  program_id = RunProgram(Config\Path\Editor, "", "", #PB_Program_Open)
  
  ; Ожидаем завершения работы редактора
  If program_id  
    While ProgramRunning(program_id)
      Delay(1000)
    Wend
  EndIf
  
  ; Разблокируем пункты подменю автоматической отправки
  UnlockAutoSendMenuItems()
  
  ; Если включена автоматическая проверка почты
  If timer <> 0
    ; Теперь, когда он закончил свою работу, можем проверить почту
    RunHideSend()
    ; и вернуть таймер автоматической проверки почты
    StartAutoSend(timer)
  EndIf
EndProcedure

; Запускает почтовый редактор, останавливая авт. проверку почты 
; и возобновляя её после закрытия редактора.
Procedure RunEditorProgram()
  ; Если окно не спрятано в трее, то запускаем редактор по старинке
  If Config\Window\HideInTray <> 1
    HideRunProgram(Config\Path\Editor)
  Else
    If Not IsThread(WaitCloseEditorThread)
      SetTrayIcon()
      WaitCloseEditorThread = CreateThread(@RunAndWaitCloseEditor(), #PB_Ignore)
    EndIf
  EndIf
EndProcedure

;}

LoadConfig("Kubik_Set.ini")

; До тех пор, пока AutoSetting=1, вместо лаунчера запускается настройка поинт-комплекта 
If Config\Start\AutoSetting = 1 
  RunProgram(Config\Path\FTN_Set, "", "", #PB_Program_Wait)
  LoadConfig("Kubik_Set.ini") ; Повторно считываем информацию из конфигурационного файла Kubik_Set.ini
  If Config\Start\AutoSetting
    End ; Поинт-комплект не был настроен - выходим из приложения
  EndIf
EndIf  

; Если Params=1, то запускается Kubik_Params.exe
If Config\Start\Params = 1
  If RunProgram("Kubik_Params.exe", "", "", #PB_Program_Wait)
    LoadConfig("Kubik_Set.ini") ; После того, как Params обновил пути в конфигах - загружаем Kubik_Set.ini заново.
  Else
    MessageRequester("Ошибка", "Не удалось запустить Kubik_Params.exe", 16)
  EndIf
Else
  Debug "Запуск Kubik_Params.exe отключен!"
EndIf 

LoadSkin()
Window()
Menu()
Shortcuts()

; Если приложение при завершении было свернуто в трее, то и запустится оно тоже в трее.
; Параметр Config\Start\RunInTray задаёт принудительный запуск в трей, 
; даже если при выходе окно не было спрятано в трей
If (Config\Window\HideInTray + Config\Start\RunInTray) = 0
  HideWindow(#Window, 0)
Else
  HideWindowInTray()
EndIf

;- Раскомментировать если нужно проверить работоспособность уведомлений
; Test_FakeHideSend(null)

; Если пользователем была задана авт. отправка почты...
If Config\Send\AutoSendTimer <> 0
  RunHideSend()
  
  ; Проверим, допустимо ли данное значение AutoSendTimer
  If Config\Send\AutoSendTimer < 5
    Config\Send\AutoSendTimer = 5
  ElseIf Config\Send\AutoSendTimer > 60
    Config\Send\AutoSendTimer = 60
  EndIf
  
  Select Config\Send\AutoSendTimer
    Case 5
      StartAutoSend(5)
      SelectAutoSendMenuItem(#MenuItem_AutoSend_5min)
    Case 10
      StartAutoSend(10)
      SelectAutoSendMenuItem(#MenuItem_AutoSend_10min)
    Case 15
      StartAutoSend(15)
      SelectAutoSendMenuItem(#MenuItem_AutoSend_15min)
    Case 30
      StartAutoSend(30)
      SelectAutoSendMenuItem(#MenuItem_AutoSend_30min)
    Case 60
      StartAutoSend(60)
      SelectAutoSendMenuItem(#MenuItem_AutoSend_60min)
    Default
      StopAutoSend()
      SelectAutoSendMenuItem(#MenuItem_AutoSend_Off)
  EndSelect
Else
  SelectAutoSendMenuItem(#MenuItem_AutoSend_Off)
EndIf

Repeat
  Event = WaitWindowEvent(500)
  
  ; См. описание переменной HideSendActive в начале исходного файла
  If HideSendActive <> #PB_Ignore
    If HideSendActive = #Send_Lock
      ; Была запущена проверка почты, неоходимо заблокировать кнопку проверки почты
      DisableGadget(#ButtonImage_Send, 1)
      DisableMenuItem(#TrayMenu, #MenuItem_Send, 1)
      SetTrayIcon(#Tray_Send)
    ElseIf HideSendActive = #Send_Unlock
      ; Проверка почты завершена, разблокируем кнопку отправки почты
      DisableGadget(#ButtonImage_Send, 0)
      DisableMenuItem(#TrayMenu, #MenuItem_Send, 0)
      SetTrayIcon(#Tray_Default)
    EndIf
    HideSendActive = #PB_Ignore
  EndIf
  
  ; Выводим сообщение о новых сообщениях, т.к. не это можно делать только из гл. потока.
  ; Заведует данными переменными HideSend().
  If HideSend_NewMsgs = 1
    SetTrayIcon(#Tray_NewMsg)
    NotifyMessage(NotifyTitle(), HideSend_Info.s)
    HideSend_NewMsgs = 0
    HideSend_Info.s = ""
  EndIf

  Select Event
    Case #PB_Event_CloseWindow
      If Config\Window\CloseInTray = 1
        HideWindowInTray()
      Else
        Break
      EndIf
    Case #PB_Event_Timer
      If EventTimer() = #TimerSend ; Время автоматического приема почты
        Debug Str(Config\Send\AutoSendTimer) + " минут прошли - время автоматического приема почты!"
        RunHideSend()
      EndIf
    Case #WM_RBUTTONDOWN ; Клик по окну правой кнопкой мыши.
      DisplayPopupMenu(#Menu, WindowID(#Window))
    Case #PB_Event_SysTray
      Select EventType()
        Case #PB_EventType_LeftClick
          RunEditorProgram()
        Case #PB_EventType_RightClick
          DisplayPopupMenu(#TrayMenu, WindowID(#Window))
      EndSelect
    Case #PB_Event_Gadget
      Select EventGadget()
        Case #ButtonImage_Editor
          RunEditorProgram()
        Case #ButtonImage_Send
          RunProgram(Config\Path\Send, "", "")
        Case #ButtonImage_Help
          RunProgram(Config\Other\Help, "", "")
        Case #ButtonImage_KubikFolder
          RunProgram(Config\Path\KubikFolder, "", "")
        Case #ButtonImage_Menu
          DisplayPopupMenu(#Menu, WindowID(#Window))
        Case #ButtonImage_SSetting
          HideRunProgram(Config\Path\FTN_Set)
      EndSelect
    Case #PB_Event_Menu
      Select EventMenu()
        Case #MenuItem_Menu
          DisplayPopupMenu(#Menu, WindowID(#Window))
        Case #MenuItem_HideInTray
          HideWindowInTray()
        Case #MenuItem_RestoreFromTray
          RestoreWindowFromTray()
        Case #MenuItem_Editor
          RunEditorProgram()
        Case #MenuItem_Send
          RunProgram(Config\Path\Send, "", "")
        Case #MenuItem_OpenKubikFolder
          RunProgram(Config\Path\KubikFolder, "", "")
        Case #MenuItem_OpenFidoFolder
          RunProgram(Config\Path\FidoFolder, "", "")
        Case #MenuItem_OpenSSetting
          HideRunProgram(Config\Path\FTN_Set);
        Case #MenuItem_OpenReadMe
          RunProgram(Config\Path\About, "", "")
        Case #MenuItem_OpenHelp
          RunProgram(Config\Other\Help, "", "")
        Case #MenuItem_OpenWebSite
          RunProgram(Config\Other\Site, "", "")
        Case #MenuItem_Exit
          Break
       
      ; Пункты меню автоматической отправки почты.
      ;{
       Case #MenuItem_AutoSend_Off
         StopAutoSend()
         SelectAutoSendMenuItem(#MenuItem_AutoSend_Off)
       Case #MenuItem_AutoSend_5min
         StartAutoSend(5)
         SelectAutoSendMenuItem(#MenuItem_AutoSend_5min)
       Case #MenuItem_AutoSend_10min
         StartAutoSend(10)
         SelectAutoSendMenuItem(#MenuItem_AutoSend_10min)
       Case #MenuItem_AutoSend_15min
         StartAutoSend(15)
         SelectAutoSendMenuItem(#MenuItem_AutoSend_15min)
       Case #MenuItem_AutoSend_30min
         StartAutoSend(30)
         SelectAutoSendMenuItem(#MenuItem_AutoSend_30min)
       Case #MenuItem_AutoSend_60min
         StartAutoSend(60)
         SelectAutoSendMenuItem(#MenuItem_AutoSend_60min)
       ;}
         
      ; Пункты меню настройки
      ;{
      ;- Обработку событий - сюда  

      Case #MenuItem_Setting_Notify_OnlyMe
        If Config\Send\NotifyMsgsSentOnlyMe = 1
          Config\Send\NotifyMsgsSentOnlyMe = 0
        Else
          Config\Send\NotifyMsgsSentOnlyMe = 1
        EndIf
        SetMenuItemState(#TrayMenu, #MenuItem_Setting_Notify_OnlyMe, Config\Send\NotifyMsgsSentOnlyMe)
        SetMenuItemState(#Menu, #MenuItem_Setting_Notify_OnlyMe, Config\Send\NotifyMsgsSentOnlyMe)
      Case #MenuItem_Setting_RunInTray
        If Config\Start\RunInTray = 1
          Config\Start\RunInTray = 0
        Else
          Config\Start\RunInTray = 1
        EndIf
        SetMenuItemState(#TrayMenu, #MenuItem_Setting_RunInTray, Config\Start\RunInTray)
        SetMenuItemState(#Menu, #MenuItem_Setting_RunInTray, Config\Start\RunInTray)
      Case #MenuItem_Setting_CloseInTray
        If Config\Window\CloseInTray = 1
          Config\Window\CloseInTray = 0
        Else
          Config\Window\CloseInTray = 1
        EndIf
        SetMenuItemState(#TrayMenu, #MenuItem_Setting_CloseInTray, Config\Window\CloseInTray)
        SetMenuItemState(#Menu, #MenuItem_Setting_CloseInTray, Config\Window\CloseInTray)
      ;}
        
    EndSelect
  EndSelect
ForEver

If Config\Window\HideInTray <> 1
  Config\Window\X = WindowX(#Window)
  Config\Window\Y = WindowY(#Window)
EndIf

SaveConfig("Kubik_Set.ini")
; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 85
; FirstLine = 78
; Folding = 4v88-v0
; EnableXP
; UseIcon = icons\128x128\fido.ico
; Executable = Kubik_Start.exe
; IncludeVersionInfo
; VersionField0 = 3,0,0,0
; VersionField1 = 3,0,0,0
; VersionField2 = Kubik Project
; VersionField3 = Kubik
; VersionField4 = 3.0
; VersionField7 = Kubik Start
; VersionField8 = Kubik_Start.exe
; VersionField9 = (C) 2017 Kubik Project
; VersionField14 = http://kubik-fido.blogspot.com/
; VersionField17 = 0419 Russian