#!/bin/bash
source venv/si1p1/bin/activate \
[[ -d build/users ]] || mkdir -p build/users \
QUART_APP=src.user_rest:app quart run –p 5050
