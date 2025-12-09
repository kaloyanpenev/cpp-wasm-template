@echo off
setlocal

:: clang-format script for Windows. 
:: This script is used to run clang-format on all C/C++ files in the current directory and its subdirectories.
:: This script requires a path to clang-format.exe version 18 to be provided as the first argument.
:: Usage: run-clang-format.bat "path\to\clang-format.exe" [additional arguments...]

if "%~1"=="" (
    echo Error: Please provide the path to clang-format.exe as the first argument.
    echo Usage: run-clang-format.bat "path\to\clang-format.exe" [additional arguments...]
    exit /b 1
)

:: Resolve the directory of this script (trailing backslash included)
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_SH=%SCRIPT_DIR%run-clang-format.sh"

if not exist "%SCRIPT_SH%" (
    echo Error: run-clang-format.sh not found at "%SCRIPT_SH%"
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
start "apply-clang-format" /D "%SCRIPT_DIR%" /W /B "%EXE%" "%SCRIPT_SH%" --executable="%CLANG_FORMAT_EXE%"

endlocal