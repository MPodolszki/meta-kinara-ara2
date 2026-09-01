# Llama Model Classes

LlaMA is a series of large language models (LLMs) based on Transformers architecture. LLaMA is designed for efficient inference by training relatively smaller models on a much larger number of tokens, instead of relying solely on extremely large model sizes

We have added two LlaMA specific classes.

- AraLlamaConfig ()
- AraLlamaForCausalLM()

## AraLlamaConfig()

**AraLlamaConfig** is a configuration class that inherits from **AraPretrainedConfig**, meaning it extends a base configuration class. This creates an instance of **AraLlamaConfig** with the generated LlaMA model configuration.

To know more about the AraPretrainedConfig class, refer [AraPretrainedConfig](ara_pretrained_config.mdx).

## AraLlamaForCausalLM()

**AraModelForCausalLM** is created on top of **AraModelForCausalLM** for LlaMA models to generate text that allows you to modify parameters to control the generation process, and to create or save custom generation settings.

**AraLlamaConfig** loads model settings and paths.

To know more about **AraModelForCausalLM**, refer [AraModelForCausalLM](ara_model_for_causallm.mdx).

### Example:

```python

from optimum.ara import AraLlamaForCausalLM, AraLlamaConfig

# Initialize a Llama style configuration
configuration = AraLlamaConfig.from_pretrained("[config-directory-path]")

# Initialize a model from Llama style configuration
model = AraLlamaForCausalLM.from_config(configuration)

```
