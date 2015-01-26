IncludeFile "Kubik_Include_CFGS.pb"

Global NewKubikFolder.s, NewKubikDosFolder.s, OldKubikDosFolder.s, OldFidoDosFolder.s, OldBinkdFidoDosFolder.s,  NewFidoDosFolder.s, NewBinkdFidoDosFolder.s

Procedure EditConf2(Path$,  OldKubikPath$,  OldFidoPath$,  OldBinkdFidoPath$, KubikPath$, FidoPath$, BinkdFidoPath$)
     Text.s=""
    If OpenFile(0, Path$) ; Файл открыт для чтения и записи.
      Size=Lof(0) 
       If Size>0 ; Файл не пустой.
         Text = Space(Size) ; Буфер под данные файла.
         ReadData(0, @Text, Size) ; Считываем данные.
           Text=ReplaceString(Text, ""+OldKubikPath$+"", ""+KubikPath$+"")
           If AltFidoPath<>1
             Text=ReplaceString(Text, ""+OldFidoPath$+"", ""+FidoPath$+"")
             Text=ReplaceString(Text, ""+OldBinkdFidoPath$+"", ""+BinkdFidoPath$+"")
           EndIf
         FileSeek(0,0)    ; Переход в начало файла
         TruncateFile(0)  ; и полная его очистка.
         WriteString(0,Text)
       EndIf
      CloseFile(0)
    Else
      MessageRequester("Ошибка","Не удалось открыть файл "+Path$+"!", 16)
    EndIf
EndProcedure

Procedure.s GetShortFileName ( Long.s ) ; Спасибо за процедуру ВиниПуру http://purebasic.mybb.ru/viewtopic.php?id=361
  Short.s = Long 
  GetShortPathName_ ( @Long, @Short, Len(Short) ) 
  ProcedureReturn Short 
EndProcedure 

Procedure EditConf(Path.s)
     Text.s=""
    If OpenFile(0, Path) ; Файл открыт для чтения и записи.
      Size=Lof(0) 
       If Size>0 ; Файл не пустой.
         Text = Space(Size) ; Буфер под данные файла.
         ReadData(0, @Text, Size) ; Считываем данные.
           Text=ReplaceString(Text, OldKubikDosFolder, ""+NewKubikDosFolder+"")
           If AltFidoPath<>1
             Text=ReplaceString(Text, OldFidoDosFolder, ""+NewFidoDosFolder+"")
             Text=ReplaceString(Text, OldBinkdFidoDosFolder, ""+NewBinkdFidoDosFolder+"")
           EndIf
         FileSeek(0,0)    ; Переход в начало файла
         TruncateFile(0)  ; и полная его очистка.
         WriteString(0,Text)
       EndIf
      CloseFile(0)
    Else
      MessageRequester("Ошибка","Не удалось открыть файл "+Path$+"!", 16)
    EndIf
EndProcedure

KubikSetting("Read") ; Запускаем процедуру чтения параметров из конфига Kubik_Set.ini.

NewKubikFolder.s = GetCurrentDirectory() ; Получаем путь до поинт-комплекта.
NewKubikDosFolder.s = GetShortFileName (NewKubikFolder.s); Получаем путь до поинт-комплекта в формате DOS 8.3.

If KubikFolder<>NewKubikFolder.s ; Сверяем старое расположение (из конфига Kubik_Set.ini) с нынешним.
  ; Если не совпадает, то...
  ; Запоминаем группу старых путей, которые мы будем менять на новые:
  OldKubikDosFolder.s=KubikFolderDos ; Старое месторасположение поинт-комплекта.
  
  If AltFidoPath = 0
    OldFidoDosFolder.s=FidoFolderDos
    NewFidoDosFolder.s=""+GetShortFileName (NewKubikDosFolder)+"fido\"
    NewFidoFolder.s=""+NewKubikFolder+"fido\"
  Else
    OldFidoDosFolder.s=KubikFolderDos ; Старое месторасположение почтовых баз поинт-комплекта.
    NewFidoDosFolder.s=FidoFolderDos ; Новое месторасположение почтовых баз поинт-комплекта.
    NewFidoFolder.s=FidoFolder
  EndIf
  
  OldBinkdFidoDosFolder.s=ReplaceString(OldFidoDosFolder, "\", "\\") ; Старое месторасположение почтовых баз поинт-комплекта для конфига binkd.
  NewBinkdFidoDosFolder.s=ReplaceString(NewFidoDosFolder, "\", "\\") ; Новое месторасположение почтовых баз поинт-комплекта для конфига binkd.
  
  ; Запускаем процедуры сохранения нового пути в необходимый конфигурационный файл.
  EditConf("binkd\binkd.cfg")
  EditConf("husky\husky.cfg")
  EditConf("SimpleX-0.49\config.ini")
  EditConf("GoldED+1.1.5\golded.cfg")
  EditConf("GoldED+1.1.5\ge.bat")
  ; Сохраняем новые пути в конфиг кубика.
  KubikFolder=NewKubikFolder
  FidoFolder=NewFidoFolder
  KubikFolderDos=NewKubikDosFolder
  FidoFolderDos=NewFidoDosFolder
  KubikSetting("Write")
EndIf 

; Конец ;)
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
; VersionField6 = РљРѕРјРїРѕРЅРµРЅС‚ Kubik Modern
; VersionField7 = Kubik Params
; VersionField8 = Kubik_Params.exe
; VersionField9 = (РЎ) 2012 Kubik Project
; VersionField13 = de.j.rabbit@gmail.com
; VersionField14 = http://kubik-fido.blogspot.com/
; VersionField17 = 0419 Russian
; VersionField18 = Fido:
; VersionField19 = Blog
; VersionField21 = 2:5020/2140.140
; VersionField22 = http://kubik-fido.blogspot.com/