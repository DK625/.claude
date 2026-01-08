# Slash Command: /search

## Mục đích
Kích hoạt tính năng nghiên cứu toàn diện với bộ 4 công cụ MCP: **DuckDuckGo (Search nhanh)**, **Wikipedia (Kiến thức nền)**, **Fetch (Đào sâu)** và **Sequential Thinking (Tư duy hệ thống)**.

---

## Quy trình thực hiện

### Bước 1: Kiểm tra và Cài đặt

1. **Kiểm tra cấu hình MCP hiện tại:**
   - Đọc file `.mcp.json` để kiểm tra xem đã có cấu hình các MCP servers chưa
   - Kiểm tra sự tồn tại của các servers: `ddg-search`, `wikipedia`, `fetch`, `sequential-thinking`

2. **Quyết định có cần cài đặt không:**

   **NẾU tất cả 4 MCP servers đã có trong `.mcp.json`:**
   - Bỏ qua bước cài đặt
   - Chuyển thẳng sang Bước 2 (Hướng dẫn Strategy)
   - Thông báo: "✅ Các MCP Server đã được cấu hình sẵn trong .mcp.json"

   **NẾU thiếu bất kỳ MCP server nào:**
   - Phát hiện hệ điều hành
   - Chạy script cài đặt tương ứng

3. **Chạy script cài đặt (chỉ khi cần):**

   **Windows:**
   ```bash
   powershell -ExecutionPolicy Bypass -File .claude/commands/search/setup.ps1
   ```

   **Mac/Linux:**
   ```bash
   # Đặt quyền thực thi (chỉ cần làm 1 lần)
   chmod +x .claude/commands/search/setup.sh

   # Chạy script
   ./.claude/commands/search/setup.sh
   ```

4. **Xác nhận cài đặt:**
   - Sau khi script chạy xong (hoặc bỏ qua nếu đã cài), thông báo cho người dùng rằng các MCP server đã sẵn sàng
   - Nếu gặp lỗi, hướng dẫn người dùng cài đặt thủ công

### Bước 2: Hướng dẫn Strategy sử dụng

Sau khi cài đặt thành công, thông báo cho người dùng về chiến lược sử dụng:

```
✅ Các MCP Server cho /search đã sẵn sàng!

🚀 Chiến lược Nghiên cứu Toàn diện

═══════════════════════════════════════════════════════════════
📋 CÁC MODE TÌM KIẾM (Search Modes)
═══════════════════════════════════════════════════════════════

1️⃣ MODE "FAST" - Tìm kiếm nhanh (Thông tin tức thời)
   • Áp dụng cho: thời tiết, giá cả, tin nóng
   • Công cụ: ddg-search
   • Thời gian: < 5 giây
   • Ví dụ: "Thời tiết Hà Nội hôm nay", "Giá Bitcoin"

2️⃣ MODE "BROAD" - Nghiên cứu rộng (Bức tranh tổng cảnh)
   • Áp dụng cho: khái niệm mới, lịch sử, kiến thức nền
   • Công cụ: wikipedia → ddg-search
   • Quy trình:
     a) Tra wikipedia để lấy định nghĩa chuẩn và bối cảnh lịch sử
     b) Dùng ddg-search tìm xu hướng hoặc thảo luận mới nhất
   • Ví dụ: "Blockchain là gì?", "Lịch sử AI"

3️⃣ MODE "DEEP" - Nghiên cứu sâu (Thợ lặn dữ liệu)
   • Áp dụng cho: fix bug, đọc doc kỹ thuật, phân tích báo cáo
   • Công cụ: sequential-thinking → ddg-search → fetch
   • Quy trình:
     a) Planning: Dùng sequential_thinking liệt kê các khía cạnh cần tìm hiểu
     b) Discovery: Dùng ddg-search tìm các URL chất lượng cao
     c) Extraction: Dùng fetch để "đọc xuyên" các link đó
     d) Refining: Dùng sequential_thinking để đối chiếu thông tin
   • Ví dụ: "Cách fix lỗi CORS trong React", "Phân tích API documentation"

═══════════════════════════════════════════════════════════════
⚠️ LƯU Ý AN TOÀN KHI DÙNG FETCH
═══════════════════════════════════════════════════════════════

1. Chặn IP Nội bộ:
   • KHÔNG dùng fetch cho: localhost, 127.0.0.1, 192.168.x.x

2. HTTPS Only:
   • Chỉ truy cập các link có https://

3. Cơ chế Chunking:
   • Với trang web dài, dùng start_index để đọc từng đoạn 1000-2000 từ

4. Xác thực JS:
   • Nếu fetch trả về "Enable JavaScript to view", dừng lại và thông báo
   • Fetch không chạy được JavaScript

═══════════════════════════════════════════════════════════════
💡 GỢI Ý TỐI ƯU HIỆU QUẢ
═══════════════════════════════════════════════════════════════

• Bật Cache cho Wikipedia: Thêm --enable-cache vào args
• Phối hợp MarkItDown: Dùng để chuyển file doc về văn bản
• Kiểm tra chéo: Đối chiếu thông tin DDG với Wikipedia
• Cross-check: Luôn xác minh thông tin từ nhiều nguồn

═══════════════════════════════════════════════════════════════
```

