#!/bin/bash
# .claude/commands/search/setup.sh
# Script tự động cài đặt uv/uvx, node/npx và cấu hình MCP servers cho /search command
# QUAN TRỌNG: Script này sẽ KHÔNG XÓA hay GHI ĐÈ các MCP server đã có

set -e  # Exit on error

echo "🚀 Bắt đầu cài đặt Search Tools (MCP Servers)..."
echo ""

# ============================================================================
# BƯỚC 1: Kiểm tra và cài đặt uv/uvx
# ============================================================================
echo "📦 Kiểm tra uv/uvx..."
if command -v uvx &> /dev/null; then
    echo "✅ uv/uvx đã được cài đặt"
    uv_version=$(uvx --version 2>&1)
    echo "   Phiên bản: $uv_version"
    echo ""
else
    echo "⚠️  uv/uvx chưa được cài đặt. Đang tiến hành cài đặt..."
    echo ""

    # Kiểm tra hệ điều hành
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - ưu tiên dùng brew
        if command -v brew &> /dev/null; then
            echo "📥 Cài đặt uv qua Homebrew..."
            brew install uv
        else
            echo "📥 Tải và cài đặt uv từ astral.sh..."
            curl -LsSf https://astral.sh/uv/install.sh | sh
        fi
    else
        # Linux
        echo "📥 Tải và cài đặt uv từ astral.sh..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi

    # Add uv to PATH for current session
    export PATH="$HOME/.local/bin:$PATH"

    # Kiểm tra lại
    if command -v uvx &> /dev/null; then
        echo "✅ Đã cài đặt uv/uvx thành công!"
        echo ""
    else
        echo "❌ Lỗi khi cài đặt uv. Vui lòng cài thủ công:"
        echo "   curl -LsSf https://astral.sh/uv/install.sh | sh"
        echo ""
        exit 1
    fi
fi

# ============================================================================
# BƯỚC 2: Kiểm tra và cài đặt Node.js/npx
# ============================================================================
echo "📦 Kiểm tra Node.js/npx..."
if command -v npx &> /dev/null; then
    echo "✅ Node.js/npx đã được cài đặt"
    node_version=$(node --version 2>&1)
    npm_version=$(npm --version 2>&1)
    echo "   Node version: $node_version"
    echo "   NPM version: $npm_version"
    echo ""
else
    echo "❌ Node.js/npx chưa được cài đặt."
    echo ""
    echo "Vui lòng cài đặt Node.js:"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "   macOS: brew install node"
    else
        echo "   Linux: sudo apt install nodejs npm  (hoặc tương tự cho distro của bạn)"
    fi
    echo "   Hoặc tải từ: https://nodejs.org/"
    echo ""
    echo "Sau khi cài đặt Node.js, vui lòng chạy lại script này."
    echo ""
    exit 1
fi

# ============================================================================
# BƯỚC 3: Tạo/cập nhật file .mcp.json (AN TOÀN)
# ============================================================================
echo "⚙️  Cấu hình MCP Servers..."
config_path=".mcp.json"

