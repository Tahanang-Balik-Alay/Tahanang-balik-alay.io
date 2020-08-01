@echo off & CD "%~dp0"

goto :startup

:rooof
::: / Variable used in calling this script from the Self created resizing Batch.    
    Set "AlignFile=%~dpnx0"
::: \

::: / Creates variable /AE = Ascii-27 escape code.
::: - http://www.dostips.com/forum/viewtopic.php?t=1733
::: - https://stackoverflow.com/a/34923514/12343998
:::
::: - /AE can be used  with and without DelayedExpansion.
    Setlocal
    For /F "tokens=2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
        Endlocal
        Set "/AE=%%a"
    )
::: \

::: / Set environment state for Macro Definitions
    Setlocal DisableDelayedExpansion

    (Set LF=^


    %= Above Empty lines Required =%)

    Set ^"\n=^^^%LF%%LF%^%LF%%LF%^^"


::: / Color Macro Variables
::: - Macro used to print the "%%H"th character (Passed with randomly set Char variable as the 2nd Arg) from the defined Character Set
::: - At Y;X Position (Arg 1, %%G) in Color %%H
    Set @PrintMapped=for /L %%n in (1 1 2) do if %%n==2 (%\n%
        For /F "tokens=1,2,3,4 delims=, " %%G in ("!argv!") do (%\n%
            Echo(%/AE%[%%GH!%%I!!CharacterSet:~%%H,%%J!!Off!^&^&Endlocal%\n%
        ) %\n%
    ) ELSE setlocal enableDelayedExpansion ^& set argv=, 
::: -
::: - Macro used to print content of Variable passed with 2nd Arg (%%H)
::: - At Y;X Position (%%G) in Color %%H
    Set @Menu=for /L %%n in (1 1 2) do if %%n==2 (%\n%
        For /F "tokens=1,2,3 delims=, " %%G in ("!argv!") do (%\n%
            Echo(%/AE%[%%GH!%%I!!%%H!!Off!^&^&Endlocal%\n%
        ) %\n%
    ) ELSE setlocal enableDelayedExpansion ^& set argv=, 
::: \ End Macro Definitions

::: / Assigns ANSI color code values to each color, then builds an Array containing those color values to be accessed using random number.
    Setlocal EnableDelayedExpansion
    Set /A Red=31,Green=32,Yellow=33,Blue=34,Purple=35,Cyan=36,White=37,Grey=90,Pink=91,Beige=93,Aqua=94,Magenta=95,Teal=96,Off=0,CI#=0
    For %%A in (Red,Yellow,Pink,Beige,Grey,Purple,Green,Cyan,White,Aqua,Magenta,Blue,Teal,Off) do (
        Set "%%A=%/AE%[!%%A!m"
        Set /A "CI#+=1"
        Set "C#[!CI#!]=%%A"
    )
::: \

::: / Define character Set to be used. Accessed using Random number and Substring Modification to extract the character at that mapped position
    Set "CharacterSet=1qA{Z2W<sX[3EDC@4R}FV^5TG&BYHn7]UJM8-IK9OL0Ppo_iu>ytre$wQ\aSdf/gh~jkl+mN|bvc#xz"
::: \

::: / Identifies when the program has been called by the resizung batch it creates and goes to label passed by call
    If Not "%~3"=="" (
        Set "Console_Hieght=%~1"
        Set "Console_Width=%~2"
        Set "AlignFile=%~4"
        Goto :%~3
    ) Else (Goto :mfr)
::: \


::: / Subroutine to process output of wmic command into usable variables  for screen dimensions (resolution)

    :ChangeConsole <Lines> <Columns> <Label to Resume From> <If a 4th parameter is Defined, Aligns screen at top left>
::: - Get screen Dimensions
    For /f "delims=" %%# in  ('"wmic path Win32_VideoController  get CurrentHorizontalResolution,CurrentVerticalResolution /format:value"') do (
        Set "%%#">nul
    )
::: -  Calculation of X axis relative to screen resolution and console size

    Set /A CentreX= ( ( CurrentHorizontalResolution / 2 ) - ( %~2 * 4 ) ) + 8

::: - Sub Optimal calculation of Y axis relative to screen resolution and console size
    For /L %%A in (10,10,%1) DO Set /A VertMod+=1
    Set /A CentreY= ( CurrentVerticalResolution / 4 ) - ( %~1 * Vertmod )
    For /L %%B in (1,1,%VertMod%) do Set /A CentreY+= ( VertMod * 2 )

::: - Optional 4th parameter can be used to align console at top left of screen instead of screen centre
    If Not "%~4"=="" (Set /A CentreY=0,CentreX=-8)

    Set "Console_Width=%~2"

::: - Creates a batch file to reopen the main script using Call with parameters to define properties for console change and the label to resume from.
        (
        Echo.@Mode Con: lines=%~1 cols=%~2
        Echo.@Title PROTOCOL C-1-2-v-2
        Echo.@Call "%AlignFile%" "%~1" "%~2" "%~3" "%AlignFile%" 
        )>"%temp%\ChangeConsole.bat"

::: - .Vbs script creation and launch to reopen batch with new console settings, with aid of above batch script
        (
        Echo.Set objWMIService = GetObject^("winmgmts:\\.\root\cimv2"^)
        Echo.Set objConfig = objWMIService.Get^("Win32_ProcessStartup"^)
        Echo.objConfig.SpawnInstance_
        Echo.objConfig.X = %CentreX%
        Echo.objConfig.Y = %CentreY%
        Echo.Set objNewProcess = objWMIService.Get^("Win32_Process"^)
        Echo.intReturn = objNewProcess.Create^("%temp%\ChangeConsole.bat", Null, objConfig, intProcessID^)
        )>"%temp%\Consolepos.vbs"

::: - Starts the companion batch script to Change Console properties, ends the parent.
    Start "" "%temp%\Consolepos.vbs" & Exit

:mfr

    Call :ChangeConsole 45 170 Matrix top
ping localhost -n 2 >nul
goto :3loop
::: / Display Elements  
:Matrix

goto:loop3
Setlocal enableDelayedExpansion

::: - Numbers higher than actual console hieght cause the the console to scroll. the higher the number, the smoother the scroll
::: - and the less dense the characters on screen will be.
    Set /A Console_Hieght=(Console_Hieght * 5) / 4
::: - Menu Selection
    Set "Opt1=(W)aterfall %cyan%Matrix"
    Set "Opt2=(C)haos     %red%M%yellow%a%green%t%blue%r%purple%i%magenta%x"
    Set "Opt3=%red%(%pink%R%magenta%)%purple%a%blue%i%aqua%n%cyan%b%green%o%yellow%w %red%painting"
    Set "Opt4=(F)laming %yellow%Matrix"
    %@Menu% 1;1 Opt1 blue
    %@Menu% 2;1 Opt2 magenta
    %@Menu% 3;1 Opt3 aqua
    %@Menu% 4;1 Opt4 red
    Choice /N /C WCRF /M ""
    CLS & Goto :loop%Errorlevel%

:loop1
TITLE loop
:1loop
    For /L %%A in (1,1,125) do (
%= lower for loop end value equals faster transition, higher equals slower. Result of nCI color variable not being expanded with new value during for loop =%
        Set /A Xpos=!random! %%!Console_Width! + 1,Ypos=!random! %%!Console_Hieght! + 1,Char=!random! %%79 + 1,nCI=!random! %%!CI#! + 1,CharCount=!random! %%3 + 1
        %@PrintMapped% !Ypos!;!Xpos! !Char! !C#[%nCI%]! !CharCount!
    )
Goto :1loop

:loop2
TITLE Chaos Matrix By T3RRY
:2loop
    For /L %%A in (1,1,5000) do ( 
        Set /A Xpos=!random! %%!Console_Width! + 1,Ypos=!random! %%!Console_Hieght! + 1,Char=!random! %%79 + 1,nCI=!random! %%!CI#! + 1,CharCount=!random! %%3 + 1
        For %%B in (!nCI!) do %@PrintMapped% !Ypos!;!Xpos! !Char! !C#[%%B]! !CharCount!
    )
Goto :HERSA codec

:loop3
TITLE PROTOCOL C-1-2-v-2
    Set /A Console_Hieght=((Console_Hieght / 5) * 4) - 4
:3loop
    Set /A Xpos=!random! %%!Console_Width! + 1,Ypos=!random! %%!Console_Hieght! + 1,Char=!random! %%79 + 1,nCI=!random! %%!CI#! + 1,CharCount=!random! %%3 + 1
    For %%B in (!nCI!) do %@PrintMapped% !Ypos!;!Xpos! !Char! !C#[%%B]! !CharCount!
Goto :3loop

:loop4
TITLE AAI codec
:4loop
    For /L %%A in (1,1,200000) do ( 
        Set /A Xpos=!random! %%!Console_Width! + 1,Ypos=!random! %%!Console_Hieght! + 1,Char=!random! %%79 + 1,nCI=!random! %%!CI#! + 1,CharCount=!random! %%5 + 1
        For %%B in (!nCI!) do %@PrintMapped% !Ypos!;!Xpos! !Char! !C#[2]! !CharCount!
        Set /A Xpos-=1,Ypos+=1,Char=!random! %%79 + 1,nCI=!random! %%!CI#! + 1,CharCount=!random! %%6 + 1
        For %%B in (!nCI!) do %@PrintMapped% !Ypos!;!Xpos! !Char! !C#[1]! !CharCount!
        Set /A Xpos=!random! %%!Console_Width! + 1,Ypos=!random! %%!Console_Hieght! + 1,Char=!random! %%79 + 1,nCI=!random! %%!CI#! + 1,CharCount=!random! %%5 + 1
        For %%B in (!nCI!) do %@PrintMapped% !Ypos!;!Xpos! !Char! !C#[2]! !CharCount!
        Set /A Xpos-=1,Ypos+=1,Char=!random! %%79 + 1,nCI=!random! %%!CI#! + 1,CharCount=!random! %%6 + 1
        For %%B in (!nCI!) do %@PrintMapped% !Ypos!;!Xpos! !Char! !C#[1]! !CharCount!
        Set /A Xpos=!random! %%!Console_Width! + 1,Ypos=!random! %%!Console_Hieght! + 1,Char=!random! %%79 + 1,nCI=!random! %%!CI#! + 1,CharCount=!random! %%5 + 1
        For %%B in (!nCI!) do %@PrintMapped% !Ypos!;!Xpos! !Char! !C#[2]! !CharCount!
        Set /A Xpos+=1,Ypos+=1,Char=!random! %%79 + 1,nCI=!random! %%!CI#! + 1,CharCount=!random! %%6 + 1
        For %%B in (!nCI!) do %@PrintMapped% !Ypos!;!Xpos! !Char! !C#[1]! !CharCount!
        Set /A Xpos=!random! %%!Console_Width! + 1,Ypos=!random! %%!Console_Hieght! + 1,Char=!random! %%79 + 1,nCI=!random! %%!CI#! + 1,CharCount=!random! %%5 + 1
        For %%B in (!nCI!) do %@PrintMapped% !Ypos!;!Xpos! !Char! !C#[2]! !CharCount!
        Set /A Xpos+=1,Ypos-=1,Char=!random! %%79 + 1,nCI=!random! %%!CI#! + 1,CharCount=!random! %%6 + 1
        For %%B in (!nCI!) do %@PrintMapped% !Ypos!;!Xpos! !Char! !C#[1]! !CharCount!
        Set /A Xpos=!random! %%!Console_Width! + 1,Ypos=!random! %%!Console_Hieght! + 1,Char=!random! %%79 + 1,nCI=!random! %%!CI#! + 1,CharCount=!random! %%5 + 1
        For %%B in (!nCI!) do %@PrintMapped% !Ypos!;!Xpos! !Char! !C#[2]! !CharCount!
        Set /A Xpos-=1,Ypos-=1,Char=!random! %%79 + 1,nCI=!random! %%!CI#! + 1,CharCount=!random! %%6 + 1
        For %%B in (!nCI!) do %@PrintMapped% !Ypos!;!Xpos! !Char! !C#[1]! !CharCount!
    )
Goto :4loop



:startup



TITLE P I R O N


  
echo                                                                WARNING!

ping localhost -n 5 >nul

echo.
echo                           This application is/has not been released yet, there maybe some kind of errors,
echo                               glitches, and other stuff that may cause problems to this application,
echo                                 until further update, this application is not considered finish.
echo.

ping localhost -n 15 >nul

cls

ping localhost -n 3 >nul

echo                                                       displaying----current build.

cls

ping localhost -n 5 >nul

echo                                          P I R O N----security:                    v0.1 Unrelease
echo.

ping localhost -n 5 >nul

echo                                          P I R O N----activOS:                     activOs Nirvana 0
echo.

ping localhost -n 5 >nul
 
echo                                          P I R O N----secureLine:                  v1 Unrelease
echo.

ping localhost -n 5 >nul

echo                                          P I R O N----orbiT:                       v1.2 Unrelease
echo.

ping localhost -n 5 >nul

echo                                          P I R O N----H.E.R.S.A                    She can learn on its own.
echo.

ping localhost -n 5 >nul

echo                                          P I R O N----AAI                          H.E.R.S.A 
echo.

ping localhost -n 5 >nul

cls

ping localhost -n 5 >nul

echo             P I R O N secureLine Started

ping localhost -n 5 >nul

echo             P I R O N orbiT Started 

ping localhost -n 5 >nul

echo             P I R O N AAI Started

ping localhost -n 5 >nul

echo             Starting P I R O N Security

ping localhost -n 5 >nul

cls

echo Loading application...

ping localhost -n 5 >nul

cls

Echo Loading TransFile

ping localhost -n 5 >nul

cls

echo Starting TransFile

ping localhost -n 5 >nul

cls

echo TransFile Scanning:


ping localhost -n 3 >nul

color c

tree


ping localhost -n 5 >nul

cls

color f

echo TransFile completed (1215122/1215122)

ping localhost -n 4 >nul

echo All required file is completed.

ping localhost -n 10 >nul

echo redirecting to P I R O N Startup.

ping localhost -n 10 >nul

goto:Startup2

:Startup2
title P I R O N V0.1

ping localhost -n 3 >nul

echo STARTING P I R O N

ping localhost -n 5 >nul
cls

echo LOADING P I R O N

Ping localhost -n 5 >nul
cls

echo PLEASE WAIT...

ping localhost -n 2 >nul
cls

echo Running P I R O N 

ping localhost -n 2 >nul 
cls

echo P I R O N STARTED

ping localhost -n 5 >nul
cls

echo                             db   d8b   db d88888b db       .o88b.  .d88b.  .88b  d88. d88888b
ping localhost -n 1 >nul
echo                             88   I8I   88 88'     88      d8P  Y8 .8P  Y8. 88'YbdP`88 88' 
ping localhost -n 1 >nul  
echo                             88   I8I   88 88ooooo 88      8P      88    88 88  88  88 88ooooo
ping localhost -n 1 >nul
echo                             Y8   I8I   88 88~~~~~ 88      8b      88    88 88  88  88 88~~~~~

echo                             `8b d8'8b d8' 88.     88booo. Y8b  d8 `8b  d8' 88  88  88 88.    
echo                              `8b8' `8d8'  Y88888P Y88888P  `Y88P'  `Y88P'  YP  YP  YP Y88888P
ping localhost -n 3 >nul   
echo.
echo You are running P I R O N Security UNRELEASED version.                                                                                                             
ping localhost -n 2 >nul
echo Runing S13-9-70 PROTOCOL
ping localhost -n 3 >nul
cls
title PROTOCOL: S13-9-70
ping localhost -n 2 >nul
echo Checking system for verification purpose.
ping localhost -n 4 >nul
cls
echo System version:                   0.1 Unrelease
echo.
ping localhost -n 3 >nul
echo Ip:                               192.168.0.1
echo.
ping localhost -n 3 >nul
echo calbration data:                  E17-0AF
echo.
ping localhost -n 3 >nul
echo Apllication type:                 Security
echo.
ping localhost -n 3 >nul
echo Access:                           P I R O N PLANTINATOR
echo                                   P I R O N UNDER GROUND
echo.
ping localhost -n 3 >nul
echo AI capability:                    YES
echo.
ping localhost -n 3 >nul
echo GPS:                              YES
echo.
ping localhost -n 3 >nul
echo TELEMETRY:                        YES
echo.
ping localhost -n 3 >nul
echo Number of sensors:                PLANTINATOR : 9 sensors
echo                                   UNDER GROUND: 7 sensors
echo.
ping localhost -n 3 >nul
echo Connected device:                 PLANTINATOR
echo.
ping localhost -n 6 >nul
echo connected device version:         PLANTINATOR version:            0.2 
echo                                   Kernel:                         E10-13F 
echo                                   Board:                          0.1 
echo                                   OS:                             activOS
echo                                   AI responsible:                 H E R S A
echo                                   GPS:                            YES
echo                                   TELEMETRY:                      YES
echo                                   Tansmitter:                     NO; Full AI
echo.
ping localhost -n 8 >nul
cls
echo Scan completed 
ping localhost -n 3 >nul
echo Scan Info: No other Plug-ins Found, therefore: File Safe
ping localhost -n 3 >nul
echo redirecting to Normal state.
ping localhost -n 3 >nul
cls
echo PROTOCOL: S13-9-70 is now removed.
ping localhost -n 3 >nul
cls
echo Normal state initiated.
ping localhost -n 3 >nul
echo fethchhing LOGIN stream.
ping localhost -n 3 >nul
cls

goto :NormalLogin

:NormalLogin
Title LOGIN
ping localhost -n 3 >nul
cls
echo Please provide your Username And Password.
ping localhost -n 3 >nul
cls
cd C:\Users\Marjorie Samson\Desktop\progam

if exist "P I R O N" goto skip

md "P I R O N"

:skip

cd "P I R O N"

ping localhost -n 5 >nul


:login

color 7

title LOGIN

cls

set /p "user=Username: "

if ["%user%"] == [""] goto LOGIN

if EXIST "%user%.bat" goto pass

goto usernotexist

:usernotexist

color c

cls

echo USERNAME doesn't exist.

pause >nul

goto login

:pass

call %user%.bat

set /p "pass=Password: "

if ["%pass%"] == ["%apass%"] goto logingood ping localhost -n 4 >nul

goto passinvalid

:passinvalid

color c

cls

echo The PASSWORD you entered is not correct, please try again.

ping localhost -n 5 >nul


goto :loginAttempt2

:loginAttempt2

color 7

title Login attemt 2

cls

set /p "user=Username: "

if ["%user%"] == [""] goto LOGIN

if EXIST "%user%.bat" goto pass

goto usernotexist

:usernotexist

color c

cls

echo USERNAME doesn't exist.

pause >nul

goto login

:pass

call %user%.bat

set /p "pass=Password: "

if ["%pass%"] == ["%apass%"] goto logingood ping localhost -n 4 >nul

goto passinvalid

:passinvalid

color c

cls

echo The PASSWORD you entered is not correct, please try again.

ping localhost -n 5 >nul


goto :loginAttempt3

:loginAttempt3

color 7

title Login Attempt 3	

cls

set /p "user=Username: "

if ["%user%"] == [""] goto LOGIN

if EXIST "%user%.bat" goto pass

goto usernotexist

:usernotexist

color c

cls

echo USERNAME doesn't exist.

pause >nul

goto login

:pass

call %user%.bat

set /p "pass=Password: "

if ["%pass%"] == ["%apass%"] goto logingood ping localhost -n 4 >nul

goto passinvalid

:passinvalid

color c

cls

echo The PASSWORD you entered is not correct, you have entered an incorrect password on last attempt 
ping localhost -n 3>nul
echo Starting PROTOCOL: SELF-DESTRUCT
ping localhost -n 5 >nul
cls
TITLE PROTOCOL:SELF-DESTRUCT
ping localhost -10 >nul
setlocal enableextensions disabledelayedexpansion

    for /l %%f in (0 1 100) do (
        call :drawProgressBar %%f "Deleting all files"
    )
    for /l %%f in (100 -1 0) do (
        call :drawProgressBar %%f "Removing...."
    )
    for /l %%f in (0 5 10 100) do (
        call :drawProgressBar !random! "Deleting all cache"
    )
    ping localhost -20 >nul 

    rem Clean all after use
    call :finalizeProgressBar 1

    call :initProgressBar "|" "$"
    call :drawProgressBar 0 "Self-Destruct Completed."
    for /l %%f in (0 1 100) do (
        call :drawProgressBar %%f 
    )

ping localhost -n 5 >nul
    goto :Self-Destruct
    endlocal
    cls




:drawProgressBar value [text]
    if "%~1"=="" goto :eof
    if not defined pb.barArea call :initProgressBar
    setlocal enableextensions enabledelayedexpansion
    set /a "pb.value=%~1 %% 101", "pb.filled=pb.value*pb.barArea/100", "pb.dotted=pb.barArea-pb.filled", "pb.pct=1000+pb.value"
    set "pb.pct=%pb.pct:~-3%"
    if "%~2"=="" ( set "pb.text=" ) else ( 
        set "pb.text=%~2%pb.back%" 
        set "pb.text=!pb.text:~0,%pb.textArea%!"
    )
    <nul set /p "pb.prompt=[!pb.fill:~0,%pb.filled%!!pb.dots:~0,%pb.dotted%!][ %pb.pct% ] %pb.text%!pb.cr!"
    endlocal
    goto :eof

:initProgressBar [fillChar] [dotChar]
    if defined pb.cr call :finalizeProgressBar
    for /f %%a in ('copy "%~f0" nul /z') do set "pb.cr=%%a"
    if "%~1"=="" ( set "pb.fillChar=#" ) else ( set "pb.fillChar=%~1" )
    if "%~2"=="" ( set "pb.dotChar=." ) else ( set "pb.dotChar=%~2" )
    set "pb.console.columns="
    for /f "tokens=2 skip=4" %%f in ('mode con') do if not defined pb.console.columns set "pb.console.columns=%%f"
    set /a "pb.barArea=pb.console.columns/2-2", "pb.textArea=pb.barArea-9"
    set "pb.fill="
    setlocal enableextensions enabledelayedexpansion
    for /l %%p in (1 1 %pb.barArea%) do set "pb.fill=!pb.fill!%pb.fillChar%"
    set "pb.fill=!pb.fill:~0,%pb.barArea%!"
    set "pb.dots=!pb.fill:%pb.fillChar%=%pb.dotChar%!"
    set "pb.back=!pb.fill:~0,%pb.textArea%!
    set "pb.back=!pb.back:%pb.fillChar%= !"
    endlocal & set "pb.fill=%pb.fill%" & set "pb.dots=%pb.dots%" & set "pb.back=%pb.back%"
    goto :eof

:finalizeProgressBar [erase]
    if defined pb.cr (
        if not "%~1"=="" (
            setlocal enabledelayedexpansion
            set "pb.back="
            for /l %%p in (1 1 %pb.console.columns%) do set "pb.back=!pb.back! "
            <nul set /p "pb.prompt=!pb.cr!!pb.back:~1!!pb.cr!"
            endlocal
        )
    )
    for /f "tokens=1 delims==" %%v in ('set pb.') do set "%%v="
    goto:eof


:Self-Destruct
     SET someOtherProgram=SomeOtherProgram.exe
       TASKKILL /IM "%someOtherProgram%"
         DEL "%~f0"
         del test.bat
         del test2.bat
         del "programs\test3.bat"





:logingood

cls


ping localhost -n 7 >nul

title Login Sucessfully

echo Generating Ver Code::::::::

ping localhost -n 5 >nul


echo Redirecting to P I R O N Server

echo Login Time : %time%

ping localhost -n 7 >nul                                                    

echo               d8888b.      d888888b      d8888b.       .d88b.       d8b   db 
echo               88  `8D        `88'        88  `8D      .8P  Y8.      888o  88 
echo               88oodD'         88         88oobY'      88    88      88V8o 88 
echo               88~~~           88         88`8b        88    88      88 V8o88 
echo               88             .88.        88 `88.      `8b  d8'      88  V888            
echo               88           Y888888P      88   YD       `Y88P'       VP   V8P 
                                                               
                                                               

 ping localhost -n 4 >nul

 
 ping localhost -n 2 >nul

goto :loaderbat

:loaderbat
TITLE P I R O N Server

    setlocal enableextensions disabledelayedexpansion

    for /l %%f in (0 1 100) do (
        call :drawProgressBar %%f "Starting P I R O N"
    )
    for /l %%f in (100 -1 0) do (
        call :drawProgressBar %%f "TESTING VERIFICATION CODE"
    )
    for /l %%f in (0 5 10 100) do (
        call :drawProgressBar !random! "VER CODE: %random%"
    )

    rem Clean all after use
    call :finalizeProgressBar 1



    ping localhost -n 7 >nul
    call :initProgressBar "|" "$"
    call :drawProgressBar 0        "activOS Started"
    for /l %%f in (0 1 100) do (
        call :drawProgressBar %%f 
    )

ping localhost -n 3 >nul
echo.
echo.
echo Welcome Mr.Ligolas
echo.

ping localhost -n 5 >nul
goto :activOS
    endlocal
    exit /b


:drawProgressBar value [text]
    if "%~1"=="" goto :eof
    if not defined pb.barArea call :initProgressBar
    setlocal enableextensions enabledelayedexpansion
    set /a "pb.value=%~1 %% 101", "pb.filled=pb.value*pb.barArea/100", "pb.dotted=pb.barArea-pb.filled", "pb.pct=1000+pb.value"
    set "pb.pct=%pb.pct:~-3%"
    if "%~2"=="" ( set "pb.text=" ) else ( 
        set "pb.text=%~2%pb.back%" 
        set "pb.text=!pb.text:~0,%pb.textArea%!"
    )
    <nul set /p "pb.prompt=[!pb.fill:~0,%pb.filled%!!pb.dots:~0,%pb.dotted%!][ %pb.pct% ] %pb.text%!pb.cr!"
    endlocal
    goto :eof

:initProgressBar [fillChar] [dotChar]
    if defined pb.cr call :finalizeProgressBar
    for /f %%a in ('copy "%~f0" nul /z') do set "pb.cr=%%a"
    if "%~1"=="" ( set "pb.fillChar=#" ) else ( set "pb.fillChar=%~1" )
    if "%~2"=="" ( set "pb.dotChar=." ) else ( set "pb.dotChar=%~2" )
    set "pb.console.columns="
    for /f "tokens=2 skip=4" %%f in ('mode con') do if not defined pb.console.columns set "pb.console.columns=%%f"
    set /a "pb.barArea=pb.console.columns/2-2", "pb.textArea=pb.barArea-9"
    set "pb.fill="
    setlocal enableextensions enabledelayedexpansion
    for /l %%p in (1 1 %pb.barArea%) do set "pb.fill=!pb.fill!%pb.fillChar%"
    set "pb.fill=!pb.fill:~0,%pb.barArea%!"
    set "pb.dots=!pb.fill:%pb.fillChar%=%pb.dotChar%!"
    set "pb.back=!pb.fill:~0,%pb.textArea%!
    set "pb.back=!pb.back:%pb.fillChar%= !"
    endlocal & set "pb.fill=%pb.fill%" & set "pb.dots=%pb.dots%" & set "pb.back=%pb.back%"
    goto :eof

:finalizeProgressBar [erase]
    if defined pb.cr (
        if not "%~1"=="" (
            setlocal enabledelayedexpansion
            set "pb.back="
            for /l %%p in (1 1 %pb.console.columns%) do set "pb.back=!pb.back! "
            <nul set /p "pb.prompt=!pb.cr!!pb.back:~1!!pb.cr!"
            endlocal
        )
    )
    for /f "tokens=1 delims==" %%v in ('set pb.') do set "%%v="
    goto:eof


:activOS

Title Advanced Artificial Intelligence 

cls

ping localhost -n 2 >nul

echo   #     # ####### #        #####  ####### #     # #######    #     # ######     #       ###  #####  ####### #          #     #####  
echo   #  #  # #       #       #     # #     # ##   ## #          ##   ## #     #    #        #  #     # #     # #         # #   #     # 
echo   #  #  # #       #       #       #     # # # # # #          # # # # #     #    #        #  #       #     # #        #   #  #       
echo   #  #  # #####   #       #       #     # #  #  # #####      #  #  # ######     #        #  #  #### #     # #       #     #  #####  
echo   #  #  # #       #       #       #     # #     # #          #     # #   #      #        #  #     # #     # #       #######       # 
echo   #  #  # #       #       #     # #     # #     # #          #     # #    #     #        #  #     # #     # #       #     # #     # 
echo    ## ##  ####### #######  #####  ####### #     # #######    #     # #     #    ####### ###  #####  ####### ####### #     #  #####  
                                                                                                                                   
ping localhost -n 6 >nul

cls

echo Welcome to AAI or Advanced Artificial intelligence.

ping localhost -n 3 >nul

echo  
echo.                                                                   Mr.Ligolas, there has been a glitch, you should be redirected to activOS, 
ping localhost -n 3 >nul
echo                                                                    this is AAI, server appeared to be down sir.

ping localhost -n 3 >nul
echo.
echo                                                                     I'm trying to redirect to orbiT, but it appeared that there is some
ping localhost -n 3 >nul

echo. 
echo                                                                      Codec: Code: Fault program, redirect to, an, 

ping localhost -n 3 >nul
cls
echo.
echo redirecting to H E R S A
ping localhost -n 2 >nul
echo Due to unexpected software error. Log list has been sent to AAI orbiT section >A1CF3-FFCV sector C 

cls




echo #     #          #######          ######            #####              #    
echo #     #          #                #     #          #     #            # #   
echo #     #          #                #     #          #                 #   #  
echo #######          #####            ######            #####           #     # 
echo #     #          #                #   #                  #          ####### 
echo #     #          #                #    #           #     #          #     # 
echo #     #          #######          #     #           #####           #     # 
                                                                             

                                                                                    


ping localhost -n 3 >nul
echo.
echo                                                                       Welcome, i'm HERSA
echo.                                                                       

ping localhost -n 3 >nul
echo.
echo                                                                       Error Codes have been found.


ping localhost -n 3 >nul 
echo                                                                       Muzon Taytay Rizal
echo                                                                       34c wind at 3km/h
echo                                                                       It is Partly cloudy sir,
echo                                                                       based on Google.

ping localhost -n 3 >nul

echo INSTALLING P I R O N Security

ping localhost -n 40 >nul 

echo P I R O N Security successfully installed.


call :mfr



















































































































































