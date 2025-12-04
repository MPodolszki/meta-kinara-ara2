# Copyright (c) 2025, Kinara, Inc. All rights reserved.

import os
import sys
from PIL import Image

from transformers import AutoTokenizer

from optimum.ara import AraLlavaForConditionalGeneration


MODEL_PATH = os.path.realpath("models/llava")
TOKENIZER_PATH = os.path.realpath("models/llava/assets/llava_tokenizer")  # Update with actual tokenizer path
INPUT_PROMPT = "Describe this image in detail."

# Create a sample image (you can replace this with a real image)
sample_image = Image.new("RGB", (336, 336), color=(128, 128, 128))  # Gray image

# Initialize the LLaVA model
print("Loading LLaVA model...")
model = AraLlavaForConditionalGeneration.from_pretrained(MODEL_PATH)

# Load tokenizer
print("Loading tokenizer...")
tokenizer = AutoTokenizer.from_pretrained(TOKENIZER_PATH)

# Prepare conversation (exactly like llava_image_proxy)
conversation = [
    {
        "role": "user",
        "content": [
            {"type": "text", "text": INPUT_PROMPT},
            {"type": "image"},
        ],
    },
]

print("\n" + "="*50)
print("GENERATED TEXT:")
print("="*50)

# Follow the exact flow from llava_image_proxy
# 1. Process image and conversation
model.process(sample_image, conversation, new_image=True)

# 2. Encode vision features
inputs_embeds = model.encode()

# 3. Generate response
output = model.generate(inputs_embeds=inputs_embeds)
generated_text = tokenizer.decode(output, skip_special_tokens=True)

print(generated_text)
print("="*50) 