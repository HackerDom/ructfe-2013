@echo off
setlocal enabledelayedexpansion

if /I "%1"=="-h" (
  echo Usage:
  echo   %0 Teams-count Services-count Events-count
  goto :END
)

set T=%1
set S=%2
set E=%3
echo Xml generating...
xmlgen.pl %T% %S%
echo Monitor generating...
mongen.pl %T% %S% %E%
echo Cleaning...
clean.pl monitor.dat
echo Done!
:END
endlocal