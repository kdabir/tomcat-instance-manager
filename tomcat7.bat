@echo off
rem ============================================================================
rem UTILITY SCRIPT FOR CAREATING AND WORKING WITH MULTIPLE TOMCAT INSTANCES
rem author : kunal
rem last-edit : 08 July 2011
rem ============================================================================

rem ============================================================================
rem PRE : unzip the latest tomcat distribution and have CATALINA_HOME & JAVA_HOME set
rem CATALINA_HOME & JAVA_HOME must be set as environment variable before running this script
rem SERVICE_NAME can not have special character like -_ or spaces
rem ============================================================================

rem ============================================================================
rem dev notes :
rem to write to a file use >, to append use >>
rem % ~ n remove the quotes "" (if present) from params
rem can copy tomcat7 & tomcat7w exe as service name in current dir but this wont be much useful
rem TODO jvm mem args for both scv and cmd mode startup
rem TODO stop-clean-restart
rem ============================================================================

rem setlocal ensures changes to any environment variable are local to this script
setlocal

rem ==============================SETTINGS======================================
rem SET THE CATALINA_BASE HERE OR COMMENT IF YOU WANT TO USE ENV VAR
rem set CATALINA_BASE=D:\etc\tomcat-test
rem set SERVICE_NAME=TomcatTest
rem set SERVICE_DISPLAY_NAME=Apache Tomcat Test Instance
rem set SERVICE_DESCRIPTION=Apache Tomcat Test Instance based at %CATALINA_BASE%
rem ============================================================================


rem ======================PREPROCESSING AND OPTION PARSING======================
rem CHECK IF JAVA_HOME IS VALID
if "%JAVA_HOME%" == "" goto java-not-set
if not exist "%JAVA_HOME%\bin\java.exe" goto java-not-valid

rem CHECK IF HOME IS VALID
if "%CATALINA_HOME%" == "" goto home-not-set
if not exist "%CATALINA_HOME%\bin\startup.bat" goto home-not-valid
if not exist "%CATALINA_HOME%\bin\shutdown.bat" goto home-not-valid
if not exist "%CATALINA_HOME%\bin\service.bat" goto home-not-valid
if not exist "%CATALINA_HOME%\bin\tomcat7.exe" goto home-not-valid
if not exist "%CATALINA_HOME%\bin\tomcat7w.exe" goto home-not-valid

rem CHECK FOR OPTIONS THAT DO NOT REQUIRE CATALINA_BASE
if "%1" == "" goto no-match
if "%1" == "create-instance" goto create-instance
if "%1" == "remove-instance" goto remove-instance

rem before proceeding further check for CATLAINA_BASE
if "%CATALINA_BASE%" == "" goto base-not-set
if not exist "%CATALINA_BASE%" goto base-not-valid
if not exist "%CATALINA_BASE%\conf\server.xml" goto base-not-valid

if "%1" == "start" goto start
if "%1" == "stop" goto stop
if "%1" == "restart" goto restart
if "%1" == "clean" goto clean
if "%1" == "clean-all" goto clean-all
if "%1" == "service" goto service
:no-match
goto display-usage
rem ============================================================================

rem ============================================================================
:create-instance
rem check if other params are present
if "%~2" == "" goto display-usage
if "%~3" == "" goto display-usage

if not exist "%~3" goto invalid-install-path
set CATALINA_BASE=%~3\%~2
if exist "%CATALINA_BASE%" goto instance-dir-already-exists

rem create the new tomcat base dir, webapps, logs, temp, work dir and copy the conf dir from home
mkdir "%CATALINA_BASE%"
mkdir "%CATALINA_BASE%\conf"
mkdir "%CATALINA_BASE%\logs"
mkdir "%CATALINA_BASE%\work"
mkdir "%CATALINA_BASE%\temp"
mkdir "%CATALINA_BASE%\webapps"
copy "%CATALINA_HOME%\conf\" "%CATALINA_BASE%\conf\"

rem random check if copying is successful
if not exist "%CATALINA_BASE%\conf\server.xml" goto base-not-valid
if exist "%CATALINA_BASE%" echo Instance created successfully : %CATALINA_BASE%

rem set the defaults
set SERVICE_NAME=%~2
set SERVICE_DISPLAY_NAME=Apache Tomcat : %~2
set SERVICE_DESCRIPTION=Apache Tomcat '%~2' instance based at %CATALINA_BASE%

