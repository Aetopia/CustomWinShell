$chars = [ordered]@{
    '&'  = '$A';
    '|'  = '$B';
    '('  = '$C';
    ')'  = '$F';
    '>'  = '$G';
    '<'  = '$L';
    '='  = '$Q';
    ' '  = '$S';
    '\n' = '$_';
    '\$' = '$$'
}
Write-Output '
$D   Current date
$E   Escape code
$N   Current drive
$P   Current drive and path
$T   Current time
$V   Windows version number
\$   $ (Dollar Sign)
Enter Prompt, enter a blank line to complete the prompt.
'
$parsed_prompt = @()
$prompt = while (1) { read-host | Set-Variable r; if (!$r) {break}; $r}

foreach ($element in $prompt){
    foreach ($item in $chars.Keys){
        $element = $element.replace($item, $chars."$item")
    }
    $parsed_prompt += $element
}

cmd.exe /c setx PROMPT ($parsed_prompt -Join '$_')
Write-Output 'Please restart any Command Prompt Sessions!'
