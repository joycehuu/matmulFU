module matmul(clk, rst, input_start, inA_flat, inB_flat, outD_flat, output_rdy, counter);
    input clk;
    input rst;
    input input_start;
    input [3:0] counter;

    input [127:0] inA_flat;
    input [127:0] inB_flat;

    output [127:0] outD_flat;
    output reg output_rdy;

    wire [31:0] inA [0:3];
    wire [31:0] inB [0:3];
    reg [31:0] outD [0:3];

    // putting inputs into arrays
    assign inA[0] = inA_flat[127:96];
    assign inA[1] = inA_flat[95:64];
    assign inA[2] = inA_flat[63:32];
    assign inA[3] = inA_flat[31:0];
    assign inB[0] = inB_flat[127:96];
    assign inB[1] = inB_flat[95:64];
    assign inB[2] = inB_flat[63:32];
    assign inB[3] = inB_flat[31:0];

    assign outD_flat[127:96] = outD[0];
    assign outD_flat[95:64] = outD[1];
    assign outD_flat[63:32] = outD[2];
    assign outD_flat[31:0] = outD[3];

    // multiply accumulate
    generate
        genvar i;
        genvar j;
        reg [31:0] elemA [0:3][0:3];
        reg [31:0] elemB [0:3][0:3];
        reg [31:0] acc [0:3][0:3];

        for (i = 0; i < 4; i = i+1) begin: outerloop
            for (j = 0; j < 4; j= j+1) begin: innerloop

                always @(posedge clk) begin
                    if (i == 0) begin
                        elemA[i][j] <= inA[j];
                    end else begin
                        elemA[i][j] <= elemA[i-1][j];
                    end
                    if (j == 0) begin
                        elemB[i][j] <= inB[i];
                    end else begin
                        elemB[i][j] <= elemB[i][j-1];
                    end
                end

                always @(posedge clk) begin
                    if (rst | input_start) begin
                        acc[i][j] <= 32'd0;
                    end else begin
                        acc[i][j] <= acc[i][j] + (elemA[i][j] * elemB[i][j]);
                    end
                end
            end
        end
    endgenerate

    // assign output
    always @(posedge clk) begin
        if (counter >= 7) begin
            outD[0] <= acc[0][3];
            outD[1] <= acc[1][3];
            outD[2] <= acc[2][3];
            outD[3] <= acc[3][3];
            output_rdy <= 1'b1;
        end else begin
            output_rdy <= 1'b0;
        end
    end
    
endmodule