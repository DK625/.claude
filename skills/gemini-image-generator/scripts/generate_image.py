#!/usr/bin/env python3
"""
Generate images using Google Gemini API.

Supports two model families with different APIs:
  - Gemini models (gemini-*): uses generate_content_stream
  - Imagen models (imagen-*): uses generate_images

Usage:
    python generate_image.py "<prompt>" [--model MODEL] [--size 1k|2k|4k] [--aspect-ratio RATIO]

Available models:
    gemini-3-pro-image-preview    (Gemini family)
    gemini-2.5-flash-image        (Gemini family)
    imagen-4.0-ultra-generate-001 (Imagen family)
    imagen-4.0-generate-001       (Imagen family)
    imagen-4.0-fast-generate-001  (Imagen family)

Requirements:
    pip install google-genai python-dotenv
"""

import argparse
import mimetypes
import os
import sys
from pathlib import Path

from dotenv import load_dotenv
from google import genai
from google.genai import types

OUTPUT_DIR = "public/generated-images"
DEFAULT_MODEL = "imagen-4.0-generate-001"
DEFAULT_SIZE = "1K"
DEFAULT_ASPECT_RATIO = "1:1"

SIZE_MAP = {
    "1k": "1K",
    "2k": "2K",
    "4k": "4K",
}


def save_binary_file(file_path: str, data: bytes) -> None:
    with open(file_path, "wb") as f:
        f.write(data)
    print(f"Saved: {file_path}")


def safe_filename(prompt: str, index: int, ext: str) -> str:
    base = "".join(c if c.isalnum() or c in "-_" else "_" for c in prompt[:40])
    return f"{base}_{index}{ext}"


def generate_with_gemini(client, prompt: str, model: str, size: str, aspect_ratio: str) -> None:
    """Use generate_content_stream for gemini-* models."""
    contents = [
        types.Content(
            role="user",
            parts=[types.Part.from_text(text=prompt)],
        )
    ]
    config = types.GenerateContentConfig(
        image_config=types.ImageConfig(
            aspect_ratio=aspect_ratio,
            image_size=size,
        ),
        response_modalities=["IMAGE"],
    )

    file_index = 0
    for chunk in client.models.generate_content_stream(
        model=model,
        contents=contents,
        config=config,
    ):
        if chunk.parts is None:
            continue
        if chunk.parts[0].inline_data and chunk.parts[0].inline_data.data:
            inline_data = chunk.parts[0].inline_data
            ext = mimetypes.guess_extension(inline_data.mime_type) or ".png"
            file_path = os.path.join(OUTPUT_DIR, safe_filename(prompt, file_index, ext))
            save_binary_file(file_path, inline_data.data)
            file_index += 1
        elif hasattr(chunk, "text") and chunk.text:
            print(chunk.text)


def generate_with_imagen(client, prompt: str, model: str, aspect_ratio: str) -> None:
    """Use generate_images for imagen-* models."""
    config = types.GenerateImagesConfig(
        aspect_ratio=aspect_ratio,
        number_of_images=1,
    )

    response = client.models.generate_images(
        model=model,
        prompt=prompt,
        config=config,
    )

    for i, generated in enumerate(response.generated_images):
        file_path = os.path.join(OUTPUT_DIR, safe_filename(prompt, i, ".png"))
        save_binary_file(file_path, generated.image.image_bytes)


def generate_image(
    prompt: str,
    model: str = DEFAULT_MODEL,
    size: str = DEFAULT_SIZE,
    aspect_ratio: str = DEFAULT_ASPECT_RATIO,
) -> None:
    load_dotenv()
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print("Error: GEMINI_API_KEY not found in environment or .env file", file=sys.stderr)
        sys.exit(1)

    Path(OUTPUT_DIR).mkdir(parents=True, exist_ok=True)
    client = genai.Client(api_key=api_key)

    print(f"Generating image: '{prompt}' [model={model}, size={size}, aspect={aspect_ratio}]")

    if model.startswith("imagen"):
        generate_with_imagen(client, prompt, model, aspect_ratio)
    else:
        generate_with_gemini(client, prompt, model, size, aspect_ratio)


def main():
    parser = argparse.ArgumentParser(description="Generate images with Gemini API")
    parser.add_argument("prompt", help="Text prompt for image generation")
    parser.add_argument(
        "--model",
        default=DEFAULT_MODEL,
        help=(
            f"Model to use (default: {DEFAULT_MODEL}). "
            "Gemini models: gemini-3-pro-image-preview, gemini-2.5-flash-image. "
            "Imagen models: imagen-4.0-ultra-generate-001, imagen-4.0-generate-001, imagen-4.0-fast-generate-001"
        ),
    )
    parser.add_argument(
        "--size",
        choices=["1k", "2k", "4k"],
        default="1k",
        help="Image size for Gemini models (default: 1k). Ignored for Imagen models.",
    )
    parser.add_argument(
        "--aspect-ratio",
        default="1:1",
        help="Aspect ratio, e.g. 1:1, 16:9, 9:16, 4:3, 3:4 (default: 1:1)",
    )
    args = parser.parse_args()

    size = SIZE_MAP.get(args.size, DEFAULT_SIZE)
    generate_image(args.prompt, model=args.model, size=size, aspect_ratio=args.aspect_ratio)


if __name__ == "__main__":
    main()