---

## Strategy (Chiến lược tự động)

Khi người dùng nhập `/search <nội dung>`, Claude sẽ tự động chọn Mode phù hợp:

### A. Fast Search - "Mì ăn liền"

**Khi nào sử dụng:**
- Câu hỏi về thời tiết, giá cả, tin tức nóng
- Cần trả lời nhanh < 5 giây

**Cách thực hiện:**
1. Dùng `ddg-search` với query của người dùng
2. Lấy 1-3 kết quả đầu tiên
3. Tóm tắt thông tin quan trọng nhất
4. Trả lời ngay

**Ví dụ:**
```
User: /search Thời tiết Hà Nội hôm nay

Claude:
→ Dùng ddg-search("Thời tiết Hà Nội hôm nay")
→ Trả về: "Nhiệt độ 28°C, trời nắng, độ ẩm 65%"
```

### B. Broad Search - "Bức tranh tổng cảnh"

**Khi nào sử dụng:**
- Tìm hiểu khái niệm mới
- Nghiên cứu lịch sử, bối cảnh
- Cần hiểu bản chất vấn đề

**Cách thực hiện:**
1. Tra `wikipedia` để lấy định nghĩa chuẩn và bối cảnh lịch sử
2. Dùng `ddg-search` tìm các xu hướng hoặc thảo luận mới nhất
3. Kết hợp thông tin từ cả hai nguồn
4. Trả lời với bối cảnh đầy đủ

**Ví dụ:**
```
User: /search Blockchain là gì?

Claude:
1. Tra wikipedia("Blockchain")
   → Định nghĩa: "Cơ sở dữ liệu phân tán..."
   → Lịch sử: "Ra đời năm 2008..."

2. Tra ddg-search("Blockchain trends 2024")
   → Xu hướng mới: "Web3, DeFi..."

3. Tổng hợp và trả lời
```

### C. Deep Search - "Thợ lặn dữ liệu"

**Khi nào sử dụng:**
- Fix bug phức tạp
- Đọc tài liệu kỹ thuật dài
- Phân tích báo cáo chuyên sâu
- Cần nghiên cứu từ nhiều nguồn

**Cách thực hiện:**
1. **Planning:** Dùng `sequential_thinking` để:
   - Liệt kê các khía cạnh cần tìm hiểu
   - Xác định thứ tự ưu tiên
   - Lập kế hoạch tìm kiếm

2. **Discovery:** Dùng `ddg-search` để:
   - Tìm các URL chất lượng cao (GitHub, Medium, Official Docs)
   - Lọc ra các nguồn đáng tin cậy

3. **Extraction:** Dùng `fetch` để:
   - Đọc nội dung chi tiết từ các link
   - Trích xuất thông tin quan trọng
   - Sử dụng chunking nếu trang dài

4. **Refining:** Dùng `sequential_thinking` để:
   - Đối chiếu thông tin giữa các nguồn
   - Phát hiện mâu thuẫn
   - Đưa ra kết luận cuối cùng

**Ví dụ:**
```
User: /search Cách fix lỗi CORS trong React

Claude:
1. sequential_thinking:
   - Cần hiểu: CORS là gì?
   - Nguyên nhân: Tại sao xảy ra lỗi?
   - Giải pháp: Các cách fix phổ biến
   - Best practices: Cách nào tốt nhất?

2. ddg-search("React CORS error fix"):
   → Tìm thấy: StackOverflow, React docs, Medium articles

3. fetch(các URL chất lượng):
   → Đọc chi tiết từng giải pháp
   → Lấy code examples

4. sequential_thinking:
   → So sánh các giải pháp
   → Đưa ra khuyến nghị tốt nhất
   → Giải thích rõ ràng
```

---

## Lưu ý quan trọng

### Khi NÀO chạy /search?

✅ **CHẠY khi:**
- Lần đầu tiên sử dụng search tools trong dự án
- Chưa có file `.mcp.json` hoặc chưa cấu hình các MCP servers
- Người dùng báo lỗi về MCP server
- Cần cài đặt/cập nhật các công cụ tìm kiếm

❌ **KHÔNG chạy khi:**
- Đã setup rồi, chỉ cần tìm kiếm thông thường
- Các MCP servers đã hoạt động tốt

### Cách kiểm tra đã setup chưa?

```bash
# Kiểm tra file .mcp.json có các cấu hình cần thiết không
grep -q "ddg-search" .mcp.json && \
grep -q "wikipedia" .mcp.json && \
grep -q "fetch" .mcp.json && \
grep -q "sequential-thinking" .mcp.json && \
echo "Đã setup đầy đủ" || echo "Chưa setup"
```

### Troubleshooting

