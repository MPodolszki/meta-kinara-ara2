# Whisper Model Classes

Whisper is a series of large language models (LLMs) based on encoder–decoder architecture. Whisper is designed for efficient inference, using an encoder–decoder architecture that separates audio processing from text generation.

We have added two Whisper specific classes.

- AraWhisperConfig ()
- AraModelForWhisper()

## AraWhisperConfig()

**AraWhisperConfig** is a configuration class that inherits from **AraPretrainedConfig**, meaning it extends a base configuration class. This creates an instance of **AraWhisperConfig** with the generated Whisper model configuration.

To know more about the AraPretrainedConfig class, refer [AraPretrainedConfig](ara_pretrained_config.mdx).

## AraModelForWhisper()

**AraModelForWhisper** is created on top of **AraModelForSpeechSeq2Seq** for Whisper models to generate text that allows you to modify parameters to control the generation process, and to create or save custom generation settings.

**AraWhisperConfig** loads model settings and paths.

To know more about **AraModelForSpeechSeq2Seq**, refer [AraModelForSpeechSeq2Seq](ara_model_for_seq2seq.mdx).

### Example:

```python

from optimum.ara import AraModelForWhisper, AraWhisperConfig

# Initialize a Whisper style configuration
configuration = AraWhisperConfig.from_pretrained("[config-directory-path]")

# Initialize a model from Whisper style configuration
model = AraModelForWhisper.from_config(configuration)

```
