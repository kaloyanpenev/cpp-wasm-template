@echo off

:: This script requires a path to clang-format.exe to be provided as the first argument.
:: Usage: run-clang-format.bat "path\to\clang-format.exe" [additional arguments...]

if "%~1"=="" (
    echo Error: Please provide the path to clang-format.exe as the first argument.
    echo Usage: run-clang-format.bat "path\to\clang-format.exe" [additional arguments...]
    exit /b 1
)

set "CLANG_FORMAT_EXE=%~1"
shift

:: Verify the executable exists
if not exist "%CLANG_FORMAT_EXE%" (
    echo Error: clang-format.exe not found at "%CLANG_FORMAT_EXE%"
    exit /b 1
)

set "EXE=NONE"

:: Locate bash - we run the script with bash as it has xargs which is much faster than windows cmd prompt
if exist "%ProgramFiles%\Git\bin\bash.exe" (
	:: Git for Windows
	set "EXE=%ProgramFiles%\Git\bin\bash.exe"
) 

if "%EXE%" == "NONE" (
	echo Failed to find a version of bash to run the script with. Please set it manually in the script, or run ./run-clang-format.sh script from a bash terminal.
	exit /b 1
)

:: Apply the formatting by running the shell script - /D is to set the working dir, /W is to wait for the process to finish /B is to not open a new window
echo Applying clang-format to %~dp0...
start "apply-clang-format" /D "%~dp0" /W /B "%EXE%" "%~dp0/run-clang-format.sh" --executable="%CLANG_FORMAT_EXE%" %*

