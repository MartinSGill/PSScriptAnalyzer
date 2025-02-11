$directory = Split-Path $MyInvocation.MyCommand.Path
$settingsTestDirectory = [System.IO.Path]::Combine($directory, "SettingsTest")
$project1Root = [System.IO.Path]::Combine($settingsTestDirectory, "Project1")
$project2Root = [System.IO.Path]::Combine($settingsTestDirectory, "Project2")
$settingsTypeName = 'Microsoft.Windows.PowerShell.ScriptAnalyzer.Settings'

Describe "Settings Precedence" {
    Context "settings object is explicit" {
        It "runs rules from the explicit setting file" {
            $settingsFilepath = [System.IO.Path]::Combine($project1Root, "ExplicitSettings.psd1")
            $violations = Invoke-ScriptAnalyzer -Path $project1Root -Settings $settingsFilepath -Recurse
            $violations.Count | Should -Be 2
        }
    }

    Context "settings file is implicit" {
        It "runs rules from the implicit setting file using the -Path parameter set" {
            $violations = Invoke-ScriptAnalyzer -Path $project1Root -Recurse
            $violations.Count | Should -Be 1
            $violations[0].RuleName | Should -Be "PSAvoidUsingCmdletAliases"
        }

        It "runs rules from the implicit setting file using the -ScriptDefinition parameter set" {
            Push-Location $project1Root
            $violations = Invoke-ScriptAnalyzer -ScriptDefinition 'gci; Write-Host' -Recurse
            Pop-Location
            $violations.Count | Should -Be 1
            $violations[0].RuleName | Should -Be "PSAvoidUsingCmdletAliases" `
                -Because 'the implicit settings file should have run only the PSAvoidUsingCmdletAliases rule but not PSAvoidUsingWriteHost'
        }

        It "cannot find file if not named PSScriptAnalyzerSettings.psd1" {
            $violations = Invoke-ScriptAnalyzer -Path $project2Root -Recurse
            $violations.Count | Should -Be 2
        }
    }
}

Describe "Settings Class" {
    Context "When an empty hashtable is provided" {

        It "Should return empty <name> property" -TestCases @(
            @{ Name = "IncludeRules" }
            @{ Name = "ExcludeRules" }
            @{ Name = "Severity" }
            @{ Name = "RuleArguments" }
            ) {
                Param($Name)

                $settings = New-Object -TypeName $settingsTypeName -ArgumentList @{}
                ${settings}.${Name}.Count | Should -Be 0
        }

        It "Should be able to parse empty settings hashtable from settings file" {
            $testPSSASettingsFilePath = "TestDrive:\PSSASettings.psd1"
            Set-Content $testPSSASettingsFilePath -Value '@{ExcludeRules = @()}'
            Invoke-ScriptAnalyzer -ScriptDefinition 'gci' -Settings $testPSSASettingsFilePath | Should -Not -BeNullOrEmpty
        }
    }

    Context "When a string is provided for IncludeRules in a hashtable" {
        BeforeAll {
            $ruleName = "PSAvoidCmdletAliases"
            $settings = New-Object -TypeName $settingsTypeName -ArgumentList @{ IncludeRules = $ruleName }
        }

        It "Should return an IncludeRules array with 1 element" {
            $settings.IncludeRules.Count | Should -Be 1
        }

        It "Should return the rule in the IncludeRules array" {
            $settings.IncludeRules[0] | Should -Be $ruleName
        }
    }

    Context "When rule arguments are provided in a hashtable" {
        BeforeAll {
            $settingsHashtable = @{
                Rules = @{
                    PSAvoidUsingCmdletAliases = @{
                        WhiteList = @("cd", "cp")
                    }
                }
            }
            $settings = New-Object -TypeName $settingsTypeName -ArgumentList $settingsHashtable
        }

        It "Should return the rule arguments" {
            $settings.RuleArguments["PSAvoidUsingCmdletAliases"]["WhiteList"].Count | Should -Be 2
            $settings.RuleArguments["PSAvoidUsingCmdletAliases"]["WhiteList"][0] | Should -Be "cd"
            $settings.RuleArguments["PSAvoidUsingCmdletAliases"]["WhiteList"][1] | Should -Be "cp"
        }

        It "Should Be case insensitive" {
            $settings.RuleArguments["psAvoidUsingCmdletAliases"]["whiteList"].Count | Should -Be 2
            $settings.RuleArguments["psAvoidUsingCmdletAliases"]["whiteList"][0] | Should -Be "cd"
            $settings.RuleArguments["psAvoidUsingCmdletAliases"]["whiteList"][1] | Should -Be "cp"
        }
    }

    Context "When a settings file path is provided" {
        BeforeAll {
            $settings = New-Object -TypeName $settingsTypeName `
                              -ArgumentList ([System.IO.Path]::Combine($project1Root, "ExplicitSettings.psd1"))
        }

        $expectedNumberOfIncludeRules = 3
        It "Should return $expectedNumberOfIncludeRules IncludeRules" {
            $settings.IncludeRules.Count | Should -Be $expectedNumberOfIncludeRules
        }

        $expectedNumberOfExcludeRules = 3
        It "Should return $expectedNumberOfExcludeRules ExcludeRules" {
            $settings.ExcludeRules.Count | Should -Be $expectedNumberOfExcludeRules
        }

        $expectedNumberOfRuleArguments = 3
        It "Should return $expectedNumberOfRuleArguments rule argument" {
            $settings.RuleArguments.Count | Should -Be 3
        }

        It "Should parse boolean type argument" {
            $settings.RuleArguments["PSUseConsistentIndentation"]["Enable"] | Should -BeTrue
        }

        It "Should parse int type argument" {
            $settings.RuleArguments["PSUseConsistentIndentation"]["IndentationSize"] | Should -Be 4
        }

        It "Should parse string literal" {
            $settings.RuleArguments["PSProvideCommentHelp"]["Placement"] | Should -Be 'end'
        }
    }

    Context "When CustomRulePath parameter is provided" {
        It "Should return an array of 1 item when only 1 path is given in a hashtable" {
            $rulePath = "C:\rules\module1"
            $settingsHashtable = @{
                CustomRulePath = $rulePath
            }

            $settings = New-Object -TypeName $settingsTypeName  -ArgumentList $settingsHashtable
            $settings.CustomRulePath.Count | Should -Be 1
            $settings.CustomRulePath[0] | Should -Be $rulePath
        }

        It "Should return an array of n items when n items are given in a hashtable" {
            $rulePaths = @("C:\rules\module1", "C:\rules\module2")
            $settingsHashtable = @{
                CustomRulePath = $rulePaths
            }

            $settings = New-Object -TypeName $settingsTypeName  -ArgumentList $settingsHashtable
            $settings.CustomRulePath.Count | Should -Be $rulePaths.Count
            0..($rulePaths.Count - 1) | ForEach-Object { $settings.CustomRulePath[$_] | Should -Be $rulePaths[$_] }

        }

        It "Should detect the parameter in a settings file" {
            $settings = New-Object -TypeName $settingsTypeName `
                              -ArgumentList ([System.IO.Path]::Combine($project1Root, "CustomRulePathSettings.psd1"))
            $settings.CustomRulePath.Count | Should -Be 2
        }
    }

    @("IncludeDefaultRules", "RecurseCustomRulePath") | ForEach-Object {
        $paramName = $_
        Context "When $paramName parameter is provided" {
            It "Should correctly set the value if a boolean is given - true" {
                $settingsHashtable = @{}
                $settingsHashtable.Add($paramName, $true)

                $settings = New-Object -TypeName $settingsTypeName -ArgumentList $settingsHashtable
                $settings."$paramName" | Should -BeTrue
            }

            It "Should correctly set the value if a boolean is given - false" {
                $settingsHashtable = @{}
                $settingsHashtable.Add($paramName, $false)

                $settings = New-Object -TypeName $settingsTypeName -ArgumentList $settingsHashtable
                $settings."$paramName" | Should -BeFalse
            }

            It "Should throw if a non-boolean value is given" {
                $settingsHashtable = @{}
                $settingsHashtable.Add($paramName, "some random string")

                { New-Object -TypeName $settingsTypeName -ArgumentList $settingsHashtable } | Should -Throw
            }

            It "Should detect the parameter in a settings file" {
                $settings = New-Object -TypeName $settingsTypeName `
                    -ArgumentList ([System.IO.Path]::Combine($project1Root, "CustomRulePathSettings.psd1"))
                $settings."$paramName" | Should -BeTrue
            }
        }
    }

    Context "Settings GetSafeValue API" {
        BeforeAll {
            $gsvSimpleTests = @(
                @{ Expr = '0' }
                @{ Expr = '-2'}
                @{ Expr = '-2.5'}
                @{ Expr = '$true' }
                @{ Expr = '$false' }
                @{ Expr = '123124' }
                @{ Expr = '0.142' }
                @{ Expr = '"Hello"' }
                @{ Expr = '"Well then"' }
            )

            $gsvArrayTests = @(
                @{ Expr = '1, 2, 3'; Count = 3 }
                @{ Expr = '"One","Two","Three"'; Count = 3 }
                @{ Expr = '@(1,2,3,4)'; Count = 4 }
                @{ Expr = '@("A","B","C")'; Count = 3 }
                @{ Expr = '@()'; Count = 0 }
                @{ Expr = '@(7)'; Count = 1 }
            )

            $gsvHashtableTests = @(
                @{ Expr = '@{}' }
                @{ Expr = '@{ Key = "Value" }' }
                @{ Expr = '@{ Item = @(1, 2, 3) }' }
                @{ Expr = '@{ Rules = @{ MyRule = @{ Setting1 = "Hello"; Setting2 = 42 } } }' }
                @{ Expr = '@{ Rules = @{ MyRule = @{ Setting1 = 7,4,6,1; Setting2 = 42 } } }' }
                @{ Expr = '@{ Rules = @{ MyRule = @{ Setting1 = @(); Setting2 = 42 } } }' }
                @{ Expr = '@{ Rules = @{ MyRule = @{ Setting1 = @(9, 2, 1, "Hello"); Setting2 = 42 } } }' }
                @{ Expr = '@{ Rules = @{ MyRule = @{ Setting1 = @(9, @(3, 6), 1, "Hello"); Setting2 = 42 } } }' }
                @{ Expr = '@{ Rules = @{ MyRule = @{ Setting1 = @(9, @{ x = 10; y = 11 }, 1, "Hello"); Setting2 = 42 } } }' }
            )

            $gsvThrowTests = @(
                @{ Expr = '$var' }
                @{ Expr = '' }
                @{ Expr = '$null' }
                @{ Expr = '3+7' }
                @{ Expr = '- 2.5'}
                @{ Expr = '-not $true' }
                @{ Expr = '@(1, Get-Thing)' }
                @{ Expr = '@{ Key = Get-Thing }' }
                @{ Expr = '@{ Thing = $true;7 ' }
                @{ Expr = '@{ Thing = @(Asset-Thing;10) ' }
                @{ Expr = ';)' }
            )

            $gsvMethod = [Microsoft.Windows.PowerShell.ScriptAnalyzer.Settings].GetMethod('GetSafeValueFromExpressionAst', [System.Reflection.BindingFlags]'nonpublic,static')

            function ShouldBeDeeplyEqual
            {
                param(
                    [Parameter(Position=0)]
                    $To,

                    [Parameter(ValueFromPipeline)]
                    $InputObject
                )

                if ($null -eq $To)
                {
                    $InputObject | Should -Be $null
                    return
                }

                if ($To -is [hashtable])
                {
                    foreach ($toKey in $To.get_Keys())
                    {
                        $inputVal = $InputObject[$toKey]
                        if ($inputVal -is [array])
                        {
                            @(,$inputVal) | ShouldBeDeeplyEqual -To $To[$toKey]
                            continue
                        }
                        $inputVal | ShouldBeDeeplyEqual -To $To[$toKey]
                    }
                    return
                }

                if ($To -is [array])
                {
                    $InputObject.Count | Should -Be $To.Count
                    for ($i = 0; $i -lt $To.Count; $i++)
                    {
                        $inputVal = $InputObject[$i]
                        if ($inputVal -is [array])
                        {
                            @(,$inputVal) | ShouldBeDeeplyEqual -To $To[$i]
                            continue
                        }
                        $inputVal | ShouldBeDeeplyEqual -To $To[$i]
                    }
                    return
                }

                $InputObject | Should -Be $To
            }
        }

        It "Safely gets the simple value <Expr>" -TestCases $gsvSimpleTests {
            param([string]$Expr)

            $pwshVal = Invoke-Expression $Expr

            $exprAst = [System.Management.Automation.Language.Parser]::ParseInput($Expr, [ref]$null, [ref]$null)
            $exprAst = $exprAst.Find({$args[0] -is [System.Management.Automation.Language.ExpressionAst]}, $true)
            $gsvVal = $gsvMethod.Invoke($null, @($exprAst))

            $gsvVal | Should -Be $pwshVal
        }

        It "Safely gets the array value <Expr>" -TestCases $gsvArrayTests {
            param([string]$Expr)

            $pwshVal = Invoke-Expression $Expr

            $exprAst = [System.Management.Automation.Language.Parser]::ParseInput($Expr, [ref]$null, [ref]$null)
            $exprAst = $exprAst.Find({$args[0] -is [System.Management.Automation.Language.ExpressionAst]}, $true)
            $gsvVal = $gsvMethod.Invoke($null, @($exprAst))


            # Need to test the type like this so that the pipeline doesn't unwrap the type,
            # but we also don't create the array ourselves
            $gsvVal.GetType().IsArray | Should -BeTrue

            @(,$gsvVal) | ShouldBeDeeplyEqual -To $pwshVal
        }

        It "Safely gets the hashtable value <Expr>" -TestCases $gsvHashtableTests {
            param([string]$Expr)

            $pwshVal = Invoke-Expression $Expr

            $exprAst = [System.Management.Automation.Language.Parser]::ParseInput($Expr, [ref]$null, [ref]$null)
            $exprAst = $exprAst.Find({$args[0] -is [System.Management.Automation.Language.ExpressionAst]}, $true)
            $gsvVal = $gsvMethod.Invoke($null, @($exprAst))

            $gsvVal | Should -BeOfType [hashtable]
            $gsvVal | ShouldBeDeeplyEqual -To $pwshVal
        }

        It "Rejects the input <Expr>" -TestCases $gsvThrowTests {
            param([string]$Expr)

            $exprAst = [System.Management.Automation.Language.Parser]::ParseInput($Expr, [ref]$null, [ref]$null)
            $exprAst = $exprAst.Find({$args[0] -is [System.Management.Automation.Language.ExpressionAst]}, $true)

            $expectedError = 'InvalidDataException'
            if ($null -eq $exprAst)
            {
                $expectedError = 'ArgumentNullException'
            }

            { $gsvVal = $gsvMethod.Invoke($null, @($exprAst)) } | Should -Throw -ErrorId $expectedError
        }
    }
}
