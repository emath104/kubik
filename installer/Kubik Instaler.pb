;{ КОНСТАНТЫ
#PROG_NAME = "Kubik Stress3Test"
#PROG_VERSION = "3.0.92.6RC"
#PROG_SIZE = 100
#ST$ = Chr(13)
#CH$ = " " +Chr(151) +Chr(151) +" "
#AP$ = Chr(34)
#LE$ = Chr(171)
#RI$ = Chr(187)
;}

;{ ОБЬЯВЛЕНИЕ ГАДЖЕТОВ И ГЛОБАЛЬНЫХ ПЕРЕМЕННЫХ
Enumeration
  #Window
  #Image_Logo
  #Image_Progress
  #Text_0
  #Text_1
  #Text_Error
  #Text_ExtractFiles
  #Text_Path
  #Button_Path
  #Button_Start
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
  EndEnumeration
Global WindowScene, Finish, CheckBox_Desktop, CheckBox_Menu_Start, CheckBox_USB, noerror, ProgressText, Path.s="C:\Kubik\"
;}

;{ ДОБАВЛЯЕМ ИЗОБРАЖЕНИЯ
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

;{ SFX
Global DoneFiles, ProgName.s=ProgramFilename()

Declare Open_Window_Error()

Procedure Error(comment.s)
  Open_Window_Error()
  SetGadgetText(#Text_Error, comment)
EndProcedure

Procedure PureSFXCallback(File.s, PerCent) ; Отображение в окне общего прогресса распаковки файлов
  Result=0
  ProgressText$ = File
  SetGadgetState(#ProgressBar_Progress, DoneFiles*100/PerCent)
  DoneFiles+1
  ProcedureReturn Result
EndProcedure

Procedure ExtractArchive(ExtractPath.s) ; Распаковка архива в папку ExtractPath
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
  
  If PureZIP_Archive_Read(ProgName) ; Открываем архив (исполняемый файл распаковщика)
    DoneFiles=1
    PureZIP_Archive_GlobalInfo(@GlobalInfo) 
    NrOfCompressed.l = GlobalInfo\number_entry
    ReturnValue.l = PureZIP_Archive_FindFirst()
    While ReturnValue = #UNZ_OK
      If PureZIP_Archive_FileInfo(@FileInfo) = #UNZ_OK           ; Данные о файле (размер, дата, степень сжатия, CRC и т. д.)
        If PureZIP_Archive_Extract(ExtractPath, #True) = #UNZ_OK ; Распаковываем файлы
          If PureSFXCallback(FileInfo\FileName, NrOfCompressed) = 1
            Break ; Распаковка прервана пользователем.
          EndIf
          ReturnValue = PureZIP_Archive_FindNext() ; Подготовка к распаковке следующего файла
        Else
          Error("Произошла ошибка при распаковке файла"+Chr(10)+FileInfo\FileName)
         ; MessageRequester("", "Произошла ошибка при распаковке файла"+Chr(10)+FileInfo\FileName, #MB_OK|#MB_ICONWARNING)
          Break
        EndIf
      EndIf
    Wend
    
    CreateDirectory(""+Path+"fido\2uplink\")
           CreateDirectory(""+Path+"fido\announce\")
           CreateDirectory(""+Path+"fido\badarea\")
           CreateDirectory(""+Path+"fido\carbonarea\")
           CreateDirectory(""+Path+"fido\dupearea\")
           CreateDirectory(""+Path+"fido\fghigetdir\")
           CreateDirectory(""+Path+"fido\filebox\")
           CreateDirectory(""+Path+"fido\flags\")
           CreateDirectory(""+Path+"fido\inbound\")
           CreateDirectory(""+Path+"fido\localinb\")
           CreateDirectory(""+Path+"fido\magic\")
           CreateDirectory(""+Path+"fido\msgbasedir\")
           CreateDirectory(""+Path+"fido\netmailarea\")
           CreateDirectory(""+Path+"fido\nodelist\")
           CreateDirectory(""+Path+"fido\outbound\")
           CreateDirectory(""+Path+"fido\outfile\")
           CreateDirectory(""+Path+"fido\protinb\")
           CreateDirectory(""+Path+"fido\public\")
           CreateDirectory(""+Path+"fido\tempinb\")
           CreateDirectory(""+Path+"fido\tempoutb\")
           CreateDirectory(""+Path+"fido\uudecode\")
           CreateDirectory(""+Path+"templates-and-setting\fidoconf\")
    PureZIP_Archive_Close() ; Закрытие архива
    
    If ReturnValue = #UNZ_END_OF_LIST_OF_FILE
      noerror = 1
    EndIf
  Else : Error("Ошибка при доступе к архиву.")
   ; MessageRequester("", "Ошибка при доступе к архиву.", #MB_OK|#MB_ICONERROR)
  EndIf
EndProcedure
;}

;{ ДОБАВЛЯЕМ ОКНО И ГАДЖЕТЫ
Procedure Open_Window_Start()
  If OpenWindow(#Window, 0, 0, 400, 350, "Установщик "+#PROG_NAME+" "+#PROG_VERSION+"",  #PB_Window_SystemMenu | #PB_Window_TitleBar | #PB_Window_ScreenCentered)
    SetWindowColor(#Window, RGB(255, 255, 255))
    ImageGadget(#Image_Logo, 70, 75, 270, 81, Image0)
    TextGadget(#Text_0, 70, 170, 270, 20, "Kubik будет установлен в:", #PB_Text_Center)
      SetGadgetFont(#Text_0, LoadFont(0, "Arial", 10))
      SetGadgetColor(#Text_0, #PB_Gadget_BackColor, RGB(255, 255, 255))
    TextGadget(#Text_Path, 70, 190, 270, 20, path, #PB_Text_Center)
      SetGadgetFont(#Text_Path, LoadFont(1, "Arial", 10))
      SetGadgetColor(#Text_Path, #PB_Gadget_BackColor, RGB(255, 255, 255))
    ButtonGadget(#Button_Start, 110, 215, 190, 50, "Установить", #PB_Button_Default)
      SetGadgetFont(#Button_Start, LoadFont(3, "Arial", 16))
    ButtonGadget(#Button_Path, 140, 270, 130, 35, "Изменить...")
      SetGadgetFont(#Button_Path, LoadFont(9, "Arial", 11))
  EndIf
EndProcedure

Procedure Open_Window_Prog()
  If IsGadget(#Image_Logo) : FreeGadget(#Image_Logo) : EndIf
  If IsGadget(#Text_0) : FreeGadget(#Text_0) : EndIf
  If IsGadget(#Text_Path) : FreeGadget(#Text_Path) : EndIf
  If IsGadget(#Button_Start) : FreeGadget(#Button_Start) : EndIf
  If IsGadget(#Button_Path) : FreeGadget(#Button_Path) : EndIf
  ImageGadget(#Image_Progress, 137, 90, 130, 130, Image1)
  ProgressBarGadget(#ProgressBar_Progress, 105, 250, 190, 10, 0, 10, #PB_ProgressBar_Smooth)
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
  Frame3DGadget(#fTop ,225, 260, 1, 80, "", #PB_Frame3D_Single)
EndProcedure

Procedure Open_Window_Error()
  If IsGadget(#Image_Progress) : FreeGadget(#Image_Progress) : EndIf
  If IsGadget(#ProgressBar_Progress) : FreeGadget(#ProgressBar_Progress) : EndIf
  SetWindowColor(#Window, -1)
  TextGadget(#Text_1, 75, 125, 250, 25, "Установка прервана!", #PB_Text_Center)
    SetGadgetFont(#Text_1, LoadFont(7, "Arial", 12))
  TextGadget(#Text_Error, 20, 170, 360, 100, "", #PB_Text_Center)
  Frame3DGadget(#fTex, 10, 155, 375, 120, "Причина:")
  ButtonGadget(#Button_Exit, 250, 285, 130, 35, "Выход", #PB_Button_Default)
    SetGadgetFont(#Button_Exit, LoadFont(3, "Arial", 13))
EndProcedure
;}

;{ ПРОЦЕДУРА ДЛЯ СОЗДАНИЯ ЯРЛЫКОВ
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

;{ ПРОЦЕДУРА ДЛЯ ОПРЕДЕЛЕНИЯ РАСПОЛОЖЕНИЯ СИСТЕМНЫХ КАТАЛОГОВ
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
;}

Procedure QuitSetup()
Protected.a Rez
 If Finish = 1 Or #IDYES = MessageRequester("Выход из программы установки" +#CH$ +#PROG_NAME, "Установка не завершена. Если Вы выйдете, программа не будет установлена." +#ST$ +"Вы действительно хотите прервать установку программы" +#ST$ +#PROG_NAME +"?", #MB_YESNO|#MB_ICONQUESTION)
   WindowScene = 1
 EndIf
EndProcedure

Procedure Activate()
Path.s="C:\Kubik3\"
Open_Window_Start()
 Repeat
   Event = WaitWindowEvent(100)
   GadgetID = EventGadget()
   Select Event
     Case #PB_Event_Gadget
     Select GadgetID
       Case #Button_Start ; Условие будет выполнено при щелчке по кнопке УСТАНОВИТЬ.
         Open_Window_Prog()
         CreateDirectory(Path)
         If FileSize(Path) = -2 ; Папка существует
           ExtractArchive(Path)
         Else : Error("Укажите корректный путь к месту распаковки файлов!") ;MessageRequester("", "Укажите корректный путь к месту распаковки файлов!", #MB_OK|#MB_ICONWARNING) : Open_Window_Start()
         EndIf
         If noerror=1 : Open_Window_Final() : EndIf
         Finish = 1
       Case #Button_Path ; Условие будет выполнено при щелчке по кнопке ...
         TempPath.s=PathRequester("Выберите путь установки:",Path)
         If TempPath<>"" : Path = TempPath : SetGadgetText(#Text_Path, Path) : EndIf
       Case #Button_Exit
         If noerror = 1
           If 1=GetGadgetState(#CheckBox_Desktop)
             desktop$ = GetSysFolder(0)
             CreateShortcut_all(""+Path.s+"\Kubik_Start.exe",""+desktop$+"Kubik.lnk","","Нужен Фидонет? Жми сюда!",""+Path.s+"",#SW_SHOWNORMAL,"",0)
           EndIf
           If 1=GetGadgetState(#CheckBox_Menu_Start)
             menu_start$ = GetSysFolder(2)
             CreateShortcut_all(""+Path.s+"\Kubik_Start.exe",""+menu_start$+"Kubik.lnk","","Нужен Фидонет? Жми сюда!",""+Path.s+"",#SW_SHOWNORMAL,"",0)
           EndIf
           If 1=GetGadgetState(#CheckBox_Run_KStart)
             RunProgram(""+Path.s+"\Kubik_Start.exe","",""+Path.s+"")
           EndIf
           If 1=GetGadgetState(#CheckBox_Web_Site)
             RunProgram("http://kubik-fido.blogspot.com/")
           EndIf
         EndIf
         WindowScene = 1
       EndSelect
     Case #PB_Event_CloseWindow
       QuitSetup()
   EndSelect
 Until WindowScene = 1
EndProcedure

Activate()
End
; IDE Options = PureBasic 4.61 (Windows - x86)
; CursorPosition = 49
; Folding = 2-q-
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
; VersionField6 = IP РїРѕРёРЅС‚-РєРѕРјРїР»РµРєС‚ РґР»СЏ СЂР°Р±РѕС‚С‹ РІ СЃРµС‚Рё Р¤РёРґРѕ.
; VersionField7 = Kubik
; VersionField8 = Kubik_Modern_3.0.92.6RC.exe
; VersionField9 = (C) Kubik Project 2010-2013
; VersionField14 = http://kubik-fido.blogspot.com/
; VersionField17 = 0419 Russian
; VersionField18 = Fido:
; VersionField21 = 2:5020/2140.140