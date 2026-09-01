# AraGenerationConfig APIs

To use **AraGenerationConfig** class, we import it from `optimum.ara` in the below mentioned way.

```python
from optimum.ara import AraGenerationConfig
```

**AraGenerationConfig** is a configuration class for text generation that allows you to modify parameters to control the generation process, and to create or save custom generation settings.

Below is the list of APIs

- [`make_ara_config()`](#make_ara_config)
- [`from_pretrained()`](#from_pretrained)
- [`to_json_string()`](#to_json_string)
- [`from_json_file()`](#from_json_file)
- [`from_model_config()`](#from_model_config)

## make_ara_config()

Creates an **AraHostConfig** instance with the specified MCP values.

```python
.make_ara_config(
    cls,
    target_token_post_mcp: int = 1,
    target_token_pre_mcp: int = 1,
    target_prompt_post_mcp: int = 1,
    target_prompt_pre_mcp: int = 1,
) -> AraHostConfig:
```

### Arguments:

| Arguments | Description |
| ------------------------------ | --------------------------------------------------------------- |
| `target_token_post_mcp (int)` | MCP value for post-processing of next_token generation. |
| `target_token_pre_mcp (int)` | MCP value for token pre-processing of next_token generation. |
| `target_prompt_post_mcp (int)` | MCP value for prompt post-processing of first_token generation. |
| `target_prompt_pre_mcp (int)` | MCP value for prompt pre-processing of first_token generation. |

> **ℹ️ Note:**
>
> - Setting any of these values to **0** performs post/pre-processing on the host machine like CPU or server.
> - Setting any of these values to **1** performs post/pre-processing on the Ara devices.

### Returns:

```python
return AraHostConfig(
        target_token_post_mcp=target_token_post_mcp,
        target_token_pre_mcp=target_token_pre_mcp,
        target_prompt_post_mcp=target_prompt_post_mcp,
        target_prompt_pre_mcp=target_prompt_pre_mcp,
    )
```

Returns an instance of **AraHostConfig** with the created configuration.

### Example:

```python
# Import required classes from the generation configuration utilities of the optimum.ara module.
from optimum.ara.generation.configuration_utils import (
    AraGenerationConfig,  # Class used for setting generation-specific configuration
    AraHostConfig,        # Base class or interface that generation config should comply with
)

# Define a test method by creating an AraPretrainedConfig instance with default parameters.
def test_ara_config_creation(self):

    # Create a default AraGenerationConfig using the provided utility method.
    config = AraGenerationConfig.make_ara_config()

    # Verify that the config object returned is an instance of AraHostConfig
    assert isinstance(
        config, AraHostConfig
    ), 

    # Assert that the default value of target_token_post_mcp is 1
    assert (
        config.target_token_post_mcp == 1
    ), 

    # Assert that the default value of target_token_pre_mcp is 1
    assert (
        config.target_token_pre_mcp == 1
    ),
```

## from_pretrained()

Loads an **AraGenerationConfig** from a pretrained model directory or file.

```python
.from_pretrained(
        cls,
        pretrained_model_name_or_path: Union[str, os.PathLike],
        cache_dir: Optional[Union[str, os.PathLike]] = None,
        force_download: bool = False,
        local_files_only: bool = False,
        token: Optional[Union[str, bool]] = None,
        revision: str = "main",
        **kwargs,
    ) -> "AraGenerationConfig":
```

### Arguments:

| Arguments | Description |
| ------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `pretrained_model_name_or_path (str or PathLike)` | Can be a string, the model id of a pretrained model configuration, a directory path with a saved configuration, for example, using `save_pretrained()`, or a direct path/URL to a JSON config file. |
| `cache_dir(Optional[Union[str, os.PathLike]])` **(unsupported for now)** | Path to a directory in which a downloaded pretrained model configuration should be cached if the standard cache should not be used. |
| `force_download(bool)` **(unsupported for now)** | Whether or not to force to (re-)download the configuration files and override the cached versions if they exist. Defaults to False. |
| `local_files_only(bool)` **(unsupported for now)** | If True, loads only local files without attempting to download from remote sources. Defaults to False. |
| `token(Optional[Union[str, bool]])` **(unsupported for now)** | Token used for HTTP bearer authorization when accessing remote files. If set to True or left unspecified, a default token is used. |
| `Revision(str)` **(unsupported for now)** | Specifies the version of the model to use. Can be a branch name, tag, or commit ID, as models are stored in git. |
| `**kwargs` | Additional configuration values that override existing settings when loading the model. |

### Returns:

Returns an instance of **AraGenerationConfig** with loaded configurations.

### Example:

In the below eaxmple, a causalLM config is loaded from local directory using AraGenerationConfig.from_pretrained(). Assumes model is compiled into dvm format.

```python
# Import the os module 
import os

# Import Ara generation configuration utilities from the optimum.ara package
from optimum.ara.generation.configuration_utils import (
    AraGenerationConfig,  # Class for generation-specific configuration
    AraHostConfig,        # Base class or interface expected for generation configurations
)

# Define a test method to test loading a generation config from a directory
def test_config_loading_from_config_dir(self):

    # Load the generation configuration from a directory containing model configuration files
    config = AraGenerationConfig.from_pretrained(
        os.path.realpath("models/llama2-7b")  
    )

    # Assert that the loaded config is an instance of AraGenerationConfig
    assert isinstance(
        config, AraGenerationConfig
    ),
```

## to_json_string()

Serializes the configuration to a JSON-formatted string.

```python
.to_json_string(self, use_diff: bool = False, ignore_metadata=False) -> str:
```

### Arguments:

| Arguments | Description |
| ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------- |
| `use_diff (bool, optional)` **(unsupported for now)** | If True, only the changes from the default AraPretrainedConfig() are saved to the JSON file. Default is True. |
| `ignore_metadata (bool, optional)` **(unsupported for now)** | Whether or not to ignore metadata. |

### Returns:

```python
return json.dumps(combined_dict, indent=2, sort_keys=True) + "\n" 
```

Provides complete configuration including Ara-specific settings as a clean, indented JSON string.

### Example

```python
# Import the os module 
import os

# Import Ara generation configuration utilities from the optimum.ara package
from optimum.ara.generation.configuration_utils import (
    AraGenerationConfig,  # Class for generation-specific configuration
    AraHostConfig,        # Base class or interface expected for generation configurations
)

# Define a test method to test loading a generation config from a directory
def test_config_loading_from_config_dir(self):


    # Load the generation configuration from a directory containing model configuration files
    config = AraGenerationConfig.from_pretrained(
        os.path.realpath("models/llama2-7b")  
    )

    # Assert that the loaded config is an instance of AraGenerationConfig
    assert isinstance(
        config, AraGenerationConfig
    ), 

    # Serialize the configuration to a JSON-formatted string
    json_string = config.to_json_string(use_diff=False, ignore_metadata=False)

    # Print or use the JSON string 
    print(json_string)
```

## from_json_file()

Loads an **AraGenerationConfig** from a JSON file.

```python
.from_json_file(
    cls, json_file: Union[str, os.PathLike]
) -> "AraGenerationConfig":
```

### Arguments:

| Arguments | Description |
| ----------------------------- | ------------------------------------------------ |
| `json_file (str or PathLike)` | Path to the JSON file containing the parameters. |

### Raises:

- `AssertionError`:
  - Raised when the specified json_file path is incorrect, file is missing, or wrong config directory used.

### Returns:

```python
return cls(ara_cfg=ara_cfg, **config_dict)
```

This returns an instance of **AraGenerationConfig**, `ara_cfg`, a structured config object created from Ara-specific settings. And `**config_dict`, the complete original config dictionary.

### Example

In the below example, a causalLM config is loaded from a local generation_config.json file using AraGenerationConfig.

```python
# Import the os module
import os

# Import configuration-related classes from the Ara generation utilities module
from optimum.ara.generation.configuration_utils import (
    AraGenerationConfig,  # Class to handle generation config for Ara models
)

# Define a test function for loading generation config from a JSON file
def test_config_loading_from_config_path(self):


    # Load the configuration using a static method that reads a JSON config file from the given path
    config = AraGenerationConfig.from_json_file(
        os.path.realpath("models/llama2-7b/generation_config.json")  
    )

    # Assert that the loaded config is indeed an instance of AraGenerationConfig
    assert isinstance(
        config, AraGenerationConfig
    ), 
```

## from_model_config():

Creates a **AraGenerationConfig** object from a model configuration.

```python
.from_model_config(cls, model_config):
```

### Arguments:

| Arguments | Description |
| -------------- | ------------------------------------------------------------------- |
| `model_config` | The model config that is used to instantiate the generation config. |

### Returns:

```python
return cls(ara_cfg=ara_cfg, **gen_cfg)
```

This returns an instance of **AraGenerationConfig**, `ara_cfg`, a structured config object created from Ara-specific settings. And `**gen_cfg` the created configuration.

### Example:

In the below example, **AraGenerationConfig** is created from loaded AraPretrainedConfig configurations of a model.

```python
# Import the os module 
import os

# Import Ara configuration utilities
from optimum.ara.generation.configuration_utils import (
    AraGenerationConfig,  # Class for generation-specific configuration
    AraHostConfig, # Base class or interface expected for generation configurations
)

from optimum.ara.configuration_utils import (
    AraPretrainedConfig,  # Class for model-level configuration
)

# Define a test method to test creating a generation config from a model config
def test_generation_config_from_model_config(self):


    # Load the model configuration from a JSON file
    model_config = AraPretrainedConfig.from_json_file(
        os.path.realpath("models/llama2-7b/config.json")
    )

    # Create a generation configuration using the model configuration
    generation_config = AraGenerationConfig.from_model_config(model_config)

    # Assert that the result is an instance of AraGenerationConfig
    assert isinstance(
        generation_config, AraGenerationConfig
    ), 
```
