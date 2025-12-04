# Copyright (c) 2025, Kinara, Inc. All rights reserved.

from transformers import AutoTokenizer, AutoModelForCausalLM, AutoConfig, TextStreamer
from optimum import ara

config = AutoConfig.from_pretrained("KinaraInc/llama2-7b")
config.ara.dvm_path = '/auto/share/releases/sdk/ara2/demo_releases/standalone_demos/assets/llm/stage_r1.2_t4/llama2_2k_specd/model.dvm'

model = AutoModelForCausalLM.from_config(config)
tokenizer = AutoTokenizer.from_pretrained("/users/naveen/models/tokenizers/llama2_tokenizer")
streamer = TextStreamer(tokenizer, skip_prompt=True, skip_special_tokens=True)

messages = [
    {"role": "system", "content": "You are a helpful assistant."},
    {"role": "user", "content": "Tell me a story?"},
]

inputs = tokenizer.apply_chat_template(
    conversation=messages, tokenize=False, add_generation_prompt=True
)
inputs = tokenizer(inputs)
print("\n")
output = model.generate(**inputs, streamer=streamer)
print("\n")
model.display_perf_statistics()