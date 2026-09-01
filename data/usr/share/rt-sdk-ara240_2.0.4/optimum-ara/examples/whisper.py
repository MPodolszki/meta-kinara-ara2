# Copyright (c) 2025, Kinara, Inc. All rights reserved.
# Copyright 2025-2026 NXP
# SPDX-License-Identifier: Apache-2.0

from transformers import AutoProcessor, WhisperProcessor
from typing import Any, cast
import soundfile as sf
import librosa
from optimum.ara import AraModelForWhisper
from transformers import (
    TextStreamer,
    AutoModelForSpeechSeq2Seq,
    AutoConfig,
)

# Load the tokenizer for the medium model
processor = AutoProcessor.from_pretrained("openai/whisper-medium")

config = AutoConfig.from_pretrained("models/whisper")
forced_decoder_ids = [
    tid
    for _, tid in cast(WhisperProcessor, processor).get_decoder_prompt_ids(
        language="english", task="transcribe", no_timestamps=True
    )
]
forced_decoder_ids = [50258] + forced_decoder_ids
model = AutoModelForSpeechSeq2Seq.from_config(config)

# ds = load_dataset("hf-internal-testing/librispeech_asr_dummy", "clean", split="validation")
audio_input, sr = sf.read("models/whisper/audio.wav")
prompt = "transcribe English: "
# prompt_ids = tokenizer(prompt, return_tensors="pt").input_ids

if sr != 16000:
    audio_input = librosa.resample(audio_input, orig_sr=sr, target_sr=16000)
    sr = 16000

if len(audio_input.shape) > 1:
    audio_input = audio_input.mean(axis=1)

ds = [{"audio": {"array": audio_input, "sampling_rate": sr}}]

inputs = cast(WhisperProcessor, processor)(
    ds[0]["audio"]["array"], sampling_rate=sr, return_tensors="pt"
)
# inputs = processor(audio_input, sampling_rate=sr, return_tensors="pt")
input_features = inputs.input_features
streamer = TextStreamer(getattr(processor, "tokenizer"))
generated_ids = model.generate(
    input_features=input_features,
    streamer=streamer,
    target_prompt_pre_mcp=0,
    prompt_ids=getattr(processor, "tokenizer")(prompt, return_tensors="pt").input_ids,
    forced_decoder_ids=forced_decoder_ids,
)
