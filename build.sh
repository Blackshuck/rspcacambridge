#!/bin/bash

# 1. If needed, generates Python virtual env with chevron installed.
# 2. Copies assets (CSS, img, etc.) into the build folder.
# 3. Converts each mustache file in the templates folder into html.
# 4. Runs prettier on the output.

PYTHON_VENV="./venv"
ASSETS=("./css" "./icons" "./fonts" "./img")

TEMPLATES_DIR="./templates"
OUTPUT_DIR="./build"
PARTIALS_DIR="$TEMPLATES_DIR/partials"
DATA_DIR="$TEMPLATES_DIR/data"

if [ ! -d ${PARTIALS_DIR} ]; then
  echo " - ✘ Please check that partials folder ${PARTIALS_DIR} exists"
  exit
fi
if [ ! -d ${OUTPUT_DIR} ]; then
  echo "Creating output directory ${OUTPUT_DIR}"
  mkdir ${OUTPUT_DIR}
fi

if [ ! -d "${PYTHON_VENV}" ]; then
  echo "Creating new Python venv and installing chevron"
  python3 -m venv "${PYTHON_VENV}"
  source "${PYTHON_VENV}/bin/activate"
  python3 -m pip install chevron
else
  source "${PYTHON_VENV}/bin/activate"
fi

echo -n "Copying assets into ${OUTPUT_DIR}: "
for assetPath in ${ASSETS[*]}; do
  if [ ! -d "${assetPath}" ]; then
    continue
  fi
  echo -n "${assetPath} "
  cp -r "${assetPath}" "${OUTPUT_DIR}"
done
echo

generate_html() {
  echo -n "$1"
  name=$(basename "$1" .mustache)
  folder="$(basename "$(dirname "$1")")"
  if [ "${folder}" == "$(basename "${TEMPLATES_DIR}")" ]; then
    json="${DATA_DIR}/${name}.json"
  else
    json="${DATA_DIR}/${folder}/${name}.json"
  fi
  if [ ! -f "${json}" ]; then
    echo " - ✘ Please check that ${json} exists"
    return
  fi
  if chevron -p ${PARTIALS_DIR} -d "${json}" "$1" >"${OUTPUT_DIR}/${name}.html"; then
    echo " - ✔ OK"
    prettier --write "${OUTPUT_DIR}/${name}.html"
  else
    echo " - ✘ FAIL"
  fi
}

process_folder() {
  for d in "$1"/*; do
    if [ "${d}" == "${DATA_DIR}" ] || [ "${d}" == "${PARTIALS_DIR}" ]; then
      return
    fi
    if [ ! -d "${d}" ] && [ "${d: -9}" == ".mustache" ]; then
      generate_html "${d}"
    elif [ -d "${d}" ]; then
      process_folder "${d}"
    fi
  done
}

process_folder ${TEMPLATES_DIR}
