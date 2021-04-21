
echo %date% %time% Patch MS request in DriverCD Ver3.0 >> c:\windows\PQArecord.log

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\ASUS\MSRecommend" /v DisplayVersion /t REG_SZ /d 3.0 /f

rem backup Disable3Fun
copy /y Disable3Fun.exe C:\Preload64
:: disable InstantOn Gadget
call InsRunCfg.exe /disable

:: disable Smart gesture function
rem set _ASUS_REG_PATH_="HKLM\SOFTWARE\ASUS\ASUS Smart Gesture"
rem reg ADD %_ASUS_REG_PATH_% /v SupportMS /t REG_DWORD /d 1 /f

rem 
echo call C:\Preload64\Disable3Fun.exe >> c:\preload64\patch\AsDCDInst.cmd

:: clean desktop
echo if exist C:\preload64\patch\sleep.exe start /w C:\preload64\patch\sleep.exe 3 >> c:\preload64\patch\AsDCDInst.cmd
echo del /q  c:\users\public\Desktop\*.* >> c:\preload64\patch\AsDCDInst.cmd
echo del /q  c:\users\public\Desktop\*.* >> c:\Windows\Temp\Local1.cmd
echo Clean Desktop > c:\windows\log\CleanDT.log
