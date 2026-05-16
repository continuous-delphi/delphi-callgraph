param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Arguments
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not [string]::IsNullOrWhiteSpace($env:DELPHI_CALLGRAPH_FAKE_SLEEP_MS)) {
    Start-Sleep -Milliseconds ([int]$env:DELPHI_CALLGRAPH_FAKE_SLEEP_MS)
}

if (-not [string]::IsNullOrWhiteSpace($env:DELPHI_CALLGRAPH_FAKE_ARGS_FILE)) {
    $parent = [System.IO.Path]::GetDirectoryName($env:DELPHI_CALLGRAPH_FAKE_ARGS_FILE)
    if (-not [string]::IsNullOrWhiteSpace($parent) -and -not (Test-Path -LiteralPath $parent -PathType Container)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    Set-Content -LiteralPath $env:DELPHI_CALLGRAPH_FAKE_ARGS_FILE -Value ($Arguments | ConvertTo-Json -Compress) -Encoding UTF8
}

if ($Arguments -contains '--fake-fail') {
    exit 9
}

for ($i = 0; $i -lt $Arguments.Count; $i++) {
    $arg = $Arguments[$i]
    if ($arg -in @('--json', '--dot', '--summary') -and $i + 1 -lt $Arguments.Count) {
        $outFile = $Arguments[$i + 1]
        $parent = [System.IO.Path]::GetDirectoryName($outFile)
        if (-not [string]::IsNullOrWhiteSpace($parent) -and -not (Test-Path -LiteralPath $parent -PathType Container)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }

        switch ($arg) {
            '--json'    { Set-Content -LiteralPath $outFile -Value '{"nodes":[],"edges":[]}' -Encoding UTF8 }
            '--dot'     { Set-Content -LiteralPath $outFile -Value 'digraph G { A -> B }' -Encoding UTF8 }
            '--summary' { Set-Content -LiteralPath $outFile -Value 'Call graph summary' -Encoding UTF8 }
        }
    }
}

if ($Arguments -contains '--graphviz-uses') {
    Set-Content -LiteralPath (Join-Path (Get-Location).Path 'GVUses.dot') -Value 'digraph Uses { A -> B }' -Encoding UTF8
}

if ($Arguments -contains '--graphviz-classes') {
    Set-Content -LiteralPath (Join-Path (Get-Location).Path 'GVClasses.dot') -Value 'digraph Classes { TFoo -> TBar }' -Encoding UTF8
}

if ($Arguments -contains '--graphviz') {
    $projectFile = @($Arguments | Where-Object { $_ -notmatch '^-' } | Select-Object -Last 1)
    $baseName = if ($projectFile.Count -gt 0) {
        [System.IO.Path]::GetFileNameWithoutExtension($projectFile[0])
    }
    else {
        'callgraph'
    }
    Set-Content -LiteralPath (Join-Path (Get-Location).Path "$baseName.gv") -Value 'digraph Project { App -> Unit1 }' -Encoding UTF8
}

exit 0
