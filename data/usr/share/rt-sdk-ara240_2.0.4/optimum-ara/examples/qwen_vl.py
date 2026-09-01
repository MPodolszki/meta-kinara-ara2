# Copyright (c) 2025, Kinara, Inc. All rights reserved.
# Copyright 2025-2026 NXP
# SPDX-License-Identifier: Apache-2.0

import cv2
import tempfile
import os
import sys
from typing import Any, cast
from pathlib import Path
from optimum.ara import AraQwen2_5_VLForConditionalGeneration, QwenVLProcessor
from optimum.ara.generation.configuration_utils import AraGenerationConfig
from transformers import TextStreamer

# Configuration
VIDEO_PATH = "/home/shayan/personFalling_8.mov_2secs.mp4"
PROMPT = "Describe this video briefly"
MODEL_PATH = "./models/qwen2.5-vl"

# Initialize components
model = AraQwen2_5_VLForConditionalGeneration.from_pretrained(MODEL_PATH)
processor = QwenVLProcessor()

# Process inputs
generation_config = AraGenerationConfig.from_pretrained(
    MODEL_PATH + "/generation_config.json"
)
processed_inputs = processor(PROMPT, VIDEO_PATH)

streamer = TextStreamer(processor.tokenizer, stream=sys.stdout)
# Generate
result = model.generate(
    **processed_inputs,
    generation_config=generation_config,
    max_new_tokens=512,
    temperature=1.0,
    do_sample=False,
    stream=False,
    streamer=streamer,
)

# Decode the generated tokens to text
generated_text = processor.decode(result.flatten(), skip_special_tokens=True)

print("\n" + "=" * 50)
print("GENERATED TEXT:")
print("=" * 50)
print(generated_text)
print("=" * 50)
model.display_perf_statistics()
