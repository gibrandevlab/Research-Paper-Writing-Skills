<#
.SYNOPSIS
  Shared, compactable conversation memory for every AI agent working in this repo.

.DESCRIPTION
  Keeps .ai-context/ as a vendor-neutral memory store and compacts it when the
  estimated token count reaches the configured threshold (default 100,000).

  Commands:
    init               Create/repair the .ai-context structure (idempotent).
    start              Start a new session log for one agent.
    log                Append a structured entry to the current session log.
    status             Show token usage vs. the compaction threshold.
    compact            Archive the oldest logs and create COMPACTION_TASK.md.
    compact-done       Finish a compaction after CONTEXT.md was rewritten.
    resume             Print the handoff pack (context + state + recent logs).
    capture            Import recent messages from a Claude Code transcript (JSONL).
    hook-session-start (Claude Code hook) Inject context at session start.
    hook-precompact    (Claude Code hook) Capture the transcript before compaction.
    help               Show this text.

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File tools/ai-context.ps1 init

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File tools/ai-context.ps1 start -Agent cline -Goal "Add memory rules"

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File tools/ai-context.ps1 log -Agent cline `
    -Did "Created AGENTS.md","Added hooks" -Decisions "Use PS 5.1 only" -Next "Test compaction"

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File tools/ai-context.ps1 status
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('init', 'start', 'log', 'status', 'compact', 'compact-done', 'reset', 'resume', 'capture', 'hook-session-start', 'hook-precompact', 'help')]
    [string]$Command,

    [string]$Agent = 'unknown',
    [string]$Goal,
    [string[]]$Did = @(),
    [string[]]$Decisions = @(),
    [string[]]$Files = @(),
    [string[]]$Next = @(),
    [string[]]$Open = @(),
    [string]$Note,
    [string]$TranscriptPath,
    [int]$MaxMessages = 0,
    [switch]$Force,
    [switch]$Yes,
    [switch]$Hard,
    [string]$Root,

    # Optional: hook payload piped in-process (e.g. '{"source":"startup"}' | ai-context.ps1 hook-session-start).
    # Claude Code itself sends the payload on stdin, which is read from [Console]::In.
    [Parameter(ValueFromPipeline = $true)]
    [string]$StdinPayload
)

$ErrorActionPreference = 'Stop'

if ($Root) {
    $script:RepoRoot = (Resolve-Path -Path $Root).Path
} elseif ($PSScriptRoot) {
    $script:RepoRoot = Split-Path -Parent $PSScriptRoot
} else {
    $script:RepoRoot = (Get-Location).Path
}

$script:ContextDir = Join-Path $script:RepoRoot '.ai-context'
$script:LogDir     = Join-Path $script:ContextDir 'log'
$script:ArchiveDir = Join-Path $script:ContextDir 'archive'
$script:ConfigPath = Join-Path $script:ContextDir 'config.json'
$script:ContextPath = Join-Path $script:ContextDir 'CONTEXT.md'
$script:ResearchPath = Join-Path $script:ContextDir 'RESEARCH.md'
$script:StatePath  = Join-Path $script:ContextDir 'STATE.json'
$script:TaskPath   = Join-Path $script:ContextDir 'COMPACTION_TASK.md'
$script:ScriptPath = Join-Path $script:RepoRoot 'tools\ai-context.ps1'
$script:ConfigCache = $null

# ---------------------------------------------------------------- helpers ----

function Write-Utf8([string]$Path, [string]$Text) {
    $dir = Split-Path -Parent $Path
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Text, $encoding)
}

function Read-Text([string]$Path) {
    if (Test-Path -LiteralPath $Path) {
        return [System.IO.File]::ReadAllText($Path)
    }
    return ''
}

function Get-ConfigObject {
    if ($null -ne $script:ConfigCache) { return $script:ConfigCache }
    if (Test-Path -LiteralPath $script:ConfigPath) {
        try {
            $script:ConfigCache = (Read-Text $script:ConfigPath) | ConvertFrom-Json
        } catch {
            $script:ConfigCache = $null
        }
    }
    return $script:ConfigCache
}

function Get-Cfg([string]$Name, $Default) {
    $cfg = Get-ConfigObject
    if ($cfg -and ($cfg.PSObject.Properties.Name -contains $Name) -and $null -ne $cfg.$Name) {
        return $cfg.$Name
    }
    return $Default
}

function Get-RelPath([string]$FullPath) {
    if ($FullPath.StartsWith($script:RepoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        $rel = $FullPath.Substring($script:RepoRoot.Length).TrimStart([char[]]@('\', '/'))
        return ($rel -replace '\\', '/')
    }
    return $FullPath
}

function Limit-Text([string]$Text, [int]$Max) {
    if ($null -eq $Text) { return '' }
    $clean = ($Text -replace '\s+', ' ').Trim()
    if ($Max -le 0) { return $clean }
    if ($clean.Length -gt $Max) { return $clean.Substring(0, $Max) + ' ...' }
    return $clean
}

function Split-Values([string[]]$Values) {
    # powershell.exe -File passes "a;;b" as one string, so allow ';;' as separator.
    $out = @()
    foreach ($value in $Values) {
        if ($null -eq $value) { continue }
        foreach ($piece in ($value -split ';;')) {
            $trimmed = $piece.Trim()
            if ($trimmed.Length -gt 0) { $out += $trimmed }
        }
    }
    return $out
}

function Get-TokenEstimate([string]$Text) {
    if ([string]::IsNullOrEmpty($Text)) { return 0 }
    $cpt = [double](Get-Cfg 'chars_per_token' 4)
    if ($cpt -le 0) { $cpt = 4 }
    return [int][math]::Ceiling($Text.Length / $cpt)
}

function Get-FileTokens([string]$Path) {
    return (Get-TokenEstimate (Read-Text $Path))
}

function Format-Number([double]$Value) {
    return $Value.ToString('N0', [System.Globalization.CultureInfo]::InvariantCulture)
}

# ------------------------------------------------------------------ state ----

function Get-State {
    if (Test-Path -LiteralPath $script:StatePath) {
        try {
            $state = (Read-Text $script:StatePath) | ConvertFrom-Json
            foreach ($name in @('decisions', 'open_questions', 'next_steps', 'files_in_focus')) {
                if (-not ($state.PSObject.Properties.Name -contains $name) -or $null -eq $state.$name) {
                    $state | Add-Member -NotePropertyName $name -NotePropertyValue @() -Force
                }
            }
            return $state
        } catch {
            # fall through to a fresh state
        }
    }
    return [pscustomobject][ordered]@{
        schema           = 1
        project          = (Split-Path -Leaf $script:RepoRoot)
        current_session  = $null
        active_goal      = $null
        decisions        = @()
        open_questions   = @()
        next_steps       = @()
        files_in_focus   = @()
        last_compaction  = $null
        compaction_count = 0
        resets           = 0
        last_reset       = $null
        updated_at       = $null
    }
}

function Save-State($State) {
    $State.updated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    Write-Utf8 $script:StatePath ($State | ConvertTo-Json -Depth 8)
}

function Add-RecentItems($Existing, [string[]]$New, [int]$Max, [string]$TimePrefix) {
    $list = New-Object System.Collections.ArrayList
    foreach ($item in @($Existing)) {
        if ($item) { [void]$list.Add([string]$item) }
    }
    foreach ($item in $New) {
        if ([string]::IsNullOrWhiteSpace($item)) { continue }
        $value = Limit-Text $item (Get-Cfg 'max_entry_chars' 600)
        if ($TimePrefix) { $value = "$TimePrefix $value" }
        if (-not $list.Contains($value)) { [void]$list.Add($value) }
    }
    while ($list.Count -gt $Max) { $list.RemoveAt(0) }
    return @($list.ToArray())
}

# -------------------------------------------------------------- structure ----

function New-ContextTemplate([string]$ResetNote) {
    $note = ''
    if ($ResetNote) {
        $note = @"

> Operational context was RESET at $ResetNote.
> Previous context, logs and state are archived in .ai-context/archive/$ResetNote-reset/.
> Research knowledge is preserved in .ai-context/RESEARCH.md.
"@
    }
    return @"
# Project Context (operational, shared by all agents)

> Working memory: current focus, decisions, next steps. Read together with RESEARCH.md.
> Keep under ~3,000 tokens. Rewritten only during compaction, reset or an explicit handoff.
> Last compacted: never | Compaction count: 0
$note
## 1. What this project is

(one short paragraph; stable details belong in RESEARCH.md)

## 2. Current focus

- Task:
- Status:
- Agent of record:
- Working dir / branch:

## 3. Decisions

| Date | Decision | Rationale |
| --- | --- | --- |
|  |  |  |

## 4. Constraints and conventions

- 

## 5. Open questions

- 

## 6. Next steps

1. 

## 7. Key files

- 
"@
}

function New-ResearchTemplate {
    return @"
# Research Context (persistent)

> Domain knowledge that must survive compaction and context resets.
> Never archived by compact or reset (only reset -Hard moves it).
> Keep under ~2,000 tokens. Update it when the science changes, not when code changes.
> Read it together with `.ai-context/CONTEXT.md` at session start.

## 1. Subject / paper identity

- Working title:
- Target venue / deadline:
- One-sentence pitch:
- Problem and gap:

## 2. Core claims and evidence

| # | Claim | Evidence (table / figure / section) | Status |
| --- | --- | --- | --- |
| 1 |  |  |  |

## 3. Method knowledge (stable)

(one paragraph a reviewer would accept; no implementation details)

## 4. Evaluation standards

- Datasets / splits:
- Metrics (and direction):
- Baselines:
- Compute budget:

## 5. Key results

| Setting | Metric | Ours | Best baseline | Delta |
| --- | --- | --- | --- | --- |

## 6. Terminology and conventions

| Term / symbol | Meaning | First defined in |
| --- | --- | --- |

## 7. Scope boundaries

- Claims this work does NOT make:
- Known limitations:

## 8. Key references

- 
"@
}

function Invoke-Init {
    foreach ($dir in @($script:ContextDir, $script:LogDir, $script:ArchiveDir)) {
        if (-not (Test-Path -LiteralPath $dir)) {
            New-Item -ItemType Directory -Force -Path $dir | Out-Null
        }
    }

    if (-not (Test-Path -LiteralPath $script:ConfigPath)) {
        $defaultConfig = [ordered]@{
            schema                          = 1
            compact_threshold_tokens        = 100000
            keep_recent_tokens              = 20000
            chars_per_token                 = 4
            max_context_md_tokens           = 3000
            auto_capture_transcript_messages = 40
            max_entry_chars                 = 600
        }
        Write-Utf8 $script:ConfigPath ($defaultConfig | ConvertTo-Json -Depth 5)
    }

    if (-not (Test-Path -LiteralPath $script:ContextPath)) {
        Write-Utf8 $script:ContextPath (New-ContextTemplate '')
    }

    if (-not (Test-Path -LiteralPath $script:ResearchPath)) {
        Write-Utf8 $script:ResearchPath (New-ResearchTemplate)
    }

    if (-not (Test-Path -LiteralPath $script:StatePath)) {
        $state = Get-State
        Save-State $state
    }

    foreach ($keep in @((Join-Path $script:LogDir '.gitkeep'), (Join-Path $script:ArchiveDir '.gitkeep'))) {
        if (-not (Test-Path -LiteralPath $keep)) { Write-Utf8 $keep '' }
    }
}

function Get-LogFiles {
    if (-not (Test-Path -LiteralPath $script:LogDir)) { return @() }
    return @(Get-ChildItem -LiteralPath $script:LogDir -Filter '*.md' -File |
        Sort-Object LastWriteTime)
}

function Get-NewestLogFile {
    $logs = Get-LogFiles
    if ($logs.Count -eq 0) { return $null }
    return $logs[$logs.Count - 1]
}

function New-SessionId {
    return (Get-Date).ToString('yyyyMMdd-HHmmss')
}

function Get-SessionPath([string]$SessionId, [string]$AgentName) {
    $slug = ($AgentName.ToLower() -replace '[^a-z0-9\-]', '-')
    return (Join-Path $script:LogDir ("{0}-{1}.md" -f $SessionId, $slug))
}

function Invoke-StartSession([string]$AgentName, [string]$SessionGoal) {
    Invoke-Init
    $now = Get-Date
    $state = Get-State
    $sid = New-SessionId

    if ($state.current_session -and $state.current_session.file) {
        $previous = Join-Path $script:RepoRoot ($state.current_session.file -replace '/', '\')
        if (Test-Path -LiteralPath $previous) {
            $footer = "`n---`n`n_Session closed: $($now.ToString('yyyy-MM-dd HH:mm:ss'))_`n"
            Add-Content -LiteralPath $previous -Value $footer -Encoding UTF8
        }
    }

    $sessionFile = Get-SessionPath $sid $AgentName
    $header = @"
# Session $sid - $AgentName

- Started: $($now.ToString('yyyy-MM-dd HH:mm:ss'))
- Goal: $(if ($SessionGoal) { $SessionGoal } else { '(not stated)' })
- Format: one entry per work unit; see AGENTS.md

---

"@
    Write-Utf8 $sessionFile $header

    $state.current_session = [pscustomobject][ordered]@{
        id         = $sid
        file       = (Get-RelPath $sessionFile)
        agent      = $AgentName
        goal       = $SessionGoal
        started_at = $now.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    }
    if ($SessionGoal) { $state.active_goal = $SessionGoal }
    Save-State $state

    return $sessionFile
}

# ------------------------------------------------------------------- log ----

function Add-LogEntry {
    param(
        [string]$AgentName,
        [string]$EntryGoal,
        [string[]]$EntryDid,
        [string[]]$EntryDecisions,
        [string[]]$EntryFiles,
        [string[]]$EntryNext,
        [string[]]$EntryOpen,
        [string]$EntryNote,
        [switch]$SkipStateUpdate
    )

    Invoke-Init
    $state = Get-State
    $now = Get-Date
    $maxChars = [int](Get-Cfg 'max_entry_chars' 600)

    $sessionFile = $null
    if ($state.current_session -and $state.current_session.file) {
        $candidate = Join-Path $script:RepoRoot ($state.current_session.file -replace '/', '\')
        if (Test-Path -LiteralPath $candidate) { $sessionFile = $candidate }
    }
    if (-not $sessionFile) {
        $sessionFile = Invoke-StartSession $AgentName $EntryGoal
    }

    $lines = New-Object System.Collections.ArrayList
    [void]$lines.Add('')
    [void]$lines.Add(("### {0} | {1}" -f $now.ToString('HH:mm'), $AgentName))
    if ($EntryGoal) { [void]$lines.Add("- Goal: $(Limit-Text $EntryGoal $maxChars)") }

    if ($EntryDid.Count -gt 0) {
        [void]$lines.Add('- Did:')
        foreach ($item in $EntryDid) {
            if ([string]::IsNullOrWhiteSpace($item)) { continue }
            [void]$lines.Add("  - $(Limit-Text $item $maxChars)")
        }
    }
    if ($EntryDecisions.Count -gt 0) {
        [void]$lines.Add('- Decision:')
        foreach ($item in $EntryDecisions) {
            if ([string]::IsNullOrWhiteSpace($item)) { continue }
            [void]$lines.Add("  - $(Limit-Text $item $maxChars)")
        }
    }
    if ($EntryFiles.Count -gt 0) {
        $cleanFiles = @()
        foreach ($item in $EntryFiles) {
            if (-not [string]::IsNullOrWhiteSpace($item)) { $cleanFiles += (Limit-Text $item 200) }
        }
        if ($cleanFiles.Count -gt 0) { [void]$lines.Add("- Files: $($cleanFiles -join ', ')") }
    }
    if ($EntryNext.Count -gt 0) {
        [void]$lines.Add('- Next:')
        foreach ($item in $EntryNext) {
            if ([string]::IsNullOrWhiteSpace($item)) { continue }
            [void]$lines.Add("  - $(Limit-Text $item $maxChars)")
        }
    }
    if ($EntryOpen.Count -gt 0) {
        [void]$lines.Add('- Open:')
        foreach ($item in $EntryOpen) {
            if ([string]::IsNullOrWhiteSpace($item)) { continue }
            [void]$lines.Add("  - $(Limit-Text $item $maxChars)")
        }
    }
    if ($EntryNote) { [void]$lines.Add("- Note: $(Limit-Text $EntryNote $maxChars)") }

    Add-Content -LiteralPath $sessionFile -Value (($lines.ToArray()) -join "`n") -Encoding UTF8

    if (-not $SkipStateUpdate) {
        $stamp = $now.ToString('yyyy-MM-dd')
        $state.decisions = Add-RecentItems $state.decisions $EntryDecisions 20 $stamp
        $state.open_questions = Add-RecentItems $state.open_questions $EntryOpen 20 ''
        $state.next_steps = Add-RecentItems $state.next_steps $EntryNext 15 ''
        $state.files_in_focus = Add-RecentItems $state.files_in_focus $EntryFiles 20 ''
        if ($EntryGoal) { $state.active_goal = Limit-Text $EntryGoal 300 }
        Save-State $state
    }

    Write-Output "Logged to: $(Get-RelPath $sessionFile)"

    $report = Get-TokenReport
    if ($report.Total -ge $report.Threshold) {
        Write-Output ''
        Write-Output ("WARNING: context memory is at ~{0} tokens (threshold {1}). Run 'compact' now." -f (Format-Number $report.Total), (Format-Number $report.Threshold))
    }
    if (Test-Path -LiteralPath $script:TaskPath) {
        Write-Output 'NOTE: .ai-context/COMPACTION_TASK.md is pending. Finish it with compact-done.'
    }
}

