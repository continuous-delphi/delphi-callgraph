# `delphi-callgraph` Changelog

All notable changes to this project will be documented in this file.

---

## [1.0.0] - 2026-05-17

- deterministic radCallGraph output is enabled by default via
  `--deterministic`; pass `-Deterministic:$false` to keep timestamps
  (Doesn't add a generated date/time stamp)

---

## [0.1.0] - 2026-05-16

- initial standalone PowerShell wrapper for `radCallGraph.exe`
- output format routing for JSON, DOT, and text summary files
- PasDoc GraphViz dispatch using `--graphviz-uses` and `--graphviz-classes`
- Delphi compiler GraphViz dispatch using `--graphviz` and `--graphviz-exclude`
- structured JSON result output via `-OutputFile`
- Pester test suite with fake graph engines for CI

<br />
<br />

### `delphi-callgraph` - a developer tool from Continuous Delphi

![continuous-delphi logo](https://continuous-delphi.github.io/assets/logos/continuous-delphi-480x270.png)

https://github.com/continuous-delphi
