#!/usr/bin/env bash
set -euo pipefail

[[ -f README.md ]] || { echo "Missing root README.md"; exit 1; }
[[ -f LICENSE ]] || { echo "Missing LICENSE"; exit 1; }
[[ -f docs/coverage_plan.md ]] || { echo "Missing docs/coverage_plan.md"; exit 1; }
[[ -f docs/verification_report.md ]] || { echo "Missing docs/verification_report.md"; exit 1; }

day_count=$(find . -maxdepth 1 -type d -name 'day[0-9][0-9]_*' | wc -l)
[[ "${day_count}" -eq 14 ]] || { echo "Expected exactly 14 root day directories; found ${day_count}"; exit 1; }

if grep -Rq 'ashishkommineni/7-days-of-rtl' README.md docs .github 2>/dev/null; then
    echo "Found stale 7-days-of-rtl repository link"
    exit 1
fi

[[ ! -d 14-days-of-verilog-rtl ]] || {
    echo "Found retired duplicate 14-days-of-verilog-rtl tree"
    exit 1
}
[[ ! -f .github/workflows/rtl-14day-regression.yml ]] || {
    echo "Found retired partial-series workflow"
    exit 1
}

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
    question_count=$(grep -Ec '^[0-9]+\. \*\*' "${day_dir}/README.md")
    [[ "${question_count}" -eq 10 ]] || {
        echo "Expected 10 interview questions in ${day_dir}/README.md; found ${question_count}"; exit 1;
    }
done

echo "[STRUCTURE] PASS: fourteen days contain RTL, testbench, assertion/coverage evidence, ten interview Q&A, explanation, and expected output"
