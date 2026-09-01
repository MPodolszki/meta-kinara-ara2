# Copyright (c) 2025, Kinara, Inc. All rights reserved.
# Copyright 2025-2026 NXP
# SPDX-License-Identifier: Apache-2.0

import os
from typing import Any, cast
import sys
from pathlib import Path
from threading import Thread

import gradio as gr  # pip install gradio

from optimum.ara import AraQwen2_5_VLForConditionalGeneration, QwenVLProcessor
from optimum.ara.generation.configuration_utils import AraGenerationConfig
from transformers import TextIteratorStreamer

# ---- Configuration ----
MODEL_PATH = "models/qwen2.5-vl-3B_variable_length/"

# ---- Load model & processor once (startup) ----
model = AraQwen2_5_VLForConditionalGeneration.from_pretrained(MODEL_PATH)
processor = QwenVLProcessor()
generation_config = AraGenerationConfig.from_pretrained(
    MODEL_PATH + "/generation_config.json"
)

tokenizer = processor.tokenizer


def describe_video(video_path: str, prompt: str):
    """
    Generator function that yields tokens as they are generated. [web:21][web:22]
    Gradio automatically treats any function with `yield` as streaming output. [web:23]
    """
    if not video_path or not os.path.exists(video_path):
        yield "Please upload a valid video file."
        return

    # Process inputs
    processed_inputs = processor(prompt, video_path)

    # Create TextIteratorStreamer to capture tokens as they're generated [web:26]
    streamer = TextIteratorStreamer(
        tokenizer, skip_prompt=True, skip_special_tokens=True
    )

    # Prepare generation arguments
    generation_kwargs = {
        **processed_inputs,
        "generation_config": generation_config,
        "max_new_tokens": 512,
        "temperature": 1.0,
        "do_sample": False,
        "streamer": streamer,
    }

    # Run generation in a separate thread so we can stream tokens [web:26]
    thread = Thread(target=model.generate, kwargs=generation_kwargs)
    thread.start()

    # Yield tokens as they arrive from the streamer
    generated_text = ""
    for new_token in streamer:
        generated_text += new_token
        yield generated_text

    # Ensure thread completes
    thread.join()


with gr.Blocks() as demo:
    gr.Markdown("## Qwen2.5-VL Video Description Demo (Streaming)")

    with gr.Row():
        with gr.Column():
            video_input = gr.Video(
                label="Input video",
                sources=["upload"],
                format="mp4",
            )
            prompt_input = gr.Textbox(
                label="Prompt",
                value="Describe this video briefly",
            )
            run_btn = gr.Button("Generate description")
        with gr.Column():
            output_text = gr.Textbox(
                label="Generated description",
                lines=8,
            )

    run_btn.click(
        fn=describe_video,
        inputs=[video_input, prompt_input],
        outputs=[output_text],
    )

if __name__ == "__main__":
    demo.launch()
