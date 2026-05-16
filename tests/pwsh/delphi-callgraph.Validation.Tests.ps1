Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'delphi-callgraph -- validation' {

    BeforeAll {
        $script:ScriptPath = (Resolve-Path (Join-Path $PSScriptRoot '../../source/delphi-callgraph.ps1')).Path
        $script:FixtureDir = (Resolve-Path (Join-Path $PSScriptRoot 'fixtures')).Path
        $script:SampleUnit = Join-Path $script:FixtureDir 'SampleUnit.pas'
    }

    It 'exits with code 0 for -Version' {
        & pwsh -NoProfile -File $script:ScriptPath -Version
        $LASTEXITCODE | Should -Be 0
    }

    It 'outputs JSON for -Version -Format json' {
        $output = & pwsh -NoProfile -File $script:ScriptPath -Version -Format json
        $parsed = $output | ConvertFrom-Json
        $parsed.tool.name | Should -Be 'delphi-callgraph'
        $parsed.tool.version | Should -Not -BeNullOrEmpty
    }

    It 'exits with code 2 when no path or project file is supplied' {
        & pwsh -NoProfile -File $script:ScriptPath 2>$null
        $LASTEXITCODE | Should -Be 2
    }

    It 'exits with code 4 when an input path is missing' {
        & pwsh -NoProfile -File $script:ScriptPath -Path (Join-Path $TestDrive 'missing.pas') 2>$null
        $LASTEXITCODE | Should -Be 4
    }

    It 'exits with code 2 for an invalid output format' {
        & pwsh -NoProfile -File $script:ScriptPath -Path $script:SampleUnit -Formats xml 2>$null
        $LASTEXITCODE | Should -Be 2
    }

    It 'exits with code 2 when PasDoc is asked for JSON output' {
        & pwsh -NoProfile -File $script:ScriptPath -Path $script:SampleUnit -Engine PasDoc -Formats json 2>$null
        $LASTEXITCODE | Should -Be 2
    }

    It 'exits with code 3 when the engine cannot be found' {
        & pwsh -NoProfile -File $script:ScriptPath -Path $script:SampleUnit -EnginePath 'definitely-missing-callgraph-engine.exe' 2>$null
        $LASTEXITCODE | Should -Be 3
    }

}
