#!/usr/bin/env bash
set -euo pipefail

for number in 01 02 03 04 05 06 07 08 09 10 11 12 13 14; do
    day_dir=$(find . -maxdepth 1 -type d -name "day${number}_*" -print -quit)
    [[ -n "${day_dir}" ]] || { echo "Missing day ${number}"; exit 1; }
    [[ -f "${day_dir}/README.md" ]] || { echo "Missing ${day_dir}/README.md"; exit 1; }
    [[ -f "${day_dir}/expected_output.md" ]] || { echo "Missing ${day_dir}/expected_output.md"; exit 1; }
    compgen -G "${day_dir}/rtl/*.sv" >/dev/null || { echo "Missing RTL for ${day_dir}"; exit 1; }
    compgen -G "${day_dir}/tb/*.sv" >/dev/null || { echo "Missing testbench for ${day_dir}"; exit 1; }
    grep -REq 'assert[[:space:]]*\(|assert[[:space:]]+property' "${day_dir}" --include='*.sv' || {
        echo "Missing executable assertion for ${day_dir}"; exit 1;
    }
    grep -REq 'cover[[:space:]]+property|covergroup|hit_|checks' "${day_dir}" --include='*.sv' || {
        echo "Missing coverage implementation for ${day_dir}"; exit 1;
    }
done

echo "[STRUCTURE] PASS: fourteen days contain RTL, testbench, assertions/coverage, explanation, and expected output"
