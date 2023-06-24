# PSReadLine functions: https://docs.microsoft.com/en-us/powershell/module/psreadline/about/about_psreadline
# PSReadLine options: https://docs.microsoft.com/en-us/powershell/module/psreadline/set-psreadlineoption

using namespace System.Management.Automation
using namespace System.Management.Automation.Language

Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

$doNotAddToHistory = @(
    "git lg"
    "git lgc"
    "git lgr"
    "git lgb"
    "git s"
    "git ss"
    "git show"
    "git lg; git s"
    "git lgr; git s"
    "dir"
)
Set-PSReadLineOption -AddToHistoryHandler {
    param($command)
    return ($doNotAddToHistory -notcontains $command)
}

Set-PSReadLineKeyHandler -Key Ctrl+`| `
    -BriefDescription SmartGotoBrace `
    -LongDescription "Go to the matching brace, parenthesis, or square bracket" `
    -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($line[$cursor] -in '(', ')', '{', '}', '[', ']') {
        [Microsoft.PowerShell.PSConsoleReadLine]::GotoBrace($key, $arg)
    }
    elseif ($line[$cursor - 1] -in '(', ')', '{', '}', '[', ']') {
        [Microsoft.PowerShell.PSConsoleReadLine]::BackwardChar($key, $arg)
        [Microsoft.PowerShell.PSConsoleReadLine]::GotoBrace($key, $arg)
    }
}

Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key RightArrow `
    -BriefDescription ForwardCharAndAcceptNextSuggestionWord `
    -LongDescription "Move cursor one character to the right in the current editing line and accept the next word in suggestion when it's at the end of current editing line" `
    -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($cursor -lt $line.Length) {
        [Microsoft.PowerShell.PSConsoleReadLine]::ForwardChar($key, $arg)
    }
    else {
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptNextSuggestionWord($key, $arg)
    }
}
Set-PSReadLineKeyHandler -Key Ctrl+RightArrow `
    -BriefDescription NextWordAndAcceptSuggestion `
    -LongDescription "Move cursor one word to the right in the current editing line and accept entire suggestion when it's at the end of current editing line" `
    -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($cursor -lt $line.Length) {
        [Microsoft.PowerShell.PSConsoleReadLine]::NextWord($key, $arg)
    }
    else {
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptSuggestion($key, $arg)
    }
}
Set-PSReadLineKeyHandler -Key Escape `
    -BriefDescription ReallyRevertLine `
    -LongDescription "Really clear the line (including lines imported from history)" `
    -ScriptBlock {
    param($key, $arg)

    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine($key, $arg)
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine($key, $arg)
}

# Related: https://github.com/PowerShell/PSReadLine/issues/1778
function RemoveFromHistory([Parameter(Mandatory)][string]$command) {
    $toRemove = [Regex]::Escape(($command -replace "\n", "```n"))
    $history = Get-Content (Get-PSReadLineOption).HistorySavePath -Raw
    $history = $history -replace "(?m)^$toRemove\r\n", ""
    Set-Content (Get-PSReadLineOption).HistorySavePath $history
}

Set-PSReadLineKeyHandler -Key Shift+Delete `
    -BriefDescription RemoveFromHistory `
    -LongDescription "Removes the content of the current line from history" `
    -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    RemoveFromHistory $line
}

Set-PSReadLineKeyHandler -Key Ctrl+Shift+Delete `
    -BriefDescription RemovePreviousCommandFromHistory `
    -LongDescription "Removes the previous command from history" `
    -ScriptBlock {
    param($key, $arg)

    $previousCommand = [Microsoft.PowerShell.PSConsoleReadLine]::GetHistoryItems() | select -Last 1

    RemoveFromHistory $previousCommand.CommandLine
}

Set-PSReadLineKeyHandler -Key Ctrl+x `
    -BriefDescription SmartCut `
    -LongDescription "Cut selection or buffer" `
    -ScriptBlock {
    param($key, $arg)

    $selectionStart = $null
    $selectionLength = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)

    if ($selectionLength -lt 1) {
        [Microsoft.PowerShell.PSConsoleReadLine]::SelectAll($key, $arg)
    }

    [Microsoft.PowerShell.PSConsoleReadLine]::Cut($key, $arg)
}

Set-PSReadLineKeyHandler -Key F9 `
    -BriefDescription GitInfo `
    -LongDescription "Show git information" `
    -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if (!$line -and (git rev-parse --is-inside-work-tree 2>$null)) {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("git lg; git s")
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine($key, $arg)
    }
}

