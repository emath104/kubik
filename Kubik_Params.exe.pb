IncludeFile "Kubik_Include_CFGS.pb"

Global NewKubikFolder.s, NewKubikDosFolder.s, OldKubikDosFolder.s, OldFidoDosFolder.s, OldBinkdFidoDosFolder.s,  NewFidoDosFolder.s, NewBinkdFidoDosFolder.s

Procedure EditConf2(Path$,  OldKubikPath$,  OldFidoPath$,  OldBinkdFidoPath$, KubikPath$, FidoPath$, BinkdFidoPath$)
     Text.s=""
    If OpenFile(0, Path$) ; ���� ������ ��� ������ � ������.
      Size=Lof(0) 
       If Size>0 ; ���� �� ������.
         Text = Space(Size) ; ����� ��� ������ �����.
         ReadData(0, @Text, Size) ; ��������� ������.
           Text=ReplaceString(Text, ""+OldKubikPath$+"", ""+KubikPath$+"")
           If AltFidoPath<>1
             Text=ReplaceString(Text, ""+OldFidoPath$+"", ""+FidoPath$+"")
             Text=ReplaceString(Text, ""+OldBinkdFidoPath$+"", ""+BinkdFidoPath$+"")
           EndIf
         FileSeek(0,0)    ; ������� � ������ �����
         TruncateFile(0)  ; � ������ ��� �������.
         WriteString(0,Text)
       EndIf
      CloseFile(0)
    Else
      MessageRequester("������","�� ������� ������� ���� "+Path$+"!", 16)
    EndIf
EndProcedure

Procedure.s GetShortFileName ( Long.s ) ; ������� �� ��������� �������� http://purebasic.mybb.ru/viewtopic.php?id=361
  Short.s = Long 
  GetShortPathName_ ( @Long, @Short, Len(Short) ) 
  ProcedureReturn Short 
EndProcedure 

Procedure EditConf(Path.s)
     Text.s=""
    If OpenFile(0, Path) ; ���� ������ ��� ������ � ������.
      Size=Lof(0) 
       If Size>0 ; ���� �� ������.
         Text = Space(Size) ; ����� ��� ������ �����.
         ReadData(0, @Text, Size) ; ��������� ������.
           Text=ReplaceString(Text, OldKubikDosFolder, ""+NewKubikDosFolder+"")
           If AltFidoPath<>1
             Text=ReplaceString(Text, OldFidoDosFolder, ""+NewFidoDosFolder+"")
             Text=ReplaceString(Text, OldBinkdFidoDosFolder, ""+NewBinkdFidoDosFolder+"")
           EndIf
         FileSeek(0,0)    ; ������� � ������ �����
         TruncateFile(0)  ; � ������ ��� �������.
         WriteString(0,Text)
       EndIf
      CloseFile(0)
    Else
      MessageRequester("������","�� ������� ������� ���� "+Path$+"!", 16)
    EndIf
EndProcedure

KubikSetting("Read") ; ��������� ��������� ������ ���������� �� ������� Kubik_Set.ini.

NewKubikFolder.s = GetCurrentDirectory() ; �������� ���� �� �����-���������.
NewKubikDosFolder.s = GetShortFileName (NewKubikFolder.s); �������� ���� �� �����-��������� � ������� DOS 8.3.

If KubikFolder<>NewKubikFolder.s ; ������� ������ ������������ (�� ������� Kubik_Set.ini) � ��������.
  ; ���� �� ���������, ��...
  ; ���������� ������ ������ �����, ������� �� ����� ������ �� �����:
  OldKubikDosFolder.s=KubikFolderDos ; ������ ����������������� �����-���������.
  
  If AltFidoPath = 0
    OldFidoDosFolder.s=FidoFolderDos
    NewFidoDosFolder.s=""+GetShortFileName (NewKubikDosFolder)+"fido\"
    NewFidoFolder.s=""+NewKubikFolder+"fido\"
  Else
    OldFidoDosFolder.s=KubikFolderDos ; ������ ����������������� �������� ��� �����-���������.
    NewFidoDosFolder.s=FidoFolderDos ; ����� ����������������� �������� ��� �����-���������.
    NewFidoFolder.s=FidoFolder
  EndIf
  
  OldBinkdFidoDosFolder.s=ReplaceString(OldFidoDosFolder, "\", "\\") ; ������ ����������������� �������� ��� �����-��������� ��� ������� binkd.
  NewBinkdFidoDosFolder.s=ReplaceString(NewFidoDosFolder, "\", "\\") ; ����� ����������������� �������� ��� �����-��������� ��� ������� binkd.
  
  ; ��������� ��������� ���������� ������ ���� � ����������� ���������������� ����.
  EditConf("binkd\binkd.cfg")
  EditConf("husky\husky.cfg")
  EditConf("SimpleX-0.49\config.ini")
  EditConf("GoldED+1.1.5\golded.cfg")
  EditConf("GoldED+1.1.5\ge.bat")
  ; ��������� ����� ���� � ������ ������.
  KubikFolder=NewKubikFolder
  FidoFolder=NewFidoFolder
  KubikFolderDos=NewKubikDosFolder
  FidoFolderDos=NewFidoDosFolder
  KubikSetting("Write")
EndIf 

; ����� ;)
; IDE Options = PureBasic 5.30 (Windows - x86)
; Folding = 6
; EnableXP
; UseIcon = icons\32x32\params.ico
; Executable = Kubik_Params.exe
; IncludeVersionInfo
; VersionField0 = 4,0,0,3
; VersionField1 = 4,0,0,3
; VersionField2 = Kubik Project
; VersionField3 = Kubik
; VersionField4 = 4
; VersionField5 = 4
; VersionField6 = Компонент Kubik Modern
; VersionField7 = Kubik Params
; VersionField8 = Kubik_Params.exe
; VersionField9 = (С) 2012 Kubik Project
; VersionField13 = de.j.rabbit@gmail.com
; VersionField14 = http://kubik-fido.blogspot.com/
; VersionField17 = 0419 Russian
; VersionField18 = Fido:
; VersionField19 = Blog
; VersionField21 = 2:5020/2140.140
; VersionField22 = http://kubik-fido.blogspot.com/