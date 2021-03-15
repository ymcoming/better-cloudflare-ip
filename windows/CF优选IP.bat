chcp 936
cls
@echo off
cd "%~dp0"
color A
setlocal enabledelayedexpansion
set /p bandwidth=������������ CloudFlare �������Ĵ����С(��λ Mbps):
set /a speed=%bandwidth%*128
set /a startH=%time:~0,2%
if %time:~3,1% EQU 0 (set /a startM=%time:~4,1%) else (set /a startM=%time:~3,2%)
if %time:~6,1% EQU 0 (set /a startS=%time:~7,1%) else (set /a startS=%time:~6,2%)
goto start
:start
del data.txt ip.txt CR.txt CRLF.txt cut.txt speed.txt meta.txt
RD /S /Q temp
cls
if exist "resolve.txt" goto resolve
if not exist "resolve.txt" goto dnsresolve
:dnsresolve
title DNS������ȡCF�ڵ�IP
curl --ipv4 --retry 3 -v https://speed.cloudflare.com/__down>meta.txt 2>&1
for /f "tokens=3 delims= " %%i in ('findstr "cf-meta-asn:" meta.txt') do (
set asn=%%i
)
for /f "tokens=3 delims= " %%i in ('findstr "cf-meta-city:" meta.txt') do (
set city=%%i
)
for /f "tokens=3 delims= " %%i in ('findstr "cf-meta-latitude:" meta.txt') do (
set latitude=%%i
)
for /f "tokens=3 delims= " %%i in ('findstr "cf-meta-longitude:" meta.txt') do (
set longitude=%%i
)
curl --ipv4 --retry 3 https://service.udpfile.com?asn=%asn%^&city=%city% -o data.txt -#
goto getip
:resolve
for /f "delims=" %%i in (resolve.txt) do (
set resolveip=%%i
)
title ָ�������ȡCF�ڵ�IP
curl --ipv4 --resolve speed.cloudflare.com:443:%resolveip% --retry 3 -v https://speed.cloudflare.com/__down>meta.txt 2>&1
for /f "tokens=3 delims= " %%i in ('findstr "cf-meta-asn:" meta.txt') do (
set asn=%%i
)
for /f "tokens=3 delims= " %%i in ('findstr "cf-meta-city:" meta.txt') do (
set city=%%i
)
for /f "tokens=3 delims= " %%i in ('findstr "cf-meta-latitude:" meta.txt') do (
set latitude=%%i
)
for /f "tokens=3 delims= " %%i in ('findstr "cf-meta-longitude:" meta.txt') do (
set longitude=%%i
)
curl --ipv4 --resolve service.udpfile.com:443:%resolveip% --retry 3 https://service.udpfile.com?asn=%asn%^&city=%city% -o data.txt -#
if not exist "data.txt" goto start
if not exist "meta.txt" goto start
del meta.txt
:getip
for /f "skip=4" %%i in (data.txt) do (
echo %%i>>ip.txt
)
for /f "tokens=2 delims==" %%a in ('findstr /C:"domain" data.txt') do (
set domain=%%a
)
for /f "tokens=2 delims==" %%a in ('findstr /C:"file" data.txt') do (
set file=%%a
)
for /f "tokens=2 delims==" %%a in ('findstr /C:"url" data.txt') do (
set url=%%a
)
for /f "tokens=2 delims==" %%a in ('findstr /C:"app" data.txt') do (
set app=%%a
if !app! NEQ 20210315 (echo �����°汾����: !app!&echo ���µ�ַ: !url!&title ���º�ſ���ʹ��&echo ��������˳�����&pause>nul&exit)
)
del data.txt
title ���� ICMP ������
fping -f ip.txt -c 20 --interval=0 -s > ping.csv
echo ��ʼ������������
findstr "%%" ping.csv>temp.csv
del ping.csv
for /f "tokens=1,2,5 delims=, " %%a in (temp.csv) do (
echo %%a,%%b,%%c>>ping.csv
)
del temp.csv
for /f "delims=" %%a in (ping.csv) do (
set temp=%%a
set temp=!temp:%%=!
set temp=!temp:ms=!
echo !temp!>>temp.csv
)
del ping.csv
for /f "tokens=1,2,3 delims=," %%a in (temp.csv) do (
if %%b LSS 10 (echo   %%b,%%c,%%a>>ping.csv) else if %%b LSS 100 (echo  %%b,%%c,%%a>>ping.csv)
)
del temp.csv
for /f "tokens=1,2,3 delims=," %%a in (ping.csv) do (
set temp=%%b
set temp=!temp:.0=!
set temp=!temp:.1=!
set temp=!temp:.2=!
set temp=!temp:.3=!
set temp=!temp:.4=!
set temp=!temp:.5=!
set temp=!temp:.6=!
set temp=!temp:.7=!
set temp=!temp:.8=!
set temp=!temp:.9=!
if !temp! LSS 100 (echo %%a, %%b,%%c>>temp.csv) else (echo %%a,%%b,%%c>>temp.csv)
)
sort /+5 temp.csv | sort /o ping.csv
del ip.txt
del temp.csv
del sort.txt
cls
set /a a=0
for /f "tokens=3 delims=," %%a in (ping.csv) do (
echo %%a>>sort.txt
set /a a=a+1
title ��ȡ���Ժ��IP��ַ----���ڴ���� !a! ��
)
del ping.csv
cls
set count=0
for /f "tokens=1,2" %%a in ('type "sort.txt"') do (
echo %%a >> ip.txt
title ѡȡ20�����������ٵ�IP��ַ���ز���
set /a count+=1
if !count! equ 20 goto speedtest
)
:speedtest
del sort.txt
mkdir temp
cls
for /f "tokens=1,2" %%a in ('type "ip.txt"') do (
start /b curl --resolve !domain!:443:%%a https://!domain!/!file! -o temp/%%a -s --connect-timeout 2 --max-time 10
echo %%a ��������
)
del ip.txt
chcp 936
cls
echo �ȴ����ٽ��̽���,ɸѡ��������ѡ��IP
timeout /T 15 /NOBREAK
cd temp
dir /o:-s /b > ../ip.txt
cd ..
set /a n=0
for /f "delims=" %%a in (ip.txt) do (
set /a n+=1&if !n!==1 set "a=%%a")
set /a n=0
for /f "delims=" %%a in (ip.txt) do (
set /a n+=1&if !n!==2 set "b=%%a")
set /a n=0
for /f "delims=" %%a in (ip.txt) do (
set /a n+=1&if !n!==3 set "c=%%a")
for /f "delims=" %%a in ('dir temp /b /a-d^| find /v /c "&#@"') do (
		if %%a GEQ 3 (
		chcp 936
		) else (
		goto start
		)
	)