rem set if sent as parameters
if not "%~4" == "" set SERVICE_NAME=%~4
if not "%~5" == "" set SERVICE_DISPLAY_NAME=%~5
if not "%~6" == "" set SERVICE_DESCRIPTION=%~6

rem write a new bat file that sets the env vars and call this bat
echo @echo off>%~2.bat
echo set CATALINA_BASE=%CATALINA_BASE%>>%~2.bat
echo set SERVICE_NAME=%SERVICE_NAME%>>%~2.bat
echo set SERVICE_DISPLAY_NAME=%SERVICE_DISPLAY_NAME%>>%~2.bat
echo set SERVICE_DESCRIPTION=%SERVICE_DESCRIPTION%>>%~2.bat
echo %0 %%*>>%~2.bat
if exist "%~2.bat" echo Instance handler script created successfully

goto end
rem ============================================================================

rem ============================================================================
:remove-instance
rem TODO IMP: before removing the instance, check if its installed as service.
if "%~2" == "" goto display-usage
if "%~3" == "" goto display-usage

set CATALINA_BASE=%~3\%~2
if not exist "%CATALINA_BASE%" goto base-not-valid

rem may ask once for confirmation
rmdir /s /q "%CATALINA_BASE%"
rem remove the env setter bat file
del "%~2.bat"
if not exist "%CATALINA_BASE%" echo Instance removed successfully
if not exist "%~2.bat" echo Instance handler script remvoed successfully
goto end
rem ============================================================================

rem ============================================================================
rem cleans logs, work & temp dir
:clean
rmdir /s /q "%CATALINA_BASE%\logs"
mkdir "%CATALINA_BASE%\logs"
rmdir /s /q "%CATALINA_BASE%\work"
mkdir "%CATALINA_BASE%\work"
rmdir /s /q "%CATALINA_BASE%\temp"
mkdir "%CATALINA_BASE%\temp"
echo \nDONE
goto end
rem ============================================================================

rem ============================================================================
:clean-all
rmdir /s /q "%CATALINA_BASE%\webapps"
mkdir "%CATALINA_BASE%\webapps"
goto clean
rem ============================================================================

rem ============================================================================
:start
call "%CATALINA_HOME%\bin\startup.bat"
echo SERVER STARTED (IN A SEPERATE WINDOW)
goto end
rem ============================================================================

rem ============================================================================
:stop
call "%CATALINA_HOME%\bin\shutdown.bat"
echo SERVER STOPPED
goto end
rem ============================================================================

rem ============================================================================
:restart
echo STOPPING THE SERVER...
call "%CATALINA_HOME%\bin\shutdown.bat"
echo STARTING THE SERVER...
call "%CATALINA_HOME%\bin\startup.bat"
echo SERVER RESTARTED
goto end
rem ============================================================================


rem ============================================================================
:service
rem set some common variables beforehand
set TOMCATEXE=%CATALINA_HOME%\bin\tomcat7.exe
set TOMCAT_SVC_MGR=%CATALINA_HOME%\bin\tomcat7w.exe

if "%2" == "" goto display-usage
if "%2" == "install" goto service-install
if "%2" == "remove" goto service-remove
if "%2" == "edit" goto service-edit
if "%2" == "monitor" goto service-monitor
if "%2" == "run-in-console" goto service-run-in-console
if "%2" == "start" goto service-start
if "%2" == "stop" goto service-stop
if "%2" == "restart" goto service-restart
rem ============================================================================

