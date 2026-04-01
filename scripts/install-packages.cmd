@REM NOTE:
@REM -----
@REM This helper installs project dependencies via Yarn.
@REM Requires Node.js and Yarn/Corepack to be available in PATH.

setlocal
SET oldDir=%CD%
SET projectPath=%~dp0..

@REM Build EEP Web Shared
call yarn
IF %ERRORLEVEL% NEQ 0 (
   exit /b %ERRORLEVEL%
)

cd %oldDir%
endlocal
