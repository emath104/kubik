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
  If OpenWindow(#Window_0, 344, 256, 334, 264, "Создание самораспаковывающего ZIP",#PB_Window_MinimizeGadget|#PB_Window_Invisible|#PB_Window_ScreenCentered)
      TextGadget(#Text_0, 5, 5, 320, 15, "Путь к папке с файлами:")
      StringGadget(#String_0, 5, 20, 290, 20, "", #PB_String_ReadOnly)
      TextGadget(#Text_1, 5, 55, 320, 15, "Путь к месту сохранения создаваемого архива:")
      StringGadget(#String_1, 5, 70, 290, 20, "", #PB_String_ReadOnly)
      TextGadget(#Text_2, 5, 140, 100, 15, "Обработка файла:")
      TextGadget(#Text_CurrentFiles, 105, 140, 220, 15, "")
      ProgressBarGadget(#ProgressBar_FileProgress, 5, 155, 320, 15, 0, 100, #PB_ProgressBar_Smooth)
      TextGadget(#Text_4, 5, 185, 150, 15, "Общий прогресс:")
      ProgressBarGadget(#ProgressBar_AllProgress, 5, 200, 320, 15, 0, 100, #PB_ProgressBar_Smooth)
      ButtonGadget(#Button_Archive, 80, 230, 190, 25, "Создать SFX архив")
      ButtonGadget(#Button_1, 300, 20, 30, 20, "...")
      ButtonGadget(#Button_2, 300, 70, 30, 20, "...")
      TextGadget(#Text_5, 5, 105, 85, 15, "Пароль архива:")
      StringGadget(#String_Password, 95, 100, 200, 20, "")
  EndIf
EndProcedure

Procedure File_Progress(File.s, PerCent.f, UserParam.l) ; Отображение в окне прогресса упаковки текущего файла
  SetGadgetText(#Text_CurrentFiles, File)
  SetGadgetState(#ProgressBar_FileProgress, PerCent)
  While WindowEvent() : Wend
EndProcedure

Procedure All_Progress(File.s, PerCent.f, UserParam.l) ; Отображение в окне общего прогресса упаковки файлов
  SetGadgetState(#ProgressBar_AllProgress, PerCent)
  While WindowEvent() : Wend
EndProcedure

Procedure Button_Archive(Directory.s, File.s)
  
  *Mem = AllocateMemory(100000) ; Память (100 тысяч байт) для копирования данных из временного архива в самораспаковывающийся.
  If *Mem
    TempDir.s=GetTemporaryDirectory() ; Определение пути к временной папке
    If FileSize(TempDir) = -2
      
      Repeat ; Генерация имени временного файла архива
        ArcFile.s = TempDir + "$$"+Str(Random(100000))+"xx.tmp"
      Until FileSize(ArcFile) = -1
      ; Упаковка файлов
      If PureZIP_AddFiles(ArcFile, Directory+"*.*", #PureZIP_StorePathRelative, #PureZIP_Recursive)
        If ReadFile(0,ArcFile) ; Открыли временный файл архива
          ArchiveSize=Lof(0)   ; Размер этого файла
          If CreateFile(1,File) ; Создаем файл самораспаковывающегося архива
            WriteData(1, ?SFX_File, ?SFX_File_End-?SFX_File) ; В начало файла - модуль распаковки архива.
            
            While Eof(0) = 0 ; Копирование данных из временного в самораспаковывающийся архив
              CountBytes = ReadData(0,*Mem,100000)
              If CountBytes>0
                WriteData(1,*Mem,CountBytes)
              EndIf
            Wend
            
            WriteLong(1,ArchiveSize) ; Дописывание в конец самораспаковывающегося архива, размер архива.
            CloseFile(1)
            SetGadgetText(#Text_CurrentFiles, "Самораспаковывающийся архив создан")
            MessageRequester("", "Самораспаковывающийся архив создан.", #MB_OK|#MB_ICONINFORMATION)
          Else
            MessageRequester("", "Не удалось создать файл!", #MB_OK|#MB_ICONERROR)
          EndIf
          CloseFile(0)
        Else
          MessageRequester("", "Не удалось открыть архив для чтения!", #MB_OK|#MB_ICONERROR)
        EndIf
        
      Else
        MessageRequester("", "Ошибка при упаковке файлов!", #MB_OK|#MB_ICONERROR)
      EndIf
      DeleteFile(ArcFile) ; Удаление временного файла ZIP архива.
    Else
      MessageRequester("", "Не обнаружена временная папка Windows!", #MB_OK|#MB_ICONERROR)
    EndIf
  Else
    MessageRequester("", "Не удалось выделить память!", #MB_OK|#MB_ICONERROR)
  EndIf
 
EndProcedure


Open_Window_0()
PureZIP_SetCompressionCallback(@File_Progress()) ; Регистрация процедуры прогресса упаковки файлов
PureZIP_SetProgressionCallback(@All_Progress()) ; Регистрация процедуры общего прогресса упаковки
HideWindow(#Window_0, 0)


Repeat ; Главный цикл Repeat - Until
  Event = WaitWindowEvent() ; Идентификатор события
  
  If Event = #PB_Event_Gadget
    Select EventGadget() ; Идентификатор гаджета по которому кликнули
      Case #Button_1 ; Кнопка выбора папки с файлами
        Path.s=PathRequester("Укажите путь к архивируемым файлам","")
        If FileSize(Path) = -2 ; Папка существует
          SetGadgetText(#String_0, Path)
        EndIf
        
      Case #Button_2 ; Кнопка выбора места сохранения архива
        File.s=SaveFileRequester("","","EXE файлы|*.exe|Все файлы|*.*",0)
        If File<>""
          If GetExtensionPart(File)="" ; Не указанно расширение файла
            File+".exe"
          EndIf
          SetGadgetText(#String_1, File)
        EndIf 
        
      Case #Button_Archive ; Кнопка создания архива
        String1.s=GetGadgetText(#String_0)
        String2.s=GetGadgetText(#String_1)
        If String1<>"" And String2<>""
          Password.s = GetGadgetText(#String_Password) ; Пароль архива
          PureZIP_SetArchivePassword(Password) 
          Button_Archive(String1, String2)
        Else
          MessageRequester("", "Заполните поля!", 48)
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