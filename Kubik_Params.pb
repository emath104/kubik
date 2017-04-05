; Kubik Params. ������� ��� �������� ������������ ����� � ������. ������ ��������� ������������ �����-���������.
; ������ 2
; (�) 2012-2017 ragweed
; PureBasic 5.31

;-
#Test_AlwaysFixConfigs = 1

; ����� ���� ��������� ���?

; ��� ����������� LoadConfig() � SaveConfig() �� ������ Kubik_Include
IncludeFile "Kubik_Include.pbi"

; ������� ������������ �����-���������
Global CurrentKubikPath.s

; ������� ������������ �������� ��� �����-���������
Global CurrentFidoPath.s

; ������� ������������ �����-��������� � ������� 8.3
Global CurrentKubikShortPath.s

; ������� ������������ �������� ��� �����-��������� � ������� 8.3
Global CurrentFidoShortPath.s

; ������ ������������ �����-��������� � ������� 8.3
Global OldKubikShortPath.s

; ������ ������������ �������� ��� �����-��������� � ������� 8.3
Global OldFidoShortPath.s

; ������ ����������� ��������� � ���������������� ����
; ����� 1 � ������ ������, ����� 0
Procedure FixConfig(config_path.s) 
  text.s = ""
  If OpenFile(0, config_path.s) ; ���� ������ ��� ������ � ������.
    size = Lof(0)
    
    If size > 0
      text.s = Space(size)
      ReadData(0, @text, size)
      
      ; ��� ������� binkd
      OldBinkdFidoDosFolder.s=ReplaceString(OldFidoShortPath.s, "\", "\\")
      NewBinkdFidoDosFolder.s=ReplaceString(CurrentFidoShortPath.s, "\", "\\")
      
      text.s = ReplaceString(Text, OldKubikShortPath.s, CurrentKubikShortPath.s)
      If Config\Path\AltFidoPath <> 1
        text.s = ReplaceString(text.s, OldFidoShortPath.s, CurrentFidoShortPath.s)
        text.s = ReplaceString(text.s, OldBinkdFidoDosFolder.s, NewBinkdFidoDosFolder.s)
      EndIf
      
      FileSeek(0,0)
      TruncateFile(0)
      WriteString(0, text.s)
    EndIf
    
    CloseFile(0)
    ProcedureReturn 1
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

Debug "����� Kubik Params."

; ��������� ������ Kubik_Set.ini, ���� ��� �� ������� - ��� ������ ���������� ������
If LoadConfig("Kubik_Set.ini", 1)
  
  Debug "Kubik_Set.ini ������."
  
  ; ���������, ��� �� Kubik_Params �������� � ������. ����� (Config\Start\Params)
  If Config\Start\Params = 1
    
    Debug "������������ �����-���������, ������ �� Kubik_Set.ini - '" + Config\Path\KubikFolder + "'"
    
    ; �������� ������� ������������ �����-���������
    CurrentKubikPath.s = GetCurrentDirectory() 
    Debug "������� ������������ �����-��������� - '" + CurrentKubikPath.s + "'"
    
    ; �������� ���� �� �����-��������� � ������e 8.3
    CurrentKubikShortPath.s = GetShortFileName(CurrentKubikPath.s)
    Debug "������� ������������ �����-��������� (8.3) - '" + CurrentKubikShortPath.s + "'"
    
    ; ������� ������ ������������ (�� ������� Kubik_Set.ini) � ��������
    ; ���� �� ���������, ������ ����� �� ���� �������� �������� ������ ���� �� �����
    ; ����� ������ Kubik Params ���������
    If Config\Path\KubikFolder <> CurrentKubikPath.s Or #Test_AlwaysFixConfigs = 1
      
      Debug "���� � ������. ����� ���������� �� ������������ �����-���������. Kubik Params �������� ���� ������."
      
      ; ���������� ������ ������ �����, ������� �� ����� ������ �� �����
      OldKubikShortPath.s = GetShortFileName(Config\Path\KubikFolder) ;- ������ ����������������� �����-���������.
      
      ; ���������, Config\Path\AltFidoPath = 1 ��������, ��� ������������ �������� ��� (����� fido\) ������ ������������� �������
      ; ������ �� ������������ ������ ���������������� � ���� ��� �� �������, �� �������, ��� ��� � �������� ������ �� ���������� ������ 
      ; Kubik Params ����� ���� ������ ���������� ����������� - �� ���� ���� �� �� ������ � ����. ���������� � �������� ��� ������������ 
      ; Kubik SSetting
      If Config\Path\AltFidoPath = 0
        OldFidoShortPath.s = GetShortFileName(Config\Path\FidoFolder)
        CurrentFidoShortPath.s = GetShortFileName(CurrentKubikPath.s) + "fido\"
        CurrentFidoPath.s    = CurrentKubikPath.s + "fido\"
      Else
        Debug "���� �� �������� ��� �� ����� �������� � ������. ������ (Config\Path\AltFidoPath = 1)."
        OldFidoShortPath.s = GetShortFileName(Config\Path\FidoFolder)
        CurrentFidoShortPath.s = GetShortFileName(Config\Path\FidoFolder)
        CurrentFidoPath.s    = Config\Path\FidoFolder
      EndIf
      
      Debug "������� ������������ �������� ���� �����-��������� - '" + CurrentFidoPath.s + "'"
      Debug "������� ������������ �������� ���� �����-��������� (8.3) - '" + CurrentFidoShortPath.s + "'"
      
      Debug "�����, ����� ����. ����� ���������� ������� (��������� 'templates\Config_List.ini')."
      ; ��������� Config_List.ini, ����� ������ - ����� ������. ����� ����� �������
      If OpenPreferences("templates\Config_List.ini")
        ; ���������� ����� ����� templates\
        If ExamineDirectory(0, "templates\", "*.template")
          While NextDirectoryEntry(0)
            If DirectoryEntryType(0) = #PB_DirectoryEntry_File
              config_path.s = ReadPreferenceString(DirectoryEntryName(0), "")
              If config_path.s <> ""
                ; ��������� ��������� ���������� ������ ���� � ����������� ���������������� ����
                Debug "����� ��������� � '" + config_path.s + "'."
                If Not FixConfig(config_path.s)
                  Debug "������ ��� �������� ��������� � '" + config_path.s + "' ���������� ����� �������."
                  Break
                EndIf
              EndIf
            EndIf
          Wend
          FinishDirectory(0)
          
          ; ��������� ����� ���� � Kubik_Set.ini
          Config\Path\KubikFolder = CurrentKubikPath.s
          Config\Path\FidoFolder  = CurrentFidoPath.s
          SaveConfig("Kubik_Set.ini")
        Else
          Debug "� ���� ���������� ������� �� 'templates\'?. ���������� ����� �������."
        EndIf
      Else
        Debug "����������� 'templates\Config_List.ini'. ���������� ����� �������."
      EndIf
    Else
      Debug "������������ �����-��������� �� ����������. ������ Kubik Params �� ���������."
    EndIf
  Else
    Debug "Kubik Params �������� �� ������ ������. �����. ���������� ����� �������."
  EndIf
Else
  Debug "������. ���� 'Kubik_Set.ini' �� ������. ���������� ����� �������."
EndIf

Debug "Kubik Params ��������� ���� ������."
; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 110
; FirstLine = 71
; Folding = +
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
; VersionField6 = Р В РЎв„ўР В РЎвЂўР В РЎВР В РЎвЂ”Р В РЎвЂўР В Р вЂ¦Р В Р’ВµР В Р вЂ¦Р РЋРІР‚С™ Kubik Modern
; VersionField7 = Kubik Params
; VersionField8 = Kubik_Params.exe
; VersionField9 = (Р В Р Р‹) 2012 Kubik Project
; VersionField13 = de.j.rabbit@gmail.com
; VersionField14 = http://kubik-fido.blogspot.com/
; VersionField17 = 0419 Russian
; VersionField18 = Fido:
; VersionField19 = Blog
; VersionField21 = 2:5020/2140.140
; VersionField22 = http://kubik-fido.blogspot.com/