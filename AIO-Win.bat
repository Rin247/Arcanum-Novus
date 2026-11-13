@echo off
rem ============================================================================
rem  AIO-win -- the Windows part of AIO.bat. Called by AIO.bat, never by hand.
rem  Standalone: stamped per project by tools\split_aio.py, reads nothing else.
rem    build   configure + build          compile  build, configure if needed
rem    deploy  windeployqt into build\Dist, zipped     run   launch the exe
rem    test    ctest, 300s per-test timeout            clean  empty build\
rem  Exit 0 pass, 1 fail, 3 not implemented for this project.
rem ============================================================================
set "AIO_APP=arcanum-novus"
set "AIO_FAMILY=cmake"
set "AIO_EXE="
set "AIO_CMAKE_DIR=source"
set "AIO_CMAKE_PRESETS=1"
set "AIO_CMAKE_QT="
set "AIO_CMAKE_APP="
set "AIO_GRADLE_DIR="
set "AIO_GRADLE_MODULE="
set "AIO_ANDROID_ID="
set "AIO_BUILD_DIR=build"
set "AIO_NODE="
set "AIO_QT_DEPLOY="
rem  A command run before configure, for a project whose build has a precondition:
rem  Daedalus stops its own service first, because a running service holds the exe.
set "AIO_PRE_BUILD="
setlocal EnableExtensions EnableDelayedExpansion
set "AIO_HOME=%~dp0"
if "%AIO_HOME:~-1%"=="\" set "AIO_HOME=%AIO_HOME:~0,-1%"
set "QT_DIR=C:\Dev\Qt\6.12.0\msvc2022_64"
set "CMAKE_EXE=C:\Dev\Qt\Tools\CMake_64\bin\cmake.exe"
set "CTEST_EXE=C:\Dev\Qt\Tools\CMake_64\bin\ctest.exe"
set "NINJA_DIR=C:\Dev\Qt\Tools\Ninja"
set "VCVARS=C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat"
set "JOB_CAP=8"
if exist "%NINJA_DIR%\ninja.exe" set "PATH=%NINJA_DIR%;%PATH%"
if /i "%VERB%"=="build"   goto :aio_win_build
if /i "%VERB%"=="compile" goto :aio_win_build
if /i "%VERB%"=="debug"   goto :aio_win_build
if /i "%VERB%"=="deploy"  goto :aio_win_deploy
if /i "%VERB%"=="run"     goto :aio_win_run
if /i "%VERB%"=="test"    goto :aio_win_test
if /i "%VERB%"=="clean"   goto :aio_win_clean
if /i "%VERB%"=="--list"  goto :aio_win_list
echo [win] %VERB% is not implemented for Windows.
exit /b 3

:aio_win_build
if defined AIO_PRE_BUILD (
    echo [aio] pre-build: %AIO_PRE_BUILD%
    call %AIO_PRE_BUILD%
    if errorlevel 1 (
        echo [aio] the pre-build step failed
        exit /b 1
    )
)
if /i "%AIO_FAMILY%"=="gradle" goto :aio_win_gradle
if /i "%AIO_FAMILY%"=="node" goto :aio_win_node
if "%AIO_CMAKE_DIR%"=="" (
    echo [win] %AIO_APP% has no Windows build.
    exit /b 3
)
call :aio_need_msvc
call :aio_need_cmake
if defined CLEAN if exist "%AIO_HOME%\%AIO_BUILD_DIR%" rmdir /s /q "%AIO_HOME%\%AIO_BUILD_DIR%"
if not exist "%AIO_HOME%\%AIO_BUILD_DIR%\%CONFIG%\CMakeCache.txt" goto :aio_win_do_configure
if not exist "%AIO_HOME%\%AIO_BUILD_DIR%\CMakeCache.txt" goto :aio_win_do_configure
goto :aio_win_build_it

:aio_win_do_configure
call :aio_win_configure
if errorlevel 1 exit /b 1
goto :aio_win_build_it

