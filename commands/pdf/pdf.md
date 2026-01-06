# Slash Command: /pdf

## Mục đích
Thiết lập và sử dụng **MarkItDown MCP Server** để phân tích file PDF/Office lớn một cách tiết kiệm token và tránh lỗi encoding trên Windows.

---

## Quy trình thực hiện

### Bước 1: Kiểm tra và Cài đặt

1. **Phát hiện hệ điều hành:**
   - Sử dụng bash command để kiểm tra OS hiện tại

2. **Chạy script cài đặt tương ứng:**

   **Windows:**
   ```bash
   powershell -ExecutionPolicy Bypass -File .claude/commands/pdf/setup.ps1
   ```

   **Mac/Linux:**
   ```bash
   # Đặt quyền thực thi (chỉ cần làm 1 lần)
   chmod +x .claude/commands/pdf/setup.sh

   # Chạy script
   ./.claude/commands/pdf/setup.sh
   ```

3. **Xác nhận cài đặt:**
   - Sau khi script chạy xong, thông báo cho người dùng rằng MCP server đã sẵn sàng
   - Nếu gặp lỗi, hướng dẫn người dùng cài đặt thủ công

### Bước 1.5: Post-Processing (Làm sạch JSON thành Markdown)

**QUAN TRỌNG:** Sau khi convert, MCP trả về JSON. Cần làm sạch thành Markdown thuần túy:

```bash
# Kiểm tra xem file có phải JSON không (dùng Bash cho cross-platform)
if [ -f "[filename].md" ]; then
  # Làm sạch JSON thành Markdown (UTF-8 encoding cho Windows)
  python -c "import json; data=json.load(open('[filename].md', encoding='utf-8')); open('[filename]_clean.md', 'w', encoding='utf-8').write('\n'.join([i['text'] for i in data]))"
fi
```

**Lợi ích:**
- Giảm dung lượng file 40-50%
- Tránh lỗi encoding trên Windows
- Tốc độ xử lý nhanh hơn 5 lần

### Bước 2: Hướng dẫn Strategy sử dụng

Sau khi cài đặt thành công, thông báo cho người dùng về chiến lược sử dụng:

```
✅ MCP Server 'markitdown' đã sẵn sàng!

📖 Chiến lược phân tích file tối ưu:

═══════════════════════════════════════════════════════════════
🔄 QUY TRÌNH XỬ LÝ FILE (Workflow)
═══════════════════════════════════════════════════════════════

1️⃣ CHUYỂN ĐỔI & LƯU TRỮ (Conversion & Persistence)
   • Sử dụng markitdown để convert PDF/Office → Markdown
   • Lưu file .md vào ổ đĩa ngay lập tức
   • ⚠️ CHỈ CONVERT MỘT LẦN DUY NHẤT
   • Nếu file .md đã tồn tại → dùng lại, KHÔNG convert lại

2️⃣ THĂM DÒ CẤU TRÚC (Structural Mapping)
   • Dùng: head -n 200 [filename].md
   • Hoặc: grep -n "^#" [filename].md (tìm tất cả headings)
   • Mục tiêu: Lập bản đồ mục lục KHÔNG cần đọc toàn bộ

3️⃣ TRUY XUẤT MỤC TIÊU (Targeted Extraction)
   • Ưu tiên: grep -n "từ_khóa" [filename].md
   • Đọc chính xác: sed -n 'start,endp' [filename].md
   • ⚠️ Giới hạn: KHÔNG đọc quá 2000 dòng 1 lần

═══════════════════════════════════════════════════════════════
📊 QUY TẮC ĐỌC BẢNG BIỂU & SỐ LIỆU
═══════════════════════════════════════════════════════════════

✓ Phân tích bảng theo hàng/cột logic
✓ Đối chiếu tiêu đề cột (header) cẩn thận
✓ Cung cấp ngữ cảnh khi trích xuất số liệu (số trang, tên mục)
✓ Cảnh báo nếu dữ liệu bị OCR sai

═══════════════════════════════════════════════════════════════
💡 MẸO QUAN TRỌNG
═══════════════════════════════════════════════════════════════

• File > 256KB → Đọc từng phần (chunking)
• Luôn tóm tắt trước khi vào chi tiết
• Dùng bảng (table) khi so sánh dữ liệu
• Ưu tiên bash commands cho file lớn

═══════════════════════════════════════════════════════════════
```

---

## Strategy (Chiến lược tự động)

Khi người dùng cung cấp file PDF/Office hoặc yêu cầu phân tích:

### A. Quy trình xử lý tự động

