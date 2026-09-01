# Copyright (c) 2025, Kinara, Inc. All rights reserved.
# Copyright 2025-2026 NXP
# SPDX-License-Identifier: Apache-2.0

from transformers import AutoTokenizer, TextStreamer
from optimum import ara
from optimum.ara import AraGenerationConfig, AraModelForCausalLM, CustomLogitsProcessor
import numpy as np
import torch

model = AraModelForCausalLM.from_pretrained(
    "models/qwen2.5-instruct-7B/"
)
tokenizer = AutoTokenizer.from_pretrained(
    "/auto/share/releases/sdk/ara2/demo_releases/standalone_demos/assets/llm/common/qwen_2.5_1.5B_python_coder/tokenizer/"
)
streamer = TextStreamer(tokenizer, skip_prompt=True, skip_special_tokens=True)
generation_config = AraGenerationConfig.from_pretrained(
    "models/qwen2.5-instruct-7B/"
)
print(generation_config)

prompt = 'Below are python functions\n\ndef expand_center(s, left, right):\n    while left >= 0 and right < len(s) and s[left] == s[right]:\n        left -= 1\n        right += 1\n    return s[left+1:right]\n\ndef find_longest(s):\n    longest = ""\n    for i in range(len(s)):\n        for a, b in [(i, i), (i, i+1)]:  # odd & even centers\n            temp = expand_center(s, a, b)\n            if len(temp) > len(longest):\n                longest = temp\n    return longest\n\nfrom the above python functions what is the code for find_longest function, need only code, no description.\n'

messages = [
    {"role": "system", "content": "You are a helpful assistant."},
    {"role": "user", "content": prompt},
]

inputs = tokenizer.apply_chat_template(
    conversation=messages, tokenize=False, add_generation_prompt=True
)

inputs = tokenizer(inputs)
generation_config = AraGenerationConfig.from_pretrained(
    "./local_models/qwen2.5-instruct-7B/"
)
print(generation_config)


class SimpleCustomProcessor1(CustomLogitsProcessor):
    def __init__(self):
        print("CustomPostProcessing init called!")
        self.first_call = True
        self.acceptance_length = 0
        self.count = 0

        self.expected_tokens = [
            73594,
            12669,
            198,
            750,
            1477,
            17799,
            477,
            1141,
            982,
            262,
            22032,
            284,
            8389,
            262,
            369,
            600,
            304,
            2088,
            6901,
            1141,
            9957,
            286,
            369,
            264,
            11,
            293,
            304,
            17826,
            72,
            11,
            600,
            701,
            320,
            72,
            11,
            600,
            10,
            16,
            8,
            5669,
            220,
            671,
            10322,
            609,
            1496,
            18652,
            198,
            310,
            2730,
            284,
            9225,
            21087,
            1141,
            11,
            264,
            11,
            293,
            340,
            310,
            421,
            2422,
            9758,
            8,
            861,
            2422,
            12628,
            477,
            982,
            394,
            22032,
            284,
            2730,
            198,
            262,
            470,
            22032,
            198,
            73594,
            151645,
        ]
        self.pos = 0
        self.last_match_len = 0

    def __call__(
        self, input_ids: torch.LongTensor, scores: np.ndarray, **kwargs
    ) -> tuple[np.ndarray, np.ndarray]:

        tokens = np.argmax(scores, axis=-1)
        tokens = self.updateB(tokens.flatten().tolist())

        candidate_token = self.make_result(tokens)

        self.acceptance_length += len(tokens)
        self.count += 1

        return np.array(tokens), np.array(candidate_token[1:])

    def updateB(self, b):
        """
        Find the longest matching prefix between b and expected_tokens starting at pos.
        Modifies b to contain only the matching prefix.
        """
        self.last_match_len = 0

        # Try longest prefix first
        for length in range(len(b), 0, -1):
            if self.pos + length > len(self.expected_tokens):
                continue

            # Check if current length matches
            match = True
            for j in range(length):
                if self.expected_tokens[self.pos + j] != b[j]:
                    match = False
                    break

            if match:
                self.last_match_len = length
                # Resize b to keep only matching prefix
                b[:] = b[:length]  # Modify list in-place
                break

        # No match at all → keep only first element
        if self.last_match_len == 0:
            b = b[:1]  # Keep only first element
            self.last_match_len = 0  # nothing matched in expected_tokens
        return b

    def make_result(self, b):
        """
        Return [last_of_B, next3_from_expected_tokens]
        """
        result = []
        if not b:
            return result

        # Last element of B (either matched prefix or just b[0])
        result.append(b[-1])

        # If something matched, continue after match
        start = self.pos + self.last_match_len

        # Next 3 from expected_tokens
        k = start
        while k < len(self.expected_tokens) and len(result) < 4:
            result.append(self.expected_tokens[k])
            k += 1

        # Advance pos only if match was found
        self.pos += self.last_match_len

        return result


processor = SimpleCustomProcessor1()

output = model.generate(
    **inputs,
    streamer=streamer,
    generation_config=generation_config,
    custom_logits_processor=processor,
)
print("\n")
# print(tokenizer.decode(output))
if processor.count != 0:
    print("avg accepetance length : ", processor.acceptance_length / processor.count)
else:
    print("avg accepetance length : 1")

model.display_perf_statistics()
