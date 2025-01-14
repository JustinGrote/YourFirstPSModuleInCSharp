Describe 'Lab 2: Get a random sentence' {
  BeforeAll {
    $SCRIPT:ProjectName = 'Lab2.RandomSentence'
    $ErrorActionPreference = 'Stop'
    $SCRIPT:ProjectPath = Join-Path $PSScriptRoot "../src/$ProjectName"
    $SCRIPT:PublishPath = Join-Path $ProjectPath 'bin/Debug/net6.0/publish'
    if (-not (Test-Path "$ProjectPath/$ProjectName.csproj")) {
      throw [NotImplementedException]"This lab has not been initialized yet. Hint: dotnet new classlib -f net6.0 -o $ProjectPath"
    }
    $SCRIPT:PackageList = dotnet list $ProjectPath package
    if (-not $PackageList -match 'System.Management.Automation.*7.2') {
      throw [NotImplementedException]"This lab has does not have the System.Management.Automation v7.2 package added for PowerShell module development. Hint: dotnet add $ProjectPath package System.Management.Automation --version 7.2.11"
    }
    if (-not $PackageList -match 'Lorem.Universal.Net') {
      throw [NotImplementedException]"This lab does not have the Lorem Universal package added. Hint: dotnet add $ProjectPath package Lorem.Universal.Net"
    }
    & dotnet publish $ProjectPath
    Import-Module (Join-Path $PublishPath "$ProjectName.dll")
  }
  Context 'Get-PEURandomSentence' {
    It 'Generates a Random Sentence between 5 and 10 words' {
      $actual = Get-PEURandomSentence
      $actual | Should -Not -BeNullOrEmpty

      $words = ($actual -split ' ').Count
      $words | Should -BeGreaterOrEqual 5
      $words | Should -BeLessOrEqual 10
    }
    It 'Generates a sentence between -Min and -Max' {
      $actual = Get-PEURandomSentence -Min 50 -Max 150
      $actual | Should -Not -BeNullOrEmpty

      $words = ($actual -split ' ').Count
      $words | Should -BeGreaterOrEqual 50
      $words | Should -BeLessOrEqual 150
    }
    It '-Name ends the sentence with ", {Name}"' {
      $name = 'PSConfEUParticipant'
      $actual = Get-PEURandomSentence -Name $name
      $actual | Should -Not -BeNullOrEmpty
      $actual | Should -Match -RegularExpression ", $name`$"
    }
    It 'Names provided via pipeline produce 3 separate sentences ending in the persons name' {
      $name = 'PSConfEUParticipant'
      $actual = $name | Get-PEURandomSentence
      $actual | Should -Not -BeNullOrEmpty
      $actual.Count | Should -BeExactly 3
      ($actual | Select-Object -Unique).Count | Should -BeExactly 3
      $actual | ForEach-Object { $_ | Should -Match -RegularExpression ", $name`$" }
    }
  }
}