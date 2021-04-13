if exist C:\preload64\KB2756872 goto InsHotfix
goto End

:InsHotfix
pushd C:\preload64\KB2756872
start /w Windows8-RT-KB2756872-x64.msu /quiet /norestart
del /q C:\preload64\KB2756872\Windows8-RT-KB2756872-x64.msu
echo echo KB > C:\preload64\KB2756872\Windows8-RT-KB2756872-x64.msu
popd

:End