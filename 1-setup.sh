#!/bin/bash -x
uv add packaging setuptools wheel torch==2.6.0 awscli pydantic 
uv add 'axolotl[deepspeed,flash-attn]' --no-build-isolation
uv add datasets
