; Kubik Send. Программа для последовательного запуска тоссера/мейлера (отправки и приёма почты).
; Версия 1.1
; (С) 2012-2016 ragweed
; PureBasic 5.31

; Смотри описание для параметров "-a" и "--auto_send".
Global AutoSend = 0

; Проверяем наличие параметров, переданных при запуске Kubik Send.
For i=0 To CountProgramParameters() - 1
  Select ProgramParameter()
    Case "-a", "--auto_send"
      ; Этот параметр заставляет Kubik Send:
      ; * Не отображать приветствие и прощание
      ; * Начинать проверку почты без задержки (игнорирование Config/Send/STime)
      ; * Завершение работы сразу после проверки почты (игнорирование Config/Send/Сlose)
      AutoSend = 1
  EndSelect
Next

IncludeFile "Kubik_Include_CFGS.pb"

; Задержка Config/Send/STime миллисекунд.
Procedure DelaySTime()
  If AutoSend <> 1
    Delay(stime)
  EndIf
EndProcedure

Procedure PrintText(color,text.s, defaultcolor)
  ConsoleColor(color, 0)
  PrintN(text)
  ConsoleColor(defaultcolor, 0)
EndProcedure

OpenConsole()
ConsoleTitle("Kubik Send")
Path$ = GetCurrentDirectory()

KubikSetting("Read")

If AutoSend <> 1
  PrintText(14,"Kubik Send | ЋвЇа ўЄ  Ё ЇаЁс¬ дЁ¤®и­®© Ї®звл.", textcolor)
  PrintText(15,"(C) Kubik Project 2016", textcolor)
  DelaySTime()
EndIf

; Автор изначального варианта - 22vlad
; Взято здесь: http://purebasic.info/phpBB2/viewtopic.php?t=411
Global Dim programs.l(100,100)
NewList l.s() ; Создаем лист, где будем хранить каждую строчку исходного кода 

If OpenFile(0,"extensions\sys\send.xml") ; Открываем исходник и считываем текст построчно 
Repeat 
  AddElement(l.s()) 
  l.s()=ReadString(0) 
Until Eof(0) 
CloseFile(0) 
Else
  PrintText(4,"”Ђ’Ђ‹њЌЂџ Ћ€ЃЉЂ>>Џа®ўҐавҐ Є®­дЁЈга жЁ®­­лҐ д ©«л Їа®Ја ¬¬л!!!", textcolor)
  DelaySTime()
  End
EndIf

; первый проход: ищем теги программ 
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

; проверка правильности расположения тегов
;If countWin=0 : MessageRequester("Error 0","Программа не имеет ни одного тега: выход") : End : EndIf 
If countWin=0
  PrintText(4,"”Ђ’Ђ‹њЌЂџ Ћ€ЃЉЂ>>Џа®ўҐавҐ Є®­дЁЈга жЁ®­­лҐ д ©«л Їа®Ја ¬¬л!!!", textcolor)
  DelaySTime()
  End
EndIf 

For i=1 To countWin 
  ;Debug Str(programs(i,0))+"   "+Str(programs(0,i)) 
  If programs(0,i)<programs(i,0) 
    PrintText(4,"Џа®ўҐамвҐ Їа ўЁ«м­®бвм вҐЈ®ў <runprogram></runprogram>!!!", textcolor)
    DelaySTime()
    End 
  EndIf 
Next i 

; второй проход: читаем параметры тегов
For i=1 To countWin 
  SelectElement(l.s(),programs(i,0)) 
  string.s=Trim(l.s()) 
  ; Chr(34) Ascii код кавычки (")
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

If AutoSend <> 1
  PrintText(15,"ЋвЇа ўЄ  § ўҐаиҐ­ .", 0)
  
  If close=1
     ctimes.s=Str(ctime)
     Length=Len(ctimes)-3
     ctimes=Left(ctimes,Length)
     PrintText(15,"ЋЄ­® § Єа®Ґвбп  ўв®¬ вЁзҐбЄЁ зҐаҐ§ "+ctimes+" бҐЄ.", textcolor)
     DelaySTime()
     CloseConsole()
  Else
     PrintText(15,"Ќ ¦¬ЁвҐ ENTER, зв®Ўл ўл©вЁ.", textcolor)
     Input()
     CloseConsole()
  EndIf
EndIf
; IDE Options = PureBasic 5.31 (Windows - x86)
; ExecutableFormat = Console
; CursorPosition = 38
; Folding = -
; EnableXP
; UseIcon = icons\32x32\send.ico
; Executable = Kubik_Send.exe
; CommandLine = -a
; IncludeVersionInfo
; VersionField0 = 1,1,0,0
; VersionField1 = 1,1,0,0
; VersionField2 = Kubik Project
; VersionField3 = Kubik
; VersionField4 = 1,1
; VersionField7 = Kubik Send
; VersionField8 = Kubik_Send.exe
; VersionField9 = (C) 2016 Kubik Project
; VersionField14 = http://kubik-fido.blogspot.com/
; VersionField17 = 0419 Russian