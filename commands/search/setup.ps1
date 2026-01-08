# .claude/commands/search/setup.ps1
# Script tự động cài đặt uv/uvx, node/npx và cấu hình MCP servers cho /search command
# QUAN TRỌNG: Script này sẽ KHÔNG XÓA hay GHI ĐÈ các MCP server đã có

Write-Host "Starting Search Tools (MCP Servers) installation..." -ForegroundColor Cyan
Write-Host ""

# ============================================================================
# BƯỚC 1: Kiểm tra và cài đặt uv/uvx
# ============================================================================
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

# ============================================================================
# BƯỚC 2: Kiểm tra và cài đặt Node.js/npx
# ============================================================================
Write-Host "Checking Node.js/npx..." -ForegroundColor Yellow
$npxInstalled = Get-Command npx -ErrorAction SilentlyContinue

if (-not $npxInstalled) {
    Write-Host "Node.js/npx not found." -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Node.js manually from: https://nodejs.org/" -ForegroundColor Yellow
    Write-Host "After installing Node.js, please run this script again." -ForegroundColor Yellow
    Write-Host ""
    exit 1
} else {
    Write-Host "Node.js/npx already installed" -ForegroundColor Green
    $nodeVersion = & node --version 2>&1
    $npmVersion = & npm --version 2>&1
    Write-Host "   Node version: $nodeVersion" -ForegroundColor Gray
    Write-Host "   NPM version: $npmVersion" -ForegroundColor Gray
    Write-Host ""
}

# ============================================================================
# BƯỚC 3: Tạo/cập nhật file .mcp.json (AN TOÀN)
# ============================================================================
Write-Host "Configuring MCP Servers..." -ForegroundColor Yellow
$configPath = ".mcp.json"

# Danh sách các MCP servers cần cài cho /search
$searchServers = @{
    "ddg-search" = @{
        "command" = "uvx"
        "args" = @("duckduckgo-mcp-server")
    }
    "fetch" = @{
        "command" = "uvx"
        "args" = @("mcp-server-fetch")
    }
    "wikipedia" = @{
        "command" = "uvx"
        "args" = @("wikipedia-mcp")
    }
    "sequential-thinking" = @{
        "command" = "cmd"
        "args" = @("/c", "npx", "-y", "@modelcontextprotocol/server-sequential-thinking")
    }
}

# Kiểm tra file .mcp.json đã tồn tại chưa
if (Test-Path $configPath) {
    Write-Host ".mcp.json already exists. Merging configuration..." -ForegroundColor Cyan
    Write-Host ""

    try {
        # Đọc cấu hình hiện tại
        $existingConfig = Get-Content $configPath -Raw | ConvertFrom-Json

        # Đảm bảo có thuộc tính mcpServers
        if (-not $existingConfig.PSObject.Properties.Name -contains "mcpServers") {
            $existingConfig | Add-Member -NotePropertyName "mcpServers" -NotePropertyValue @{} -Force
        }

        # Tạo backup trước khi thay đổi
        $backupPath = ".mcp.json.backup"
        Copy-Item $configPath $backupPath -Force
        Write-Host "Created backup: $backupPath" -ForegroundColor Gray

        # Kiểm tra và thêm từng MCP server
        $addedServers = @()
        $existingServers = @()

        foreach ($serverName in $searchServers.Keys) {
            if ($existingConfig.mcpServers.PSObject.Properties.Name -contains $serverName) {
                Write-Host "   '$serverName' already configured - skipping" -ForegroundColor Gray
                $existingServers += $serverName
            } else {
                Write-Host "   Adding '$serverName'..." -ForegroundColor Cyan
                $existingConfig.mcpServers | Add-Member -NotePropertyName $serverName -NotePropertyValue $searchServers[$serverName] -Force
                $addedServers += $serverName
            }
        }

        # Lưu file với định dạng JSON đẹp
        $jsonOutput = $existingConfig | ConvertTo-Json -Depth 10
        Set-Content -Path $configPath -Value $jsonOutput

        Write-Host ""
        if ($addedServers.Count -gt 0) {
            Write-Host "Added new MCP servers:" -ForegroundColor Green
            foreach ($server in $addedServers) {
                Write-Host "   + $server" -ForegroundColor Green
            }
        }
        if ($existingServers.Count -gt 0) {
            Write-Host "Kept existing MCP servers:" -ForegroundColor Yellow
            foreach ($server in $existingServers) {
                Write-Host "   = $server" -ForegroundColor Yellow
            }
        }
        Write-Host ""
    }
    catch {
        Write-Host "Error reading/updating .mcp.json: $_" -ForegroundColor Red
        Write-Host "   Restoring from backup..." -ForegroundColor Yellow
        if (Test-Path $backupPath) {
            Copy-Item $backupPath $configPath -Force
            Write-Host "   Restored successfully" -ForegroundColor Green
        }
        Write-Host ""
        exit 1
    }
} else {
    Write-Host "Creating new .mcp.json file..." -ForegroundColor Cyan

    # Tạo cấu hình mới
    $newConfig = @{
        "mcpServers" = $searchServers
    }

    $jsonOutput = $newConfig | ConvertTo-Json -Depth 10
    Set-Content -Path $configPath -Value $jsonOutput
    Write-Host "Created .mcp.json with search tools configuration!" -ForegroundColor Green
    Write-Host ""
}

# ============================================================================
# BƯỚC 4: Kiểm tra tất cả MCP servers có trong .mcp.json
# ============================================================================
Write-Host "Current MCP servers in .mcp.json:" -ForegroundColor Cyan
$finalConfig = Get-Content $configPath -Raw | ConvertFrom-Json
$allServers = $finalConfig.mcpServers.PSObject.Properties.Name
foreach ($server in $allServers) {
    Write-Host "   - $server" -ForegroundColor White
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Gray
Write-Host "Setup complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Gray
Write-Host ""
Write-Host "You can now use /search with 3 modes:" -ForegroundColor Cyan
Write-Host "   1. Fast Search   - Quick info (weather, prices, news)" -ForegroundColor White
Write-Host "   2. Broad Search  - Research topics (concepts, history)" -ForegroundColor White
Write-Host "   3. Deep Search   - Technical analysis (docs, debugging)" -ForegroundColor White
Write-Host ""
Write-Host "Installed MCP tools:" -ForegroundColor Cyan
Write-Host "   - DuckDuckGo Search (ddg-search)" -ForegroundColor White
Write-Host "   - Wikipedia (wikipedia)" -ForegroundColor White
Write-Host "   - Web Fetch (fetch)" -ForegroundColor White
Write-Host "   - Sequential Thinking (sequential-thinking)" -ForegroundColor White
Write-Host ""
Write-Host "Tip: Claude will automatically choose the right mode based on your query!" -ForegroundColor Yellow
Write-Host ""
