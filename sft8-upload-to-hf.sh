uv run hf auth login --token $HF_TOKEN
uv run hf auth whoami
uv run hf upload tayaee/Qwen2.5-1.5B-Instruct-ko-Reasoning-alpha ./outputs/qwen2.5-1.5b-sft-merge/merged . --commit-message "alpha: SFT 1 epoch on 50k Korean CoT"

