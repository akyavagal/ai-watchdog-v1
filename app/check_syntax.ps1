$content = Get-Content 'Main.ps1' -Raw
$errors = $null
$tokens = $null
[System.Management.Automation.Language.Parser]::ParseInput($content, [ref]$tokens, [ref]$errors)
if ($errors) {
    $errors | ForEach-Object { 
        Write-Host "ERROR: $($_.Message) at line $($_.Extent.StartLineNumber), col $($_.Extent.StartColumnNumber)" 
    }
} else {
    Write-Host "No syntax errors found."
}
