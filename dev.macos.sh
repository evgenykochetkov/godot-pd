#!/bin/bash

set -e
set -o pipefail

rm -f ./demo/addons/godot-pd/bin/*

cmake . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release --target install -j 8

cp ./demo/addons/godot-pd/bin/libgodot-pd.macos.template_release.universal.dylib ./demo/addons/godot-pd/bin/libgodot-pd.macos.template_debug.universal.dylib
