# Matmul Functional Unit
- Currently, the matmul.v file contains the functional unit Verilog code to do a 32-bit (4x4) x (4x4) matrix multiplication. This is performed in a systolic array manner where only one row and one column is streamed in at a time.
- The matmul_tb.v contains the testbench for verifying the functional unit. You can input 4x4 matrices into matrixA and matrixB and run the commands below to verify the output.
- Alternatively, max_3x3.v contains the function unit Verilog code for a (3x3) x (3x3) matrix multiplication. 

### Commands
```bash
# Compile the modules (4x4)
iverilog -Wimplicit -o matmul matmul_tb.v matmul.v

# Run the testbench
vvp matmul

# Open the waveform visualizer
gtkwave matmul.vcd

## For 3x3
iverilog -Wimplicit -o max max_3x3_tb.v max_3x3.v
vvp max
gtkwave max_3x3.vcd