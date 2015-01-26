; Kubik Send. ��������� ��� ����� ������.
; ������ 1 ���� 7
; (�) 2012 ��140 ��� Kubik Project.
; ����� ���������� 4,51 \ 4,61.

IncludeFile "Kubik_Include_CFGS.pb"

Procedure PrintText(color,text.s, defaultcolor)
  ConsoleColor(color,0) : PrintN(text) : ConsoleColor(defaultcolor,0)
EndProcedure

OpenConsole()
ConsoleTitle("Kubik Send")
Path$ = GetCurrentDirectory()

KubikSetting("Read")

PrintText(14,"Kubik Send | ��������� Kubik Modern.", textcolor)
PrintText(14,"��ࠢ�� � ��� 䨤�譮� �����.", textcolor)
PrintText(15,"(C) Kubik Project 2012", textcolor)
Delay(stime) 

; ����� - 22vlad ; ����������� - EM140 ��� Kubik Project ; http://purebasic.info/phpBB2/viewtopic.php?t=411
Global Dim programs.l(100,100)
NewList l.s() ; ������� ����, ��� ����� ������� ������ ������� ��������� ���� 

If OpenFile(0,"extensions\sys\send.xml") ; ��������� �������� � ��������� ����� ��������� 
Repeat 
  AddElement(l.s()) 
  l.s()=ReadString(0) 
Until Eof(0) 
CloseFile(0) 
Else : PrintText(4,"��������� ������>>�஢��� ���䨣��樮��� 䠩�� �ணࠬ��!!!", textcolor) : Delay(stime) : End
EndIf

; ������ ������: ���� ���� �������� 
countWin=0 
For i=0 To CountList(l.s())-1 
  SelectElement(l.s(),i) 
  string.s=Trim(l.s()) 
  string.s=Left(string.s,12) 
  Select string.s 
    Case "<runprogram " 
      countWin=countWin+1 
      If countWin>10 : Break : EndIf 
      programs(countWin,0)=i 
    Case "</runprogram" 
      programs(0,countWin)=i 
  EndSelect 
Next i 

; �������� ������������ ������������ �����
;If countWin=0 : MessageRequester("Error 0","��������� �� ����� �� ������ ����: �����") : End : EndIf 
If countWin=0 : PrintText(4,"��������� ������>>�஢��� ���䨣��樮��� 䠩�� �ணࠬ��!!!", textcolor) : Delay(stime) : End : EndIf 

For i=1 To countWin 
  ;Debug Str(programs(i,0))+"   "+Str(programs(0,i)) 
  If programs(0,i)<programs(i,0) 
   ;MessageRequester("Error 1","��������� ������������ ����� <runprogram></runprogram>: �����") : End 
    PrintText(4,"�஢���� �ࠢ��쭮��� ⥣�� <runprogram></runprogram>!!!", textcolor) : Delay(stime) : End 
  EndIf 
Next i 

; ������ ������: ������ ��������� �����
For i=1 To countWin 
  SelectElement(l.s(),programs(i,0)) 
  string.s=Trim(l.s()) 
  ; Chr(34) Ascii ��� ������� (")
  b=FindString(string.s,"name="+Chr(34)+"",1)+6
  e=FindString(string.s,""+Chr(34)+"",b) 
  Debug Mid(string.s,b,e-b)
  ProgramName$=Mid(string.s,b,e-b)
  
  b=FindString(string.s,"path="+Chr(34)+"",1)+6
  e=FindString(string.s,""+Chr(34)+"",b) 
  Debug Mid(string.s,b,e-b)
  Filename$=Mid(string.s,b,e-b)
  
  b=FindString(string.s,"directory="+Chr(34)+"",1)+11
  e=FindString(string.s,""+Chr(34)+"",b) 
  Debug Mid(string.s,b,e-b)
  WorkingDirectory$=Mid(string.s,b,e-b)
  
  b=FindString(string.s,"parameter="+Chr(34)+"",1)+11
  e=FindString(string.s,""+Chr(34)+"",b) 
  Debug Mid(string.s,b,e-b)
  Parameter$=Mid(string.s,b,e-b)
  
  PrintText(8,">>"+ProgramName$+"", textcolor) 
  Parameter$=ReplaceString(Parameter$, "%FTNAddress%", FTNAddress)
  Result = RunProgram(Filename$, Parameter$, WorkingDirectory$, #PB_Program_Wait)
Next i

PrintText(15,"��ࠢ�� �����襭�.", 0)
 
If close=1
   ctimes.s=Str(ctime)
   Length=Len(ctimes)-3
   ctimes=Left(ctimes,Length)
   PrintText(15,"���� ���஥��� ��⮬���᪨ �१ "+ctimes+" ᥪ.", textcolor)
   Delay(ctime)
   CloseConsole()
Else
   PrintText(15,"������ ENTER, �⮡� ���.", textcolor)
   Input()
   CloseConsole()
EndIf
End 
; IDE Options = PureBasic 5.30 (Windows - x86)
; ExecutableFormat = Console
; CursorPosition = 1
; Folding = +
; EnableXP
; UseIcon = icons\32x32\send.ico
; Executable = Kubik_Send.exe
; IncludeVersionInfo
; VersionField0 = 1,0,0,7
; VersionField1 = 1,0,0,7
; VersionField2 = Kubik Project
; VersionField3 = Kubik
; VersionField4 = 1
; VersionField5 = 1
; VersionField6 = Компонент Kubik Modern
; VersionField7 = Kubik Send
; VersionField8 = Kubik_Send.exe
; VersionField9 = (С) 2012 Kubik Project
; VersionField13 = de.j.rabbit@gmail.com
; VersionField14 = http://kubik-fido.blogspot.com/
; VersionField17 = 0419 Russian
; VersionField18 = Fido:
; VersionField19 = Blog
; VersionField21 = 2:5020/2140.140
; VersionField22 = http://kubik-fido.blogspot.com/