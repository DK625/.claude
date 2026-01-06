#!/bin/bash
# .claude/commands/pdf/setup.sh
# Script tự động cài đặt uv/uvx và cấu hình MCP server cho markitdown (PDF reader)

set -e  # Exit on error

echo "🚀 Bắt đầu cài đặt PDF Reader (MarkItDown MCP Server)..."
echo ""

# Bước 1: Kiểm tra uv/uvx đã được cài đặt chưa
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

# Bước 2: Tạo/cập nhật file .mcp.json
echo "⚙️  Cấu hình MCP Server..."
config_path=".mcp.json"

# Kiểm tra file .mcp.json đã tồn tại chưa
if [ -f "$config_path" ]; then
    echo "📄 File .mcp.json đã tồn tại. Đang kiểm tra cấu hình..."

    # Kiểm tra xem markitdown đã được cấu hình chưa
    if grep -q '"markitdown"' "$config_path"; then
        echo "✅ MCP Server 'markitdown' đã được cấu hình sẵn!"
        echo ""
        echo "🎉 Setup hoàn tất! Bạn có thể sử dụng /pdf ngay bây giờ."
        exit 0
    else
        echo "⚠️  Chưa có cấu hình 'markitdown'. Đang thêm vào..."

        # Tạo backup
        cp "$config_path" "$config_path.backup"

        # Sử dụng jq để thêm cấu hình (nếu có jq)
        if command -v jq &> /dev/null; then
            jq '.mcpServers.markitdown = {"command": "uvx", "args": ["markitdown-mcp"]}' "$config_path" > "$config_path.tmp"
            mv "$config_path.tmp" "$config_path"
            echo "✅ Đã thêm cấu hình 'markitdown' vào .mcp.json"
        else
            # Fallback: Thông báo cho user thêm thủ công
            echo "⚠️  Không tìm thấy jq. Vui lòng thêm cấu hình sau vào .mcp.json:"
            echo ""
            echo '  "markitdown": {'
            echo '    "command": "uvx",'
            echo '    "args": ["markitdown-mcp"]'
            echo '  }'
            echo ""
        fi
    fi
else
    echo "📝 Tạo file .mcp.json mới..."

    # Tạo cấu hình mới
    cat <<EOF > "$config_path"
{
  "mcpServers": {
    "markitdown": {
      "command": "uvx",
      "args": ["markitdown-mcp"]
    }
  }
}
EOF

    echo "✅ Đã tạo file .mcp.json với cấu hình markitdown!"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Setup hoàn tất!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📖 Bạn có thể bắt đầu sử dụng /pdf để:"
echo "   • Đọc file PDF"
echo "   • Đọc file Word (DOCX)"
echo "   • Đọc file Excel (XLSX)"
echo "   • Đọc file PowerPoint (PPTX)"
echo ""
echo "💡 Tip: Kéo thả file vào chat hoặc yêu cầu Claude phân tích file!"
echo ""
echo "⚠️  Lưu ý: Bạn có thể cần khởi động lại terminal để PATH được cập nhật."
echo ""
