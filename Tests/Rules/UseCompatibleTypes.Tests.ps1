# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$script:RuleName = 'PSUseCompatibleTypes'
$script:AnyProfileConfigKey = 'AnyProfilePath'
$script:TargetProfileConfigKey = 'TargetProfiles'

$script:Srv2012_3_profile = 'win-8_x64_6.2.9200.0_3.0_x64_4.0.30319.42000_framework'
$script:Srv2012r2_4_profile = 'win-8_x64_6.3.9600.0_4.0_x64_4.0.30319.42000_framework'
$script:Srv2016_5_profile = 'win-8_x64_10.0.14393.0_5.1.14393.2791_x64_4.0.30319.42000_framework'
$script:Srv2016_6_1_profile = 'win-8_x64_10.0.14393.0_6.1.3_x64_4.0.30319.42000_core'
$script:Srv2019_5_profile = 'win-8_x64_10.0.17763.0_5.1.17763.316_x64_4.0.30319.42000_framework'
$script:Srv2019_6_1_profile = 'win-8_x64_10.0.17763.0_6.1.3_x64_4.0.30319.42000_core'
$script:Win10_5_profile = 'win-48_x64_10.0.17763.0_5.1.17763.316_x64_4.0.30319.42000_framework'
$script:Win10_6_1_profile = 'win-48_x64_10.0.17763.0_6.1.3_x64_4.0.30319.42000_core'
$script:Ubuntu1804_6_1_profile = 'ubuntu_x64_18.04_6.1.3_x64_4.0.30319.42000_core'

$script:TypeCompatibilityTestCases = @(
    @{ Target = $script:Srv2012_3_profile; Script = '[System.Management.Automation.ModuleIntrinsics]::GetModulePath("here", "there", "everywhere")'; Types = @('System.Management.Automation.ModuleIntrinsics'); Version = "3.0"; OS = 'Windows'; ProblemCount = 1 }
    @{ Target = $script:Srv2012_3_profile; Script = '$ast -is [System.Management.Automation.Language.FunctionMemberAst]'; Types = @('System.Management.Automation.Language.FunctionMemberAst'); Version = "3.0"; OS = 'Windows'; ProblemCount = 1 }
    @{ Target = $script:Srv2012_3_profile; Script = '$version = [System.Management.Automation.SemanticVersion]::Parse($version)'; Types = @('System.Management.Automation.SemanticVersion'); Version = "3.0"; OS = 'Windows'; ProblemCount = 1 }
    @{ Target = $script:Srv2012_3_profile; Script = '$kw = New-Object "System.Management.Automation.Language.DynamicKeyword"'; Types = @('System.Management.Automation.Language.DynamicKeyword'); Version = "3.0"; OS = 'Windows'; ProblemCount = 1 }
    @{ Target = $script:Srv2012_3_profile; Script = '& { param([Parameter(Position=0)][ArgumentCompleter({"Banana"})][string]$Hello) $Hello } "Banana"'; Types = @('ArgumentCompleter'); Version = "3.0"; OS = 'Windows'; ProblemCount = 1 }

    @{ Target = $script:Srv2012r2_4_profile; Script = '[WildcardPattern]"bicycle*"'; Types = @('WildcardPattern'); Version = "4.0"; OS = 'Windows'; ProblemCount = 1 }
    @{ Target = $script:Srv2012r2_4_profile; Script = '$client = [System.Net.Http.HttpClient]::new()'; Types = @('System.Net.Http.HttpClient'); Version = "4.0"; OS = 'Windows'; ProblemCount = 1 }
    @{ Target = $script:Srv2012r2_4_profile; Script = '[Microsoft.PowerShell.EditMode]"Vi"'; Types = @('Microsoft.PowerShell.EditMode'); Version = "4.0"; OS = 'Windows'; ProblemCount = 1 }

    @{ Target = $script:Srv2019_5_profile; Script = '[Microsoft.PowerShell.Commands.WebSslProtocol]::Default -eq "Tls12"'; Types = @('Microsoft.PowerShell.Commands.WebSslProtocol'); Version = "5.1"; OS = 'Windows'; ProblemCount = 1 }
    @{ Target = $script:Srv2019_5_profile; Script = '[System.Collections.Immutable.ImmutableList[string]]::Empty'; Types = @('System.Collections.Immutable.ImmutableList'); Version = "5.1"; OS = 'Windows'; ProblemCount = 1 }
    @{ Target = $script:Srv2019_5_profile; Script = '[System.Collections.Generic.TreeSet[string]]::new(@("duck", "goose", "banana"))'; Types = @('System.Collections.Generic.TreeSet'); Version = "5.1"; OS = 'Windows'; ProblemCount = 1 }

    @{ Target = $script:Srv2019_6_1_profile; Script = 'function CertFunc { param([System.Net.ICertificatePolicy]$Policy) Do-Something $Policy }'; Types = @('System.Net.ICertificatePolicy'); Version = "6.1"; OS = 'Windows'; ProblemCount = 1 }

    @{ Target = $script:Ubuntu1804_6_1_profile; Script = '[System.Management.Automation.Security.SystemPolicy]::GetSystemLockdownPolicy()'; Types = @('System.Management.Automation.Security.SystemPolicy'); Version = "6.1.2"; OS = 'Linux'; ProblemCount = 1 }
    @{ Target = $script:Ubuntu1804_6_1_profile; Script = '[System.Management.Automation.Security.SystemPolicy]::GetSystemLockdownPolicy()'; Types = @('System.Management.Automation.Security.SystemPolicy'); Version = "6.1.2"; OS = 'Linux'; ProblemCount = 1 }
    @{ Target = $script:Ubuntu1804_6_1_profile; Script = '[System.Management.Automation.Security.SystemEnforcementMode]$enforcementMode = "Audit"'; Types = @('System.Management.Automation.Security.SystemEnforcementMode'); Version = "6.1.2"; OS = 'Linux'; ProblemCount = 1 }
    @{ Target = $script:Ubuntu1804_6_1_profile; Script = '$ci = New-Object "Microsoft.PowerShell.Commands.ComputerInfo"'; Types = @('Microsoft.PowerShell.Commands.ComputerInfo'); Version = "6.1.2"; OS = 'Linux'; ProblemCount = 1 }
)

