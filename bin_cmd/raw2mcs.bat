@echo off
where /q perl
IF ERRORLEVEL 1 (
SET "PERLEXE=C:\Program Files\Git\usr\bin\perl.exe"
) ELSE (
SET "PERLEXE=perl"
)
"%PERLEXE%" "-I" "%~dp0..\lib" "%~dp0..\bin\raw2mcs" %*
