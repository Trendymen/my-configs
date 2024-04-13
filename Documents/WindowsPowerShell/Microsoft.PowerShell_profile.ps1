$env:LC_ALL='C.UTF-8'
 $curPath = pwd
 $pathUri = ([uri] $curPath.ToString())
 if($pathUri.LocalPath -eq "C:\Windows\System32") {
     cd "~"
 }
# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
