#!/usr/bin/env bash
set -euo pipefail

verilator_bin=${VERILATOR:-verilator}
selected_day=${1:-all}

days=(
  "01|day01_nyc_clock|tb_nyc_clock|nyc_clock.sv|tb_nyc_clock.sv"
  "02|day02_round_robin_arbiter|tb_round_robin_arbiter|round_robin_arbiter.sv|tb_round_robin_arbiter.sv"
  "03|day03_byte_enable_register_file|tb_byte_enable_register_file|byte_enable_register_file.sv|tb_byte_enable_register_file.sv"
  "04|day04_ready_valid_skid_buffer|tb_ready_valid_skid_buffer|ready_valid_skid_buffer.sv|tb_ready_valid_skid_buffer.sv"
  "05|day05_cdc_pulse_synchronizer|tb_cdc_pulse_synchronizer|cdc_pulse_synchronizer.sv|tb_cdc_pulse_synchronizer.sv"
  "06|day06_pipelined_mac|tb_pipelined_mac|pipelined_mac.sv|tb_pipelined_mac.sv"
  "07|day07_two_by_two_router|tb_two_by_two_router|two_by_two_router.sv|tb_two_by_two_router.sv"
  "08|day08_apb_interrupt_controller|tb_apb_interrupt_controller|apb_interrupt_controller.sv|tb_apb_interrupt_controller.sv"
  "09|day09_secded_memory|tb_secded_memory|secded_memory.sv|tb_secded_memory.sv"
  "10|day10_int8_dot_product|tb_int8_dot_product|int8_dot_product.sv|tb_int8_dot_product.sv"
  "11|day11_axis_width_converter|tb_axis_width_converter|axis_width_converter_64_to_32.sv|tb_axis_width_converter.sv"
  "12|day12_safe_clock_gate|tb_safe_clock_gate|safe_clock_gate.sv|tb_safe_clock_gate.sv"
  "13|day13_branch_predictor|tb_two_bit_branch_predictor|two_bit_branch_predictor.sv|tb_two_bit_branch_predictor.sv"
  "14|day14_micro_dma|tb_micro_dma|micro_dma.sv|tb_micro_dma.sv"
)

mkdir -p build logs

run_day() {
    local number=$1 directory=$2 top=$3 rtl=$4 tb=$5
    local build_dir="build/day${number}"
    local compile_log="logs/day${number}_compile.log"
    local run_log="logs/day${number}_run.log"
    local sources=("${directory}/rtl/${rtl}")
    local source
    mkdir -p "${build_dir}"
    for source in "${directory}"/assertions/*.sv "${directory}"/coverage/*.sv; do
        [[ -e "${source}" ]] && sources+=("${source}")
    done
    sources+=("${directory}/tb/${tb}")
    echo "[RUN] Day ${number}: ${directory}"
    if ! "${verilator_bin}" --binary --timing --assert -Wall -Wno-fatal \
        -Wno-SYNCASYNCNET \
        --top-module "${top}" --Mdir "${build_dir}" \
        "${sources[@]}" >"${compile_log}" 2>&1; then
        cat "${compile_log}"
        return 1
    fi
    "${build_dir}/V${top}" | tee "${run_log}"
}

matched=0
for entry in "${days[@]}"; do
    IFS='|' read -r number directory top rtl tb <<<"${entry}"
    if [[ "${selected_day}" == "all" || "${selected_day}" == "${number}" ]]; then
        run_day "${number}" "${directory}" "${top}" "${rtl}" "${tb}"
        matched=1
    fi
done

[[ ${matched} -eq 1 ]] || { echo "Unknown day '${selected_day}'. Use 01 through 14."; exit 2; }
echo "[REGRESSION] PASS: selected RTL projects completed without assertion failures"
