Tanh module.

This is a hardware implementation of a tanh module. The module runs under a test bench for multiple data sets. In essence, the module performs two functions - matrix multiplication and tanh value interpolation. The matrix multiplication was achieved with the use of a multiplier followed by an accumulator. The achieved values were then used to interpolate the tanhvalue to a precision of 8 bits.

The project was written in verilog, simulated using VSim and synthesized using Design Vision.

Since this was purely an academic project, it is not optimized in terms of logic area or clock period.