**Lỗi 1: "uvx: command not found"**
- **Nguyên nhân:** Chưa cài uv/uvx
- **Giải pháp:** Chạy lại script setup hoặc cài thủ công:
  - Windows: `powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"`
  - Mac: `brew install uv` hoặc `curl -LsSf https://astral.sh/uv/install.sh | sh`
  - Linux: `curl -LsSf https://astral.sh/uv/install.sh | sh`

**Lỗi 2: "npx: command not found"**
- **Nguyên nhân:** Chưa cài Node.js/npm
- **Giải pháp:** Cài đặt Node.js từ nodejs.org
  - Windows: Download installer từ nodejs.org
  - Mac: `brew install node`
  - Linux: `sudo apt install nodejs npm` hoặc tương tự

**Lỗi 3: "MCP server not responding"**
- **Nguyên nhân:** MCP server chưa khởi động hoặc cấu hình sai
- **Giải pháp:**
  - Kiểm tra file `.mcp.json` có đúng format không
  - Restart Claude Code CLI
  - Thử chạy thủ công: `uvx duckduckgo-mcp-server`

**Lỗi 4: "Fetch blocked by CORS"**
- **Nguyên nhân:** Website chặn fetch từ bên ngoài
- **Giải pháp:** Thử nguồn khác hoặc thông báo cho người dùng

**Lỗi 5: "Too many requests"**
- **Nguyên nhân:** Rate limit từ search engine
- **Giải pháp:** Chờ một lúc rồi thử lại

---

## Ví dụ sử dụng

### Ví dụ 1: Fast Search

```
User: /search Giá Bitcoin hôm nay

Claude:
→ Mode: FAST
→ Dùng: ddg-search("Bitcoin price today")
→ Kết quả: "Bitcoin: $42,500 USD (tăng 2.3%)"
```

### Ví dụ 2: Broad Search

```
User: /search Machine Learning là gì?

Claude:
→ Mode: BROAD
→ Bước 1: wikipedia("Machine Learning")
   • Định nghĩa: "Lĩnh vực của trí tuệ nhân tạo..."
   • Lịch sử: "Thuật ngữ được đặt ra năm 1959..."

→ Bước 2: ddg-search("Machine Learning 2024 trends")
   • Xu hướng: "LLMs, AutoML, Edge AI..."

→ Tổng hợp: [Trả lời chi tiết với bối cảnh đầy đủ]
```

### Ví dụ 3: Deep Search

```
User: /search Cách optimize React app performance

Claude:
→ Mode: DEEP
→ Bước 1 (Planning): sequential_thinking
   • Cần tìm: Common performance issues
   • Cần tìm: Profiling tools
   • Cần tìm: Optimization techniques
   • Cần tìm: Best practices

→ Bước 2 (Discovery): ddg-search
   • Tìm thấy: React docs, web.dev, các bài viết chuyên sâu

→ Bước 3 (Extraction): fetch
   • Đọc chi tiết từ các nguồn uy tín
   • Lấy code examples và benchmarks

→ Bước 4 (Refining): sequential_thinking
   • Đối chiếu các kỹ thuật
   • Sắp xếp theo mức độ ưu tiên
   • Đưa ra roadmap cụ thể

→ Kết quả: [Hướng dẫn chi tiết từng bước với code examples]
```

---

## Tham khảo

**MCP Servers:**
- `duckduckgo-mcp-server` - Search engine nhanh
- `wikipedia-mcp` - Kiến thức bách khoa
- `mcp-server-fetch` - Đọc nội dung web
- `@modelcontextprotocol/server-sequential-thinking` - Tư duy có hệ thống

**Dependencies:**
- `uv` / `uvx`: Python package installer (cho ddg-search, wikipedia, fetch)
- `node` / `npx`: Node.js package runner (cho sequential-thinking)

**Tài liệu liên quan:**
- `.claude/commands/search/setup.ps1` - Script cài đặt Windows
- `.claude/commands/search/setup.sh` - Script cài đặt Mac/Linux

---

## Checklist hoàn thành

Sau khi chạy `/search`, kiểm tra:

- [ ] File `.mcp.json` đã tồn tại
- [ ] File `.mcp.json` có cấu hình `ddg-search`
- [ ] File `.mcp.json` có cấu hình `wikipedia`
- [ ] File `.mcp.json` có cấu hình `fetch`
- [ ] File `.mcp.json` có cấu hình `sequential-thinking`
- [ ] Có thể chạy `uvx duckduckgo-mcp-server` thành công
- [ ] Có thể chạy `npx -y @modelcontextprotocol/server-sequential-thinking` thành công
- [ ] Đã hiểu 3 modes: Fast, Broad, Deep
- [ ] Đã test với các query mẫu

---

**🎯 Mục tiêu cuối cùng:** Người dùng có thể sử dụng `/search` để nghiên cứu thông tin một cách thông minh, tự động chọn công cụ phù hợp, và nhận được kết quả chính xác, toàn diện
