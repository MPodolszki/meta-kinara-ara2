# Auto Classes

Auto Classes are used to automatically handle the detection of pretrained models. This loads the correct model, configuration, and tokenizer based on the provided model.

To use Auto classes, we import it from `transformers` in the below mentioned way.

```python

from transformers import AutoModelForCausalLM, AutoConfig

```

We have registered our config and model classes with following Auto Classes.

- AutoConfig()
- AutoModelForCausalLM()

These Auto classes can be configured to understand the custom classes specific to each model for loading and fetching precise model details.

### AutoConfig

This is a general configuration class that automatically loads the right type of configurations (for example, for a text or vision model) when you load it using the `from_pretrained()` method.

### AutoModelForCausalLM

This is a general model class that automatically turns into the right type of model (like a text, image, or speech model) when you load it using methods such as `from_pretrained()` or `from_config()`.

### Example

In this example, configurations of Llama 2 - 7B are automatically loaded using AutoModelForCausal and AutoConfig and input is tokenized and streamed using the provided Model type.

```python

# Import required classes from the generation configuration utilities of the optimum.ara module.
from transformers import AutoTokenizer, TextStreamer, AutoModelForCausalLM, AutoConfig
from optimum import ara

# Create a AraLlamaConfig using the below method to determine the correct Config class.
config = AutoConfig.from_pretrained("models/llama2-7b")

# Load the model using the configuration object.
model = AutoModelForCausalLM.from_config(config)

# Instantiate tokenizer class of the library from a pretrained model vocabulary.
tokenizer = AutoTokenizer.from_pretrained("models/llama2-7b/llama2_tokenizer")

# Instantiate TextStreamer class of the library.
streamer = TextStreamer(tokenizer, skip_prompt=True, skip_special_tokens=True)

```
