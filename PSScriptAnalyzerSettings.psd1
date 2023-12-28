# https://github.com/PowerShell/PSScriptAnalyzer
# https://github.com/PowerShell/PSScriptAnalyzer/blob/master/docs/Rules/README.md
@{
    ExcludeRules = @(
        'PSAvoidUsingCmdletAliases'
        'PSAvoidUsingInvokeExpression'
        'PSAvoidUsingPositionalParameters'
        'PSAvoidUsingWriteHost'
        'PSUseApprovedVerbs'
        'PSUseShouldProcessForStateChangingFunctions'
        'PSUseSingularNouns'
    )
    IncludeRules = @(
        'PSUseConsistentIndentation'
    )
    Rules        = @{
        PSUseConsistentIndentation = @{
            Enable              = $true
            IndentationSize     = 4
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
            Kind                = 'space'
        }
    }
}
