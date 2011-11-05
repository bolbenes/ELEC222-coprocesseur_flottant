onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /test_bench_DE2/DE2/COPROi/clk
add wave -noupdate -radix hexadecimal /test_bench_DE2/DE2/COPROi/copro_valid
add wave -noupdate -radix hexadecimal /test_bench_DE2/DE2/COPROi/copro_accept
add wave -noupdate -radix hexadecimal /test_bench_DE2/DE2/COPROi/copro_opcode
add wave -noupdate -radix hexadecimal /test_bench_DE2/DE2/COPROi/copro_op0
add wave -noupdate -radix hexadecimal /test_bench_DE2/DE2/COPROi/copro_op1
add wave -noupdate -radix hexadecimal /test_bench_DE2/DE2/COPROi/copro_complete
add wave -noupdate -radix hexadecimal /test_bench_DE2/DE2/COPROi/copro_result
add wave -noupdate -radix hexadecimal /test_bench_DE2/DE2/COPROi/op0
add wave -noupdate -radix hexadecimal /test_bench_DE2/DE2/COPROi/op1
add wave -noupdate -radix hexadecimal /test_bench_DE2/DE2/COPROi/resultat
add wave -noupdate -radix hexadecimal /test_bench_DE2/DE2/COPROi/state
add wave -noupdate -radix hexadecimal /test_bench_DE2/DE2/COPROi/n_state
add wave -noupdate -radix hexadecimal /test_bench_DE2/DE2/COPROi/counter
add wave -noupdate -radix hexadecimal /test_bench_DE2/DE2/COPROi/opcode
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {15530000 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {15402 ns} {15629110 ps}