# --------------------------------------------------------------- measuring ----

function Get-TokenReport {
    $items = New-Object System.Collections.ArrayList
    $total = 0

    foreach ($pair in @(
            @{ Name = '.ai-context/RESEARCH.md'; Path = $script:ResearchPath },
            @{ Name = '.ai-context/CONTEXT.md'; Path = $script:ContextPath },
            @{ Name = '.ai-context/STATE.json'; Path = $script:StatePath })) {
        if (Test-Path -LiteralPath $pair.Path) {
            $tokens = Get-FileTokens $pair.Path
            $total += $tokens
            [void]$items.Add([pscustomobject]@{ Name = $pair.Name; Tokens = $tokens })
        }
    }

    $logInfo = New-Object System.Collections.ArrayList
    foreach ($log in (Get-LogFiles)) {
        $tokens = Get-FileTokens $log.FullName
        $total += $tokens
        [void]$items.Add([pscustomobject]@{ Name = (Get-RelPath $log.FullName); Tokens = $tokens })
        [void]$logInfo.Add([pscustomobject]@{ Path = $log.FullName; Tokens = $tokens })
    }

    $threshold = [int](Get-Cfg 'compact_threshold_tokens' 100000)
    $percent = 0
    if ($threshold -gt 0) { $percent = [math]::Round(($total / $threshold) * 100, 1) }

    return [pscustomobject]@{
        Total       = $total
        Threshold   = $threshold
        Percent     = $percent
        Files       = @($items.ToArray())
        Logs        = @($logInfo.ToArray())
        TaskPending = (Test-Path -LiteralPath $script:TaskPath)
    }
}

