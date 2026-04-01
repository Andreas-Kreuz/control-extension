@REM NOTE:
@REM -----
@REM Requires Node.js and Yarn/Corepack to be available in PATH.

setlocal
SET oldDir=%CD%
SET projectPath=%~dp0..

call yarn workspace @ak/web-app dev
IF %ERRORLEVEL% NEQ 0 (
   exit /b %ERRORLEVEL%
)

cd %oldDir%
endlocal
