param(
    [Parameter(Mandatory=$true)]
    [string]$TargetDir
)

$RAW_BASE = "https://raw.githubusercontent.com/yallma3/codewiser/main"

$TargetDir = Resolve-Path $TargetDir -ErrorAction SilentlyContinue
if (-not $TargetDir) {
    $TargetDir = [System.IO.Path]::GetFullPath($TargetDir)
}
New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null

Write-Host "🚀 Initializing Multi-Agent Skills Framework in $TargetDir..."

# --- Agent Selection (checkbox-style) ---
$choices = @("OpenCode / MiMo / Crush", "Claude Code", "Cursor", "Antigravity", "Kilo Code")
$selections = @($false, $false, $false, $false, $false)

Write-Host ""
Write-Host "Select AI agents (enter number to toggle, 'd' when done):"

while ($true) {
    for ($i = 0; $i -lt $choices.Length; $i++) {
        $mark = " "
        if ($selections[$i]) { $mark = "x" }
        Write-Host "  [$mark] $($i+1))) $($choices[$i])"
    }
    Write-Host "  [ ] d) Done"
    Write-Host "  [ ] c) Cancel"
    $input = Read-Host "> "

    switch ($input) {
        { $_ -in "1","2","3","4","5" } {
            $idx = [int]$input - 1
            $selections[$idx] = -not $selections[$idx]
        }
        { $_ -in "d","D","" } {
            $any = $false
            foreach ($s in $selections) { if ($s) { $any = $true; break } }
            if (-not $any) {
                Write-Host "No agents selected. Cancelled."
                exit 0
            }
            break
        }
        { $_ -in "c","C" } { Write-Host "Cancelled."; exit 0 }
        default { Write-Host "  Invalid choice." }
    }
}

$use_opencode = $selections[0]
$use_claude   = $selections[1]
$use_cursor   = $selections[2]
$use_antigravity = $selections[3]
$use_kilo     = $selections[4]

# --- 1. Create directory structure ---
Write-Host ""
Write-Host "📁 Creating folder architecture..."
New-Item -ItemType Directory -Path "$TargetDir\.agents\skills" -Force | Out-Null
New-Item -ItemType Directory -Path "$TargetDir\.agents\specs" -Force | Out-Null
New-Item -ItemType Directory -Path "$TargetDir\.agents\plans" -Force | Out-Null
New-Item -ItemType Directory -Path "$TargetDir\.agents\research" -Force | Out-Null

if ($use_claude) { New-Item -ItemType Directory -Path "$TargetDir\.claude" -Force | Out-Null }
if ($use_cursor) { New-Item -ItemType Directory -Path "$TargetDir\.cursor" -Force | Out-Null }
if ($use_antigravity) { New-Item -ItemType Directory -Path "$TargetDir\.antigravity" -Force | Out-Null }
if ($use_kilo) { New-Item -ItemType Directory -Path "$TargetDir\.kilo" -Force | Out-Null }