function Show-Status {
    $report = Get-TokenReport
    $remaining = $report.Threshold - $report.Total
    if ($remaining -lt 0) { $remaining = 0 }

    Write-Output '.ai-context status'
    Write-Output ("  threshold : {0} tokens (estimate = chars / {1})" -f (Format-Number $report.Threshold), (Get-Cfg 'chars_per_token' 4))
    Write-Output ("  used      : {0} tokens ({1}%)" -f (Format-Number $report.Total), $report.Percent)
    Write-Output ("  remaining : {0} tokens" -f (Format-Number $remaining))
    Write-Output ''
    foreach ($file in $report.Files) {
        Write-Output ("  {0,9}  {1}" -f (Format-Number $file.Tokens), $file.Name)
    }
    if ($report.Files.Count -eq 0) { Write-Output '  (no context files yet - run init)' }
    Write-Output ''
    Write-Output '  RESEARCH.md is persistent: compact and reset never archive it.'
    Write-Output ''
    if ($report.TaskPending) {
        Write-Output '  PENDING: .ai-context/COMPACTION_TASK.md exists -> rewrite CONTEXT.md, then run compact-done.'
    } elseif ($report.Total -ge $report.Threshold) {
        Write-Output "  OVER THRESHOLD: run 'compact' to archive old logs and create the compaction task."
    } else {
        Write-Output '  OK: no compaction needed.'
    }
}