Set-PSReadLineKeyHandler -Key F10 `
    -BriefDescription DirectoryInfo `
    -LongDescription "Show directory information" `
    -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if (!$line) {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("dir")
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine($key, $arg)
    }
}

# From https://github.com/PowerShell/PSReadLine/blob/master/PSReadLine/SamplePSReadLineProfile.ps1
#   with some changes

Set-PSReadLineKeyHandler -Key '"', "'" `
    -BriefDescription SmartInsertQuote `
    -LongDescription "Insert paired quotes if not already on a quote" `
    -ScriptBlock {
    param($key, $arg)

    $quote = $key.KeyChar

    $selectionStart = $null
    $selectionLength = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    # If text is selected, just quote it without any smarts
    if ($selectionStart -ne -1) {
        [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, $quote + $line.SubString($selectionStart, $selectionLength) + $quote)
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
        return
    }

    $ast = $null
    $tokens = $null
    $parseErrors = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$parseErrors, [ref]$null)

    function FindToken {
        param($tokens, $cursor)

        foreach ($token in $tokens) {
            if ($cursor -lt $token.Extent.StartOffset) { continue }
            if ($cursor -lt $token.Extent.EndOffset) {
                $result = $token
                $token = $token -as [StringExpandableToken]
                if ($token) {
                    $nested = FindToken $token.NestedTokens $cursor
                    if ($nested) { $result = $nested }
                }

                return $result
            }
        }
        return $null
    }

    $token = FindToken $tokens $cursor

    # If we're on or inside a **quoted** string token (so not generic), we need to be smarter
    if ($token -is [StringToken] -and $token.Kind -ne [TokenKind]::Generic) {
        # If we're at the start of the string, assume we're inserting a new string
        if ($token.Extent.StartOffset -eq $cursor) {
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$quote$quote ")
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
            return
        }

        # If we're at the end of the string, move over the closing quote if present.
        if ($token.Extent.EndOffset -eq ($cursor + 1) -and $line[$cursor] -eq $quote) {
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
            return
        }
    }

    if ($null -eq $token -or
        $token.Kind -eq [TokenKind]::RParen -or $token.Kind -eq [TokenKind]::RCurly -or $token.Kind -eq [TokenKind]::RBracket) {
        if ($line[0..$cursor].Where{ $_ -eq $quote }.Count % 2 -eq 1) {
            # Odd number of quotes before the cursor, insert a single quote
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert($quote)
        }
        else {
            # Insert matching quotes, move cursor to be in between the quotes
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$quote$quote")
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
        }
        return
    }

    # If cursor is at the start of a token, enclose it in quotes.
    if ($token.Extent.StartOffset -eq $cursor) {
        if ($token.Kind -eq [TokenKind]::Generic -or $token.Kind -eq [TokenKind]::Identifier -or
            $token.Kind -eq [TokenKind]::Variable -or $token.TokenFlags.hasFlag([TokenFlags]::Keyword)) {
            $end = $token.Extent.EndOffset
            $len = $end - $cursor
            [Microsoft.PowerShell.PSConsoleReadLine]::Replace($cursor, $len, $quote + $line.SubString($cursor, $len) + $quote)
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($end + 2)
            return
        }
    }

    # We failed to be smart, so just insert a single quote
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($quote)
}

Set-PSReadLineKeyHandler -Key '(', '{', '[' `
    -BriefDescription InsertPairedBraces `
    -LongDescription "Insert matching braces" `
    -ScriptBlock {
    param($key, $arg)

    $closeChar = switch ($key.KeyChar) {
        <#case#> '(' { [char]')'; break }
        <#case#> '{' { [char]'}'; break }
        <#case#> '[' { [char]']'; break }
    }

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($key.KeyChar -eq "{" -and $line[$cursor - 1] -ne "$") {
        $extraSpace = " "
    }
    else {
        $extraSpace = ""
    }

    $selectionStart = $null
    $selectionLength = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)

    if ($selectionStart -ne -1) {
        # Text is selected, wrap it in brackets
        [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, $key.KeyChar + $extraSpace + $line.SubString($selectionStart, $selectionLength) + $extraSpace + $closeChar)
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
    }
    else {
        # No text is selected, insert a pair
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)$extraSpace$extraSpace$closeChar")
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + ($extraSpace ? 2 : 1))
    }
}

Set-PSReadLineKeyHandler -Key ')', ']', '}' `
    -BriefDescription SmartCloseBraces `
    -LongDescription "Insert closing brace or skip" `
    -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($line[$cursor] -eq $key.KeyChar) {
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
    }
    else {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)")
    }
}

Set-PSReadLineKeyHandler -Key Backspace `
    -BriefDescription SmartBackspace `
    -LongDescription "Delete previous character or matching quotes/parens/braces" `
    -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($cursor -gt 0) {
        $toMatch = $null
        if ($cursor -lt $line.Length) {
            switch ($line[$cursor]) {
                <#case#> '"' { $toMatch = '"'; break }
                <#case#> "'" { $toMatch = "'"; break }
                <#case#> ')' { $toMatch = '('; break }
                <#case#> ']' { $toMatch = '['; break }
                <#case#> '}' { $toMatch = '{'; break }
            }
        }

        if ($toMatch -ne $null -and $line[$cursor - 1] -eq $toMatch) {
            [Microsoft.PowerShell.PSConsoleReadLine]::Delete($cursor - 1, 2)
        }
        else {
            [Microsoft.PowerShell.PSConsoleReadLine]::BackwardDeleteChar($key, $arg)
        }
    }
}
