; —юда мы планируем перенести все процедуры св€занные с чтением/записью параметров в конфигурационных файлах и объеденить их.

Global FullName.s, UplinkName.s, FTNAddress.s, PointAddress.s, Location.s, ServerName.s, StationName.s, Password.s, Error, KubikFolder.s, AltFidoPath, AlterFidoPath.s, Help.s, Sys
Global close, log, stime, ctime, textcolor
Global Sys, Ssetting, Params, AnimateWindow, AniSpOpen, AniSpClose, Skinwinname, WinName.s, x, y
Global Editor.s, KubikFolder.s, FidoPath.s, Send.s, Set.s, FidoFolder.s, Site.s, Blog.s, Extensions.s, SkinFold.s, Name.s
Global winnameskin.s, tools, image, logo, i1x, i1y, i1w, i1h, i2x, i2y, i2w, i2h, W, H, R, G, B, B1X, B1Y, B1W, B1H, B2X, B2Y, B2W, B2H
Global B3X, B3Y, B3W, B3H, B4X, B4Y, B4W, B4H, B5X, B5Y, B5W, B5H, B6X, B6Y, B6W, B6H, KubikFolderDos.s, FidoFolderDos.s

Procedure KubikSetting(Mode.s) ; Mode.s=Read - считывание значений из Kubik_Set.ini | Mode.s=Write - сохранение.
 If OpenPreferences("Kubik_Set.ini")
   Select Mode
     Case "Read" : Debug "Read"
       PreferenceGroup("Version")
         Sys=ReadPreferenceLong("Sys",0)
       PreferenceGroup("Start")
         Ssetting=ReadPreferenceLong("Ssetting",1)
         Params=ReadPreferenceLong("Params",1)
       PreferenceGroup("Skins")
         SkinFold=ReadPreferenceString("SkinFold","extensions\skins")  
       PreferenceGroup("Window")
         AnimateWindow=ReadPreferenceLong("AnimateWindow",0)
         AniSpOpen=ReadPreferenceLong("AniSpOpen",0)
         AniSpClose=ReadPreferenceLong("AniSpClose",0)
         Skinwinname=ReadPreferenceLong("Skinwinname",0)
         WinName=ReadPreferenceString("WinName","Kubik Start")
         x=ReadPreferenceLong("x",200)
         y=ReadPreferenceLong("y",200)  
       PreferenceGroup("Send")
         close=ReadPreferenceLong("close",0)
         log=ReadPreferenceLong("debug",0)
         stime=ReadPreferenceLong("pause",3000)
         ctime=ReadPreferenceLong("ctime",5000)
         textcolor=ReadPreferenceLong("textcolor",7)
       PreferenceGroup("FTN")
         FullName=ReadPreferenceString("FullName","")
         UplinkName=ReadPreferenceString("UplinkName","")
         PointAddress=ReadPreferenceString("PointAddress","")
         Location=ReadPreferenceString("Location","")
         StationName=ReadPreferenceString("StationName","")
         FTNAddress=ReadPreferenceString("FTNAddress","")
         ServerName=ReadPreferenceString("ServerName","")
         Password=ReadPreferenceString("Password","")
       PreferenceGroup("Path")
         Editor=ReadPreferenceString("Editor","SimpleX-0.49\simplex.exe")
         FidoFolder=ReadPreferenceString("FidoFolder","")
         Send=ReadPreferenceString("Send","send.exe")
         Set=ReadPreferenceString("Set","")
         AltFidoPath=ReadPreferenceLong("AltFidoPath",0)
         KubikFolder=ReadPreferenceString("KubikFolder","")
         Help=ReadPreferenceString("Help","")
         KubikFolderDos=ReadPreferenceString("KubikFolderDos","")
         FidoFolderDos=ReadPreferenceString("FidoFolderDos","")
       PreferenceGroup("Web")
         Site=ReadPreferenceString("Site","")
         Blog=ReadPreferenceString("Blog","")
         Extensions=ReadPreferenceString("Extensions","")
      Case "Write" : Debug "Write" 
       PreferenceGroup("Window")
         WritePreferenceLong("x",x)
         WritePreferenceLong("y",y)  
       PreferenceGroup("FTN")
         WritePreferenceString("FullName", FullName)
         WritePreferenceString("UplinkName", UplinkName)
         WritePreferenceString("PointAddress", PointAddress)
         WritePreferenceString("StationName", StationName)
         WritePreferenceString("Location", Location)
         WritePreferenceString("FTNAddress", FTNAddress)
         WritePreferenceString("ServerName", ServerName)
         WritePreferenceString("Password", Password) 
       PreferenceGroup("Start")
         WritePreferenceLong("Ssetting", 0)
       PreferenceGroup("Path")
         WritePreferenceString("KubikFolder", KubikFolder)
         WritePreferenceString("FidoFolder", FidoFolder)
         WritePreferenceString("KubikFolderDos", KubikFolderDos)
         WritePreferenceString("FidoFolderDos", FidoFolderDos)
   EndSelect 
  ClosePreferences()
 EndIf
