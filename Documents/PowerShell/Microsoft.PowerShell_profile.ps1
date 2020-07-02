
$env:LC_ALL = 'C.UTF-8'
$curPath = Get-Location
$pathUri = ([uri] $curPath.ToString())
if ($pathUri.LocalPath -eq "C:\Windows\System32") {
    Set-Location "~"
}
# Increase history
$MaximumHistoryCount = 10000

# Produce UTF-8 by default
$PSDefaultParameterValues["Out-File:Encoding"] = "utf8"

# Show selection menu for tab
Set-PSReadlineKeyHandler -Chord Tab -Function MenuComplete

# Helper Functions
#######################################################

function uptime {
    Get-WmiObject win32_operatingsystem | select csname, @{LABEL = 'LastBootUpTime';
        EXPRESSION                                               = { $_.ConverttoDateTime($_.lastbootuptime) }
    }
}

function redo-profile {
    & $profile
}

function find-file($name) {
    Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | foreach {
        $place_path = $_.directory
        Write-Output "${place_path}\${_}"
    }
}

function Get-Path {
    ($Env:Path).Split(";")
}

function unzip ($file) {
    $dirname = (Get-Item $file).Basename
    Write-Output("Extracting", $file, "to", $dirname)
    New-Item -Force -ItemType directory -Path $dirname
    expand-archive $file -OutputPath $dirname -ShowProgress
}


# Unixlike commands
#######################################################

function df {
    get-volume
}

function sed($file, $find, $replace) {
    (Get-Content $file).replace("$find", $replace) | Set-Content $file
}

function sed-recursive($filePattern, $find, $replace) {
    $files = Get-ChildItem . "$filePattern" -rec
    foreach ($file in $files) {
        (Get-Content $file.PSPath) |
        Foreach-Object { $_ -replace "$find", "$replace" } |
        Set-Content $file.PSPath
    }
}

function grep($regex, $dir) {
    if ( $dir ) {
        Get-ChildItem $dir | Out-String | select-string $regex
        return
    }
    $input | Out-String | select-string $regex
}

function grepv($regex) {
    $input | Where-Object { !$_.Contains($regex) }
}

function which($name) {
    Get-Command $name | Select-Object -ExpandProperty Definition
}

function export($name, $value) {
    set-item -force -path "env:$name" -value $value;
}

function pkill($name) {
    Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
}

function pgrep($name) {
    Get-Process $name
}

function touch($file) {
    "" | New-Item $file -Encoding UTF-8
} 

# https://gist.github.com/aroben/5542538
function pstree {
    $ProcessesById = @{ }
    foreach ($Process in (Get-WMIObject -Class Win32_Process)) {
        $ProcessesById[$Process.ProcessId] = $Process
    }

    $ProcessesWithoutParents = @()
    $ProcessesByParent = @{ }
    foreach ($Pair in $ProcessesById.GetEnumerator()) {
        $Process = $Pair.Value

        if (($Process.ParentProcessId -eq 0) -or !$ProcessesById.ContainsKey($Process.ParentProcessId)) {
            $ProcessesWithoutParents += $Process
            continue
        }

        if (!$ProcessesByParent.ContainsKey($Process.ParentProcessId)) {
            $ProcessesByParent[$Process.ParentProcessId] = @()
        }
        $Siblings = $ProcessesByParent[$Process.ParentProcessId]
        $Siblings += $Process
        $ProcessesByParent[$Process.ParentProcessId] = $Siblings
    }

    function Show-ProcessTree([UInt32]$ProcessId, $IndentLevel) {
        $Process = $ProcessesById[$ProcessId]
        $Indent = " " * $IndentLevel
        if ($Process.CommandLine) {
            $Description = $Process.CommandLine
        }
        else {
            $Description = $Process.Caption
        }

        Write-Output ("{0,6}{1} {2}" -f $Process.ProcessId, $Indent, $Description)
        foreach ($Child in ($ProcessesByParent[$ProcessId] | Sort-Object CreationDate)) {
            Show-ProcessTree $Child.ProcessId ($IndentLevel + 4)
        }
    }

    Write-Output ("{0,6} {1}" -f "PID", "Command Line")
    Write-Output ("{0,6} {1}" -f "---", "------------")

    foreach ($Process in ($ProcessesWithoutParents | Sort-Object CreationDate)) {
        Show-ProcessTree $Process.ProcessId 0
    }
}

# Aliases
#######################################################

function pull () { & git pull $args }
function checkout () { & git checkout $args }