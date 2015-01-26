; Kubik Start. ��������� ��� ����� 3 ������.
; ������ 2,0
; (�) 2013 ��140 ��� Kubik Project.
; ����� ���������� 4,51 \ 4,61.

IncludeFile "Kubik_Include_CFGS.pb" ; ���������� ���� � ��������� ������/�������������� ��������.

;{ ���������
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

Procedure HideRunProgram(Name.s) ; ��������� %Name.s,% ���������� KubikStart, � ������������ ��� ������� ����� �������� %Name.s%.
  SetWindowState(#Window, #PB_Window_Minimize) ; ����������� KubikStart.
  HideWindow(#Window, 1) ; �������� KubikStart.
  RunProgram(Name, "", "", #PB_Program_Wait) ; ��������� %Name.s% � ��� � ����������.
  HideWindow(#Window, 0) ; ��������� KubikStart.
  SetWindowState(#Window, #PB_Window_Normal) ; ������������� KubikStart.
EndProcedure

Procedure Menu() ; ��������� ���� � KubikStart (������� ���!)
  If CreatePopupMenu(#Menu) ; ����������, ��������� ����.
    ;If AltFidoPath=1 ; ���� � Kubik_Set.ini ������ �������������� ������������ ��� �������� ���, ��...
    ;  FidoFolder=AlterFidoPath ; ...����� fido ������������ � %AlterFidoPath%
    ;EndIf
    MenuItem(#ButtonImage_Editor, "�������� ��������")
      AddKeyboardShortcut(#Window, #PB_Shortcut_F2, #ButtonImage_Editor)
    MenuBar() 
    MenuItem(#MenuItem_Extensions, "���������� ����������")
    MenuBar() 
    MenuItem(#MenuItem_OpenKubikFolder, "������� ����� "+KubikFolder+"")
    MenuItem(#MenuItem_OpenFidoFolder, "������� ����� "+FidoFolder+"")
    MenuBar() 
    MenuItem(#MenuItem_OpenSSetting, "��������� �/�")
    MenuBar() 
    MenuItem(#MenuItem_OpenReadMe, "�������� �����-���������")
    MenuItem(#MenuItem_OpenHelp, "�������")
  ; MenuItem(#MenuItem_OpenWebSite, "���-���� �������")
    MenuItem(#MenuItem_OpenBlog, "���� �������")
    MenuBar()
    MenuItem(#MenuItem_Exit, "�����")
  EndIf

  
  
EndProcedure

Procedure Window() ; ������ ���� KubikStart (������� ���!)
  If Skinwinname=1 : title.s=winnameskin.s : Else : title.s=WinName.s : EndIf ; ���� Skinwinname=1, �� ���� �������� ���� �� ����� �������� ����� (description.ini), ���� ���, �� �� Kubik_Set.ini
  
  If OpenWindow(#Window, x, y, W, H, title.s,  #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_TitleBar | #PB_Window_Invisible)  
    
  
    
  SetWindowColor(#Window, RGB(R, G, B)); ����� ���� ����.
  
  If logo=1 ; ���� � ����� ���� �������, ��...
    LoadImage(0, ""+SkinFold.s+"\"+name.s+"\logo.png") ; ��������� ���� ������.
    ImageGadget(#Image_0, i1x, i1y, i1w, i1h, ImageID(0)) ; ��������� ����������� �� ����.
  EndIf
     
  If image=1 ; ���� � ����� ���� �������������� ������������, ��...
    LoadImage(1, ""+SkinFold.s+"\"+name.s+"\image.png") ; ��������� ��������������� �����������.
    ImageGadget(#Image_1, i2x, i2y, i2w, i2h, ImageID(1)) ; ��������� ����������� �� ����.
  EndIf
  
  If AnimateWindow=1 ; ���� � Kubik_Set.ini ���������� ������� ��������� ���, ��...
    AnimateWindow_(WindowID(#Window),AniSpOpen,#AW_BLEND|#AW_ACTIVATE) ; ������� ��������� ����.
  Else
    HideWindow(#Window, 0) ; ������ ���������� ������� ����.
  EndIf
    
  If LoadImage(2, ""+SkinFold.s+"\"+name.s+"\editor.png") ; ��������� ������ "������ �����".  
    ButtonImageGadget(#ButtonImage_Editor, B1X, B1Y, B1W, B1H, ImageID(2)) ; ������ ������ � ���� �������.
    GadgetToolTip(#ButtonImage_Editor, "������ �����") ; ��������� ����������� ����������� � ������.
  EndIf
      
  If LoadImage(3, ""+SkinFold.s+"\"+name.s+"\send.png") ; ��������� ������ "��������� ����� � �������".  
    ButtonImageGadget(#ButtonImage_Send, B2X, B2Y, B2W, B2H, ImageID(3))
    GadgetToolTip(#ButtonImage_Send, "��������� ����� � �������")
  EndIf
      
  If tools=1 ; ���� � description.ini ���������� �������������� ������, ��...
    If LoadImage(4, ""+SkinFold.s+"\"+name.s+"\help.png") ; ��������� ������ "���������� ��������".  
      ButtonImageGadget(#ButtonImage_Help, B3X, B3Y, B3W, B3H, ImageID(4))
      GadgetToolTip(#ButtonImage_Help, "���������� ��������")
    EndIf
      
    If LoadImage(5, ""+SkinFold.s+"\"+name.s+"\folder.png") ; ��������� ������ "������� ����� \Kubik\".  
      ButtonImageGadget(#ButtonImage_KubikFolder, B4X, B4Y, B4W, B4H, ImageID(5))
      GadgetToolTip(#ButtonImage_KubikFolder, "������� ����� \Kubik\")
    EndIf
    
    If LoadImage(6, ""+SkinFold.s+"\"+name.s+"\set.png") ; ��������� ������ "��������� �����-���������".  
      ButtonImageGadget(#ButtonImage_SSetting, B5X, B5Y, B5W, B5H, ImageID(6))
      GadgetToolTip(#ButtonImage_SSetting, "��������� �����-���������")
    EndIf
  EndIf
      
  If LoadImage(7, ""+SkinFold.s+"\"+name.s+"\menu.png") ; ��������� ������ "����".  
    ButtonImageGadget(#ButtonImage_Menu, B6X, B6Y, B6W, B6H, ImageID(7))
    GadgetToolTip(#ButtonImage_Menu, "����")
  EndIf
EndIf
EndProcedure  

Procedure Main() ; ����������, ���� ���������. ������ ������ Main()! � ��� End, �� ����� ^_^
 KubikSetting("Read") ; ��������� ���������� �� ����������������� ����� Kubik_Set.ini (��. Kubik_Include_CFGS.pb).

 If Ssetting=1 ; �� ��� ���, ���� Ssetting=1, �� ������ ����������� ����������� �������������� 
   RunProgram(Set, "", "", #PB_Program_Wait)
   KubikSetting("Read") ; �������� ��������� ���������� �� ����������������� ����� Kubik_Set.ini
   If Ssetting=1 : End : EndIf ; ���� Ssetting �� �������� =1, �� ��������� �����.
 EndIf  
   
 If Params=1 ; ���� Params=1, �� ����������� Kubik_Params.exe
   If RunProgram("Kubik_Params.exe", "", "", #PB_Program_Wait) : Debug "Kubik_Params.exe �������!" : KubikSetting("Read")
   Else : MessageRequester("������","�� ������� ��������� Kubik_Params.exe!", 16)
   EndIf
 Else : Debug "Kubik_Params.exe �� �������!"
 EndIf 
 
 UsePNGImageDecoder() ; �������� ��������� ������� PNG.
 LoadSkin() ; ��������� �������� ���������� ��� ���� #Window (��. Kubik_Include_CFGS.pb).
 Window() ; ��� �������, ��� ��� �� ��������� ��������� Window().
 Menu() ; �� ������ ��� ��� - ������ � ����!
 
 Repeat ; �������� ���� ���������.
   Event = WaitWindowEvent()
     Select Event ; �������� ��������� ������ ��� �������� � ����������� �� WaitWindowEvent().
       Case #WM_RBUTTONDOWN ; ���� �� ���� ������ ������� ����.
         DisplayPopupMenu(#Menu, WindowID(0)) ; ���������� ����.
       Case #PB_Event_Gadget ; ���� �� ������-�� ������� (������, �������� %)).
         Select EventGadget() ; �������� ��������� ������ ��� �������� � ����������� �� EventGadget().
           Case #ButtonImage_Editor : OpenConsole() : HideRunProgram(Editor) : CloseConsole() ; ������� ����� ��������� ��� ������ �� ������ ������ �����.
           Case #ButtonImage_Send : OpenConsole() :  RunProgram(Send, "", "") : CloseConsole() ; ������� ����� ��������� ��� ������ �� ������ ��������.
           Case #ButtonImage_Help : RunProgram(Help, "", "") : Debug "����" ; ������� ����� ��������� ��� ������ �� ������ �������.
           Case #ButtonImage_KubikFolder : RunProgram(KubikFolder, "", "") ; ������� ����� ��������� ��� ������ �� ������ �����.
           Case #ButtonImage_Menu : DisplayPopupMenu(#Menu, WindowID(0)) ; ������� ����� ��������� ��� ������ �� ������ ����.
           Case #ButtonImage_SSetting : HideRunProgram(Set); ������� ����� ��������� ��� ������ �� ������ ���������.
         EndSelect
       Case #PB_Event_Menu
         Select EventMenu() ; �������� ��������� ������ ��� �������� � ����������� �� EventMenu().
           Case #ButtonImage_Editor : OpenConsole() : HideRunProgram(Editor) : CloseConsole() ; ������� ����� ��������� ��� ������ �� ������ ������ �����.  
           Case #MenuItem_OpenKubikFolder : RunProgram("explorer.exe", "/root, �:\", "") ; ���� ������, ������� ���������� �� ����������, ��� ����������� ^_^ 
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
   Until Event = #PB_Event_CloseWindow ; ���� ���� ����� ������� - ����� �� �����.
   x = WindowX(0) ; ���������� ������� ���� �� ��� X.
   y = WindowY(0) ; ���������� ������� ���� �� ��� Y.
   KubikSetting("Write") ; ���������� �������� ���������� � Kubik_Set.ini (��. Kubik_Include_CFGS.pb).
   If AnimateWindow=1 : AnimateWindow_(WindowID(#Window),AniSpClose,#AW_BLEND|#AW_HIDE) : EndIf ; ���� AnimateWindow=1, �� ���� ������ ��������...
EndProcedure

Main() ; ������� ;)
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
; VersionField6 = Запускатор для Kubik Modern
; VersionField7 = Kubik Start
; VersionField8 = Kubik_Start.exe
; VersionField9 = (С) 2013 Kubik Project
; VersionField13 = de.j.rabbit@gmail.com
; VersionField14 = http://kubik-fido.blogspot.com/
; VersionField17 = 0419 Russian
; VersionField18 = Fido:
; VersionField19 = Blog
; VersionField21 = 2:5020/2140.140
; VersionField22 = http://kubik-fido.blogspot.com/