$raw = [Console]::In.ReadToEnd()
$evt = $raw | ConvertFrom-Json
$evt | Add-Member -NotePropertyName '@timestamp' -NotePropertyValue ((Get-Date).ToUniversalTime().ToString('o'))
$line = ($evt | ConvertTo-Json -Compress -Depth 20) + "`n"
$dir = "$env:USERPROFILE\.claude\hook-logs"
New-Item -ItemType Directory -Force -Path $dir | Out-Null
[System.IO.File]::AppendAllText("$dir\agent-activity.jsonl", $line, (New-Object System.Text.UTF8Encoding $false))
exit 0