rem  The configure step: the named preset first, then the platform-named preset,
rem  then -S/-B. Whichever runs, the tree is taken from the cache it wrote.
:aio_win_configure
set "SRC=%AIO_HOME%\%AIO_CMAKE_DIR%"
set "QT_ARG="
if "%AIO_CMAKE_QT%"=="1" set "QT_ARG=-DCMAKE_PREFIX_PATH=%QT_DIR%"
set "ISA_ARG="
if defined X86 set "ISA_ARG=-DX86_ISA=%X86%"
echo [aio] configure "%AIO_CMAKE_DIR%" preset=%AIO_CMAKE_PRESETS% config=%CONFIG%
if "%AIO_CMAKE_PRESETS%"=="1" (
    rem  The stamped preset name first: it is the one the project wrote down, and
    rem  guessing from the configuration is how a tree gets configured twice.
    call :aio_win_try_preset %AIO_CMAKE_PRESET_NAME%
    if "!CFG_RC!"=="0" exit /b 0
    call :aio_win_try_preset %CONFIG%
    if "!CFG_RC!"=="0" exit /b 0
    call :aio_win_try_preset %CONFIG%Win64
    if "!CFG_RC!"=="0" exit /b 0
    set "FOUND="
    for /f "usebackq delims=" %%P in (`"%CMAKE_EXE%" --list-presets 2^>nul`) do (
        echo %%P | findstr /i /c:"windows" /c:"win64" /c:"win-x64" >nul
        if not errorlevel 1 echo %%P | findstr /i /c:"%CONFIG%" /c:"release" >nul
        if not errorlevel 1 if not defined FOUND set "FOUND=%%P"
    )
    if defined FOUND (
        for /f "tokens=1 delims= " %%N in ('!FOUND:^"=!') do call :aio_win_try_preset %%N
        if "!CFG_RC!"=="0" exit /b 0
    )
    echo [aio] no preset configured this project; configuring directly.
)
set "BDIR=%AIO_HOME%\%AIO_BUILD_DIR%\%CONFIG%"
"%CMAKE_EXE%" -S "%SRC%" -B "%BDIR%" -G Ninja -DCMAKE_BUILD_TYPE=%CONFIG% %QT_ARG% %ISA_ARG%
if errorlevel 1 (
    echo [aio] cmake configure failed
    exit /b 1
)
exit /b 0

:aio_win_try_preset
set "CFG_RC=1"
if "%~1"=="" exit /b 0
"%CMAKE_EXE%" --list-presets 2>nul | findstr /i /c:"%~1" >nul
if errorlevel 1 exit /b 0
rem  A preset carries its own cache variables: `cmake --preset X -Dfoo=bar` is an
rem  error, not a preset with an override, so the toolchain arguments are dropped
rem  here rather than passed and refused.
"%CMAKE_EXE%" --preset %1
if errorlevel 1 (
    echo [aio] preset %1 failed
    exit /b 0
)
set "CFG_RC=0"
echo [aio] configured with preset %1
exit /b 0

rem  The tree CMake actually wrote -- flat build\ or build\<cfg>, chosen by the
rem  preset. The configuration's own directory wins when it exists: a scan for the
rem  newest CMakeCache.txt answers with whichever configuration was touched last,
rem  and a tree holding both Debug and Release has both. The scan is only for a
rem  project whose preset wrote a differently-named directory.
:aio_win_tree
set "BDIR=%AIO_HOME%\%AIO_BUILD_DIR%\%CONFIG%"
if exist "%BDIR%\CMakeCache.txt" exit /b 0
set "BDIR="
for /f "delims=" %%C in ('dir /b /s /a-d /o-d "%AIO_HOME%\%AIO_BUILD_DIR%\CMakeCache.txt" 2^>nul') do (
    if not defined BDIR for %%D in ("%%C") do set "BDIR=%%~dpD"
)
if not defined BDIR set "BDIR=%AIO_HOME%\%AIO_BUILD_DIR%\%CONFIG%\"
exit /b 0

