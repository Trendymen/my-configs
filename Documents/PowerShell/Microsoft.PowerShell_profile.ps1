$env:LC_ALL='C.UTF-8'
 $curPath = pwd
 $pathUri = ([uri] $curPath.ToString())
 if($pathUri.LocalPath -eq "C:\Windows\System32") {
     cd "~"
 }