# -------------------------------------------------------------- compaction ----

function Invoke-Compact {
    param([switch]$Force, [switch]$Quiet)

    Invoke-Init
    $report = Get-TokenReport
    $over = ($report.Total -ge $report.Threshold)

    if (-not $over -and -not $Force) {
        if (-not $Quiet) {
            Write-Host ("Nothing to do: ~{0} tokens is below the {1} threshold. Use -Force to compact anyway." -f (Format-Number $report.Total), (Format-Number $report.Threshold))
        }
        return $null
    }
    if (Test-Path -LiteralPath $script:TaskPath) {
        if (-not $Quiet) {
            Write-Host 'A compaction task is already pending: .ai-context/COMPACTION_TASK.md'
        }
        return $null
    }

    $logs = $report.Logs
    if ($logs.Count -eq 0) {
        if (-not $Quiet) { Write-Host 'No session logs to archive.' }
        return $null
    }

    $keep = [int](Get-Cfg 'keep_recent_tokens' 20000)
    $cut = $logs.Count
    $keptTokens = 0
    for ($i = $logs.Count - 1; $i -ge 0; $i--) {
        if (($keptTokens + $logs[$i].Tokens) -le $keep) {
            $keptTokens += $logs[$i].Tokens
            $cut = $i
        } else {
            break
        }
    }

    $moves = @()
    if ($cut -gt 0) {
        $moves = @($logs[0..($cut - 1)])
    } else {
        # Every log fits the keep window but the total is still over budget:
        # archive the oldest log so compaction always makes progress.
        $moves = @($logs[0])
        $keptTokens = $keptTokens - $logs[0].Tokens
    }

    $stamp = (Get-Date).ToString('yyyyMMdd-HHmmss')
    $archivePath = Join-Path $script:ArchiveDir $stamp
    $suffix = 1
    while (Test-Path -LiteralPath $archivePath) {
        $suffix++
        $archivePath = Join-Path $script:ArchiveDir ("{0}-{1}" -f $stamp, $suffix)
    }
    New-Item -ItemType Directory -Force -Path $archivePath | Out-Null

    $raw = New-Object System.Text.StringBuilder
    $bullets = New-Object System.Text.StringBuilder
    $archivedTokens = 0
    [void]$raw.AppendLine("# Archived transcripts - $stamp")
    [void]$raw.AppendLine('')
    [void]$bullets.AppendLine("# Archived digest (headings + bullets) - $stamp")
    [void]$bullets.AppendLine('')

    foreach ($item in $moves) {
        $name = Split-Path -Leaf $item.Path
        $content = Read-Text $item.Path
        $archivedTokens += $item.Tokens
        [void]$raw.AppendLine("## $name")
        [void]$raw.AppendLine('')
        [void]$raw.AppendLine($content.TrimEnd())
        [void]$raw.AppendLine('')

        [void]$bullets.AppendLine("## $name")
        foreach ($line in ($content -split "`r?`n")) {
            $trimmed = $line.Trim()
            if ($trimmed -match '^#{1,6} ' -or $trimmed -match '^- ' -or $trimmed -match '^  - ') {
                [void]$bullets.AppendLine($trimmed)
            }
        }
        [void]$bullets.AppendLine('')
    }

    $digestPath = Join-Path $archivePath 'DIGEST.md'
    $bulletPath = Join-Path $archivePath 'DIGEST-BULLETS.md'
    Write-Utf8 $digestPath $raw.ToString()
    Write-Utf8 $bulletPath $bullets.ToString()

    foreach ($item in $moves) {
        Move-Item -LiteralPath $item.Path -Destination (Join-Path $archivePath (Split-Path -Leaf $item.Path)) -Force
    }

    $state = Get-State
    $currentMoved = $false
    if ($state.current_session -and $state.current_session.file) {
        $currentName = Split-Path -Leaf ($state.current_session.file -replace '/', '\')
        foreach ($item in $moves) {
            if ((Split-Path -Leaf $item.Path) -eq $currentName) { $currentMoved = $true }
        }
    }
    if ($currentMoved) { $state.current_session = $null }
    $state.last_compaction = $stamp
    Save-State $state

    New-CompactionTaskFile -Stamp $stamp -Moves $moves -ArchivedTokens $archivedTokens -TotalBefore $report.Total -Threshold $report.Threshold -KeptTokens $keptTokens

    if (-not $Quiet) {
        Write-Host 'Compaction prepared.'
        Write-Host ("  archived : {0} log(s), ~{1} tokens -> .ai-context/archive/{2}/" -f $moves.Count, (Format-Number $archivedTokens), $stamp)
        Write-Host ("  live     : ~{0} tokens (kept newest logs, target <= {1})" -f (Format-Number ($report.Total - $archivedTokens)), (Format-Number $keptTokens))
        Write-Host '  next     : agent rewrites .ai-context/CONTEXT.md, then run compact-done'
    }
    return $stamp
}

function New-CompactionTaskFile {
    param(
        [string]$Stamp,
        $Moves,
        [int]$ArchivedTokens,
        [int]$TotalBefore,
        [int]$Threshold,
        [int]$KeptTokens
    )

    $maxContext = [int](Get-Cfg 'max_context_md_tokens' 3000)
    $stateJson = (Get-State) | ConvertTo-Json -Depth 8
    $stateJson = ($stateJson -split "`r?`n" | ForEach-Object { '    ' + $_ }) -join "`n"

    $task = @"
# COMPACTION TASK (action required)

Generated: $((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))
Archive folder: .ai-context/archive/$Stamp/
Archived: $($Moves.Count) log file(s), ~$(Format-Number $ArchivedTokens) tokens
Live context after archiving: ~$(Format-Number ($TotalBefore - $ArchivedTokens)) tokens (threshold $(Format-Number $Threshold))

## Do this now (agent)

1. Read '.ai-context/archive/$Stamp/DIGEST-BULLETS.md' first.
   Open 'DIGEST.md' only where bullets are not enough.
2. Rewrite '.ai-context/CONTEXT.md' so a new agent can continue without the archive.
   Keep it under ~$(Format-Number $maxContext) tokens; merge duplicates, drop chit-chat,
   keep facts, decisions, constraints, blockers and next steps.
   Update the "Last compacted" line and the compaction count.
3. Keep '.ai-context/STATE.json' in sync (current task, decisions, open questions, next steps).
4. Run: powershell -NoProfile -ExecutionPolicy Bypass -File tools/ai-context.ps1 compact-done
   That deletes this task file. Do not delete anything else.

## Required CONTEXT.md structure

1. What this project is
2. Current focus (task, status, owner agent, branch/dir)
3. Decisions (table: date | decision | rationale)
4. Constraints and conventions
5. Open questions
6. Next steps (ordered)
7. Key files

## State snapshot at compaction time

$stateJson
"@
    Write-Utf8 $script:TaskPath $task
}

function Invoke-CompactDone {
    Invoke-Init
    if (-not (Test-Path -LiteralPath $script:TaskPath)) {
        Write-Output 'No pending compaction task. Nothing to do.'
        return
    }
    $taskTime = (Get-Item -LiteralPath $script:TaskPath).LastWriteTime
    $contextTime = (Get-Item -LiteralPath $script:ContextPath).LastWriteTime
    if ($contextTime -le $taskTime -and -not $Force) {
        Write-Output 'CONTEXT.md has not been rewritten since the task was created.'
        Write-Output 'Rewrite .ai-context/CONTEXT.md first, then run compact-done (or pass -Force to skip the check).'
        exit 1
    }

    Remove-Item -LiteralPath $script:TaskPath -Force
    $state = Get-State
    $count = 1
    if ($state.compaction_count) { $count = [int]$state.compaction_count + 1 }
    $state.compaction_count = $count
    $state.last_compaction = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    Save-State $state

    Write-Output ("Compaction #{0} completed." -f $count)
    $report = Get-TokenReport
    Write-Output ("Live context: ~{0} tokens ({1}% of {2})." -f (Format-Number $report.Total), $report.Percent, (Format-Number $report.Threshold))
}

# ------------------------------------------------------------------- reset ----

function Invoke-Reset {
    param([switch]$Hard, [switch]$Yes)

    Invoke-Init
    if (-not $Yes) {
        Write-Output 'reset = back to zero operational context, keeping the research context.'
        Write-Output '  kept      : rule files (AGENTS.md, CLAUDE.md, ...), .ai-context/RESEARCH.md, config.json'
        Write-Output '  archived  : CONTEXT.md, STATE.json, COMPACTION_TASK.md, all log/*.md'
        Write-Output '  -Hard     : also archive RESEARCH.md and start a blank research context'
        Write-Output 'Nothing is deleted; everything is moved to .ai-context/archive/<timestamp>-reset/.'
        Write-Output ''
        Write-Output 'Confirm with: ai-context.ps1 reset -Yes [-Hard]'
        return
    }

    $previous = Get-State
    $resetCount = 1
    if ($previous.resets) { $resetCount = [int]$previous.resets + 1 }

    $stamp = (Get-Date).ToString('yyyyMMdd-HHmmss')
    $dest = Join-Path $script:ArchiveDir ("{0}-reset" -f $stamp)
    $suffix = 1
    while (Test-Path -LiteralPath $dest) {
        $suffix++
        $dest = Join-Path $script:ArchiveDir ("{0}-reset-{1}" -f $stamp, $suffix)
    }
    New-Item -ItemType Directory -Force -Path $dest | Out-Null

    foreach ($file in @($script:ContextPath, $script:StatePath, $script:TaskPath)) {
        if (Test-Path -LiteralPath $file) {
            Move-Item -LiteralPath $file -Destination (Join-Path $dest (Split-Path -Leaf $file)) -Force
        }
    }
    foreach ($log in Get-LogFiles) {
        Move-Item -LiteralPath $log.FullName -Destination (Join-Path $dest $log.Name) -Force
    }
    $researchArchived = $false
    if ($Hard -and (Test-Path -LiteralPath $script:ResearchPath)) {
        Move-Item -LiteralPath $script:ResearchPath -Destination (Join-Path $dest 'RESEARCH.md') -Force
        $researchArchived = $true
    }

    $manifestLines = @()
    foreach ($file in (Get-ChildItem -LiteralPath $dest -File)) {
        $manifestLines += ("- {0} (~{1} tokens)" -f $file.Name, (Format-Number (Get-FileTokens $file.FullName)))
    }
    $manifestText = (@($manifestLines) -join "`n")
    Write-Utf8 (Join-Path $dest 'RESET.md') ("# Reset $stamp`n`nOperational context archived. Research knowledge stays in .ai-context/RESEARCH.md.`n`n$manifestText`n")

    Write-Utf8 $script:ContextPath (New-ContextTemplate $stamp)
    if ($researchArchived -or -not (Test-Path -LiteralPath $script:ResearchPath)) {
        Write-Utf8 $script:ResearchPath (New-ResearchTemplate)
    }

    $state = Get-State
    $state.current_session = $null
    $state.active_goal = $null
    $state.decisions = @()
    $state.open_questions = @()
    $state.next_steps = @()
    $state.files_in_focus = @()
    $state.last_compaction = $null
    $state.compaction_count = 0
    $state | Add-Member -NotePropertyName resets -NotePropertyValue $resetCount -Force
    $state | Add-Member -NotePropertyName last_reset -NotePropertyValue $stamp -Force
    Save-State $state

    Write-Output ("Reset #{0} complete -> archived in .ai-context/archive/{1}-reset/" -f $resetCount, $stamp)
    if ($researchArchived) {
        Write-Output 'RESEARCH.md was archived as well (-Hard); a blank research template is in place.'
    } else {
        Write-Output 'Kept: .ai-context/RESEARCH.md (research context), rule files, config.json'
    }
    $report = Get-TokenReport
    Write-Output ("Live context: ~{0} tokens ({1}% of {2})." -f (Format-Number $report.Total), $report.Percent, (Format-Number $report.Threshold))
}

# ----------------------------------------------------------------- handoff ----

function Invoke-Resume {
    Invoke-Init
    $report = Get-TokenReport
    $state = Get-State

    Write-Output '================= HANDOFF PACK ================='
    Write-Output ("tokens: ~{0} / {1} ({2}%)" -f (Format-Number $report.Total), (Format-Number $report.Threshold), $report.Percent)
    if ($report.TaskPending) {
        Write-Output 'WARNING: .ai-context/COMPACTION_TASK.md is pending. Do it before new work.'
    }
    Write-Output ''
    Write-Output '----------------- CONTEXT.md -------------------'
    $contextText = (Read-Text $script:ContextPath).TrimEnd()
    Write-Output $contextText
    Write-Output ''
    Write-Output '----------------- RESEARCH.md ------------------'
    $researchText = (Read-Text $script:ResearchPath).TrimEnd()
    Write-Output $researchText
    Write-Output ''
    Write-Output '----------------- STATE.json -------------------'
    if ($state.current_session) {
        Write-Output ("current session : {0} ({1})" -f $state.current_session.id, $state.current_session.agent)
        Write-Output ("session file    : {0}" -f $state.current_session.file)
    } else {
        Write-Output 'current session : (none)'
    }
    Write-Output ("active goal     : {0}" -f $state.active_goal)
    Write-Output ("compactions     : {0} (last: {1})" -f $state.compaction_count, $state.last_compaction)
    foreach ($pair in @(
            @{ Label = 'decisions'; Items = $state.decisions },
            @{ Label = 'open questions'; Items = $state.open_questions },
            @{ Label = 'next steps'; Items = $state.next_steps },
            @{ Label = 'files in focus'; Items = $state.files_in_focus })) {
        Write-Output ''
        Write-Output ("{0}:" -f $pair.Label)
        if (@($pair.Items).Count -eq 0) {
            Write-Output '  - (empty)'
        } else {
            foreach ($item in @($pair.Items)) { Write-Output ("  - {0}" -f $item) }
        }
    }

    $newest = Get-NewestLogFile
    if ($newest) {
        Write-Output ''
        Write-Output ("----------------- recent log: {0} -----------------" -f $newest.Name)
        Get-Content -LiteralPath $newest.FullName -Tail 80 -Encoding UTF8 | ForEach-Object { Write-Output $_ }
    }
    Write-Output '==============================================='
}

# ----------------------------------------------------------------- capture ----

function Invoke-Capture {
    param(
        [string]$Path,
        [string]$AgentName,
        [int]$Max
    )

    Invoke-Init
    if (-not $Path) { throw 'capture requires -TranscriptPath' }
    if (-not (Test-Path -LiteralPath $Path)) { throw "Transcript not found: $Path" }
    if ($Max -le 0) { $Max = [int](Get-Cfg 'auto_capture_transcript_messages' 40) }

    $messages = New-Object System.Collections.ArrayList
    $lines = Get-Content -LiteralPath $Path -Encoding UTF8
    foreach ($line in $lines) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        try { $obj = $line | ConvertFrom-Json } catch { continue }
        if ($null -eq $obj) { continue }
        if ($obj.PSObject.Properties.Name -contains 'isMeta' -and $obj.isMeta -eq $true) { continue }

        $role = $null
        if ($obj.PSObject.Properties.Name -contains 'type' -and ($obj.type -eq 'user' -or $obj.type -eq 'assistant')) {
            $role = $obj.type
        }
        $content = $null
        if ($obj.PSObject.Properties.Name -contains 'message' -and $obj.message) {
            if ($obj.message.PSObject.Properties.Name -contains 'role') { $role = $obj.message.role }
            $content = $obj.message.content
        } elseif ($obj.PSObject.Properties.Name -contains 'content') {
            $content = $obj.content
        }
        if (-not $role -or $role -eq 'system') { continue }

        $text = ''
        if ($content -is [string]) {
            $text = $content
        } elseif ($content) {
            $parts = New-Object System.Collections.ArrayList
            foreach ($part in $content) {
                if ($part -is [string]) { [void]$parts.Add($part) }
                elseif ($part.PSObject.Properties.Name -contains 'text' -and $part.text) { [void]$parts.Add([string]$part.text) }
            }
            $text = ($parts.ToArray() -join "`n")
        }
        $text = ($text -replace '\s+', ' ').Trim()
        if ($text.Length -eq 0) { continue }
        if ($text.Length -gt 1500) { $text = $text.Substring(0, 1500) + ' ...[truncated]' }
        [void]$messages.Add([pscustomobject]@{ Role = $role; Text = $text })
    }

    if ($messages.Count -eq 0) {
        Write-Output 'No user/assistant messages found in the transcript.'
        return
    }

    $tail = @($messages.ToArray())
    if ($tail.Count -gt $Max) {
        $tail = @($tail[($tail.Count - $Max)..($tail.Count - 1)])
    }

    $state = Get-State
    $sessionFile = $null
    if ($state.current_session -and $state.current_session.file) {
        $candidate = Join-Path $script:RepoRoot ($state.current_session.file -replace '/', '\')
        if (Test-Path -LiteralPath $candidate) { $sessionFile = $candidate }
    }
    if (-not $sessionFile) {
        $sessionFile = Invoke-StartSession $AgentName 'captured transcript'
    }

    $builder = New-Object System.Text.StringBuilder
    [void]$builder.AppendLine('')
    [void]$builder.AppendLine(("### {0} | captured transcript ({1} messages)" -f (Get-Date).ToString('HH:mm'), $tail.Count))
    [void]$builder.AppendLine("- Source: $(Split-Path -Leaf $Path)")
    foreach ($msg in $tail) {
        [void]$builder.AppendLine(("- {0}: {1}" -f $msg.Role, $msg.Text))
    }
    Add-Content -LiteralPath $sessionFile -Value ($builder.ToString()) -Encoding UTF8

    Write-Output ("Captured {0} messages into {1}" -f $tail.Count, (Get-RelPath $sessionFile))
}

# ------------------------------------------------------------------- hooks ----

function Read-StdinJson {
    if ($StdinPayload) {
        try { return ($StdinPayload | ConvertFrom-Json) } catch { return $null }
    }
    try {
        if ([Console]::IsInputRedirected) {
            $raw = [Console]::In.ReadToEnd()
            if (-not [string]::IsNullOrWhiteSpace($raw)) {
                return ($raw | ConvertFrom-Json)
            }
        }
    } catch {
        # ignore malformed hook payloads
    }
    return $null
}

function Invoke-HookSessionStart {
    Invoke-Init
    try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false) } catch { }
    $payload = Read-StdinJson
    $source = 'startup'
    if ($payload -and ($payload.PSObject.Properties.Name -contains 'source') -and $payload.source) {
        $source = $payload.source
    }

    $parts = New-Object System.Collections.ArrayList
    [void]$parts.Add("AI CONTEXT MEMORY (.ai-context) - auto-injected [$source]")
    [void]$parts.Add('These files are the shared memory for every agent. Follow AGENTS.md.')
    [void]$parts.Add('')
    [void]$parts.Add('=== .ai-context/CONTEXT.md ===')
    [void]$parts.Add((Read-Text $script:ContextPath).TrimEnd())

    [void]$parts.Add('')
    [void]$parts.Add('=== .ai-context/RESEARCH.md (persistent, survives reset) ===')
    [void]$parts.Add((Read-Text $script:ResearchPath).TrimEnd())

    $state = Get-State
    [void]$parts.Add('')
    [void]$parts.Add('=== STATE.json ===')
    [void]$parts.Add(($state | ConvertTo-Json -Depth 8))

    $newest = Get-NewestLogFile
    if ($newest) {
        [void]$parts.Add('')
        [void]$parts.Add("=== Recent log: $($newest.Name) (last 50 lines) ===")
        foreach ($line in (Get-Content -LiteralPath $newest.FullName -Tail 50 -Encoding UTF8)) {
            [void]$parts.Add($line)
        }
    }

    if (Test-Path -LiteralPath $script:TaskPath) {
        [void]$parts.Add('')
        [void]$parts.Add('=== ACTION REQUIRED: .ai-context/COMPACTION_TASK.md is pending. Do it first. ===')
    }

    $context = ($parts.ToArray() -join "`n")
    if ($context.Length -gt 24000) {
        $context = $context.Substring(0, 24000) + "`n...[truncated: run 'resume' for the full pack]"
    }

    $output = [pscustomobject]@{
        hookSpecificOutput = [pscustomobject]@{
            hookEventName     = 'SessionStart'
            additionalContext = $context
        }
    }
    [Console]::Out.Write(($output | ConvertTo-Json -Depth 5 -Compress))
}

