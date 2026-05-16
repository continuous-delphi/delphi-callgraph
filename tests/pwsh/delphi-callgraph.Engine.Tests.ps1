Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'delphi-callgraph -- engine dispatch' {

    BeforeAll {
        $script:ScriptPath = (Resolve-Path (Join-Path $PSScriptRoot '../../source/delphi-callgraph.ps1')).Path
        $script:FixtureDir = (Resolve-Path (Join-Path $PSScriptRoot 'fixtures')).Path
        $script:FakeEngine = Join-Path $script:FixtureDir 'fake-graph-engine.ps1'
        $script:SampleUnit = Join-Path $script:FixtureDir 'SampleUnit.pas'
        $script:SampleProject = Join-Path $script:FixtureDir 'SampleProject.dpr'
    }

    BeforeEach {
        $env:DELPHI_CALLGRAPH_FAKE_ARGS_FILE = ''
        $env:DELPHI_CALLGRAPH_FAKE_SLEEP_MS = ''
    }

    AfterEach {
        $env:DELPHI_CALLGRAPH_FAKE_ARGS_FILE = ''
        $env:DELPHI_CALLGRAPH_FAKE_SLEEP_MS = ''
    }

    It 'runs radCallGraph and writes all requested output files' {
        $outDir = Join-Path $TestDrive 'rad'
        $resultFile = Join-Path $TestDrive 'rad-result.json'

        & pwsh -NoProfile -File $script:ScriptPath `
            -Path $script:SampleUnit `
            -EnginePath $script:FakeEngine `
            -Formats json,dot,txt `
            -OutputDir $outDir `
            -OutputFile $resultFile

        $LASTEXITCODE | Should -Be 0
        Test-Path (Join-Path $outDir 'callgraph.json') | Should -Be $true
        Test-Path (Join-Path $outDir 'callgraph.dot') | Should -Be $true
        Test-Path (Join-Path $outDir 'callgraph.txt') | Should -Be $true

        $result = Get-Content -LiteralPath $resultFile -Raw | ConvertFrom-Json
        $result.success | Should -Be $true
        $result.engine | Should -Be 'radCallGraph'
        $result.formats | Should -Contain 'json'
        $result.formats | Should -Contain 'dot'
        $result.formats | Should -Contain 'txt'
    }

    It 'forwards radCallGraph class and annotation options' {
        $outDir = Join-Path $TestDrive 'rad-args'
        $argsFile = Join-Path $TestDrive 'rad-args.json'
        $env:DELPHI_CALLGRAPH_FAKE_ARGS_FILE = $argsFile

        & pwsh -NoProfile -File $script:ScriptPath `
            -Path $script:SampleUnit `
            -EnginePath $script:FakeEngine `
            -Formats json `
            -OutputDir $outDir `
            -Class TFoo `
            -Annotations:$false

        $LASTEXITCODE | Should -Be 0
        $args = @(Get-Content -LiteralPath $argsFile -Raw | ConvertFrom-Json)
        $args | Should -Contain '--class'
        $args | Should -Contain 'TFoo'
        $args | Should -Contain '--no-annotations'
    }

    It 'runs PasDoc with both GraphViz options when GraphKind is all' {
        $outDir = Join-Path $TestDrive 'pasdoc'
        $argsFile = Join-Path $TestDrive 'pasdoc-args.json'
        $env:DELPHI_CALLGRAPH_FAKE_ARGS_FILE = $argsFile

        & pwsh -NoProfile -File $script:ScriptPath `
            -Path $script:SampleUnit `
            -Engine PasDoc `
            -EnginePath $script:FakeEngine `
            -GraphKind all `
            -Formats dot `
            -OutputDir $outDir

        $LASTEXITCODE | Should -Be 0
        Test-Path (Join-Path $outDir 'GVUses.dot') | Should -Be $true
        Test-Path (Join-Path $outDir 'GVClasses.dot') | Should -Be $true

        $args = @(Get-Content -LiteralPath $argsFile -Raw | ConvertFrom-Json)
        $args | Should -Contain '--graphviz-uses'
        $args | Should -Contain '--graphviz-classes'
        $args | Should -Contain '--output'
    }

    It 'runs DCC with graphviz exclude options' {
        $outDir = Join-Path $TestDrive 'dcc'
        $argsFile = Join-Path $TestDrive 'dcc-args.json'
        $resultFile = Join-Path $TestDrive 'dcc-result.json'
        $env:DELPHI_CALLGRAPH_FAKE_ARGS_FILE = $argsFile

        & pwsh -NoProfile -File $script:ScriptPath `
            -ProjectFile $script:SampleProject `
            -Engine DCC `
            -EnginePath $script:FakeEngine `
            -GraphVizExclude System.*,Vcl.* `
            -Formats dot `
            -OutputDir $outDir `
            -OutputFile $resultFile

        $LASTEXITCODE | Should -Be 0
        Test-Path (Join-Path $outDir 'SampleProject.gv') | Should -Be $true

        $args = @(Get-Content -LiteralPath $argsFile -Raw | ConvertFrom-Json)
        $args | Should -Contain '--graphviz'
        $args | Should -Contain '--graphviz-exclude=System.*;Vcl.*'

        $result = Get-Content -LiteralPath $resultFile -Raw | ConvertFrom-Json
        $result.files.dot | Should -Be (Join-Path $outDir 'SampleProject.gv')
    }

    It 'returns engine failure when the engine exits non-zero' {
        & pwsh -NoProfile -File $script:ScriptPath `
            -Path $script:SampleUnit `
            -EnginePath $script:FakeEngine `
            -EngineArguments --fake-fail `
            -Formats json `
            -OutputDir (Join-Path $TestDrive 'fail') 2>$null

        $LASTEXITCODE | Should -Be 5
    }

    It 'returns engine failure when timeout is exceeded' {
        $env:DELPHI_CALLGRAPH_FAKE_SLEEP_MS = '2000'

        & pwsh -NoProfile -File $script:ScriptPath `
            -Path $script:SampleUnit `
            -EnginePath $script:FakeEngine `
            -Formats json `
            -OutputDir (Join-Path $TestDrive 'timeout') `
            -TimeoutSeconds 1 2>$null

        $LASTEXITCODE | Should -Be 5
    }

}
