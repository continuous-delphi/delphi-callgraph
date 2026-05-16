# delphi-callgraph

![delphi-callgraph logo](https://continuous-delphi.github.io/assets/logos/delphi-callgraph-480x270.png)


[![Delphi](https://img.shields.io/badge/delphi-red)](https://www.embarcadero.com/products/delphi)
[![CI](https://github.com/continuous-delphi/delphi-callgraph/actions/workflows/ci.yml/badge.svg)](https://github.com/continuous-delphi/delphi-callgraph/actions/workflows/ci.yml)
[![GitHub Release](https://img.shields.io/github/v/release/continuous-delphi/delphi-callgraph?display_name=release)](https://github.com/continuous-delphi/delphi-callgraph/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/continuous-delphi/delphi-callgraph)
[![Continuous Delphi](https://img.shields.io/badge/org-continuous--delphi-red)](https://github.com/continuous-delphi)

Call graph and dependency analyzer wrapper for Delphi source code, with JSON,
DOT, and text outputs.

## Overview

`delphi-callgraph` wraps graph engines behind one PowerShell command surface.
The default engine is `radCallGraph.exe`, which can emit JSON, DOT, and text
summary output from Delphi source. The wrapper also supports DOT dependency
graphs from PasDoc and from the Delphi compiler GraphViz option.

Designed for use as a standalone command and as a future bundled tool inside
[delphi-powershell-ci](https://github.com/continuous-delphi/delphi-powershell-ci).

## Running the Tool

```powershell
pwsh -File .\source\delphi-callgraph.ps1 -Path source `
    -Formats json,dot,txt -OutputDir artifacts\callgraph
```

With an explicit engine path:

```powershell
pwsh -File .\source\delphi-callgraph.ps1 -Path source `
    -EnginePath C:\tools\radCallGraph.exe `
    -Class TMyService -Formats json,dot
```

## PowerShell Compatibility

Runs on Windows PowerShell 5.1 (`powershell.exe`) and PowerShell 7+ (`pwsh`).
The test suite requires PowerShell 7+.

## Supported Engines

| Engine | Default executable | Outputs | Notes |
|---|---|---|---|
| `radCallGraph` | `radCallGraph.exe` | `json`, `dot`, `txt` | Default engine for call graph analysis |
| `PasDoc` | `pasdoc.exe` / `pasdoc` | `dot` | Uses `--graphviz-uses` and `--graphviz-classes` |
| `DCC` | `dcc32.exe` / `dcc32` | `dot` | Uses compiler `--graphviz` output |

## Parameters

| Parameter | Default | Description |
|---|---|---|
| `-Path` | | Source files or directories to analyze. |
| `-Engine` | `radCallGraph` | Graph engine: `radCallGraph`, `PasDoc`, or `DCC`. |
| `-EnginePath` | auto-detect | Explicit path to the engine executable. |
| `-OutputDir` | `callgraph` | Directory for generated graph files. |
| `-Formats` | `json` for radCallGraph, `dot` otherwise | Comma-separated formats: `json`, `dot`, `txt`. |
| `-JsonFile` | `callgraph.json` | Explicit JSON output path. |
| `-DotFile` | engine-specific | Explicit DOT/GV output path. |
| `-SummaryFile` | `callgraph.txt` | Explicit text summary path. |
| `-Class` | | radCallGraph class filter. |
| `-Annotations` | `$true` | Include `{cg:...}` annotation data for radCallGraph. |
| `-GraphKind` | engine default | `call`, `uses`, `classes`, `dependency`, or `all`. |
| `-GraphVizUses` | off | PasDoc unit dependency graph. |
| `-GraphVizClasses` | off | PasDoc class hierarchy graph. |
| `-PasDocOptions` | `@()` | Extra PasDoc options passed before source paths. |
| `-ProjectFile` | | DCC project file for compiler GraphViz output. |
| `-GraphVizExclude` | `@()` | DCC unit patterns for `--graphviz-exclude`. |
| `-EngineArguments` | `@()` | Extra arguments passed to the selected engine. |
| `-TimeoutSeconds` | `300` | Maximum engine runtime before failure. |
| `-OutputFile` | | Structured JSON result file for CI integration. |

## radCallGraph Examples

```powershell
pwsh -File .\source\delphi-callgraph.ps1 -Path source `
    -Engine radCallGraph `
    -Formats json,dot,txt `
    -OutputDir artifacts\callgraph
```

```powershell
pwsh -File .\source\delphi-callgraph.ps1 -Path source `
    -Class TOrderService `
    -Annotations:$false `
    -JsonFile artifacts\callgraph\orders.json
```

## PasDoc Examples

Generate a unit dependency graph:

```powershell
pwsh -File .\source\delphi-callgraph.ps1 -Path source `
    -Engine PasDoc `
    -GraphKind uses `
    -Formats dot `
    -OutputDir artifacts\pasdoc-graph
```

Generate both unit and class graphs:

```powershell
pwsh -File .\source\delphi-callgraph.ps1 -Path source `
    -Engine PasDoc `
    -GraphKind all `
    -Formats dot
```

PasDoc writes `GVUses.dot` and/or `GVClasses.dot` in the output directory.

## Delphi Compiler GraphViz Example

```powershell
pwsh -File .\source\delphi-callgraph.ps1 `
    -Engine DCC `
    -ProjectFile source\MyApp.dpr `
    -GraphVizExclude System.*,Vcl.*,Winapi.* `
    -Formats dot `
    -OutputDir artifacts\compiler-graph
```

The compiler writes a `<project>.gv` GraphViz file.

## Structured Result

Use `-OutputFile` to write a JSON summary for CI tooling:

```json
{
  "engine": "radCallGraph",
  "inputs": ["C:/repo/source"],
  "exitCode": 0,
  "success": true,
  "outputDir": "C:/repo/artifacts/callgraph",
  "formats": ["json", "dot"],
  "files": {
    "json": "C:/repo/artifacts/callgraph/callgraph.json",
    "dot": "C:/repo/artifacts/callgraph/callgraph.dot"
  },
  "summary": {
    "files": 34,
    "nodes": 389,
    "classes": 25,
    "standalone": 36,
    "edges": 1143
  },
  "duration": 1.2
}
```

## Exit Codes

```text
0 = success
1 = unexpected error
2 = invalid arguments
3 = engine executable not found
4 = input file or directory not found
5 = graph engine failed or timed out
```

## Running Tests

Requires PowerShell 7+, Pester 5.7+, and PSScriptAnalyzer.

```powershell
./tests/run-tests.ps1
```

## References

- [PasDoc command line GraphViz options](https://pasdoc.github.io/CommandLine.html)
- [Embarcadero Delphi compiler GraphViz export](https://docwiki.embarcadero.com/RADStudio/Athens/en/GraphViz_file_export_for_the_Delphi_Compiler)

## Maturity

This repository is currently `incubator`. Both implementations are under active development.
It will graduate to `stable` once:

- At least one downstream consumer exists.

Until graduation, breaking changes may occur

## Continuous-Delphi

This tool is part of the [Continuous-Delphi](https://github.com/continuous-delphi)
ecosystem, focused on strengthening Delphi's continued success.