# Kiểm tra file .mcp.json đã tồn tại chưa
if [ -f "$config_path" ]; then
    echo "📄 File .mcp.json đã tồn tại. Đang merge cấu hình..."
    echo ""

    # Tạo backup
    cp "$config_path" "$config_path.backup"
    echo "   Đã tạo backup: $config_path.backup"

    # Kiểm tra xem có jq không (để merge JSON dễ dàng hơn)
    if command -v jq &> /dev/null; then
        # Sử dụng jq để merge an toàn

        # Kiểm tra và thêm từng MCP server
        added_servers=""
        existing_servers=""

        # ddg-search
        if jq -e '.mcpServers["ddg-search"]' "$config_path" > /dev/null 2>&1; then
            echo "   'ddg-search' đã được cấu hình - bỏ qua"
            existing_servers="$existing_servers\n   = ddg-search"
        else
            echo "   Đang thêm 'ddg-search'..."
            jq '.mcpServers["ddg-search"] = {"command": "uvx", "args": ["duckduckgo-mcp-server"]}' "$config_path" > "$config_path.tmp"
            mv "$config_path.tmp" "$config_path"
            added_servers="$added_servers\n   + ddg-search"
        fi

        # fetch
        if jq -e '.mcpServers["fetch"]' "$config_path" > /dev/null 2>&1; then
            echo "   'fetch' đã được cấu hình - bỏ qua"
            existing_servers="$existing_servers\n   = fetch"
        else
            echo "   Đang thêm 'fetch'..."
            jq '.mcpServers["fetch"] = {"command": "uvx", "args": ["mcp-server-fetch"]}' "$config_path" > "$config_path.tmp"
            mv "$config_path.tmp" "$config_path"
            added_servers="$added_servers\n   + fetch"
        fi

        # wikipedia
        if jq -e '.mcpServers["wikipedia"]' "$config_path" > /dev/null 2>&1; then
            echo "   'wikipedia' đã được cấu hình - bỏ qua"
            existing_servers="$existing_servers\n   = wikipedia"
        else
            echo "   Đang thêm 'wikipedia'..."
            jq '.mcpServers["wikipedia"] = {"command": "uvx", "args": ["wikipedia-mcp"]}' "$config_path" > "$config_path.tmp"
            mv "$config_path.tmp" "$config_path"
            added_servers="$added_servers\n   + wikipedia"
        fi

        # sequential-thinking
        if jq -e '.mcpServers["sequential-thinking"]' "$config_path" > /dev/null 2>&1; then
            echo "   'sequential-thinking' đã được cấu hình - bỏ qua"
            existing_servers="$existing_servers\n   = sequential-thinking"
        else
            echo "   Đang thêm 'sequential-thinking'..."
            jq '.mcpServers["sequential-thinking"] = {"command": "cmd", "args": ["/c", "npx", "-y", "@modelcontextprotocol/server-sequential-thinking"]}' "$config_path" > "$config_path.tmp"
            mv "$config_path.tmp" "$config_path"
            added_servers="$added_servers\n   + sequential-thinking"
        fi

        echo ""
        if [ -n "$added_servers" ]; then
            echo -e "Đã thêm MCP servers mới:$added_servers"
        fi
        if [ -n "$existing_servers" ]; then
            echo -e "Giữ nguyên MCP servers có sẵn:$existing_servers"
        fi
    else
        # Fallback: Không có jq, thông báo cho user thêm thủ công
        echo "⚠️  Không tìm thấy jq (JSON processor)."
        echo ""
        echo "Vui lòng cài jq để tự động merge:"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo "   macOS: brew install jq"
        else
            echo "   Linux: sudo apt install jq"
        fi
        echo ""
        echo "Hoặc thêm thủ công các cấu hình sau vào .mcp.json:"
        echo ""
        echo '  "ddg-search": {'
        echo '    "command": "uvx",'
        echo '    "args": ["duckduckgo-mcp-server"]'
        echo '  },'
        echo '  "fetch": {'
        echo '    "command": "uvx",'
        echo '    "args": ["mcp-server-fetch"]'
        echo '  },'
        echo '  "wikipedia": {'
        echo '    "command": "uvx",'
        echo '    "args": ["wikipedia-mcp"]'
        echo '  },'
        echo '  "sequential-thinking": {'
        echo '    "command": "cmd",'
        echo '    "args": ["/c", "npx", "-y", "@modelcontextprotocol/server-sequential-thinking"]'
        echo '  }'
        echo ""
    fi
else
    echo "📝 Tạo file .mcp.json mới..."

    # Tạo cấu hình mới
    cat <<EOF > "$config_path"
{
  "mcpServers": {
    "ddg-search": {
      "command": "uvx",
      "args": ["duckduckgo-mcp-server"]
    },
    "fetch": {
      "command": "uvx",
      "args": ["mcp-server-fetch"]
    },
    "wikipedia": {
      "command": "uvx",
      "args": ["wikipedia-mcp"]
    },
    "sequential-thinking": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "@modelcontextprotocol/server-sequential-thinking"]
    }
  }
}
EOF

    echo "✅ Đã tạo file .mcp.json với cấu hình search tools!"
fi

# ============================================================================
# BƯỚC 4: Kiểm tra tất cả MCP servers có trong .mcp.json
# ============================================================================
echo ""
echo "📋 Các MCP servers hiện có trong .mcp.json:"
if command -v jq &> /dev/null; then
    jq -r '.mcpServers | keys[]' "$config_path" | while read server; do
        echo "   - $server"
    done
else
    grep -o '"[^"]*":\s*{' "$config_path" | sed 's/:\s*{//g' | sed 's/"//g' | while read server; do
        echo "   - $server"
    done
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Setup hoàn tất!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📖 Bạn có thể bắt đầu sử dụng /search với 3 modes:"
echo "   1. Fast Search   - Thông tin nhanh (thời tiết, giá cả, tin tức)"
echo "   2. Broad Search  - Nghiên cứu rộng (khái niệm, lịch sử)"
echo "   3. Deep Search   - Phân tích sâu (tài liệu kỹ thuật, debug)"
echo ""
echo "🛠️  Các công cụ MCP đã cài đặt:"
echo "   • DuckDuckGo Search (ddg-search)"
echo "   • Wikipedia (wikipedia)"
echo "   • Web Fetch (fetch)"
echo "   • Sequential Thinking (sequential-thinking)"
echo ""
echo "💡 Tip: Claude sẽ tự động chọn mode phù hợp dựa trên câu hỏi của bạn!"
echo ""
echo "⚠️  Lưu ý: Bạn có thể cần khởi động lại terminal để PATH được cập nhật."
echo ""
