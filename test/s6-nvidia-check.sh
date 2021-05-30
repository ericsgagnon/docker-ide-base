#!/bin/bash

echo "------------------------------------------------"
echo "check to make sure the container can access gpus"
echo "any gpus currently accessible are listed here:  "
nvidia-smi -L
echo "------------------------------------------------"