$script:MemberCompatibilityTestCases = @(
    @{ Target = $script:Srv2012_3_profile; Script = '[System.Management.Automation.LanguagePrimitives]::ConvertTypeNameToPSTypeName("System.String")'; Types = @('System.Management.Automation.LanguagePrimitives'); Members = @('ConvertTypeNameToPSTypeName'); Version = "3.0"; OS = 'Windows'; ProblemCount = 1 }
    @{ Target = $script:Srv2012_3_profile; Script = '[System.Management.Automation.WildcardPattern]::Get("banana*", "None").IsMatch("bananaduck")'; Types = @('System.Management.Automation.WildcardPattern'); Members = @('Get'); Version = "3.0"; OS = 'Windows'; ProblemCount = 1 }

    @{ Target = $script:Srv2012r2_4_profile; Script = 'if (-not [Microsoft.PowerShell.Commands.ModuleSpecification]::TryParse($msStr, [ref]$modSpec)){ throw "Bad!" }'; Types = @('Microsoft.PowerShell.Commands.ModuleSpecification'); Members = @('TryParse'); Version = "4.0"; OS = 'Windows'; ProblemCount = 1 }
    @{ Target = $script:Srv2012r2_4_profile; Script = '[System.Management.Automation.LanguagePrimitives]::IsObjectEnumerable($obj)'; Types = @('System.Management.Automation.LanguagePrimitives'); Members = @('IsObjectEnumerable'); Version = "4.0"; OS = 'Windows'; ProblemCount = 1 }

    @{ Target = $script:Srv2019_5_profile; Script = '$socket = [System.Net.WebSockets.WebSocket]::CreateFromStream($stream, $true, "http", [timespan]::FromMinutes(10))'; Types = @('System.Net.WebSockets.WebSocket'); Members = @('CreateFromStream'); Version = "5.1"; OS = 'Windows'; ProblemCount = 1 }
    @{ Target = $script:Srv2019_5_profile; Script = '[System.Management.Automation.HostUtilities]::InvokeOnRunspace($command, $runspace)'; Types = @('System.Management.Automation.HostUtilities'); Members = @('InvokeOnRunspace'); Version = "5.1"; OS = 'Windows'; ProblemCount = 1 }

    @{ Target = $script:Srv2019_6_1_profile; Script = '[Microsoft.PowerShell.ToStringCodeMethods]::PropertyValueCollection($obj)'; Types = @('Microsoft.PowerShell.ToStringCodeMethods'); Members = @('PropertyValueCollection'); Version = "6.1"; OS = 'Windows'; ProblemCount = 1 }

    @{ Target = $script:Ubuntu1804_6_1_profile; Script = '[System.Management.Automation.Tracing.Tracer]::GetExceptionString($e)'; Types = @('System.Management.Automation.Tracing.Tracer'); Members = @('GetExceptionString'); Version = "6.1"; OS = 'Linux'; ProblemCount = 1 }
)

