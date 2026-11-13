@echo off
rem ============================================================================
rem  AIO -- the one build entry point for arcanum-novus.
rem
rem  Written by tools\split_aio.py. This file takes the command line or the
rem  menu and calls one of three standalone platform files beside it:
rem    AIO-Win.bat      Windows: configure/build, windeployqt, ctest
rem    AIO-Linux.bat    Linux: the same, on a Linux host
rem    AIO-android.bat  Android: Gradle assemble/compile, adb install, am start
rem
rem    AIO.bat build windows Release    AIO.bat test android
rem    AIO.bat run                      with no verb: the menu
rem
rem  Exit 0 pass, 1 fail, 2 unknown verb, 3 not implemented for this project.
rem  No verb pauses, so an agent can call it; only the menu waits, and only
rem  when neither CI nor NO_INTERACTIVE is set.
rem ============================================================================
set "AIO_APP=arcanum-novus"
set "AIO_FAMILY=cmake"
set "AIO_GRADLE_DIR=@GRADLE_DIR@"
set "AIO_ANDROID_ID=@ANDROID_ID@"

setlocal EnableExtensions EnableDelayedExpansion
set "AIO_HOME=%~dp0"
if "%AIO_HOME:~-1%"=="\" set "AIO_HOME=%AIO_HOME:~0,-1%"
set "NO_PAUSE="
if defined CI set "NO_PAUSE=1"
if defined NO_INTERACTIVE set "NO_PAUSE=1"
set "WANT_VERB="
set "WANT_OS="
set "WANT_CFG="
set "EXTRA="
set "VERB="
set "OS="
set "CONFIG="
set "CLEAN="
set "X86="
set "EXE="
set "FACE="

set "WANT_VERB=%~1"
rem  A non-interactive caller gets usage, not a menu that blocks on a read.
if not defined WANT_VERB if defined NO_PAUSE goto :print_usage
if not defined WANT_VERB goto :main_menu
if /i "%WANT_VERB%"=="help" goto :print_usage
if /i "%WANT_VERB%"=="-h" goto :print_usage
if /i "%WANT_VERB%"=="--help" goto :print_usage
if /i "%WANT_VERB%"=="list" goto :main_list
call :verb_known "%WANT_VERB%"
if not defined VERB goto :main_unknown
shift
set "ARG=%~1"
call :take_platform "%ARG%"
if not errorlevel 1 shift
set "ARG=%~1"
call :take_platform "%ARG%"
if not errorlevel 1 shift
:main_collect
if "%~1"=="" goto :main_go
set "ARG=%~1"
call :take_extra "%ARG%"
shift
goto :main_collect

:main_go
if /i "%VERB%"=="update-third-party" (
    echo [aio] arcanum-novus has no third-party update step; nothing to do.
    set "RC=3"
) else (
    if /i "%AIO_FAMILY%"=="gradle" if not "%OS%"=="aio-android" set "OS=aio-android"
    call :call_face
    set "RC=!ERRORLEVEL!"
)
endlocal & exit /b %RC%

:main_unknown
echo [aio] unknown command: %WANT_VERB%
call :print_usage
endlocal & exit /b 2