EndProcedure

Procedure LoadSkin()
  name.s="default"
  
  OpenPreferences(""+SkinFold.s+"\Set.ini")
       PreferenceGroup("Skin")
         name.s=ReadPreferenceString("name","")
  ClosePreferences()
  
  If OpenPreferences(""+SkinFold.s+"\"+name.s+"\description.ini")
   PreferenceGroup("Skin")
    winnameskin.s=ReadPreferenceString("winname","")
    tools=ReadPreferenceLong("tools",0)
   PreferenceGroup("Images")
    image=ReadPreferenceLong("image",0)
    logo=ReadPreferenceLong("logo",0)

    i1x=ReadPreferenceLong("i1x",0)
    i1y=ReadPreferenceLong("i1y",0)
    i1w=ReadPreferenceLong("i1w",0)
    i1h=ReadPreferenceLong("i1h",0)
    
    i2x=ReadPreferenceLong("i2x",0)
    i2y=ReadPreferenceLong("i2y",0)
    i2w=ReadPreferenceLong("i2w",1)
    i2h=ReadPreferenceLong("i2h",1)
    
   PreferenceGroup("Size")
    W=ReadPreferenceLong("InnerWidth",272)
    H=ReadPreferenceLong("InnerHeight",300)
   PreferenceGroup("WinColor")
    R=ReadPreferenceLong("R",255)
    G=ReadPreferenceLong("G",255)
    B=ReadPreferenceLong("B",255)
   PreferenceGroup("Buttons")
    B1X=ReadPreferenceLong("B1X",10)
    B1Y=ReadPreferenceLong("B1Y",110)
    B1W=ReadPreferenceLong("B1W",120)
    B1H=ReadPreferenceLong("B1H",80)
    
    B2X=ReadPreferenceLong("B2X",145)
    B2Y=ReadPreferenceLong("B2Y",110)
    B2W=ReadPreferenceLong("B2W",120)
    B2H=ReadPreferenceLong("B2H",80)
    
    B3X=ReadPreferenceLong("B3X",10)
    B3Y=ReadPreferenceLong("B3Y",205)
    B3W=ReadPreferenceLong("B3W",75)
    B3H=ReadPreferenceLong("B3H",70)
    
    B4X=ReadPreferenceLong("B4X",100)
    B4Y=ReadPreferenceLong("B4Y",205)
    B4W=ReadPreferenceLong("B4W",75)
    B4H=ReadPreferenceLong("B4H",70)
    
    B5X=ReadPreferenceLong("B5X",190)
    B5Y=ReadPreferenceLong("B5Y",205)
    B5W=ReadPreferenceLong("B5W",75)
    B5H=ReadPreferenceLong("B5H",70)
    
    B6X=ReadPreferenceLong("B6X",196)
    B6Y=ReadPreferenceLong("B6Y",200)
    B6W=ReadPreferenceLong("B6W",76)
    B6H=ReadPreferenceLong("B6H",70)
   ClosePreferences()
 EndIf
EndProcedure  
; IDE Options = PureBasic 5.30 (Windows - x86)
; CursorPosition = 7
; Folding = -
; EnableXP