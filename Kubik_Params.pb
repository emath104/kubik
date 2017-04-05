; Kubik Params. Утилита для проверки соответствия путей в конфиг. файлах реальному расположению поинт-комплекта.
; Версия 2
; (С) 2012-2017 ragweed
; PureBasic 5.31

;-
#Test_AlwaysFixConfigs = 1

; Может сюда текстовый лог?

; Нам потребуется LoadConfig() и SaveConfig() из набора Kubik_Include
IncludeFile "Kubik_Include.pbi"

; Текущее расположение поинт-комплекта
Global CurrentKubikPath.s

; Текущее расположение почтовых баз поинт-комплекта
Global CurrentFidoPath.s

; Текущее расположение поинт-комплекта в формате 8.3
Global CurrentKubikShortPath.s

; Текущее расположение почтовых баз поинт-комплекта в формате 8.3
Global CurrentFidoShortPath.s

; Старое расположение поинт-комплекта в формате 8.3
Global OldKubikShortPath.s

; Старое расположение почтовых баз поинт-комплекта в формате 8.3
Global OldFidoShortPath.s

; Вносит необходимые изменения в конфигурационный файл
; Вернёт 1 в случае успеха, иначе 0
Procedure FixConfig(config_path.s) 
  text.s = ""
  If OpenFile(0, config_path.s) ; Файл открыт для чтения и записи.
    size = Lof(0)
    
    If size > 0
      text.s = Space(size)
      ReadData(0, @text, size)
      
      ; Для конфига binkd
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

Debug "Старт Kubik Params."

; Считываем конфиг Kubik_Set.ini, если это не удалось - нет смысла продолжать работу
If LoadConfig("Kubik_Set.ini", 1)
  
  Debug "Kubik_Set.ini считан."
  
  ; Проверяем, был ли Kubik_Params отключен в конфиг. файле (Config\Start\Params)
  If Config\Start\Params = 1
    
    Debug "Расположение поинт-комплекта, исходя из Kubik_Set.ini - '" + Config\Path\KubikFolder + "'"
    
    ; Получаем текущее расположение поинт-комплекта
    CurrentKubikPath.s = GetCurrentDirectory() 
    Debug "Текущее расположение поинт-комплекта - '" + CurrentKubikPath.s + "'"
    
    ; Получаем путь до поинт-комплекта в форматe 8.3
    CurrentKubikShortPath.s = GetShortFileName(CurrentKubikPath.s)
    Debug "Текущее расположение поинт-комплекта (8.3) - '" + CurrentKubikShortPath.s + "'"
    
    ; Сверяем старое расположение (из конфига Kubik_Set.ini) с нынешним
    ; Если не совпадает, значит будем во всех конфигах заменять старые пути на новые
    ; Иначе работа Kubik Params завершена
    If Config\Path\KubikFolder <> CurrentKubikPath.s Or #Test_AlwaysFixConfigs = 1
      
      Debug "Путь в конфиг. файле отличается от расположения поинт-комплекта. Kubik Params начинает свою работу."
      
      ; Запоминаем группу старых путей, которые мы будем менять на новые
      OldKubikShortPath.s = GetShortFileName(Config\Path\KubikFolder) ;- Старое месторасположение поинт-комплекта.
      
      ; Формально, Config\Path\AltFidoPath = 1 означает, что расположение почтовых баз (папка fido\) задано пользователем вручную
      ; однако на тестирование данной функциональности у меня нет не времени, ни желания, так что я сохранил логику из предыдущей версии 
      ; Kubik Params чтобы если данный функционал потребуется - не надо было бы всё писать с нуля. Аналогично я поступил при рефакторинге 
      ; Kubik SSetting
      If Config\Path\AltFidoPath = 0
        OldFidoShortPath.s = GetShortFileName(Config\Path\FidoFolder)
        CurrentFidoShortPath.s = GetShortFileName(CurrentKubikPath.s) + "fido\"
        CurrentFidoPath.s    = CurrentKubikPath.s + "fido\"
      Else
        Debug "Путь до почтовых баз не будет правится в конфиг. файлах (Config\Path\AltFidoPath = 1)."
        OldFidoShortPath.s = GetShortFileName(Config\Path\FidoFolder)
        CurrentFidoShortPath.s = GetShortFileName(Config\Path\FidoFolder)
        CurrentFidoPath.s    = Config\Path\FidoFolder
      EndIf
      
      Debug "Текущее расположение почтовой базы поинт-комплекта - '" + CurrentFidoPath.s + "'"
      Debug "Текущее расположение почтовой базы поинт-комплекта (8.3) - '" + CurrentFidoShortPath.s + "'"
      
      Debug "Узнаю, какие конф. файлы необходимо править (благодаря 'templates\Config_List.ini')."
      ; Открываем Config_List.ini, чтобы понять - какие конфиг. файлы нужно править
      If OpenPreferences("templates\Config_List.ini")
        ; Перебираем файлы папки templates\
        If ExamineDirectory(0, "templates\", "*.template")
          While NextDirectoryEntry(0)
            If DirectoryEntryType(0) = #PB_DirectoryEntry_File
              config_path.s = ReadPreferenceString(DirectoryEntryName(0), "")
              If config_path.s <> ""
                ; Запускаем процедуру сохранения нового пути в необходимый конфигурационный файл
                Debug "Вношу изменения в '" + config_path.s + "'."
                If Not FixConfig(config_path.s)
                  Debug "Ошибка при внесении изменений в '" + config_path.s + "' Приложение будет закрыто."
                  Break
                EndIf
              EndIf
            EndIf
          Wend
          FinishDirectory(0)
          
          ; Сохраняем новые пути в Kubik_Set.ini
          Config\Path\KubikFolder = CurrentKubikPath.s
          Config\Path\FidoFolder  = CurrentFidoPath.s
          SaveConfig("Kubik_Set.ini")
        Else
          Debug "А куда подевались шаблоны из 'templates\'?. Приложение будет закрыто."
        EndIf
      Else
        Debug "Отсутствует 'templates\Config_List.ini'. Приложение будет закрыто."
      EndIf
    Else
      Debug "Расположение поинт-комплекта не изменилось. Работа Kubik Params не требуется."
    EndIf
  Else
    Debug "Kubik Params отключен на уровне конфиг. файла. Приложение будет закрыто."
  EndIf
Else
  Debug "Конфиг. файл 'Kubik_Set.ini' не найден. Приложение будет закрыто."
EndIf

Debug "Kubik Params завершает свою работу."
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
; VersionField6 = Р В Р’В Р РЋРІвЂћСћР В Р’В Р РЋРІР‚СћР В Р’В Р РЋР’ВР В Р’В Р РЋРІР‚вЂќР В Р’В Р РЋРІР‚СћР В Р’В Р В РІР‚В¦Р В Р’В Р вЂ™Р’ВµР В Р’В Р В РІР‚В¦Р В Р Р‹Р Р†Р вЂљРЎв„ў Kubik Modern
; VersionField7 = Kubik Params
; VersionField8 = Kubik_Params.exe
; VersionField9 = (Р В Р’В Р В Р вЂ№) 2012 Kubik Project
; VersionField13 = de.j.rabbit@gmail.com
; VersionField14 = http://kubik-fido.blogspot.com/
; VersionField17 = 0419 Russian
; VersionField18 = Fido:
; VersionField19 = Blog
; VersionField21 = 2:5020/2140.140
; VersionField22 = http://kubik-fido.blogspot.com/