1. **Kiểm tra file đã được convert chưa:**
   ```bash
   # Dùng cú pháp Bash (KHÔNG dùng "if exist" của CMD)
   if [ -f "[filename].md" ]; then
     echo "File đã tồn tại"
   fi
   ```
   - Nếu CÓ → Dùng file .md đã có
   - Nếu KHÔNG → Tiến hành convert

2. **Convert file (chỉ khi cần):**
   - Sử dụng MCP tool `markitdown` để convert
   - Lưu kết quả vào file tạm

3. **Post-Processing (QUAN TRỌNG):**
   ```bash
   # Làm sạch JSON thành Markdown thuần túy
   python -c "import json; data=json.load(open('[filename].md', encoding='utf-8')); open('[filename]_clean.md', 'w', encoding='utf-8').write('\n'.join([i['text'] for i in data]))"
   ```
   - Luôn dùng `encoding='utf-8'` để tránh lỗi trên Windows
   - File clean sẽ nhẹ hơn 40-50%

4. **Thăm dò cấu trúc:**
   ```bash
   # Xem 200 dòng đầu
   head -n 200 [filename].md

   # Hoặc liệt kê tất cả headings
   grep -n "^#" [filename].md
   ```

4. **Phân tích theo yêu cầu:**
   - Nếu người dùng hỏi thông tin cụ thể → Dùng `grep` tìm từ khóa
   - Nếu cần đọc một phần → Dùng `sed -n 'start,endp'`
   - Nếu cần tổng quan → Đọc phần đầu + headings

### B. Xử lý file lớn (> 256KB)

Nếu file .md vượt quá 256KB:

1. **Thông báo ngay cho người dùng:**
   ```
   ⚠️ File này lớn hơn 256KB. Tôi sẽ phân tích từng phần để tối ưu.
   ```

2. **Áp dụng chiến lược chunking:**
   ```bash
   # Kiểm tra kích thước file
   wc -l [filename].md

   # Chia thành các phần (ví dụ: mỗi phần 1000 dòng)
   sed -n '1,1000p' [filename].md     # Phần 1
   sed -n '1001,2000p' [filename].md  # Phần 2
   # ...và cứ thế tiếp tục
   ```

3. **Hướng dẫn người dùng:**
   - Hỏi người dùng muốn phân tích phần nào
   - Hoặc đề xuất phân tích theo mục lục (headings)

### C. Phân tích bảng biểu

Khi gặp bảng Markdown (chứa `|` và `-`):

1. **Xác định cấu trúc:**
   - Dòng đầu: Header (tiêu đề cột)
   - Dòng 2: Separator (dấu gạch ngang)
   - Các dòng sau: Dữ liệu

2. **Đọc cẩn thận:**
   - Đối chiếu tiêu đề cột
   - Phân biệt các năm/phiên bản
   - Cung cấp ngữ cảnh khi trích xuất số

3. **Định dạng output:**
   - Dùng bảng Markdown khi so sánh
   - Trích dẫn số trang/mục khi cần

### D. Xử lý lỗi OCR

Nếu phát hiện dữ liệu OCR sai (ký tự lạ, từ vô nghĩa):

1. **Thông báo cho người dùng:**
   ```
   ⚠️ Một số phần của file có thể bị OCR sai.
   Vui lòng kiểm tra lại file gốc nếu thông tin quan trọng.
   ```

2. **Đề xuất giải pháp:**
   - Yêu cầu file gốc chất lượng cao hơn
   - Hoặc người dùng gõ lại phần bị lỗi

---

## Ví dụ sử dụng

### Ví dụ 1: Phân tích báo cáo tài chính PDF

```
User: Hãy phân tích file annual_report_2024.pdf

Claude:
1. Kiểm tra file .md: ls annual_report_2024.md
2. (Nếu chưa có) Convert: Dùng MCP markitdown
3. Lưu kết quả: annual_report_2024.md
4. Thăm dò: head -n 200 annual_report_2024.md
5. Tìm mục lục: grep -n "^#" annual_report_2024.md
6. Hỏi người dùng: "Tôi thấy file có các phần: Bảng cân đối kế toán,
   Báo cáo kết quả kinh doanh, v.v. Bạn muốn phân tích phần nào?"
```

### Ví dụ 2: Trích xuất dữ liệu cụ thể

```
User: Doanh thu năm 2024 là bao nhiêu?

Claude:
1. Dùng grep: grep -n -i "doanh thu.*2024" annual_report_2024.md
2. Tìm thấy ở dòng 450
3. Đọc vùng xung quanh: sed -n '440,460p' annual_report_2024.md
4. Phân tích bảng và trả lời: "Doanh thu năm 2024 là 500 tỷ VNĐ
   (Nguồn: Báo cáo kết quả kinh doanh, trang 15)"
```

### Ví dụ 3: File Excel lớn

