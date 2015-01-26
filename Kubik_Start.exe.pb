; Kubik Start. Компонент для Кубик 3 Модерн.
; Версия 2,0
; (С) 2013 ЕМ140 для Kubik Project.
; Пурик Бейсиковый 4,51 \ 4,61.

IncludeFile "Kubik_Include_CFGS.pb" ; Подключаем файл с функциями чтения/редактирования конфигов.

;{ Константы
Enumeration
  #Window
  #Image_0
  #Image_1
  #ButtonImage_Editor
  #ButtonImage_Send
  #ButtonImage_Help
  #ButtonImage_KubikFolder
  #ButtonImage_SSetting
  #ButtonImage_Menu
  #Menu
  #MenuItem_Extensions
  #MenuItem_OpenKubikFolder
  #MenuItem_OpenFidoFolder
  #MenuItem_OpenSSetting
  #MenuItem_OpenReadMe
  #MenuItem_OpenHelp
  #MenuItem_OpenWebSite
  #MenuItem_OpenBlog
  #MenuItem_Exit
EndEnumeration
;}

Procedure HideRunProgram(Name.s) ; Запускает %Name.s,% сворачивая KubikStart, и разворачивая его обратно после закрытия %Name.s%.
  SetWindowState(#Window, #PB_Window_Minimize) ; Сворачиваем KubikStart.
  HideWindow(#Window, 1) ; Скрываем KubikStart.
  RunProgram(Name, "", "", #PB_Program_Wait) ; Запускаем %Name.s% и ждём её завершения.
  HideWindow(#Window, 0) ; Возращаем KubikStart.
  SetWindowState(#Window, #PB_Window_Normal) ; Разворачиваем KubikStart.
EndProcedure

Procedure Menu() ; Добавляет меню к KubikStart (спасибо КЭП!)
  If CreatePopupMenu(#Menu) ; Собственно, добавляем меню.
    ;If AltFidoPath=1 ; Если в Kubik_Set.ini указан альтернативное расположение для почтовых баз, то...
    ;  FidoFolder=AlterFidoPath ; ...папка fido расположенна в %AlterFidoPath%
    ;EndIf
    MenuItem(#ButtonImage_Editor, "Почтовый редактор")
      AddKeyboardShortcut(#Window, #PB_Shortcut_F2, #ButtonImage_Editor)
    MenuBar() 
    MenuItem(#MenuItem_Extensions, "Установить дополнения")
    MenuBar() 
    MenuItem(#MenuItem_OpenKubikFolder, "Открыть папку "+KubikFolder+"")
    MenuItem(#MenuItem_OpenFidoFolder, "Открыть папку "+FidoFolder+"")
    MenuBar() 
    MenuItem(#MenuItem_OpenSSetting, "Настройка п/к")
    MenuBar() 
    MenuItem(#MenuItem_OpenReadMe, "Описание поинт-комплекта")
    MenuItem(#MenuItem_OpenHelp, "Справка")
  ; MenuItem(#MenuItem_OpenWebSite, "Веб-сайт проекта")
    MenuItem(#MenuItem_OpenBlog, "Блог проекта")
    MenuBar()
    MenuItem(#MenuItem_Exit, "Выход")
  EndIf

  
  
EndProcedure

Procedure Window() ; Создаёт окно KubikStart (спасибо КЭП!)
  If Skinwinname=1 : title.s=winnameskin.s : Else : title.s=WinName.s : EndIf ; Если Skinwinname=1, то берём название окна из файла описания скина (description.ini), если нет, то из Kubik_Set.ini
  
  If OpenWindow(#Window, x, y, W, H, title.s,  #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_TitleBar | #PB_Window_Invisible)  
    
  
    
  SetWindowColor(#Window, RGB(R, G, B)); Задаём цвет окна.
  
  If logo=1 ; Если в скине есть логотип, то...
    LoadImage(0, ""+SkinFold.s+"\"+name.s+"\logo.png") ; Загружаем лого Рубика.
    ImageGadget(#Image_0, i1x, i1y, i1w, i1h, ImageID(0)) ; Добавляем изображение на окно.
  EndIf
     
  If image=1 ; Если в скине есть дополнительное расположение, то...
    LoadImage(1, ""+SkinFold.s+"\"+name.s+"\image.png") ; Загружаем долполнительное изображение.
    ImageGadget(#Image_1, i2x, i2y, i2w, i2h, ImageID(1)) ; Добавляем изображение на окно.
  EndIf
  
  If AnimateWindow=1 ; Если в Kubik_Set.ini разрешенно плавное появление она, то...
    AnimateWindow_(WindowID(#Window),AniSpOpen,#AW_BLEND|#AW_ACTIVATE) ; Плавное появление окна.
  Else
    HideWindow(#Window, 0) ; Просто отображаем скрытое окно.
  EndIf
    
  If LoadImage(2, ""+SkinFold.s+"\"+name.s+"\editor.png") ; Загружаем иконку "Чтение почты".  
    ButtonImageGadget(#ButtonImage_Editor, B1X, B1Y, B1W, B1H, ImageID(2)) ; Создаём кнопку с этой иконкой.
    GadgetToolTip(#ButtonImage_Editor, "Чтение почты") ; Добавляем всплывающий комментарий к кнопке.
  EndIf
      
  If LoadImage(3, ""+SkinFold.s+"\"+name.s+"\send.png") ; Загружаем иконку "Доставить почту в Фидонет".  
    ButtonImageGadget(#ButtonImage_Send, B2X, B2Y, B2W, B2H, ImageID(3))
    GadgetToolTip(#ButtonImage_Send, "Доставить почту в Фидонет")
  EndIf
      
  If tools=1 ; Если в description.ini разрешенны дополнительные кнопки, то...
    If LoadImage(4, ""+SkinFold.s+"\"+name.s+"\help.png") ; Загружаем иконку "Справочный материал".  
      ButtonImageGadget(#ButtonImage_Help, B3X, B3Y, B3W, B3H, ImageID(4))
      GadgetToolTip(#ButtonImage_Help, "Справочный материал")
    EndIf
      
    If LoadImage(5, ""+SkinFold.s+"\"+name.s+"\folder.png") ; Загружаем иконку "Открыть папку \Kubik\".  
      ButtonImageGadget(#ButtonImage_KubikFolder, B4X, B4Y, B4W, B4H, ImageID(5))
      GadgetToolTip(#ButtonImage_KubikFolder, "Открыть папку \Kubik\")
    EndIf
    
    If LoadImage(6, ""+SkinFold.s+"\"+name.s+"\set.png") ; Загружаем иконку "Настройка поинт-комплекта".  
      ButtonImageGadget(#ButtonImage_SSetting, B5X, B5Y, B5W, B5H, ImageID(6))
      GadgetToolTip(#ButtonImage_SSetting, "Настройка поинт-комплекта")
    EndIf
  EndIf
      
  If LoadImage(7, ""+SkinFold.s+"\"+name.s+"\menu.png") ; Загружаем иконку "Меню".  
    ButtonImageGadget(#ButtonImage_Menu, B6X, B6Y, B6W, B6H, ImageID(7))
    GadgetToolTip(#ButtonImage_Menu, "Меню")
  EndIf
EndIf
EndProcedure  

Procedure Main() ; Собственно, сама программа. Просто добавь Main()! А ещё End, по вкусу ^_^
 KubikSetting("Read") ; Считываем информацию из конфигурационного файла Kubik_Set.ini (см. Kubik_Include_CFGS.pb).

 If Ssetting=1 ; До тех пор, пока Ssetting=1, то вместо СтартСмарта запускается автонастройщик 
   RunProgram(Set, "", "", #PB_Program_Wait)
   KubikSetting("Read") ; Повторно считываем информацию из конфигурационного файла Kubik_Set.ini
   If Ssetting=1 : End : EndIf ; Если Ssetting по прежнему =1, то закрываем прогу.
 EndIf  
   
 If Params=1 ; Если Params=1, то запускается Kubik_Params.exe
   If RunProgram("Kubik_Params.exe", "", "", #PB_Program_Wait) : Debug "Kubik_Params.exe запущен!" : KubikSetting("Read")
   Else : MessageRequester("Ошибка","Не удалось запустить Kubik_Params.exe!", 16)
   EndIf
 Else : Debug "Kubik_Params.exe НЕ запущен!"
 EndIf 
 
 UsePNGImageDecoder() ; Включаем поддержку формата PNG.
 LoadSkin() ; Считываем значения переменных для окна #Window (см. Kubik_Include_CFGS.pb).
 Window() ; КЕП говорит, что это мы запускаем процедуру Window().
 Menu() ; Не знаешь что это - спроси у КЭПа!
 
 Repeat ; Основной цикл программы.
   Event = WaitWindowEvent()
     Select Event ; Проводим сравнение нужных нам значений с полученными из WaitWindowEvent().
       Case #WM_RBUTTONDOWN ; Клик по окну правой кнопкой мыши.
         DisplayPopupMenu(#Menu, WindowID(0)) ; Появляется меню.
       Case #PB_Event_Gadget ; Клик по какому-то гаджету (кнопке, например %)).
         Select EventGadget() ; Проводим сравнение нужных нам значений с полученными из EventGadget().
           Case #ButtonImage_Editor : OpenConsole() : HideRunProgram(Editor) : CloseConsole() ; Условие будет выполнено при щелчке по кнопке ЧТЕНИЕ ПОЧТЫ.
           Case #ButtonImage_Send : OpenConsole() :  RunProgram(Send, "", "") : CloseConsole() ; Условие будет выполнено при щелчке по кнопке ДОСТАВКА.
           Case #ButtonImage_Help : RunProgram(Help, "", "") : Debug "Хрен" ; Условие будет выполнено при щелчке по кнопке СПРАВКА.
           Case #ButtonImage_KubikFolder : RunProgram(KubikFolder, "", "") ; Условие будет выполнено при щелчке по кнопке ПАПКА.
           Case #ButtonImage_Menu : DisplayPopupMenu(#Menu, WindowID(0)) ; Условие будет выполнено при щелчке по кнопке МЕНЮ.
           Case #ButtonImage_SSetting : HideRunProgram(Set); Условие будет выполнено при щелчке по кнопке НАСТРОЙКА.
         EndSelect
       Case #PB_Event_Menu
         Select EventMenu() ; Проводим сравнение нужных нам значений с полученными из EventMenu().
           Case #ButtonImage_Editor : OpenConsole() : HideRunProgram(Editor) : CloseConsole() ; Условие будет выполнено при щелчке по кнопке ЧТЕНИЕ ПОЧТЫ.  
           Case #MenuItem_OpenKubikFolder : RunProgram("explorer.exe", "/root, С:\", "") ; Лень писать, вообщем посмотрите по константам, что запускается ^_^ 
           Case #MenuItem_OpenFidoFolder : RunProgram(FidoFolder, "", "")
           Case #MenuItem_OpenSSetting : HideRunProgram(Set);
           Case #MenuItem_OpenReadMe : RunProgram("readme.txt", "", "")
           Case #MenuItem_OpenHelp : RunProgram(Help, "", "")
           Case #MenuItem_OpenWebSite : RunProgram(Site, "", "")
           Case #MenuItem_OpenBlog : RunProgram(Blog, "", "") 
           Case #MenuItem_Exit : Event = #PB_Event_CloseWindow
           Case #MenuItem_Extensions : RunProgram(Extensions, "", "") 
         EndSelect
     EndSelect
   Until Event = #PB_Event_CloseWindow ; Если окно будет закрыто - выход из цикла.
   x = WindowX(0) ; Запоминаем позицию окна по оси X.
   y = WindowY(0) ; Запоминаем позицию окна по оси Y.
   KubikSetting("Write") ; Записываем значение переменных в Kubik_Set.ini (см. Kubik_Include_CFGS.pb).
   If AnimateWindow=1 : AnimateWindow_(WindowID(#Window),AniSpClose,#AW_BLEND|#AW_HIDE) : EndIf ; Если AnimateWindow=1, то окно плавно исчезает...
EndProcedure

Main() ; Поехали ;)
End ; Happy End.
; IDE Options = PureBasic 5.30 (Windows - x86)
; CursorPosition = 1
; Folding = 0
; EnableXP
; UseIcon = icons\128x128\fido.ico
; Executable = Kubik_Start.exe
; IncludeVersionInfo
; VersionField0 = 2,0,0,39
; VersionField1 = 2,0,0,39
; VersionField2 = Kubik Project
; VersionField3 = Kubik
; VersionField4 = 2
; VersionField5 = 2
; VersionField6 = Р—Р°РїСѓСЃРєР°С‚РѕСЂ РґР»СЏ Kubik Modern
; VersionField7 = Kubik Start
; VersionField8 = Kubik_Start.exe
; VersionField9 = (РЎ) 2013 Kubik Project
; VersionField13 = de.j.rabbit@gmail.com
; VersionField14 = http://kubik-fido.blogspot.com/
; VersionField17 = 0419 Russian
; VersionField18 = Fido:
; VersionField19 = Blog
; VersionField21 = 2:5020/2140.140
; VersionField22 = http://kubik-fido.blogspot.com/