:aio_win_build_it
call :aio_clear_qml_cache
call :aio_win_tree
echo [aio] build %AIO_APP% %CONFIG% -j %JOB_CAP% in %BDIR%
"%CMAKE_EXE%" --build "%BDIR%" --config %CONFIG% -j %JOB_CAP%
if errorlevel 1 (
    echo [aio] build failed
    exit /b 1
)
rem  A Qt app that has not been deployed cannot start: 0xC0000135 STATUS_DLL_NOT_FOUND,
rem  and the configure, the link and the suite all pass on the way to it.
rem  The exe is the stamped AIO_EXE, not the project name: a project whose
rem  executable is named differently (Aur's "Aur Studio.exe") is not found by
rem  the project name, and the deploy failed in silence.
if "%AIO_CMAKE_QT%"=="1" call :aio_win_deploy_runtime
if errorlevel 1 exit /b 1
if "%AIO_QT_DEPLOY%"=="1" call :aio_win_package
exit /b 0

:aio_win_deploy_runtime
set "DEPLOY_EXE=%BDIR%\%AIO_EXE%"
if exist "%DEPLOY_EXE%" goto :aio_win_deploy_runtime_go
if not "%AIO_EXE%"=="" (
    rem  The stamp names the app. If the build did not produce it, deploying some
    rem  other exe is worse than failing: it is a green build of the wrong binary.
    echo [aio] %AIO_EXE% was not produced by the build; nothing was deployed
    exit /b 1
)
call :aio_find_exe
set "DEPLOY_EXE=%EXE%"
if not defined DEPLOY_EXE (
    echo [aio] no executable under %AIO_BUILD_DIR%; the Qt runtime was not deployed
    exit /b 1
)
:aio_win_deploy_runtime_go
"%QT_DIR%\bin\windeployqt.exe" --no-translations --compiler-runtime "%DEPLOY_EXE%"
if errorlevel 1 (
    echo [aio] windeployqt failed for "%DEPLOY_EXE%"; the tree will not start without its Qt runtime
    exit /b 1
)
exit /b 0

:aio_win_run
if /i "%AIO_FAMILY%"=="gradle" (
    echo [run] %AIO_APP% is Android; use: AIO.bat run android
    exit /b 3
)
if /i "%AIO_FAMILY%"=="node" (
    echo [run] %AIO_APP% is a Node app; start it with: npm run dev
    exit /b 3
)
call :aio_find_exe
if not defined EXE (
    echo [aio] %AIO_APP% has no built executable in %AIO_BUILD_DIR%; run "AIO.bat build".
    exit /b 1
)
echo [aio] run "%EXE%"
rem  The deployed tree finds its own DLLs; a tree built without windeployqt only
rem  runs while Qt's bin is on PATH, which is this machine and not the user's.
set "PATH=%QT_DIR%\bin;%PATH%"
start "" /d "%EXE%\.." "%EXE%" %EXTRA%
exit /b 0

:aio_find_exe
set "EXE="
for /f "delims=" %%E in ('dir /b /s /a-d /o-d "%AIO_HOME%\%AIO_BUILD_DIR%\%AIO_EXE%" 2^>nul') do if not defined EXE set "EXE=%%E"
if defined EXE exit /b 0
for /f "delims=" %%E in ('dir /b /s /a-d /o-d "%AIO_HOME%\%AIO_BUILD_DIR%\*.exe" 2^>nul') do (
    if not defined EXE (
        echo %%E | findstr /i /c:"CMakeFiles" /c:"vc_redist" /c:"_autogen" /c:"test" /c:"smoke" >nul
        if errorlevel 1 set "EXE=%%E"
    )
)
exit /b 0

:aio_win_test
if "%AIO_CMAKE_APP%"=="0" (
    echo [aio] %AIO_APP% registers no CTest suite; nothing to run.
    exit /b 0
)
rem  The configuration's own tree first, for the same reason as :aio_win_tree -- a
rem  scan over a tree holding both configurations answers with the other one. The
rem  scan is the fallback for a project whose preset wrote a different directory.
set "TDIR=%AIO_HOME%\%AIO_BUILD_DIR%\%CONFIG%"
if exist "%TDIR%\CTestTestfile.cmake" goto aio_win_have_tests
set "TDIR="
for /f "delims=" %%T in ('dir /b /s /a-d /o-d "%AIO_HOME%\%AIO_BUILD_DIR%\CTestTestfile.cmake" 2^>nul') do (
    if not defined TDIR for %%D in ("%%T") do set "TDIR=%%~dpD"
)
if not defined TDIR (
    echo [aio] no configured tree under %AIO_BUILD_DIR%; run "AIO.bat build".
    exit /b 1
)
:aio_win_have_tests
rem  A trailing backslash before a quote escapes the quote, so the arguments after
rem  --test-dir were being read as part of the path.
if "%TDIR:~-1%"=="\" set "TDIR=%TDIR:~0,-1%"
rem  --timeout is named because no test may wait forever (QUIRKS.md 45).
echo [aio] ctest --test-dir "%TDIR%" --timeout 300
"%CTEST_EXE%" --test-dir "%TDIR%" -C Release --output-on-failure --timeout 300
exit /b %ERRORLEVEL%

:aio_win_deploy
if not "%AIO_QT_DEPLOY%"=="1" (
    echo [deploy] %AIO_APP% has no Qt runtime to deploy; nothing was written.
    exit /b 3
)
goto :aio_win_package

:aio_win_package
call :aio_find_exe
if not defined EXE (
    echo [deploy] no executable in %AIO_BUILD_DIR%; build first.
    exit /b 1
)
if not exist "%QT_DIR%\bin\windeployqt.exe" (
    echo [deploy] windeployqt is not at %QT_DIR%\bin\windeployqt.exe
    exit /b 1
)
set "DEPLOY_FLAGS=--release"
if /i "%CONFIG%"=="Debug" set "DEPLOY_FLAGS=--debug"
set "DIST=%AIO_HOME%\%AIO_BUILD_DIR%\Dist"
echo [deploy] windeployqt %DEPLOY_FLAGS% -> %DIST%
"%QT_DIR%\bin\windeployqt.exe" %DEPLOY_FLAGS% --no-translations --compiler-runtime --dir "%DIST%" "%EXE%"
if errorlevel 1 (
    echo [deploy] windeployqt failed
    exit /b 1
)
copy /y "%EXE%" "%DIST%\" >nul
for %%F in ("%EXE%\..\*.dll") do copy /y "%%F" "%DIST%\" >nul 2>&1
powershell -NoProfile -Command "Compress-Archive -Path '%DIST%\*' -DestinationPath '%DIST%.zip' -Force" >nul 2>&1
echo [deploy] packaged -> %DIST%
exit /b 0

:aio_win_clean
if exist "%AIO_HOME%\%AIO_BUILD_DIR%" rmdir /s /q "%AIO_HOME%\%AIO_BUILD_DIR%"
exit /b 0

:aio_win_list
echo   win     cmake="%AIO_CMAKE_DIR%" presets=%AIO_CMAKE_PRESETS% qt=%AIO_CMAKE_QT% tests=%AIO_CMAKE_APP% exe="%AIO_EXE%"
exit /b 0

:aio_win_gradle
call "%AIO_HOME%\%AIO_GRADLE_DIR%\gradlew.bat" -p "%AIO_HOME%\%AIO_GRADLE_DIR%" :%AIO_GRADLE_MODULE%:assembleRelease
exit /b %ERRORLEVEL%

:aio_win_node
if "%AIO_NODE%"=="0" (
    echo [win] %AIO_APP% has no Node build.
    exit /b 3
)
call npm run build --prefix "%AIO_HOME%"
exit /b %ERRORLEVEL%

:aio_need_msvc
rem  MSVC's environment must be in the SAME command as the build (QUIRKS.md 24).
if "%VSCMD_ARG_TGT_ARCH%"=="x64" exit /b 0
if exist "%VCVARS%" call "%VCVARS%" >nul 2>&1
exit /b 0

:aio_need_cmake
if exist "%CMAKE_EXE%" exit /b 0
set "CMAKE_EXE=cmake"
exit /b 0

rem  A stale QML disk cache is read by the running app, which then shows old QML
rem  against new C++. Clear it before every build, for Qt projects only.
:aio_clear_qml_cache
if not "%AIO_CMAKE_QT%%AIO_NODE%"=="10" if not "%AIO_CMAKE_QT%"=="1" exit /b 0
set "HASQML="
for /f "usebackq delims=" %%Q in (`dir /b /s /a-d "%AIO_HOME%\%AIO_CMAKE_DIR%\*.qml" 2^>nul`) do if not defined HASQML set "HASQML=1"
if not defined HASQML exit /b 0
if exist "%AIO_HOME%\%AIO_BUILD_DIR%\.qmlcache" rmdir /s /q "%AIO_HOME%\%AIO_BUILD_DIR%\.qmlcache"
if exist "%LOCALAPPDATA%\%AIO_APP%" for /d %%D in ("%LOCALAPPDATA%\%AIO_APP%\*") do if exist "%%~D\qmlcache" rmdir /s /q "%%~D\qmlcache"
echo [aio] cleared the QML cache
exit /b 0