:main_menu
echo.
echo  AIO -- %AIO_APP%    [%AIO_FAMILY%]
echo  -------------------------------------------------------------------
echo   --- Build ---                 --- Compile ---         --- Deploy ---
echo    1. Windows Release             5. Windows               8. Windows
echo    2. Windows Debug               6. Linux                 9. Linux
echo    3. Linux                       7. Android              10. Android
echo    4. Android Release
echo   -------------------------------------------------------------------
echo   11. Debug (build Debug, then launch)
echo   12. Run        13. Test       14. Clean build folder
echo    0. Exit
echo.
set "AIO_CHOICE="
set /p "AIO_CHOICE=Choice: "
rem  An empty read is a closed or redirected stdin: exit, never spin.
if not defined AIO_CHOICE goto :main_exit
set "VERB="
if "%AIO_CHOICE%"=="1" (set "VERB=build" & set "OS=AIO-Win" & set "CONFIG=Release")
if "%AIO_CHOICE%"=="2" (set "VERB=build" & set "OS=AIO-Win" & set "CONFIG=Debug")
if "%AIO_CHOICE%"=="3" (set "VERB=build" & set "OS=AIO-Linux" & set "CONFIG=Release")
if "%AIO_CHOICE%"=="4" (set "VERB=build" & set "OS=aio-android" & set "CONFIG=Release")
if "%AIO_CHOICE%"=="5" (set "VERB=compile" & set "OS=AIO-Win" & set "CONFIG=Release")
if "%AIO_CHOICE%"=="6" (set "VERB=compile" & set "OS=AIO-Linux" & set "CONFIG=Release")
if "%AIO_CHOICE%"=="7" (set "VERB=compile" & set "OS=aio-android" & set "CONFIG=Release")
if "%AIO_CHOICE%"=="8" (set "VERB=deploy" & set "OS=AIO-Win" & set "CONFIG=Release")
if "%AIO_CHOICE%"=="9" (set "VERB=deploy" & set "OS=AIO-Linux" & set "CONFIG=Release")
if "%AIO_CHOICE%"=="10" (set "VERB=deploy" & set "OS=aio-android" & set "CONFIG=Release")
if "%AIO_CHOICE%"=="11" set "VERB=debug"
if "%AIO_CHOICE%"=="12" set "VERB=run"
if "%AIO_CHOICE%"=="13" set "VERB=test"
if "%AIO_CHOICE%"=="14" set "VERB=clean"
if "%AIO_CHOICE%"=="0" goto :main_exit
if /i "%AIO_CHOICE%"=="X" goto :main_exit
if /i "%AIO_CHOICE%"=="Q" goto :main_exit
if "%VERB%"=="" goto :main_menu
call :main_go
if "%ERRORLEVEL%"=="0" (echo [aio] OK) else (echo [aio] FAILED)
if not defined NO_PAUSE pause
endlocal & exit /b 0

:main_exit
endlocal & exit /b 0

:print_usage
echo Usage: AIO.bat [verb] [platform] [config] [options]
echo   verbs      build compile debug deploy run test clean list update-third-party
echo   platforms  windows linux android
echo   configs    Release Debug
echo   options    --clean  --x86 v3^|v4  (native projects only)
echo   list       print what this project detected
echo No verb opens the menu; a verb never prompts.
exit /b 0

:main_list
echo AIO.bat -- %AIO_APP%
echo   family   %AIO_FAMILY%
echo   owned by win
endlocal & exit /b 0

:verb_known
set "VERB="
if /i "%~1"=="build" (set "VERB=build" & set "OS=AIO-Win" & set "CONFIG=Release")
if /i "%~1"=="compile" (set "VERB=compile" & set "OS=AIO-Win" & set "CONFIG=Release")
if /i "%~1"=="debug" (set "VERB=debug" & set "OS=AIO-Win" & set "CONFIG=Debug")
if /i "%~1"=="deploy" (set "VERB=deploy" & set "OS=AIO-Win" & set "CONFIG=Release")
if /i "%~1"=="run" (set "VERB=run" & set "OS=AIO-Win" & set "CONFIG=Release")
if /i "%~1"=="test" (set "VERB=test" & set "OS=AIO-Win" & set "CONFIG=Debug")
if /i "%~1"=="clean" set "VERB=clean"
if /i "%~1"=="update-third-party" set "VERB=update-third-party"
exit /b 0

:take_platform
set "ARG=%~1"
if /i "%ARG%"=="windows" (set "OS=AIO-Win" & exit /b 0)
if /i "%ARG%"=="win" (set "OS=AIO-Win" & exit /b 0)
if /i "%ARG%"=="linux" (set "OS=AIO-Linux" & exit /b 0)
if /i "%ARG%"=="android" (set "OS=aio-android" & exit /b 0)
if /i "%ARG%"=="Release" (set "CONFIG=Release" & exit /b 0)
if /i "%ARG%"=="Debug" (set "CONFIG=Debug" & exit /b 0)
exit /b 1

:take_extra
set "ARG=%~1"
if /i "%ARG%"=="clean" (set "CLEAN=1" & exit /b 0)
if /i "%ARG%"=="rebuild" (set "CLEAN=1" & exit /b 0)
if /i "%ARG%"=="--clean" (set "CLEAN=1" & exit /b 0)
if /i "%ARG%"=="--x86" (set "X86=v3" & exit /b 0) else if defined X86 if "!X86!"=="v3" if /i "%ARG%"=="v4" (set "X86=v4" & exit /b 0)
set "EXTRA=%EXTRA% %ARG%"
exit /b 0

:call_face
if not defined OS set "OS=AIO-Win"
set "FACE=%AIO_HOME%\%OS%.bat"
if not exist "%FACE%" (
    echo [aio] %AIO_APP% has no %OS% part beside this file.
    exit /b 3
)
call "%FACE%"
exit /b %ERRORLEVEL%
