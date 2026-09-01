# Qwen Model Classes

The Qwen model is a powerful Text-only large language model that comes with improved reasoning, performance, and multilingual understanding.

We have added two Llama specific classes.

- AraQwenConfig()
- AraQwenForCausalLM()

## AraQwenConfig()

**AraQwenConfig** is a configuration class that that inherits from **AraPretrainedConfig**.

To know more about the AraPretrainedConfig class, refer [AraPretrainedConfig](ara_pretrained_config.mdx).

### Example:

## AraQwenForCausalLM ()

**AraQwenForCausalLM** is created on top of **AraModelForCausalLM** for Qwen models.
AraQwenConfig loads model settings and paths.

### Example:

```python
from optimum.ara import AraQwenForCausalLM, AraQwenForCausalLM

# Initialize a Qwen style configuration
configuration = AraQwenConfig.from_pretrained("[config-directory-path]")

# Initialize a model from Qwen style configuration
model = AraQwenForCausalLM.from_config(configuration)

```
