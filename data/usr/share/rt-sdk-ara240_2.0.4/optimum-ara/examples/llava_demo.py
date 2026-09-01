# Copyright (c) 2025, Kinara, Inc. All rights reserved.
# Copyright 2025-2026 NXP
# SPDX-License-Identifier: Apache-2.0

import os
from typing import Any, cast, List
from PIL import Image
from transformers import LlavaProcessor
from optimum.ara import AraLlavaForConditionalGeneration


MODEL_PATH = os.path.realpath("models/llava")
INPUT_PROMPT = "Describe this image in detail."
IMAGE_PATH = "/home/khuzaeymah/optimum-ara-stage/test.png"

# Load the image
sample_image = Image.open(IMAGE_PATH).convert("RGB")

# Load model
print("Loading LLaVA model...")
model = AraLlavaForConditionalGeneration.from_pretrained(MODEL_PATH)

# Load processor
print("Loading processor...")
processor = LlavaProcessor.from_pretrained("llava-hf/llava-1.5-7b-hf")

# Prepare conversation
messages = [
    {
        "role": "user",
        "content": [
            {"type": "text", "text": INPUT_PROMPT},
            {"type": "image", "image": sample_image},
        ],
    }
]

# Process inputs
print("Processing inputs...")
text = processor.apply_chat_template(
    messages, tokenize=False, add_generation_prompt=True
)
# Cast to satisfy processor signature (PIL.Image type mismatch between stubs)
processed_inputs = processor(
    text=text, images=cast(Any, [sample_image]), padding=True, return_tensors="pt"
)

# Generate
print("\n" + "=" * 50)
print("GENERATED TEXT:")
print("=" * 50)
result = model.generate(**processed_inputs)
generated_text = processor.decode(
    result.flatten() if hasattr(result, "flatten") else result, skip_special_tokens=True
)
print(generated_text)
print("=" * 50)
