; Kubik SSetting. ������������� �������� ��������� ����. ������ �������� � �����-�������� Kubik ����������.
; ������ 3.1
; (�) 2012-2016 ragweed
; PureBasic 5.31

IncludeFile "Kubik_Include_CFGS.pb"

;{ ��������� � ���������� ����������.
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
  #File_0
EndEnumeration
Global BinkdFidoFolderDos.s, FontID1 : FontID1 = LoadFont(1, "Arial", 10)
;}

Procedure Open_Window()
  If OpenWindow(#Window, 235, 142, 400, 350, "��������� �����-���������",  #PB_Window_SystemMenu | #PB_Window_SizeGadget | #PB_Window_TitleBar | #PB_Window_ScreenCentered)
    TextGadget(#Text_Info, 10, 20, 380, 30, "����� ���������� �����-��������� ����������� ������������ �� ���������� ����������.", #PB_Text_Center) 
    Frame3DGadget(#Frame3D, 30, 45, 340, 255, "")
    
    TextGadget(#Text_YourFullName, 45, 60, 155, 20, "���� ��� � �������:")
    SetGadgetFont(#Text_YourFullName, FontID1)
    StringGadget(#String_YourFullName, 215, 60, 145, 20, FullName)
    
    TextGadget(#Text_UplinkName, 45, 90, 155, 20, "��� � ������� �����:")
    SetGadgetFont(#Text_UplinkName, FontID1)
    StringGadget(#String_UplinkName, 215, 90, 145, 20, UplinkName)
    
    TextGadget(#Text_UplinkFTNAddress, 45, 120, 155, 20, "����� ����:")
    SetGadgetFont(#Text_UplinkFTNAddress, FontID1)
    StringGadget(#String_UplinkFTNAddress, 215, 120, 145, 20, FTNAddress)
    
    TextGadget(#Text_YourPointNomber, 45, 150, 155, 20, "��� �����-�����:")
    SetGadgetFont(#Text_YourPointNomber, FontID1)
    StringGadget(#String_YourPointNomber, 215, 150, 145, 20, PointAddress)
    
    TextGadget(#Text_YourLocation, 45, 180, 165, 20, "���� �����������������:")
    SetGadgetFont(#Text_YourLocation, FontID1)
    StringGadget(#String_YourLocation, 215, 180, 145, 20, Location)
    
    TextGadget(#Text_YourStationName, 45, 210, 155, 20, "�������� ����� �������:")
    SetGadgetFont(#Text_YourStationName, FontID1)
    StringGadget(#String_YourStationName, 215, 210, 145, 20, StationName)
    
    TextGadget(#Text_UplinkServerName, 45, 240, 155, 20, "DNS ����� ����:")
    SetGadgetFont(#Text_UplinkServerName, FontID1)
    StringGadget(#String_UplinkServerName, 215, 240, 145, 20, ServerName)
    
    TextGadget(#Text_Password, 45, 270, 155, 20, "������:")
    SetGadgetFont(#Text_Password, FontID1)
    StringGadget(#String_Password, 215, 270, 145, 20, Password, #PB_String_Password)
    
    ButtonGadget(#Button_Save, 30, 305, 130, 25, "���������", #PB_Button_Default)
    ButtonGadget(#Button_Help, 170, 305, 95, 25, "�������")
    ButtonGadget(#Button_Cancel, 275, 305, 95, 25, "������")
  EndIf
EndProcedure

Procedure ReadStrings() ; ��������� ��������� �������� �� �����.
  FullName=GetGadgetText(#String_YourFullName) ; �������� ��� �� ������.
  UplinkName=GetGadgetText(#String_UplinkName) ; �������� ��� ������ �� ������.
  FTNAddress=GetGadgetText(#String_UplinkFTNAddress) ; �������� ����� �� ������.
  PointAddress=GetGadgetText(#String_YourPointNomber) ; �������� ����� �� ������.
  StationName=GetGadgetText(#String_YourStationName) ; �������� ������ �� ������.
  Location=GetGadgetText(#String_YourLocation) ; �������� ������ �� ������.
  ServerName=GetGadgetText(#String_UplinkServerName) ; �������� DNS �� ������.
  Password=GetGadgetText(#String_Password) ; �������� ������ �� ������.
EndProcedure

Procedure.s GetShortFileName(Long.s) ; ������� �� ��������� �������� http://purebasic.mybb.ru/viewtopic.php?id=361
  Short.s = Long 
  GetShortPathName_ ( @Long, @Short, Len(Short) ) 
  ProcedureReturn Short 
EndProcedure 

Procedure CorrectPaths()
 KubikFolder.s = GetCurrentDirectory()
 KubikFolderDos.s = GetShortFileName(KubikFolder.s) ; ���������� ������� DOS ������������ �����-���������.
 ; ���������� ������� ������������ �������� ���.
 If AltFidoPath<>1 ; � kubik_set.ini �� ������ �������������� ���� �� �������� ���.
   FidoFolder=""+KubikFolder+"fido\"
   FidoFolderDos=""+KubikFolderDos+"fido\"
 Else ; ��, ���� �� ���� ������...
   FidoFolderDos = GetShortFileName(FidoFolder)
 EndIf
 BinkdFidoFolderDos.s=ReplaceString(FidoFolderDos, "\", "\\") ; �������� ������� :) .
EndProcedure 

Procedure EditFidoConf(TempPath.s, Path.s) ; ��������� ������ �� ������� (TempPath.s) ���������������� ���� (Path.s) � ��������� ����������� ���������.
  ; ��������� � ��������� ������ � %TempPath%.
  If CopyFile(TempPath, Path)
     Text.s=""
    If OpenFile(0, Path) ; ��������� ��� ������ � ������.
      Size=Lof(0) ; ���������� ������ �����.
       If Size>0 ; ���� �� ������.
         Text = Space(Size) ; ����� ��� ������ �����.
         ReadData(0, @Text, Size) ; ��������� ������.
         
           Text=ReplaceString(Text, "Vasiliy Pampasov", FullName); ���.
           Text=ReplaceString(Text, "Kirill Temnenkov", UplinkName); ��� ������.
           Text=ReplaceString(Text, "2:5020/XXX", FTNAddress); �����.
           Text=ReplaceString(Text, "2:5020/YYY.ZZZ", ""+FTNAddress+"."+PointAddress+""); �����.
           Text=ReplaceString(Text, "Moscow, Russia", Location); ������.
           Text=ReplaceString(Text, "temnenkov.dyndns.org", ServerName); DNS. 
           Text=ReplaceString(Text, "12345678", Password); ������.
        
           Text=ReplaceString(Text, "\KubikPath\", ""+KubikFolderDos+"") ; � ��������� ��� � �������.
           Text=ReplaceString(Text, "\FidoPath\", ""+FidoFolderDos+"")
           Text=ReplaceString(Text, "\\BinkdFidoPath\\", ""+BinkdFidoFolderDos.s+"")

         FileSeek(0,0)    ; ������� � ������ �����
         TruncateFile(0)  ; � ������ ��� �������.
         WriteString(0,Text) ; ��������� �������� ���������� text � ����.
       EndIf
      CloseFile(0)
    Else
      MessageRequester("������","�� ������� ������� ���� "+Path+"!", 16) : Error = 1
    EndIf
  Else 
    MessageRequester("������","�� ������� ����������� ���� "+TempPath+"!",16) : Error = 1
  EndIf
EndProcedure

KubikSetting("Read")
Open_Window()
Repeat
  Event = WaitWindowEvent()
  GadgetID = EventGadget()
  ;-If Sys<>2 ; ��������� ������� Kubik_Set.ini
  ;  MessageRequester("������","�� ������� ����� (��� �� ��������) Kubik_Set.ini", 16)
  ;  Event = #PB_Event_CloseWindow
  ;EndIf

  Select Event
    Case #PB_Event_Gadget
      Select GadgetID
        Case #Button_Save
          ReadStrings()
          CorrectPaths()
          EditFidoConf("templates\binkd.cfg.template", "binkd\binkd.cfg")
          EditFidoConf("templates\husky.cfg.template", "husky\husky.cfg")
          EditFidoConf("templates\config.ini.template", "SimpleX-0.49\config.ini")
          EditFidoConf("templates\golded.cfg.template", "GoldED+1.1.5\golded.cfg")
          EditFidoConf("templates\ge.bat.template", "GoldED+1.1.5\ge.bat")
          EditFidoConf("templates\send.xml.template", "extensions\sys\send.xml")
          If Error=0 : KubikSetting("Write"): MessageRequester("���������","��������� �����-��������� ����� ���������!") : End : EndIf
        Case #Button_Help : RunProgram(Help, "", "")
        Case #Button_Cancel : Break
      EndSelect
  EndSelect
Until Event = #PB_Event_CloseWindow
; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 149
; FirstLine = 61
; Folding = 5-
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
; VersionField6 = РљРѕРјРїРѕРЅРµРЅС‚ Kubik Modern
; VersionField7 = Kubik
; VersionField8 = Kubik_SSetting.exe
; VersionField9 = (РЎ) 2013 Kubik Project
; VersionField13 = de.j.rabbit@gmail.com
; VersionField14 = http://kubik-fido.blogspot.com/
; VersionField17 = 0419 Russian
; VersionField18 = Fido:
; VersionField21 = 2:5020/2140.140