Describe 'UseCompatibleTypes' {
    Context 'Targeting a single profile' {
        It "Reports <ProblemCount> problem(s) with <Script> on <OS> with PowerShell <Version> targeting <Target>" -TestCases $script:TypeCompatibilityTestCases {
            param($Script, [string]$Target, [string[]]$Types, [version]$Version, [string]$OS, [int]$ProblemCount)

            $settings = @{
                Rules = @{
                    $script:RuleName = @{
                        Enable = $true
                        $script:TargetProfileConfigKey = @($Target)
                    }
                }
            }

            $diagnostics = Invoke-ScriptAnalyzer -IncludeRule $script:RuleName -ScriptDefinition $Script -Settings $settings

            $diagnostics.Count | Should -Be $ProblemCount

            for ($i = 0; $i -lt $diagnostics.Count; $i++)
            {
                $diagnostics[$i].Type | Should -BeExactly $Types[$i]
                $diagnostics[$i].TargetPlatform.OperatingSystem.Family | Should -Be $OS
                $diagnostics[$i].TargetPlatform.PowerShell.Version.Major | Should -Be $Version.Major
                $diagnostics[$i].TargetPlatform.PowerShell.Version.Minor | Should -Be $Version.Minor
            }
        }

        It "Reports <ProblemCount> problem(s) with <Script> on <OS> with PowerShell <Version> targeting <Target>" -TestCases $script:MemberCompatibilityTestCases {
            param($Script, [string]$Target, [string[]]$Types, [string[]]$Members, [version]$Version, [string]$OS, [int]$ProblemCount)

            $settings = @{
                Rules = @{
                    $script:RuleName = @{
                        Enable = $true
                        $script:TargetProfileConfigKey = @($Target)
                    }
                }
            }

            $diagnostics = Invoke-ScriptAnalyzer -IncludeRule $script:RuleName -ScriptDefinition $Script -Settings $settings

            $diagnostics.Count | Should -Be $ProblemCount

            for ($i = 0; $i -lt $diagnostics.Count; $i++)
            {
                $diagnostics[$i].Type | Should -BeExactly $Types[$i]
                $diagnostics[$i].Member | Should -BeExactly $Members[$i]
                $diagnostics[$i].TargetPlatform.OperatingSystem.Family | Should -Be $OS
                $diagnostics[$i].TargetPlatform.PowerShell.Version.Major | Should -Be $Version.Major
                $diagnostics[$i].TargetPlatform.PowerShell.Version.Minor | Should -Be $Version.Minor
            }
        }
    }

    Context "Full file checking against all targets" {
        It "Finds all incompatibilities in the script" {
            $settings = @{
                Rules = @{
                    $script:RuleName = @{
                        Enable = $true
                        $script:TargetProfileConfigKey = @(
                            $script:Srv2012_3_profile
                            $script:Srv2012r2_4_profile
                            $script:Srv2016_5_profile
                            $script:Srv2016_6_1_profile
                            $script:Srv2019_5_profile
                            $script:Srv2019_6_1_profile
                            $script:Win10_5_profile
                            $script:Win10_6_1_profile
                            $script:Ubuntu1804_6_1_profile
                        )
                    }
                }
            }

            $diagnostics = Invoke-ScriptAnalyzer -Path "$PSScriptRoot/CompatibilityRuleAssets/IncompatibleScript.ps1" -Settings $settings -IncludeRule PSUseCompatibleTypes `
                | Where-Object { $_.RuleName -eq $script:RuleName }

            $diagnostics.Count | Should -Be 2
            foreach ($diagnostic in $diagnostics)
            {
                $diagnostic.Member | Should -BeExactly 'TryParse'
                $diagnostic.Type | Should -BeExactly 'Microsoft.PowerShell.Commands.ModuleSpecification'
            }
        }
    }

    Context "PSSA repository code checking" {
        It "Checks that there are no incompatibilities in PSSA build scripts" {
            $settings = @{
                Rules = @{
                    $script:RuleName = @{
                        Enable = $true
                        $script:TargetProfileConfigKey = @(
                            $script:Srv2012_3_profile
                            $script:Srv2012r2_4_profile
                            $script:Srv2016_5_profile
                            $script:Srv2016_6_1_profile
                            $script:Srv2019_5_profile
                            $script:Srv2019_6_1_profile
                            $script:Win10_5_profile
                            $script:Win10_6_1_profile
                            $script:Ubuntu1804_6_1_profile
                        )
                        IgnoreTypes = @('System.IO.Compression.ZipFile')
                    }
                }
            }

            $diagnostics = Invoke-ScriptAnalyzer -Path "$PSScriptRoot/../../" -Settings $settings -IncludeRule PSUseCompatibleTypes
            $diagnostics.Count | Should -Be 0
        }
    }
}