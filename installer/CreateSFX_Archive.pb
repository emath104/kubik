Enumeration
  #Window_0
EndEnumeration

Enumeration
  #Text_0
  #String_0
  #Text_1
  #String_1
  #Text_2
  #Text_CurrentFiles
  #ProgressBar_FileProgress
  #Text_4
  #ProgressBar_AllProgress
  #Button_Archive
  #Button_1
  #Button_2
  #Text_5
  #String_Password
EndEnumeration

Procedure Open_Window_0()
  If OpenWindow(#Window_0, 344, 256, 334, 264, "�������� �������������������� ZIP",#PB_Window_MinimizeGadget|#PB_Window_Invisible|#PB_Window_ScreenCentered)
      TextGadget(#Text_0, 5, 5, 320, 15, "���� � ����� � �������:")
      StringGadget(#String_0, 5, 20, 290, 20, "", #PB_String_ReadOnly)
      TextGadget(#Text_1, 5, 55, 320, 15, "���� � ����� ���������� ������������ ������:")
      StringGadget(#String_1, 5, 70, 290, 20, "", #PB_String_ReadOnly)
      TextGadget(#Text_2, 5, 140, 100, 15, "��������� �����:")
      TextGadget(#Text_CurrentFiles, 105, 140, 220, 15, "")
      ProgressBarGadget(#ProgressBar_FileProgress, 5, 155, 320, 15, 0, 100, #PB_ProgressBar_Smooth)
      TextGadget(#Text_4, 5, 185, 150, 15, "����� ��������:")
      ProgressBarGadget(#ProgressBar_AllProgress, 5, 200, 320, 15, 0, 100, #PB_ProgressBar_Smooth)
      ButtonGadget(#Button_Archive, 80, 230, 190, 25, "������� SFX �����")
      ButtonGadget(#Button_1, 300, 20, 30, 20, "...")
      ButtonGadget(#Button_2, 300, 70, 30, 20, "...")
      TextGadget(#Text_5, 5, 105, 85, 15, "������ ������:")
      StringGadget(#String_Password, 95, 100, 200, 20, "")
  EndIf
EndProcedure

Procedure File_Progress(File.s, PerCent.f, UserParam.l) ; ����������� � ���� ��������� �������� �������� �����
  SetGadgetText(#Text_CurrentFiles, File)
  SetGadgetState(#ProgressBar_FileProgress, PerCent)
  While WindowEvent() : Wend
EndProcedure

Procedure All_Progress(File.s, PerCent.f, UserParam.l) ; ����������� � ���� ������ ��������� �������� ������
  SetGadgetState(#ProgressBar_AllProgress, PerCent)
  While WindowEvent() : Wend
EndProcedure

Procedure Button_Archive(Directory.s, File.s)
  
  *Mem = AllocateMemory(100000) ; ������ (100 ����� ����) ��� ����������� ������ �� ���������� ������ � ���������������������.
  If *Mem
    TempDir.s=GetTemporaryDirectory() ; ����������� ���� � ��������� �����
    If FileSize(TempDir) = -2
      
      Repeat ; ��������� ����� ���������� ����� ������
        ArcFile.s = TempDir + "$$"+Str(Random(100000))+"xx.tmp"
      Until FileSize(ArcFile) = -1
      ; �������� ������
      If PureZIP_AddFiles(ArcFile, Directory+"*.*", #PureZIP_StorePathRelative, #PureZIP_Recursive)
        If ReadFile(0,ArcFile) ; ������� ��������� ���� ������
          ArchiveSize=Lof(0)   ; ������ ����� �����
          If CreateFile(1,File) ; ������� ���� ���������������������� ������
            WriteData(1, ?SFX_File, ?SFX_File_End-?SFX_File) ; � ������ ����� - ������ ���������� ������.
            
            While Eof(0) = 0 ; ����������� ������ �� ���������� � ��������������������� �����
              CountBytes = ReadData(0,*Mem,100000)
              If CountBytes>0
                WriteData(1,*Mem,CountBytes)
              EndIf
            Wend
            
            WriteLong(1,ArchiveSize) ; ����������� � ����� ���������������������� ������, ������ ������.
            CloseFile(1)
            SetGadgetText(#Text_CurrentFiles, "��������������������� ����� ������")
            MessageRequester("", "��������������������� ����� ������.", #MB_OK|#MB_ICONINFORMATION)
          Else
            MessageRequester("", "�� ������� ������� ����!", #MB_OK|#MB_ICONERROR)
          EndIf
          CloseFile(0)
        Else
          MessageRequester("", "�� ������� ������� ����� ��� ������!", #MB_OK|#MB_ICONERROR)
        EndIf
        
      Else
        MessageRequester("", "������ ��� �������� ������!", #MB_OK|#MB_ICONERROR)
      EndIf
      DeleteFile(ArcFile) ; �������� ���������� ����� ZIP ������.
    Else
      MessageRequester("", "�� ���������� ��������� ����� Windows!", #MB_OK|#MB_ICONERROR)
    EndIf
  Else
    MessageRequester("", "�� ������� �������� ������!", #MB_OK|#MB_ICONERROR)
  EndIf
 
EndProcedure


Open_Window_0()
PureZIP_SetCompressionCallback(@File_Progress()) ; ����������� ��������� ��������� �������� ������
PureZIP_SetProgressionCallback(@All_Progress()) ; ����������� ��������� ������ ��������� ��������
HideWindow(#Window_0, 0)


Repeat ; ������� ���� Repeat - Until
  Event = WaitWindowEvent() ; ������������� �������
  
  If Event = #PB_Event_Gadget
    Select EventGadget() ; ������������� ������� �� �������� ��������
      Case #Button_1 ; ������ ������ ����� � �������
        Path.s=PathRequester("������� ���� � ������������ ������","")
        If FileSize(Path) = -2 ; ����� ����������
          SetGadgetText(#String_0, Path)
        EndIf
        
      Case #Button_2 ; ������ ������ ����� ���������� ������
        File.s=SaveFileRequester("","","EXE �����|*.exe|��� �����|*.*",0)
        If File<>""
          If GetExtensionPart(File)="" ; �� �������� ���������� �����
            File+".exe"
          EndIf
          SetGadgetText(#String_1, File)
        EndIf 
        
      Case #Button_Archive ; ������ �������� ������
        String1.s=GetGadgetText(#String_0)
        String2.s=GetGadgetText(#String_1)
        If String1<>"" And String2<>""
          Password.s = GetGadgetText(#String_Password) ; ������ ������
          PureZIP_SetArchivePassword(Password) 
          Button_Archive(String1, String2)
        Else
          MessageRequester("", "��������� ����!", 48)
        EndIf
        
    EndSelect   
  EndIf
    
Until Event = #PB_Event_CloseWindow
End

DataSection
  SFX_File:
  IncludeBinary "SFX.exe"
  SFX_File_End:
EndDataSection
; IDE Options = PureBasic 5.30 (Windows - x86)
; CursorPosition = 20
; FirstLine = 118
; Folding = -
; EnableXP
; Executable = CreateSFX_Archive.exe