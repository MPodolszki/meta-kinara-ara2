# Qwen 2.5VL Model Classes

Qwen2.5-VL is a multimodal large language model from Qwen series that can understand both text and images. It supports tasks like visual question answering, image captioning, and document understanding, handling complex visual inputs.

We have added three Qwen 2.5VL specific classes.

- AraQwen2_5VLConfig()
- AraQwen2_5_VLForConditionalGeneration()
- QwenVLProcessor()

We have added two Qwen 2.5V Image specific classes.

- AraQwen2_5ImageConfig()
- AraQwen2_5_ImageForConditionalGeneration()

## AraQwen2_5VLConfig()

**AraQwen2_5VLConfig** is a configuration class that stores the settings for a Qwen2.5-VL model and is used to create the model based on the provided parameters that define its architecture. Configuration objects are inherited from **AraPretrainedConfig**.

## AraQwen2_5ImageConfig()

**AraQwen2_5VLConfig** is a configuration class that stores the settings for a Qwen2.5-Image model and is used to create the model based on the provided parameters that define its architecture. Configuration objects are inherited from **AraPretrainedConfig**.

To know more about the AraPretrainedConfig class, refer [AraPretrainedConfig](ara_pretrained_config.mdx).

## Example:

### AraQwen2_5_VLForConditionalGeneration()

**AraQwen2_5_VLForConditionalGeneration** is created on top of **AraModelForVisualCausalLM** for Qwen 2.5VL models. When using Qwen VLM model for vision-language tasks, the model follows the below flow:

```
1. Vision encoder processes video and outputs features.
2. Language model handles text generation with merged video+text embeddings.
```

**Important Note**: Vision Model currently supports videos upto 26 seconds.

AraQwen2_5VLConfig loads model settings and paths.

### AraQwen2_5_ImageForConditionalGeneration()

**AraQwen2_5_ImageForConditionalGeneration** is created on top of **AraModelForVisualCausalLM** for Qwen 2.5VL models. When using Qwen VLM model for vision-language tasks, the model follows the below flow:

```
1. Vision encoder processes image and outputs features.
2. Language model handles text generation with merged image+text embeddings.
```

AraQwen2_5ImageConfig loads model settings and paths.

## Example:

### QwenVLProcessor()

The **QwenVLProcessor** prepares video and text inputs for Qwen2.5-VL models. It processes videos and text prompts. Essentially, it bridges media and language inputs to the model for vision-language understanding.

```python

from optimum.ara import AraQwen2_5_VLForConditionalGeneration, QwenVLProcessor, AraQwen2_5VLConfig

# Configurations
VIDEO_PATH = "path to video file"
PROMPT = "Describe this video briefly"
MODEL_PATH = "../models/qwen2.5-vl"


# Initialize components by using configurations loaded in Model path.
model = AraQwen2_5_VLForConditionalGeneration.from_pretrained(MODEL_PATH) 

# Initialize the QwenVLProcessor
processor = QwenVLProcessor()

# Process inputs
processed_inputs = processor(VIDEO_PATH, PROMPT)

```

### AutoProcessor()

For processing image inputs, you can use the AutoProcessor class from Transformers. It processes image and text inputs and prepares them as inputs to the model’s generate function.

```python
from PIL import Image
from qwen_vl_utils import process_vision_info
from transformers import AutoProcessor

processor = AutoProcessor.from_pretrained("Qwen/Qwen2.5-VL-3B-Instruct")
image = Image.open(IMAGE_PATH)
prompt = "Describe this image."
messages = [
    {
        "role": "user",
        "content": [
            {
                "type": "image",
                "image": image,
                "resized_height": 336,
                "resized_width": 336,
            },
            {"type": "text", "text": prompt},
        ],
    }
]

text = processor.apply_chat_template(
    messages, tokenize=False, add_generation_prompt=True
)
image_inputs, video_inputs = process_vision_info(messages)

processed_inputs = processor(
    text=[text],
    images=image_inputs,
    videos=video_inputs,
    padding=True,
    return_tensors="pt",
)

```
