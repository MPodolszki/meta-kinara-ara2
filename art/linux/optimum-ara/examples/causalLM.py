# Copyright (c) 2025, Kinara, Inc. All rights reserved.

import os
import sys

from transformers import AutoTokenizer

from optimum.ara import AraModelForCausalLM


MODEL_PATH = os.path.realpath("models/llama3.1-8b")
TOKENIZER_PATH = os.path.realpath("models/llama3.1-8b/assets/llama3_tokenizer")
INPUT_PROMPT = "Hello, how are you?"

model = AraModelForCausalLM.from_pretrained(MODEL_PATH)
tokenizer = AutoTokenizer.from_pretrained(TOKENIZER_PATH)

messages = [
    {"role": "system", "content": "You are a helpful assistant."},
    {"role": "user", "content": INPUT_PROMPT},
]

inputs = tokenizer.apply_chat_template(
    conversation=messages, tokenize=False, add_generation_prompt=True
)
inputs = tokenizer(inputs)
output = model.generate(**inputs)
generated_text = tokenizer.decode(output)

print("\n" + "="*50)
print("GENERATED TEXT:")
print("="*50)
print(generated_text)
print("="*50)
