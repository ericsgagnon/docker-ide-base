#!/bin/bash

echo "------------------------------------------------"
echo "check to make sure the container can access gpus"
echo "the gpus listed below are the ones accessible:"
nvidia-smi -L
echo "------------------------------------------------"
