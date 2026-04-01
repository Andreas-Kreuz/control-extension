@REM NOTE:
@REM -----
@REM Requires Node.js and Yarn/Corepack to be available in PATH.

setlocal
SET oldDir=%CD%
SET projectPath=%~dp0..

cd /d "%projectPath%"
call yarn.cmd workspace @ak/web-app run cy-tests
IF %ERRORLEVEL% NEQ 0 (
   exit /b %ERRORLEVEL%
)

cd %oldDir%
endlocal
