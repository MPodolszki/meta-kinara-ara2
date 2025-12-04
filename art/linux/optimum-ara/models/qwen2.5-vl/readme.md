# Qwen2.5 VLM Model for Ara Hardware

This directory contains the configuration files for the Qwen2.5 VLM model optimized for Ara hardware.

## Model Information

- **Model**: Qwen2.5-VL-7B
- **Architecture**: Vision-Language Model
- **Vision Encoder**: ViT (Vision Transformer)
- **Language Model**: Qwen 2.5 7B
- **Hardware**: Ara DVM

## Files

- `config.json` - Model configuration
- `generation_config.json` - Generation parameters
- `readme.md` - This file

## Usage

```python
from optimum.ara import AraQwenForCausalLM, AraQwenConfig

# Load the model
model = AraQwenForCausalLM.from_pretrained("models/qwen2.5-vl")

# Generate text from image and prompt
from PIL import Image

image = Image.open("path/to/image.jpg")
prompt = "Describe this image in detail."

# Generate response
outputs = model.generate(
    input_ids=model.text_processor.encode(prompt),
    images=[image],
    max_length=512
)

response = model.text_processor.decode(outputs[0])
print(response)
```

## Configuration

The model uses the same two-model architecture as LLaVA:
1. **Vision Model**: ViT DVM for image feature extraction
2. **Language Model**: Qwen 2.5 DVM for text generation

Both models are loaded from the paths specified in the configuration.

## Hardware Requirements

- Ara hardware with DVM support
- Vision and language model DVM files
- Required bin files for vision encoding constants 