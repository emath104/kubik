; Kubik Send. Программа для последовательного запуска тоссера/мейлера (отправки и приёма почты).
; Версия 2
; (С) 2012-2017 ragweed
; PureBasic 5.31

; Нам потребуется LoadConfig() и CharToOem() из набора Kubik_Include
IncludeFile "Kubik_Include.pbi"

; Смотри описание для параметров "-a" и "--auto_send".
Global AutoSend = 0

; Задержка Config\Send\Pause миллисекунд.
Procedure DelaySTime()
  If AutoSend <> 1
    Delay(Config\Send\Pause)
  EndIf
EndProcedure

; Отображает сообщение в консоли
; color = -1 - цвет по-умолчанию (Config\Send\TextColor)
Procedure Msg(text.s, color = -1)
  If color <> -1
    ConsoleColor(color, 0)
  EndIf
  PrintN(CharToOem(text.s))
  ConsoleColor(Config\Send\TextColor, 0)
EndProcedure  

; Закрывает приложение
; Поведение зависит от настроек:
; Если Config\Send\AutoClose = 1, окно закрывается автоматически через Config\Send\CloseTime
; иначе - приложение ожидает нажатия ENTER, прежде чем закрытся
Procedure Close()
  If AutoSend <> 1
    If Config\Send\AutoClose = 1
      Msg("Окно закроется автоматически через " + Str(Config\Send\CloseTime / 1000) + " секунд.", 15)
      Delay(Config\Send\CloseTime)
    Else
      Msg("Нажмите ENTER, чтобы выйти.", 15)
      Input()
    EndIf
  EndIf
  CloseConsole()
  End
EndProcedure

; Проверяем наличие параметров, переданных при запуске Kubik Send.
For i=0 To CountProgramParameters() - 1
  Select ProgramParameter()
    Case "-a", "--auto_send", "--auto-send"
      ; Этот параметр заставляет Kubik Send:
      ; * Не отображать приветствие и прощание
      ; * Начинать проверку почты без задержки (игнорирование Config/Send/Pause)
      ; * Завершение работы сразу после проверки почты (игнорирование Config/Send/СloseTime)
      AutoSend = 1
  EndSelect
Next

OpenConsole()
ConsoleTitle("Kubik Send")
LoadConfig("Kubik_Set.ini", 1)

If AutoSend <> 1
  Msg("Kubik Send | Отправка и приём фидошной почты.", 14)
  Msg("(C) Kubik Project 2017", 15)
  DelaySTime()
EndIf

; Открываем конфиг с перечнем программ, которые необходимо будет последовательно запустить
If OpenPreferences("Kubik_Send.ini")
  ; Колличество программ, описанных в конфиге
  amount = ReadPreferenceLong("Amount", 0)
  
  For i = 1 To amount
    If PreferenceGroup(Str(i))
      comment.s = ReadPreferenceString("Comment", "")
      program.s = ReadPreferenceString("Program", "")
      parameters.s = ReadPreferenceString("Parameters", "")
      working_directory.s = ReadPreferenceString("WorkingDirectory", "")
      Debug i
      Debug program.s
      Debug parameters.s
      Debug working_directory.s
      Msg(">>" + comment.s, 8)
      RunProgram(program.s, parameters.s, working_directory.s, #PB_Program_Wait)
    EndIf
  Next
Else
  Msg("Отсутствует конфиг. файл Kubik_Send.ini")
  Close()
EndIf

If AutoSend <> 1
  Msg("Отправка завершена.", 15)
EndIf

Close()
; IDE Options = PureBasic 5.31 (Windows - x86)
; ExecutableFormat = Console
; CursorPosition = 4
; Folding = 5
; EnableXP
; UseIcon = icons\32x32\send.ico
; Executable = Kubik_Send.exe
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