# --- Helper: download a file ---
function Download {
    param([string]$Url, [string]$Dest)
    New-Item -ItemType Directory -Path (Split-Path $Dest -Parent) -Force | Out-Null
    try {
        Invoke-WebRequest -Uri $Url -OutFile $Dest -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

# --- Helper: compare versions (returns $true if v1 < v2) ---
function Version-Lt {
    param([string]$v1, [string]$v2)
    $parts1 = $v1.Split('.')
    $parts2 = $v2.Split('.')
    for ($i = 0; $i -lt [Math]::Max($parts1.Length, $parts2.Length); $i++) {
        $p1 = if ($i -lt $parts1.Length) { [int]$parts1[$i] } else { 0 }
        $p2 = if ($i -lt $parts2.Length) { [int]$parts2[$i] } else { 0 }
        if ($p1 -lt $p2) { return $true }
        if ($p1 -gt $p2) { return $false }
    }
    return $false
}

# --- Helper: get version for a file path from local manifest ---
function Get-ManifestVersion {
    param([string]$ManifestPath, [string]$FilePath)
    if (-not (Test-Path $ManifestPath)) { return $null }
    $obj = Get-Content $ManifestPath -Raw | ConvertFrom-Json
    if ($obj.workflows) {
        foreach ($wf in $obj.workflows.PSObject.Properties.Value) {
            foreach ($stage in $wf.stages.PSObject.Properties.Value) {
                if ($stage.files.$FilePath) {
                    return $stage.files.$FilePath
                }
            }
        }
        return $null
    } elseif ($obj.files) {
        return $obj.files.$FilePath
    }
    return $null
}

# --- Helper: flatten selected workflows into a file dictionary ---
function Flatten-WorkflowFiles {
    param([PSObject]$ManifestObj, [int[]]$SelectedIndices)
    $wfNames = @($ManifestObj.workflows.PSObject.Properties.Name)
    $files = @{}
    foreach ($idx in $SelectedIndices) {
        $wfName = $wfNames[$idx]
        $wf = $ManifestObj.workflows.$wfName
        foreach ($stage in $wf.stages.PSObject.Properties.Value) {
            foreach ($entry in $stage.files.PSObject.Properties) {
                $files[$entry.Name] = $entry.Value
            }
        }
    }
    return $files
}

# --- 2. Download remote manifest ---
Write-Host ""
Write-Host "📥 Fetching available workflows..."

$localManifestPath = "$TargetDir\.agents\manifest.json"
$remoteManifest = New-TemporaryFile

$manifestOk = Download -Url "$RAW_BASE/manifest.json" -Dest $remoteManifest.FullName
if (-not $manifestOk) {
    Write-Host "  ⚠ Failed to download remote manifest. Aborting."
    Remove-Item $remoteManifest.FullName -Force -ErrorAction SilentlyContinue
    exit 1
}

$remoteManifestObj = Get-Content $remoteManifest.FullName -Raw | ConvertFrom-Json

$localManifestObj = $null
if (Test-Path $localManifestPath) {
    $localManifestObj = Get-Content $localManifestPath -Raw | ConvertFrom-Json
}

# Detect format and optionally prompt for workflow selection
$remoteFiles = @{}
if ($remoteManifestObj.workflows) {
    # --- Workflow Selection ---
    $wfNames = @($remoteManifestObj.workflows.PSObject.Properties.Name)
    $wfSelections = @($false) * $wfNames.Count

    Write-Host ""
    Write-Host "Select workflows to install (enter number to toggle, 'd' when done):"

    while ($true) {
        for ($i = 0; $i -lt $wfNames.Count; $i++) {
            $mark = " "
            if ($wfSelections[$i]) { $mark = "x" }
            Write-Host "  [$mark] $($i+1))) $($wfNames[$i])"
        }
        Write-Host "  [ ] d) Done"
        Write-Host "  [ ] c) Cancel"
        $input = Read-Host "> "

        switch ($input) {
            { $_ -in "1".."9" } {
                $idx = [int]$input - 1
                if ($idx -ge $wfNames.Count) {
                    Write-Host "  Invalid choice."
                    continue
                }
                $wfSelections[$idx] = -not $wfSelections[$idx]
            }
            { $_ -in "d","D","" } {
                $any = $false
                foreach ($s in $wfSelections) { if ($s) { $any = $true; break } }
                if (-not $any) {
                    Write-Host "  ⚠ No workflows selected."
                    continue
                }
                break
            }
            { $_ -in "c","C" } { Write-Host "Cancelled."; Remove-Item $remoteManifest.FullName -Force -ErrorAction SilentlyContinue; exit 0 }
            default { Write-Host "  Invalid choice." }
        }
    }

    # Build selected workflow indices
    $selectedIndices = @()
    $selectedNames = @()
    for ($i = 0; $i -lt $wfSelections.Count; $i++) {
        if ($wfSelections[$i]) {
            $selectedIndices += $i
            $selectedNames += $wfNames[$i]
        }
    }

    # Build deduplicated skill directories from selected workflows
    $skillDirs = @()
    foreach ($wf in $selectedNames) {
        switch ($wf) {
            "frontend" { $skillDirs += @("shared", "frontend") }
            "backend"  { $skillDirs += @("shared", "backend") }
        }
    }
    $skillDirs = $skillDirs | Select-Object -Unique

    Write-Host ""
    Write-Host "📥 Checking for framework updates..."
    Write-Host "  Workflows: $($selectedNames -join ' ')"

    $remoteFiles = Flatten-WorkflowFiles -ManifestObj $remoteManifestObj -SelectedIndices $selectedIndices
} elseif ($remoteManifestObj.files) {
    # --- Backward compatibility: flat files structure (v1.x) ---
    Write-Host ""
    Write-Host "📥 Checking for framework updates..."

    foreach ($entry in $remoteManifestObj.files.PSObject.Properties) {
        $remoteFiles[$entry.Name] = $entry.Value
    }
    $skillDirs = @()
} else {
    Write-Host "  ⚠ Unknown manifest format. Aborting."
    Remove-Item $remoteManifest.FullName -Force -ErrorAction SilentlyContinue
    exit 1
}

# --- 3. Download/update files ---
foreach ($entry in $remoteFiles.GetEnumerator()) {
    $path = $entry.Key
    $remoteVer = $entry.Value

    $dest = "$TargetDir\$path"
    $url = "$RAW_BASE/$path"

    $localVer = Get-ManifestVersion -ManifestPath $localManifestPath -FilePath $path
    if (-not $localVer) { $localVer = "0.0.0" }

    if (-not (Test-Path $dest)) {
        New-Item -ItemType Directory -Path (Split-Path $dest -Parent) -Force | Out-Null
        Write-Host "  📄 $path (new)"
        $ok = Download -Url $url -Dest $dest
        if (-not $ok) { Write-Host "  ⚠ Failed to download $path" }
    } elseif (Version-Lt $localVer $remoteVer) {
        Write-Host "  📄 $path ($localVer → $remoteVer)"
        $answer = Read-Host "    Overwrite? [y/N]"
        if ($answer -eq "y" -or $answer -eq "Y") {
            $ok = Download -Url $url -Dest $dest
            if (-not $ok) { Write-Host "  ⚠ Failed to download $path" }
        } else {
            Write-Host "    Skipped."
        }
    } else {
        Write-Host "  ✓ $path (up to date)"
    }
}

Remove-Item $remoteManifest.FullName -Force -ErrorAction SilentlyContinue

# Save updated local manifest
Download -Url "$RAW_BASE/manifest.json" -Dest $localManifestPath | Out-Null

# --- 4. Generate supplementary explicit configurations ---
if ($use_opencode -and -not (Test-Path "$TargetDir\opencode.json")) {
    Write-Host "📄 Creating opencode.json..."
    if ($skillDirs.Count -gt 0) {
        $config = @{
            '$schema' = 'https://opencode.ai/config.json'
            skills = @{
                paths = @($skillDirs | ForEach-Object { ".agents/skills/$_" })
            }
            instructions = @(($skillDirs | ForEach-Object { ".agents/skills/$_/**/SKILL.md" }) + "AGENTS.md")
        }
        $config | ConvertTo-Json -Depth 3 | Set-Content "$TargetDir\opencode.json"
    } else {
        $config = @{
            '$schema' = 'https://opencode.ai/config.json'
            skills = @{
                paths = @(".agents/skills")
            }
            instructions = @(".agents/skills/**/SKILL.md", "AGENTS.md")
        }
        $config | ConvertTo-Json -Depth 3 | Set-Content "$TargetDir\opencode.json"
    }
}

if ($use_claude -and -not (Test-Path "$TargetDir\CLAUDE.md")) {
    Write-Host "📄 Creating CLAUDE.md..."
    @'
# Claude Code Settings

@AGENTS.md

## Claude-Specific Instructions
- Utilize the symlinked skills located in `.claude/skills/` when triggered.
'@ | Set-Content "$TargetDir\CLAUDE.md" -NoNewline
}

if ($use_antigravity -and -not (Test-Path "$TargetDir\.antigravity\workflows.json")) {
    Write-Host "📄 Creating .antigravity/workflows.json..."
    New-Item -ItemType Directory -Path "$TargetDir\.antigravity" -Force | Out-Null
    $config = @{
        workflows = @(
            @{
                name = "example"
                description = "Example workflow referencing shared .agents/skills"
            }
        )
    }
    $config | ConvertTo-Json -Depth 3 | Set-Content "$TargetDir\.antigravity\workflows.json"
}

if ($use_kilo -and -not (Test-Path "$TargetDir\.kilo\config.json")) {
    Write-Host "📄 Creating .kilo/config.json..."
    New-Item -ItemType Directory -Path "$TargetDir\.kilo" -Force | Out-Null
    if ($skillDirs.Count -gt 0) {
        $instructions = @("AGENTS.md")
        $instructions += $skillDirs | ForEach-Object { ".agents/skills/$_/**/SKILL.md" }
        $config = @{
            '$schema' = 'https://app.kilo.ai/config.json'
            instructions = $instructions
        }
        $config | ConvertTo-Json -Depth 3 | Set-Content "$TargetDir\.kilo\config.json"
    } else {
        $config = @{
            '$schema' = 'https://app.kilo.ai/config.json'
            instructions = @("AGENTS.md", ".agents/skills/*/SKILL.md")
        }
        $config | ConvertTo-Json -Depth 3 | Set-Content "$TargetDir\.kilo\config.json"
    }
}

# --- 5. Create symbolic links ---
Write-Host ""
Write-Host "🔗 Generating symbolic links..."

function Migrate-And-Symlink {
    param([string]$Src, [string]$Dest, [string]$Label)
    $srcPath = "$TargetDir\$Src"

    if ((Test-Path $srcPath) -and -not (Get-Item $srcPath).Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        Write-Host "  ↳ Migrating existing $Label assets into .agents..."
        Get-ChildItem "$srcPath\*" -ErrorAction SilentlyContinue | Copy-Item -Destination "$TargetDir\.agents\skills\" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item $srcPath -Recurse -Force -ErrorAction SilentlyContinue
    }

    if (Test-Path $srcPath) {
        Remove-Item $srcPath -Recurse -Force -ErrorAction SilentlyContinue
    }

    New-Item -ItemType SymbolicLink -Path $srcPath -Target $Dest -Force | Out-Null
    Write-Host "  ↳ Linked $srcPath -> $Dest"
}

if ($use_claude) { Migrate-And-Symlink -Src ".claude\skills" -Dest "..\.agents\skills" -Label "Claude Code" }
if ($use_cursor) { Migrate-And-Symlink -Src ".cursor\skills" -Dest "..\.agents\skills" -Label "Cursor" }

Write-Host ""
Write-Host "📎 Symbolic links created:"
if ($use_claude) { Write-Host "  - $TargetDir\.claude\skills → ..\.agents\skills" }
if ($use_cursor) { Write-Host "  - $TargetDir\.cursor\skills → ..\.agents\skills" }

Write-Host ""
Write-Host "✅ Setup complete! Target: $TargetDir"
