---
name: gemini-image-generator
description: Generate images using Google Gemini API with multiple models for different use cases. Use when the user asks to generate, create, or produce an image from a text prompt. Supports image sizes 1k, 2k, 4k (default: 1k) and aspect ratios such as 1:1, 16:9, 9:16, 4:3, 3:4 (default: 1:1 square). Images are saved to public/generated-images/. Requires GEMINI_API_KEY in the .env file.
---

# Gemini Image Generator

Generate images from text prompts using the Gemini API.

## ⚠️ QUAN TRỌNG: Chọn Model Đúng Cho Đúng Việc

### Model Selection Guide

| Use Case | Model | Lý Do |
|----------|-------|-------|
| **Ảnh có TEXT** (thumbnail, banner, poster, logo) | `imagen-4.0-ultra-generate-001` | Text rendering chuẩn xác nhất |
| **Stock ảnh, minh họa blog** | `imagen-4.0-generate-001` | Cân bằng chất lượng & hiệu suất |
| **Mockup UI/UX nhanh** | `imagen-4.0-fast-generate-001` | Tốc độ cao, độ nét tốt |
| **Concept art 4K cực chi tiết** | `gemini-3-pro-image-preview` | Cảnh phức tạp, chuyên nghiệp |
| **Sản xuất hàng loạt, tiết kiệm** | `gemini-2.5-flash-image` | Rẻ & phản hồi nhanh |

### Default Model
- **Mặc định:** `imagen-4.0-generate-001` (tiêu chuẩn)
- **Nếu prompt có chứa text/words → TỰ ĐỘNG dùng `imagen-4.0-ultra-generate-001`**

---

## Defaults

| Parameter    | Default | Options              |
|--------------|---------|----------------------|
| Model        | `imagen-4.0-generate-001` | See Model Selection Guide |
| Size         | 1k      | 1k, 2k, 4k (Gemini only) |
| Aspect ratio | 1:1     | 1:1, 16:9, 9:16, 4:3, 3:4 |
| Output dir   | `public/generated-images` | fixed |

---

## Usage

### Basic Usage
```bash
# Default (imagen-4.0-generate-001, 1k, square)
python .claude/skills/gemini-image-generator/scripts/generate_image.py "a cat sitting on a mountain"

# Custom size
python .claude/skills/gemini-image-generator/scripts/generate_image.py "a sunset over the ocean" --size 2k

# Custom aspect ratio
python .claude/skills/gemini-image-generator/scripts/generate_image.py "a wide cityscape" --aspect-ratio 16:9
```

### Model Selection Examples

```bash
# THUMBNAIL với TEXT → dùng ULTRA
python .claude/skills/gemini-image-generator/scripts/generate_image.py "YouTube thumbnail with text CLAUDE SKILLS" --model imagen-4.0-ultra-generate-001 --aspect-ratio 16:9

# Banner/Poster có chữ → dùng ULTRA
python .claude/skills/gemini-image-generator/scripts/generate_image.py "Sale banner with text 50% OFF" --model imagen-4.0-ultra-generate-001

# Rapid prototyping → dùng FAST
python .claude/skills/gemini-image-generator/scripts/generate_image.py "UI mockup dashboard" --model imagen-4.0-fast-generate-001

# Concept art chuyên nghiệp → dùng Gemini 3 Pro
python .claude/skills/gemini-image-generator/scripts/generate_image.py "Epic fantasy landscape with castle" --model gemini-3-pro-image-preview --size 4k

# Bulk generation tiết kiệm → dùng Flash
python .claude/skills/gemini-image-generator/scripts/generate_image.py "Simple icon set" --model gemini-2.5-flash-image
```

---

## Available Models

### Imagen Family (generate_images API)
| Model | Đặc điểm | Giá |
|-------|----------|-----|
| `imagen-4.0-ultra-generate-001` | **Text rendering tốt nhất**, chất lượng cao nhất | $$/output |
| `imagen-4.0-generate-001` | Tiêu chuẩn, cân bằng | $/output |
| `imagen-4.0-fast-generate-001` | Nhanh nhất, prototyping | ¢/output |

### Gemini Family (generate_content_stream API)
| Model | Đặc điểm | Giá |
|-------|----------|-----|
| `gemini-3-pro-image-preview` | Concept art 4K, cảnh phức tạp | $$$/output |
| `gemini-2.5-flash-image` | Bulk generation, tiết kiệm | ¢/output |

> **Note:** Dòng **Imagen** chỉ dùng `generate_images`, dòng **Gemini** dùng `generate_content_stream` để tích hợp chat đa phương thức.

---

## Requirements

Install dependencies (Python 3.9+):

```bash
pip install google-genai python-dotenv
```

The script reads `GEMINI_API_KEY` from the `.env` file at the project root.

---

## Output

Images are saved to `public/generated-images/` with filenames derived from the prompt.
The directory is created automatically if it does not exist.

---

## Workflow

1. **Detect use case:** Xác định loại ảnh cần tạo
2. **Select model:**
   - Có text? → `imagen-4.0-ultra-generate-001`
   - Cần nhanh? → `imagen-4.0-fast-generate-001`
   - Cần 4K chi tiết? → `gemini-3-pro-image-preview`
   - Default → `imagen-4.0-generate-001`
3. **Run script** với appropriate arguments
4. **Report** saved file path(s) to user

---

## Decision Tree

```
Cần tạo ảnh?
    │
    ├─► Prompt có chứa TEXT/words?
    │       └─► YES → imagen-4.0-ultra-generate-001
    │
    ├─► Cần tốc độ nhanh (mockup, prototype)?
    │       └─► YES → imagen-4.0-fast-generate-001
    │
    ├─► Cần 4K cực chi tiết (concept art)?
    │       └─► YES → gemini-3-pro-image-preview + --size 4k
    │
    ├─► Sản xuất hàng loạt (icons, assets)?
    │       └─► YES → gemini-2.5-flash-image
    │
    └─► Default (stock ảnh, minh họa)
            └─► imagen-4.0-generate-001
```

---

## Troubleshooting

| Vấn đề | Giải pháp |
|--------|-----------|
| Text trong ảnh bị méo | Dùng `imagen-4.0-ultra-generate-001` |
| Ảnh bị blur | Tăng size lên `2k` hoặc `4k` |
| Gen quá chậm | Dùng `imagen-4.0-fast-generate-001` |
| Tốn quá nhiều tiền | Dùng `gemini-2.5-flash-image` |
