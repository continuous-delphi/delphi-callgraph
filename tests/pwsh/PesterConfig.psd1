@{
  Run = @{
    Path = './tests/pwsh'
  }
  Output = @{
    Verbosity = 'Detailed'
  }
  TestResult = @{
    Enabled      = $true
    OutputPath   = './tests/pwsh/results/pester-results.xml'
    OutputFormat = 'NUnitXml'
  }
  CodeCoverage = @{
    Enabled = $false
  }
}