title ��ѡ��IP��ַΪ (!a!)-(!b!)-(!c!)
goto one
:one
chcp 936
del CRLF.txt cut.txt speed.txt
cls
echo ��һ�β��� !a!
curl --resolve !domain!:443:!a! https://!domain!/!file! -o nul --connect-timeout 5 --max-time 10 > CR.txt 2>&1
findstr "0:" CR.txt >> CRLF.txt
CR2CRLF CRLF.txt
for /f "delims=" %%a in (CRLF.txt) do (
set s=%%a
set s=!s:~73,5!
echo !s%!>>cut.txt
)
for /f "delims=" %%a in ('findstr /v "k M" cut.txt') do (
set x=%%a
set x=!x:~0,5!
set /a x=!x%!/1024
echo !x! >> speed.txt
)
for /f "delims=" %%a in ('findstr "k" cut.txt') do (
set x=%%a
set x=!x:~0,4!
set /a x=!x%!
echo !x! >> speed.txt
)
for /f "delims=" %%a in ('findstr "M" cut.txt') do (
set x=%%a
set x=!x:~0,2!
set y=%%a
set y=!y:~3,1!
set /a x=!x%!*1024
set /a x=!y%!*1024/10
set /a z=x+y
echo !z! >> speed.txt
)
set /a max=0
for /f "tokens=1,2" %%a in ('type "speed.txt"') do (
if %%a GEQ !max! set /a max=%%a
)
set /a max1=max
if !max! GEQ !speed! (cls&set anycast=!a!&goto end) else (goto two)
:two
chcp 936
del CRLF.txt cut.txt speed.txt
cls
echo ��һ�β��� !a! �������������,��ֵ�ٶ� !max! kB/s
echo �ڶ��β��� !a!
curl --resolve !domain!:443:!a! https://!domain!/!file! -o nul --connect-timeout 5 --max-time 10 > CR.txt 2>&1
findstr "0:" CR.txt >> CRLF.txt
CR2CRLF CRLF.txt
for /f "delims=" %%a in (CRLF.txt) do (
set s=%%a
set s=!s:~73,5!
echo !s%!>>cut.txt
)
for /f "delims=" %%a in ('findstr /v "k M" cut.txt') do (
set x=%%a
set x=!x:~0,5!
set /a x=!x%!/1024
echo !x! >> speed.txt
)
for /f "delims=" %%a in ('findstr "k" cut.txt') do (
set x=%%a
set x=!x:~0,4!
set /a x=!x%!
echo !x! >> speed.txt
)
for /f "delims=" %%a in ('findstr "M" cut.txt') do (
set x=%%a
set x=!x:~0,2!
set y=%%a
set y=!y:~3,1!
set /a x=!x%!*1024
set /a y=!y%!*1024/10
set /a z=x+y
echo !z! >> speed.txt
)
set /a max=0
for /f "tokens=1,2" %%a in ('type "speed.txt"') do (
if %%a GEQ !max! set /a max=%%a
)
set /a max2=max
if !max! GEQ !speed! (cls&set anycast=!a!&goto end) else (goto three)
:three
chcp 936
del CRLF.txt cut.txt speed.txt
cls
if !max1! GEQ !max2! (curl --ipv4 --resolve service.udpfile.com:443:!a! --retry 3 -s -X POST -d "20210315-!a!-!max1!" https://service.udpfile.com?asn=%asn%^&city=%city% -o nul --connect-timeout 5 --max-time 10) else (curl --ipv4 --resolve service.udpfile.com:443:!a! --retry 3 -s -X POST -d "20210315-!a!-!max2!" https://service.udpfile.com?asn=%asn%^&city=%city% -o nul --connect-timeout 5 --max-time 10)
echo �ڶ��β��� !a! �������������,��ֵ�ٶ� !max! kB/s
echo ��һ�β��� !b!
curl --resolve !domain!:443:!b! https://!domain!/!file! -o nul --connect-timeout 5 --max-time 10 > CR.txt 2>&1
findstr "0:" CR.txt >> CRLF.txt
CR2CRLF CRLF.txt
for /f "delims=" %%a in (CRLF.txt) do (
set s=%%a
set s=!s:~73,5!
echo !s%!>>cut.txt
)
for /f "delims=" %%a in ('findstr /v "k M" cut.txt') do (
set x=%%a
set x=!x:~0,5!
set /a x=!x%!/1024
echo !x! >> speed.txt
)
for /f "delims=" %%a in ('findstr "k" cut.txt') do (
set x=%%a
set x=!x:~0,4!
set /a x=!x%!
echo !x! >> speed.txt
)
for /f "delims=" %%a in ('findstr "M" cut.txt') do (
set x=%%a
set x=!x:~0,2!
set y=%%a
set y=!y:~3,1!
set /a x=!x%!*1024
set /a y=!y%!*1024/10
set /a z=x+y
echo !z! >> speed.txt
)
set /a max=0
for /f "tokens=1,2" %%a in ('type "speed.txt"') do (
if %%a GEQ !max! set /a max=%%a
)
set /a max1=max
if !max! GEQ !speed! (cls&set anycast=!b!&goto end) else (goto four)
:four
chcp 936
del CRLF.txt cut.txt speed.txt
cls
echo ��һ�β��� !b! �������������,��ֵ�ٶ� !max! kB/s
echo �ڶ��β��� !b!
curl --resolve !domain!:443:!b! https://!domain!/!file! -o nul --connect-timeout 5 --max-time 10 > CR.txt 2>&1
findstr "0:" CR.txt >> CRLF.txt
CR2CRLF CRLF.txt
for /f "delims=" %%a in (CRLF.txt) do (
set s=%%a
set s=!s:~73,5!
echo !s%!>>cut.txt
)
for /f "delims=" %%a in ('findstr /v "k M" cut.txt') do (
set x=%%a
set x=!x:~0,5!
set /a x=!x%!/1024
echo !x! >> speed.txt
)
for /f "delims=" %%a in ('findstr "k" cut.txt') do (
set x=%%a
set x=!x:~0,4!
set /a x=!x%!
echo !x! >> speed.txt
)
for /f "delims=" %%a in ('findstr "M" cut.txt') do (
set x=%%a
set x=!x:~0,2!
set y=%%a
set y=!y:~3,1!
set /a x=!x%!*1024
set /a y=!y%!*1024/10
set /a z=x+y
echo !z! >> speed.txt
)
set /a max=0
for /f "tokens=1,2" %%a in ('type "speed.txt"') do (
if %%a GEQ !max! set /a max=%%a
)
set /a max2=max
if !max! GEQ !speed! (cls&set anycast=!b!&goto end) else (goto five)
:five
chcp 936
del CRLF.txt cut.txt speed.txt
cls
if !max1! GEQ !max2! (curl --ipv4 --resolve service.udpfile.com:443:!b! --retry 3 -s -X POST -d "20210315-!b!-!max1!" https://service.udpfile.com?asn=%asn%^&city=%city% -o nul --connect-timeout 5 --max-time 10) else (curl --ipv4 --resolve service.udpfile.com:443:!b! --retry 3 -s -X POST -d "20210315-!b!-!max2!" https://service.udpfile.com?asn=%asn%^&city=%city% -o nul --connect-timeout 5 --max-time 10)
echo �ڶ��β��� !b! �������������,��ֵ�ٶ� !max! kB/s
echo ��һ�β��� !c!
curl --resolve !domain!:443:!c! https://!domain!/!file! -o nul --connect-timeout 5 --max-time 10 > CR.txt 2>&1
findstr "0:" CR.txt >> CRLF.txt
CR2CRLF CRLF.txt
for /f "delims=" %%a in (CRLF.txt) do (
set s=%%a
set s=!s:~73,5!
echo !s%!>>cut.txt
)
for /f "delims=" %%a in ('findstr /v "k M" cut.txt') do (
set x=%%a
set x=!x:~0,5!
set /a x=!x%!/1024
echo !x! >> speed.txt
)
for /f "delims=" %%a in ('findstr "k" cut.txt') do (
set x=%%a
set x=!x:~0,4!
set /a x=!x%!
echo !x! >> speed.txt
)
for /f "delims=" %%a in ('findstr "M" cut.txt') do (
set x=%%a
set x=!x:~0,2!
set y=%%a
set y=!y:~3,1!
set /a x=!x%!*1024
set /a y=!y%!*1024/10
set /a z=x+y
echo !z! >> speed.txt
)
set /a max=0
for /f "tokens=1,2" %%a in ('type "speed.txt"') do (
if %%a GEQ !max! set /a max=%%a
)
set /a max1=max
if !max! GEQ !speed! (cls&set anycast=!c!&goto end) else (goto six)
:six
chcp 936
del CRLF.txt cut.txt speed.txt
cls
echo ��һ�β��� !c! �������������,��ֵ�ٶ� !max! kB/s
echo �ڶ��β��� !c!
curl --resolve !domain!:443:!c! https://!domain!/!file! -o nul --connect-timeout 5 --max-time 10 > CR.txt 2>&1
findstr "0:" CR.txt >> CRLF.txt
CR2CRLF CRLF.txt
for /f "delims=" %%a in (CRLF.txt) do (
set s=%%a
set s=!s:~73,5!
echo !s%!>>cut.txt
)
for /f "delims=" %%a in ('findstr /v "k M" cut.txt') do (
set x=%%a
set x=!x:~0,5!
set /a x=!x%!/1024
echo !x! >> speed.txt
)
for /f "delims=" %%a in ('findstr "k" cut.txt') do (
set x=%%a
set x=!x:~0,4!
set /a x=!x%!
echo !x! >> speed.txt
)
for /f "delims=" %%a in ('findstr "M" cut.txt') do (
set x=%%a
set x=!x:~0,2!
set y=%%a
set y=!y:~3,1!
set /a x=!x%!*1024
set /a y=!y%!*1024/10
set /a z=x+y
echo !z! >> speed.txt
)
set /a max=0
for /f "tokens=1,2" %%a in ('type "speed.txt"') do (
if %%a GEQ !max! set /a max=%%a
)
set /a max2=max
if !max! GEQ !speed! (cls&set anycast=!c!&goto end) else (goto seven)
:seven
chcp 936
del CRLF.txt cut.txt speed.txt
cls
echo �ڶ��β��� !c! �������������,��ֵ�ٶ� !max! kB/s
if !max1! GEQ !max2! (curl --ipv4 --resolve service.udpfile.com:443:!c! --retry 3 -s -X POST -d "20210315-!c!-!max1!" https://service.udpfile.com?asn=%asn%^&city=%city% -o nul --connect-timeout 5 --max-time 10) else (curl --ipv4 --resolve service.udpfile.com:443:!c! --retry 3 -s -X POST -d "20210315-!c!-!max2!" https://service.udpfile.com?asn=%asn%^&city=%city% -o nul --connect-timeout 5 --max-time 10)
goto start
:end
set /a realbandwidth=max/128
set /a stopH=%time:~0,2%
if %time:~3,1% EQU 0 (set /a stopM=%time:~4,1%) else (set /a stopM=%time:~3,2%)
if %time:~6,1% EQU 0 (set /a stopS=%time:~7,1%) else (set /a stopS=%time:~6,2%)
set /a starttime=%startH%*3600+%startM%*60+%startS%
set /a stoptime=%stopH%*3600+%stopM%*60+%stopS%
if %starttime% GTR %stoptime% (set /a alltime=86400-%starttime%+%stoptime%) else (set /a alltime=%stoptime%-%starttime%)
curl --ipv4 --resolve service.udpfile.com:443:!anycast! --retry 3 -s -X POST -d "20210315-!anycast!-!max!" https://service.udpfile.com?asn=%asn%^&city=%city% -o data.txt
for /f "tokens=2 delims==" %%a in ('findstr /C:"publicip" data.txt') do (
set publicip=%%a
)
for /f "tokens=2 delims==" %%a in ('findstr /C:"colo" data.txt') do (
set colo=%%a
)
echo ��ѡIP !anycast! ���� %bandwidth% Mbps��������
echo ����IP !publicip!
echo ������ AS%asn%
echo ��γ�� %longitude%,%latitude%
echo META���� %city%
echo ʵ����� %realbandwidth% Mbps
echo ��ֵ�ٶ� !max! kB/s
echo �������� !colo!
echo �ܼ���ʱ %alltime% ��
echo !anycast!>resolve.txt
echo !anycast!|clip
del data.txt ip.txt CR.txt CRLF.txt cut.txt speed.txt meta.txt
RD /S /Q temp
echo ��ѡIP�Ѿ��Զ����Ƶ�������
echo ��������ر�
pause>nul