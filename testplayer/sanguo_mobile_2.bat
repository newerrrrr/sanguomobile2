@echo off
set base_dir=%~dp0
%base_dir:~0,2%
set "res_dir=%base_dir%..\
pushd %res_dir%
start "sanguo_mobile_2" "%base_dir%\bin\sanguo_mobile_2.exe"
popd
exit