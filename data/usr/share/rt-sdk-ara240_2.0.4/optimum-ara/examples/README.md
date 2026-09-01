## Run Examples

```bash
# from optimum-ara root
# update interface type in models/<model_name>/config.json
# update pre/post processing params in models/<model_name>/generate_config.json

# In example script select the model to run by specifcing model_path : models/<model_name>/
# provide path to tokenizer directory in example scrip
python examples/causalLM_auto.py

python examples/qwen_vl.py
```