rem ============================================================================
:service-install
set PR_DISPLAYNAME=%SERVICE_DISPLAY_NAME%
set PR_DESCRIPTION=%SERVICE_DESCRIPTION%
set PR_INSTALL=%TOMCATEXE%
set PR_STARTUP=MANUAL
set PR_JVM=%JAVA_HOME%\jre\bin\server\jvm.dll
if not exist "%PR_JVM%" set PR_JVM=%JAVA_HOME%\jre\bin\client\jvm.dll
if not exist "%PR_JVM%" set PR_JVM=auto
set PR_LOGPATH=%CATALINA_BASE%\logs
set PR_STDOUTPUT=auto
set PR_STDERROR=auto
set PR_CLASSPATH=%CATALINA_HOME%\bin\bootstrap.jar
set PR_STARTCLASS=org.apache.catalina.startup.Bootstrap
set PR_STOPCLASS=org.apache.catalina.startup.Bootstrap
set PR_STARTMODE=jvm
set PR_STOPMODE=jvm
rem the env vars set below do not work, have to pass them as cmd line option
rem from apache's site "Note: PR_DEPENDSON, PR_ENVIRONMENT, PR_JVMOPTIONS, PR_JVMMS, PR_JVMMX, PR_JVMSS, PR_STARTPARAMS, PR_STOPPARAMS and PR_STOPTIMEOUT will not work until this bug is fixed: DAEMON-49"
rem set PR_JVMOPTIONS="-Dcatalina.home=%CATALINA_HOME%;-Dcatalina.base=%CATALINA_BASE%;-Djava.endorsed.dirs=%CATALINA_HOME%\endorsed;-Djava.io.tmpdir=%CATALINA_BASE%\temp;-Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager;-Djava.util.logging.config.file=%CATALINA_BASE%\conf\logging.properties"
rem set PR_STARTPARAMS=start
rem set PR_STOPPARAMS=stop
rem set PR_JVMMS=128
rem set PR_JVMMX=256
"%TOMCATEXE%" //IS//%SERVICE_NAME% --JvmOptions "-Dcatalina.base=%CATALINA_BASE%;-Dcatalina.home=%CATALINA_HOME%;-Djava.endorsed.dirs=%CATALINA_HOME%\endorsed;-Djava.io.tmpdir=%CATALINA_BASE%\temp;-Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager;-Djava.util.logging.config.file=%CATALINA_BASE%\conf\logging.properties" --StartParams start --StopParams stop --JvmMs 128 --JvmMx 256

if errorlevel 1 goto service-install-failed
echo SERVICE '%SERVICE_NAME%'-'%SERVICE_DESCRIPTION%' INSTALLED SUCCESSFULLY
goto end
rem ============================================================================

rem ============================================================================
:service-remove
"%TOMCATEXE%" //DS//%SERVICE_NAME%
echo SERVICE '%SERVICE_NAME%'-'%SERVICE_DESCRIPTION%' REMOVED SUCCESSFULLY
goto end
rem ============================================================================

rem ============================================================================
:service-edit
"%TOMCAT_SVC_MGR%" //ES//%SERVICE_NAME%
goto end
rem ============================================================================

rem ============================================================================
:service-monitor
"%TOMCAT_SVC_MGR%" //MS//%SERVICE_NAME%
goto end
rem ============================================================================

rem ============================================================================
:service-run-in-console
"%TOMCATEXE%" //TS//%SERVICE_NAME%
goto end
rem ============================================================================

rem ============================================================================
:service-start
net start %SERVICE_NAME%
goto end
rem ============================================================================

rem ============================================================================
:service-stop
net stop %SERVICE_NAME%
goto end
rem ============================================================================

rem ============================================================================
:service-restart
net stop %SERVICE_NAME%
net start %SERVICE_NAME%
goto end
rem ============================================================================

rem ================================MESSAGES====================================
:home-not-set
echo 'CATALINA_HOME' ENVIRONMENT VARIABLE MISSING. PLEASE SET IT BEFORE USING THE SCRIPT
goto end
:base-not-set
echo 'CATALINA_BASE' ENVIRONMENT VARIABLE MISSING. PLEASE SET IT BEFORE USING THE SCRIPT
goto end
:java-not-set
echo 'JAVA_HOME' ENVIRONMENT VARIABLE MISSING. PLEASE SET IT BEFORE USING THE SCRIPT
goto end
:home-not-valid
echo INVALID TOMCAT HOME DIR 'CATALINA_HOME' : %CATALINA_HOME%
goto end
:base-not-valid
echo INVALID TOMCAT BASE DIR 'CATALINA_BASE' : %CATALINA_BASE%
goto end
:java-not-valid
echo INVALID TOMCAT BASE DIR 'JAVA_HOME' : %JAVA_HOME%
goto end
:invalid-install-path
echo could not find the install-path (%3) directory
goto end
:display-usage
echo USAGE :
echo 	%0 create-instance {instance-name} {install-path}
echo			[service-name] [service-display-name] [service-description]
echo 	%0 remove-instance {instance-name} {install-path}
echo 	%0 start ^| stop ^| restart ^| clean
echo 	%0 service start ^| stop ^| restart ^| run-in-console
echo 	%0 service install ^| remove ^| edit ^| monitor
echo 	where {var} - mandatory param  [var] - optional param
goto end
:service-display-usage
echo TODO
goto end
:service-install-failed
echo COULDNOT INSTALL SERVICE '%SERVICE_NAME%'
goto end
:invalid-install-path
echo invalid install path %3
goto end
:instance-dir-already-exists
echo %3\%2 already exists
goto end
rem ============================================================================

:end
