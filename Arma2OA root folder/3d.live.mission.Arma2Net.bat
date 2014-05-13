SETLOCAL ENABLEEXTENSIONS


:v64_path_a2
For /F "Tokens=2* skip=2" %%A In ('REG QUERY "HKLM\SOFTWARE\Wow6432Node\Bohemia Interactive Studio\ArmA 2" /v "MAIN"') Do (set _ARMA2PATH=%%B)

IF NOT DEFINED _ARMA2PATH (GOTO v32_path_a2) ELSE (GOTO v64_path_a2oa)

:v32_path_a2
For /F "Tokens=2* skip=2" %%C In ('REG QUERY "HKLM\SOFTWARE\Bohemia Interactive Studio\ArmA 2" /v "MAIN"') Do (set _ARMA2PATH=%%D)

IF NOT DEFINED _ARMA2PATH (GOTO uac_PATH_A2) ELSE (GOTO v64_path_a2oa)

:uac_PATH_A2
@FOR /F "tokens=2* delims=	 " %%I IN ('REG QUERY "HKLM\SOFTWARE\Wow6432Node\Bohemia Interactive Studio\ArmA 2" /v "MAIN"') DO (SET _ARMA2PATH=%%J)

IF NOT DEFINED _ARMA2PATH (GOTO std_PATH_A2) ELSE (GOTO v64_path_a2oa)

:std_PATH_A2
@FOR /F "tokens=2* delims=	 " %%K IN ('REG QUERY "HKLM\SOFTWARE\Bohemia Interactive Studio\ArmA 2" /v "MAIN"') DO (SET _ARMA2PATH=%%L)

IF NOT DEFINED _ARMA2PATH (GOTO ENDfailA2) ELSE (GOTO v64_path_a2oa)



:v64_path_a2oa
For /F "Tokens=2* skip=2" %%E In ('REG QUERY "HKLM\SOFTWARE\Wow6432Node\Bohemia Interactive Studio\ArmA 2 OA" /v "MAIN"') Do (set _ARMA2OAPATH=%%F)

IF NOT DEFINED _ARMA2OAPATH (GOTO v32_path_a2oa) ELSE (GOTO RUN)

:v32_path_a2oa
For /F "Tokens=2* skip=2" %%G In ('REG QUERY "HKLM\SOFTWARE\Bohemia Interactive Studio\ArmA 2 OA" /v "MAIN"') Do set (_ARMA2OAPATH=%%H)

IF NOT DEFINED _ARMA2OAPATH (GOTO uac_PATH_A2OA) ELSE (GOTO RUN)

:uac_PATH_A2OA
@FOR /F "tokens=2* delims=	 " %%M IN ('REG QUERY "HKLM\SOFTWARE\Wow6432Node\Bohemia Interactive Studio\ArmA 2 OA" /v "MAIN"') DO (SET _ARMA2OAPATH=%%N)

IF NOT DEFINED _ARMA2OAPATH (GOTO std_PATH_A2OA) ELSE (GOTO RUN)

:std_PATH_A2OA
@FOR /F "tokens=2* delims=	 " %%O IN ('REG QUERY "HKLM\SOFTWARE\Bohemia Interactive Studio\ArmA 2 OA" /v "MAIN"') DO (SET _ARMA2OAPATH=%%P)

IF NOT DEFINED _ARMA2OAPATH (GOTO ENDfailA2OA) ELSE (GOTO RUN)

:run
call "%_ARMA2OAPATH%\Expansion\beta\ARMA2OA.exe" "-arma2netdev" "-mod=%_ARMA2PATH%;EXPANSION;ca" "-mod=Expansion\beta;Expansion\beta\Expansion" -mod=@DayZ_Epoch;@Arma2NET -nosplash -noPause -world=empty -winxp -cpuCount=4 -exThreads=3 %1 %2 %3 %4 %5 %6 %7 %8 %9 

ENDLOCAL

:end
@exit /B 0

:ENDfailA2
@exit /B 1

:ENDfailA2OA
@exit /B 2