# .claude/commands/pdf/setup.ps1
# Script tu dong cai dat uv/uvx va cau hinh MCP server cho markitdown (PDF reader)

Write-Host "Starting PDF Reader (MarkItDown MCP Server) installation..." -ForegroundColor Cyan
Write-Host ""

# Step 1: Check if uv/uvx is already installed
Write-Host "Checking uv/uvx..." -ForegroundColor Yellow
$uvInstalled = Get-Command uvx -ErrorAction SilentlyContinue

if (-not $uvInstalled) {
    Write-Host "uv/uvx not found. Installing..." -ForegroundColor Yellow
    Write-Host ""

    try {
        # Install uv using official installer
        Write-Host "Downloading and installing uv from astral.sh..." -ForegroundColor Cyan
        powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

        # Refresh PATH in current session
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

        Write-Host "Successfully installed uv/uvx!" -ForegroundColor Green
        Write-Host ""
    }
    catch {
        Write-Host "Error installing uv. Please install manually:" -ForegroundColor Red
        Write-Host "   powershell -ExecutionPolicy ByPass -c ""irm https://astral.sh/uv/install.ps1 | iex""" -ForegroundColor White
        Write-Host ""
        exit 1
    }
} else {
    Write-Host "uv/uvx already installed" -ForegroundColor Green
    $uvVersion = & uvx --version 2>&1
    Write-Host "   Version: $uvVersion" -ForegroundColor Gray
    Write-Host ""
}

# Step 2: Create/update .mcp.json file
Write-Host "Configuring MCP Server..." -ForegroundColor Yellow
$configPath = ".mcp.json"

# Check if .mcp.json already exists
if (Test-Path $configPath) {
    Write-Host ".mcp.json already exists. Checking configuration..." -ForegroundColor Cyan

    try {
        $existingConfig = Get-Content $configPath -Raw | ConvertFrom-Json

        # Check if markitdown is already configured
        if ($existingConfig.mcpServers.PSObject.Properties.Name -contains "markitdown") {
            Write-Host "MCP Server 'markitdown' already configured!" -ForegroundColor Green
            Write-Host ""
            Write-Host "Setup complete! You can use /pdf now." -ForegroundColor Green
            exit 0
        } else {
            Write-Host "markitdown not configured. Adding..." -ForegroundColor Yellow

            # Add markitdown to existing config
            $markitdownConfig = @{
                "command" = "uvx"
                "args" = @("markitdown-mcp")
            }

            $existingConfig.mcpServers | Add-Member -NotePropertyName "markitdown" -NotePropertyValue $markitdownConfig -Force

            # Save file with clean formatting
            $jsonOutput = $existingConfig | ConvertTo-Json -Depth 10 -Compress
            $jsonOutput = $jsonOutput -replace '([{,])', "$1`n  " -replace '([}])', "`n$1"
            Set-Content -Path $configPath -Value $jsonOutput
            Write-Host "Added markitdown configuration to .mcp.json" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "Error reading/updating .mcp.json: $_" -ForegroundColor Red
        Write-Host "   Please check the file manually." -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "Creating new .mcp.json file..." -ForegroundColor Cyan

    # Create new configuration with clean formatting
    $configJson = @"
{
  "mcpServers": {
    "markitdown": {
      "command": "uvx",
      "args": ["markitdown-mcp"]
    }
  }
}
"@

    Set-Content -Path $configPath -Value $configJson
    Write-Host "Created .mcp.json with markitdown configuration!" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Gray
Write-Host "Setup complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Gray
Write-Host ""
Write-Host "You can now use /pdf to:" -ForegroundColor Cyan
Write-Host "   * Read PDF files" -ForegroundColor White
Write-Host "   * Read Word (DOCX) files" -ForegroundColor White
Write-Host "   * Read Excel (XLSX) files" -ForegroundColor White
Write-Host "   * Read PowerPoint (PPTX) files" -ForegroundColor White
Write-Host ""
Write-Host "Tip: Drag and drop files into chat or ask Claude to analyze files!" -ForegroundColor Yellow
Write-Host ""
