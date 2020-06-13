#!/bin/bash

# 1. If needed, generates Python virtual env with chevron installed.
# 2. Copies assets (CSS, img, etc.) into the build folder.
# 3. Converts each mustache file in the templates folder into html.

PYTHON_VENV="./venv"
ASSETS=("./css" "./icons" "./fonts" "./img")

TEMPLATES_DIR="./templates"
OUTPUT_DIR="./build"
PARTIALS_DIR="$TEMPLATES_DIR/partials"
DATA_DIR="$TEMPLATES_DIR/data"
TEMPLATES="$TEMPLATES_DIR/*.mustache"

if [ ! -d $PARTIALS_DIR ]; then
  echo " - ✘ Please check that partials folder $PARTIALS_DIR exists"
  exit
fi
if [ ! -d $OUTPUT_DIR ]; then
  echo "Creating output directory $OUTPUT_DIR"
  mkdir $OUTPUT_DIR
fi

if [ ! -d "$PYTHON_VENV" ]; then
  echo "Creating new Python venv and installing chevron"
  python3 -m venv "$PYTHON_VENV"
  source "$PYTHON_VENV/bin/activate"
  python3 -m pip install chevron
else
  source "$PYTHON_VENV/bin/activate"
fi

echo -n "Copying assets into $OUTPUT_DIR: "
for assetPath in ${ASSETS[*]}; do
  if [ ! -d "$assetPath" ]; then
    continue
  fi
  echo -n "$assetPath "
  cp -r "$assetPath" "$OUTPUT_DIR"
done
echo

for f in $TEMPLATES; do
  [ -e "$f" ] || continue
  echo -n "$f"
  name=$(basename "$f" .mustache)
  if [ ! -f "$DATA_DIR/$name.json" ]; then
    echo " - ✘ Please check that $DATA_DIR/$name.json exists"
    continue
  fi
  if chevron -p $PARTIALS_DIR -d "$DATA_DIR/$name.json" "$f" >"$OUTPUT_DIR/$name.html"; then
    echo " - ✔ OK"
  else
    echo " - ✘ FAIL"
  fi

done