function Invoke-HookPreCompact {
    Invoke-Init
    $payload = Read-StdinJson
    if ($payload -and ($payload.PSObject.Properties.Name -contains 'transcript_path') -and $payload.transcript_path) {
        try {
            Invoke-Capture -Path $payload.transcript_path -AgentName 'claude-code' -Max $MaxMessages | Out-Null
        } catch {
            # never block compaction because of capture problems
        }
    }
    $report = Get-TokenReport
    if ($report.Total -ge $report.Threshold) {
        Invoke-Compact -Force -Quiet | Out-Null
    }
}

# -------------------------------------------------------------- dispatcher ----

function Show-Help {
    Write-Output 'ai-context.ps1 - shared, compactable memory for AI agents'
    Write-Output ''
    Write-Output 'Commands (first argument):'
    Write-Output '  init                       create/repair .ai-context (idempotent)'
    Write-Output '  start -Agent <a> -Goal <s> start a new session log'
    Write-Output '  log   -Agent <a> -Did <..> [-Goal] [-Decisions] [-Files] [-Next] [-Open] [-Note]'
    Write-Output '        (separate multiple values with ;; , e.g. -Did "one;;two")'
    Write-Output '  status                     tokens used vs. threshold'
    Write-Output '  compact [-Force]           archive old logs + create COMPACTION_TASK.md'
    Write-Output '  compact-done [-Force]      finish compaction after CONTEXT.md rewrite'
    Write-Output '  reset [-Yes] [-Hard]       archive operational context, keep RESEARCH.md'
    Write-Output '  resume                     print CONTEXT.md + RESEARCH.md + state + recent log'
    Write-Output '  capture -TranscriptPath <p> [-MaxMessages N]   import Claude Code transcript JSONL'
    Write-Output '  hook-session-start         (hook) inject context into a new session'
    Write-Output '  hook-precompact            (hook) capture transcript, then compact if over budget'
    Write-Output ''
    Write-Output 'Examples:'
    Write-Output '  powershell -NoProfile -ExecutionPolicy Bypass -File tools/ai-context.ps1 status'
    Write-Output '  powershell -NoProfile -ExecutionPolicy Bypass -File tools/ai-context.ps1 log -Agent cline -Did "Fixed parser" -Next "Run tests"'
}

switch ($Command) {
    'init' { Invoke-Init; Write-Output ('Context structure ready: ' + (Get-RelPath $script:ContextDir)) }
    'start' {
        $path = Invoke-StartSession $Agent $Goal
        if ($path) { Write-Output "Session started: $(Get-RelPath $path)" }
    }
    'log' {
        Add-LogEntry -AgentName $Agent -EntryGoal $Goal -EntryDid (Split-Values $Did) `
            -EntryDecisions (Split-Values $Decisions) -EntryFiles (Split-Values $Files) `
            -EntryNext (Split-Values $Next) -EntryOpen (Split-Values $Open) -EntryNote $Note
    }
    'status' { Show-Status }
    'compact' { [void](Invoke-Compact -Force:$Force) }
    'compact-done' { Invoke-CompactDone }
    'reset' { Invoke-Reset -Hard:$Hard -Yes:$Yes }
    'resume' { Invoke-Resume }
    'capture' { Invoke-Capture -Path $TranscriptPath -AgentName $Agent -Max $MaxMessages }
    'hook-session-start' { Invoke-HookSessionStart }
    'hook-precompact' { Invoke-HookPreCompact }
    'help' { Show-Help }
}
