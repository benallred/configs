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
}