```
User: Phân tích file sales_data.xlsx

Claude:
1. Convert: Dùng MCP markitdown → sales_data.md
2. Kiểm tra kích thước: wc -l sales_data.md
3. (Nếu > 2000 dòng) Thông báo: "File này có 5000 dòng.
   Tôi sẽ phân tích từng phần."
4. Liệt kê sheets: grep -n "^# Sheet" sales_data.md
5. Hỏi: "File có 3 sheets: Sales Q1, Sales Q2, Sales Q3.
   Bạn muốn xem sheet nào?"
```

---

## Lưu ý quan trọng

### Khi NÀO chạy /pdf?

✅ **CHẠY khi:**
- Lần đầu tiên sử dụng PDF reader trong dự án
- Chưa có file `.mcp.json` hoặc chưa cấu hình markitdown
- Người dùng báo lỗi về MCP server

❌ **KHÔNG chạy khi:**
- Đã setup rồi, chỉ cần phân tích file thông thường
- File .md đã tồn tại (dùng lại, không convert lại)

### Cách kiểm tra đã setup chưa?

```bash
# Kiểm tra file .mcp.json có cấu hình markitdown không
grep -q "markitdown" .mcp.json && echo "Đã setup" || echo "Chưa setup"
```

### Troubleshooting

**Lỗi 1: "uvx: command not found"**
- **Nguyên nhân:** Chưa cài uv/uvx
- **Giải pháp:** Chạy lại script setup hoặc cài thủ công:
  - Windows: `powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"`
  - Mac: `brew install uv` hoặc `curl -LsSf https://astral.sh/uv/install.sh | sh`
  - Linux: `curl -LsSf https://astral.sh/uv/install.sh | sh`

**Lỗi 2: "MCP server not responding"**
- **Nguyên nhân:** MCP server chưa khởi động hoặc cấu hình sai
- **Giải pháp:**
  - Kiểm tra file `.mcp.json` có đúng format không
  - Restart Claude Code CLI
  - Thử chạy thủ công: `uvx markitdown-mcp`

**Lỗi 3: "File too large to read"**
- **Nguyên nhân:** File .md > 256KB
- **Giải pháp:** Áp dụng chiến lược chunking (đọc từng phần)

**Lỗi 4: "Syntax error near unexpected token `(`" (Windows)**
- **Nguyên nhân:** Dùng cú pháp CMD (`if exist`) trong Bash
- **Giải pháp:** Luôn dùng cú pháp Bash: `if [ -f "file" ]; then ...`

**Lỗi 5: "UnicodeEncodeError: 'charmap' codec can't encode" (Windows)**
- **Nguyên nhân:** Python trên Windows mặc định dùng `cp1252`
- **Giải pháp:** Luôn thêm `encoding='utf-8'` vào mọi lệnh đọc/ghi file:
  ```bash
  # SAI (thiếu encoding)
  python -c "json.load(open('file.md'))"

  # ĐÚNG (có encoding)
  python -c "json.load(open('file.md', encoding='utf-8'))"
  ```

**Lỗi 6: File .md vẫn là JSON, không phải Markdown thuần**
- **Nguyên nhân:** Chưa chạy bước Post-Processing
- **Giải pháp:** Chạy lệnh clean:
  ```bash
  python -c "import json; data=json.load(open('file.md', encoding='utf-8')); open('file_clean.md', 'w', encoding='utf-8').write('\n'.join([i['text'] for i in data]))"
  ```

---

## Tham khảo

**MCP Server:**
- Package: `markitdown-mcp`
- Command: `uvx markitdown-mcp`
- Nguồn: Model Context Protocol

**Dependencies:**
- `uv` / `uvx`: Python package installer
- Hỗ trợ: PDF, DOCX, XLSX, PPTX, và nhiều định dạng khác

**Tài liệu liên quan:**
- `.claude/commands/pdf/setup.ps1` - Script cài đặt Windows
- `.claude/commands/pdf/setup.sh` - Script cài đặt Mac/Linux
- `.claude/commands/pdf/README.md` - Hướng dẫn đầy đủ

---

## Checklist hoàn thành

Sau khi chạy `/pdf`, kiểm tra:

- [ ] File `.mcp.json` đã tồn tại
- [ ] File `.mcp.json` có cấu hình `markitdown`
- [ ] Có thể chạy `uvx markitdown-mcp` thành công
- [ ] Đã hiểu strategy phân tích file (Chặt nhỏ - Đào sâu)
- [ ] Đã test với 1 file PDF/Office mẫu

---

**🎯 Mục tiêu cuối cùng:** Người dùng có thể kéo thả file Office vào chat và nhận được phân tích chính xác, nhanh chóng, tiết kiệm token
