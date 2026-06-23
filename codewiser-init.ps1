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

# --- 2. Download shared framework files from repo using manifest versioning ---
Write-Host ""
Write-Host "📥 Checking for framework updates..."

$localManifestPath = "$TargetDir\.agents\manifest.json"
$remoteManifest = New-TemporaryFile

$manifestOk = Download -Url "$RAW_BASE/manifest.json" -Dest $remoteManifest.FullName
if (-not $manifestOk) {
    Write-Host "  ⚠ Failed to download remote manifest. Aborting."
    Remove-Item $remoteManifest.FullName -Force -ErrorAction SilentlyContinue
    exit 1
}

$remoteManifestObj = Get-Content $remoteManifest.FullName -Raw | ConvertFrom-Json
$files = $remoteManifestObj.files.PSObject.Properties

$localManifestObj = $null
if (Test-Path $localManifestPath) {
    $localManifestObj = Get-Content $localManifestPath -Raw | ConvertFrom-Json
}

foreach ($entry in $files) {
    $path = $entry.Name
    $remoteVer = $entry.Value

    $dest = "$TargetDir\$path"
    $url = "$RAW_BASE/$path"

    $localVer = "0.0.0"
    if ($localManifestObj -and $localManifestObj.files.$path) {
        $localVer = $localManifestObj.files.$path
    }

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

# --- 3. Generate supplementary explicit configurations ---
if ($use_opencode -and -not (Test-Path "$TargetDir\opencode.json")) {
    Write-Host "📄 Creating opencode.json..."
    @"
{
  "\$schema": "https://opencode.ai/config.json",
  "instructions": [
    ".agents/skills/**/SKILL.md",
    "AGENTS.md"
  ]
}
"@ | Set-Content "$TargetDir\opencode.json" -NoNewline
}

if ($use_claude -and -not (Test-Path "$TargetDir\CLAUDE.md")) {
    Write-Host "📄 Creating CLAUDE.md..."
    @"
# Claude Code Settings

@AGENTS.md

## Claude-Specific Instructions
- Utilize the symlinked skills located in `.claude/skills/` when triggered.
"@ | Set-Content "$TargetDir\CLAUDE.md" -NoNewline
}

if ($use_antigravity -and -not (Test-Path "$TargetDir\.antigravity\workflows.json")) {
    Write-Host "📄 Creating .antigravity/workflows.json..."
    New-Item -ItemType Directory -Path "$TargetDir\.antigravity" -Force | Out-Null
    @"
{
  "workflows": [
    {
      "name": "example",
      "description": "Example workflow referencing shared .agents/skills"
    }
  ]
}
"@ | Set-Content "$TargetDir\.antigravity\workflows.json" -NoNewline
}

if ($use_kilo -and -not (Test-Path "$TargetDir\.kilo\config.json")) {
    Write-Host "📄 Creating .kilo/config.json..."
    New-Item -ItemType Directory -Path "$TargetDir\.kilo" -Force | Out-Null
    @"
{
  "\$schema": "https://app.kilo.ai/config.json",
  "instructions": ["AGENTS.md", ".agents/skills/*/SKILL.md"]
}
"@ | Set-Content "$TargetDir\.kilo\config.json" -NoNewline
}

# --- 4. Create symbolic links ---
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
