#!/bin/bash
sed -i '/PYTHON_COMPAT/s/python3_14/python3_14 python3_15/' "$1" || true
grep -q "python3_15" "$1" && exit 0
sed -i '/PYTHON_COMPAT/s/python3_{10..14}/python3_{10..15}/' "$1"
