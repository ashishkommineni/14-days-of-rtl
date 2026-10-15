#!/usr/bin/env bash
set -euo pipefail

command -v xrun >/dev/null || {
    echo "xrun was not found. Load the Cadence Xcelium environment and license first."
    exit 127
}

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

mkdir -p logs xcelium.d
for entry in "${days[@]}"; do
    IFS='|' read -r number directory top rtl tb <<<"${entry}"
    sources=("${directory}/rtl/${rtl}")
    for source in "${directory}"/assertions/*.sv "${directory}"/coverage/*.sv; do
        [[ -e "${source}" ]] && sources+=("${source}")
    done
    sources+=("${directory}/tb/${tb}")
    echo "[XRUN] Day ${number}: ${directory}"
    xrun -64bit -sv -assert -coverage all -access +rwc -top "${top}" \
        -xmlibdirname "xcelium.d/day${number}" \
        "${sources[@]}" \
        -l "logs/day${number}_xcelium.log"
done
echo "[XCELIUM REGRESSION] PASS: all fourteen simulations completed"
