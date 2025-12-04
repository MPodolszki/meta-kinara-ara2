# Optimum Ara

Optimum Ara is an extension of the Hugging Face Optimum library that integrates with Ara hardware to enable optimized inference for Optimized Ara models.

The following models are integrated into the `optimum-ara` library:

- Llama 2 - 7B
- Llama 3.1 - 8B
- Qwen 2 - 7B
- Qwen 2.5 - 3B
- Qwen 2.5 - 7B

![Optimum Ara Architecture](docs/assets/optimum-ara-apis-architecture.png)


## Build

The following commands will generate a distribution package (stored in the ./dist directory) for release.

```bash
pip install build
python -m build
```

## Installation
> Note: Python Virtual Environment is recommended to avoid conflicts with exisiting packages  

To install from the generated distribution file.

```bash
pip install optimum_ara-< version >.whl
```

To install the package directly from source (for development):

```bash
cd optimum-ara
pip install -e ".[dev]"
```
## Dependencies (Automatically Installed)

```bash
"numpy>=1.26",
"pyyaml>=6.0",
"torch>=2.3",
"transformers>=4.42",
"pydantic==2.11.5",
```
## Prerequisite
> Note: Assumption is HW Bringup is done for the ARA Device
1. Set Envirenemnt variable `DV_TGT_ROOT` to SDK Root Directory
```bash
export DV_TGT_ROOT=<sdk root path>
```
2. Run Proxy
```bash
cd <sdk root>/art/linux/x86/proxy/
./proxy -c ../../config/proxy_config.yaml
```
## Usage

To understand the implementation using Optimum Ara APIs in an application, refer to the [Examples](./examples).

## API Documentation

Optimum Ara provides configuration and model classes inspired by Hugging Face Transformers. The **AraModelForCausalLM**, **AraPretrainedConfig**, and **AraGenerationConfig** classes from optimum.ara provide core functionality for working with Ara models.

- [AraModelForCausalLm](./docs/ara_model_for_causallm.mdx): Loads models, generates responses for prompts, and supports various instantiation methods.
- [AraPretrainedConfig](./docs/ara_pretrained_config.mdx): Manages loading and saving model configurations from local files, directories, or pretrained sources.
- [AraGenerationConfig](./docs/ara_generation_config.mdx): Enables customization of text generation parameters, allowing users to create, modify, and save generation configurations.

## Examples

```text
Steps to run Examples

1. Follow above steps.
2. Update model.dvm path in models/<model name>/config.json
3. Update model directory path in examples/casualLM.py
4. Update tokenizer assests path or use model id in examples/casualLM.py
5. python examples/casualLM.py
```