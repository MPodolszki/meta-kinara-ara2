# AraModelForCausalLM APIs

To use **AraModelForCausalLM** class, we import it from `optimum.ara` in the below mentioned way.

```python

from optimum.ara import AraModelForCausalLM

```

**AraModelForCausalLM** is a generic model class for text generation that allows you to modify parameters to control the generation process, and to create or save custom generation settings.

Below is the list of APIs:

- [`from_pretrained()`](#from_pretrained)
- [`generate()`](#generate)
- [`from_config()`](#from_config)
- [`save_config()`](#save_config)

## from_pretrained()

Establishes a connection with the Ara device and loads the model on it.

```python
    .from_pretrained(
        cls,
        model_id: Union[str, Path],
        config: Optional["AraPretrainedConfig"] = None,
        token: Optional[Union[bool, str]] = None,
        force_download: bool = False,
        file_name: Optional[str] = None,
        subfolder: str = "",
        use_cache: bool = True,
        local_files_only: bool = False,
        use_merged: Optional[bool] = None,
        **kwargs,
    ) -> "AraModelForCausalLM"
```

### Arguments:

| Arguments | Description |
| -------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `model_id (Union[str, Path])` | It can be a simple model ID in which case the default model is used. Alternatively, it can be a full path or repository name, such as **user_name/model**. |
| `config (Optional[AraPretrainedConfig])` | Optional configuration object to load instead of the default one. This also determines the tokenizer class to instantiate. |
| `token (Optional[Union[bool, str]])` **(unsupported for now)** | Token used for HTTP bearer authorization when accessing remote files. If set to True or left unspecified, a default token is used. |
| `force_download(bool)` **(unsupported for now)** | Whether or not to force to (re-)download the feature extractor files and override the cached versions if they exist. Defaults to False. |
| `file_name (Optional[str])` | Specific model file name. |
| `subfolder (str)` | Subfolder path to specify where the model file is located. |
| `use_cache (bool)` **(unsupported for now)** | Indicates whether the model should use previously computed key/value attention states to accelerate decoding, if supported. |
| `local_files_only(bool)` **(unsupported for now)** | If True, loads only local files without attempting to download from remote sources. Defaults to False. |
| `use_merged (Optional[bool])` | Use merged decoder. |
| `**kwargs` | Additional keyword arguments. If keys match configuration attributes, they override corresponding values. |

### Raises:

- `ValueError`:

  - Raised when the parameters combination use_cache=False, use_merged=True" is not supported. To use a merged decoder, past key values must be used.
  - All of `model_id`, `file_name`, and `config` are missing.

- `FileNotFoundError`:

  - Raised when none of the methods could find any DVM model file.

- `NotImplementedError`:

  - Currently, handling multiple .dvm files in the same folder is unsupported. So this is raised when more than one .dvm file found in the folder.

### Returns:

Loads **AraModelForCausalLM** model instance and returns a class object.

### Example:

In the below example, loading a causalLM model from local directory using AraModelForCausalLM.from_pretrained(). Assumes model is compiled into dvm format.

```python

# Importing the os class
import os

# Importing the AraModelForCausalLM class from the optimum.ara module
from optimum.ara import AraModelForCausalLM

# Defining a test method inside a class
def test_model_loading_from_path(self):
    
    # Loading a pre-trained model from the specified local path.
    model = AraModelForCausalLM.from_pretrained(
        os.path.realpath("models/llama2-7b")
    )


```

## generate()

Generates text sequences for given input tokens.

```python

.generate(
        self,
        inputs: Optional[torch.Tensor] = None,
        generation_config: Optional[AraGenerationConfig] = None,
        input_ids: Optional[Union[torch.Tensor, list]] = None,
        streamer: Optional["BaseStreamer"] = None,
        **kwargs,
    ):

```

### Arguments:

| Arguments | Description |
| --------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `inputs (Optional[torch.Tensor])` | The input tensor used as a prompt for text generation or passed to the model's encoder. |
| `generation_config (Optional[AraGenerationConfig])` | Defines generation settings like maximum length and sampling behavior. Any matching \*\*kwargs will override its values. If not supplied, it's loaded from generation_config.json if present, otherwise from the model's default configuration. |
| `input_ids (Optional[Union[torch.Tensor, list]])` | Token IDs representing the input prompt used for generation. |
| `streamer (Optional[BaseStreamer])` | A streamer object used to handle streaming of generated tokens. Tokens are passed using `streamer.put(token_ids)`, and the streamer handles output processing. |
| `**kwargs` | Additional parameters for generation or model-specific settings. |

### Raises:

- `DvApiException`:
  - Raised when `_generate_first_token()` method fails to generate first token.

### Returns:

Generates token IDs for the provided tensor/prompt.

### Example

```python

# Importing AraModelForCausalLM and AraGenerationConfig from the optimum.ara module
from optimum.ara import AraModelForCausalLM, AraGenerationConfig  

# Importing AutoTokenizer from Hugging Face Transformers for tokenizing input text
from transformers import AutoTokenizer  


# Defining a test method 
def test_text_generation_default(self):

    # Creating a list of chat messages with roles for system and user
    messages = [
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "how are you?"},
    ]

    # Applying the chat template to convert messages into a prompt string
    # tokenize=False means output is plain text, not tokenized yet
    # add_generation_prompt=True appends a generation prompt suitable for inference
    inputs = self.tokenizer.apply_chat_template(
        conversation=messages, tokenize=False, add_generation_prompt=True
    )

    # Tokenizing the input string into input IDs and attention masks
    inputs = self.tokenizer(inputs)

    # Generating and retrieving the first sequence
    output = self.model.generate(**inputs)

    # Asserting that the output is not empty
    assert len(output) > 0, 

    # Asserting that the first token is not the pad token
    assert (
        output[0] != self.model.generation_config.pad_token_id
    ),

```

## from_config()

Instantiates the model from a model configuration object.

```python

.from_config(cls, config: AraPretrainedConfig, **kwargs):

```

### Arguments:

| Arguments | Description |
| ------------------------------- | ------------------------------------------------------------------------------------------------ |
| ` config (AraPretrainedConfig)` | Determines which model class should be instantiated based on the provided configuration. |
| `**kwargs` | Additional parameters used to modify the configuration after loading or to initialize the model. |

### Returns:

```python

return cls.from_pretrained(model_id, config=config, **kwargs)

```

Loads a pretrained model instance from **AraModelForCausalLM** using the class object.

### Example:

Test loading a causalLM model from local config.json using AraModelForCausalLM.from_config(). Assumes model is compiled into dvm format.

```python

# Importing the os class
import os

# Import the AraModelForCausalLM class, which is used for loading and running the model
from optimum.ara import AraModelForCausalLM

# Import the AraPretrainedConfig class used for loading the model configuration
from optimum.ara.configuration_utils import AraPretrainedConfig


# Define a test function to check if the model loads correctly from a configuration file
def test_model_loading_from_config_path(self):

    # Load the configuration from a JSON file using its full file path
    config = AraPretrainedConfig.from_json_file(
        os.path.realpath("models/llama2-7b/config.json")
    )

    # Load the model using the configuration object
    model = AraModelForCausalLM.from_config(config)

    # Assert that the loaded model is an instance of AraModelForCausalLM
    assert isinstance(
        model, AraModelForCausalLM
    ), 

```

## save_config()

Saves the model configuration to the specified directory.

```python

    .save_config(self, save_directory):

```

### Arguments:

| Arguments | Description |
| ---------------------- | ------------------------------------------------ |
| `save_directory (str)` | A path to a directory containing the model file. |

### Returns:

Saves the pretrained model configurations in the specified directory. Returns true if saved otherwise false.

### Example:

```python

# Importing the os class
import os

# Import the AraModelForCausalLM class, which is used for loading and running the model
from optimum.ara import AraModelForCausalLM

# Import the AraPretrainedConfig class used for loading the model configuration
from optimum.ara.configuration_utils import AraPretrainedConfig

def test_saving_loaded_config_to_directory(self):
    # Load the configuration from a JSON file using its full file path
    config = AraPretrainedConfig.from_json_file(
        os.path.realpath("models/llama2-7b/config.json")
    )

    # Load the model using the configuration object
    model = AraModelForCausalLM.from_config(config)

    # Assert that the loaded model is an instance of AraModelForCausalLM
    assert isinstance(
        model, AraModelForCausalLM
    ), 

    # Save the loaded configuration to a new directory
    save_directory = os.path.realpath("saved_configs/llama2-7b")
    os.makedirs(save_directory, exist_ok=True)
    config.save_config(save_directory)

```
