module max_3x3(clk, rst, input_start, inA_flat, inB_flat, outD_flat, output_rdy, counter);
    input clk;
    input rst;
    input input_start;
    input [3:0] counter;

    // 32-bit [3x3] -> 32*3-1 = 95
    input [95:0] inA_flat;
    input [95:0] inB_flat;

    output [95:0] outD_flat;
    output reg output_rdy;

    wire [31:0] inA [0:2];
    wire [31:0] inB [0:2];
    reg [31:0] outD [0:2];

    // putting inputs into arrays
    assign inA[0] = inA_flat[95:64];
    assign inA[1] = inA_flat[63:32];
    assign inA[2] = inA_flat[31:0];
    assign inB[0] = inB_flat[95:64];
    assign inB[1] = inB_flat[63:32];
    assign inB[2] = inB_flat[31:0];

    assign outD_flat[95:64] = outD[0];
    assign outD_flat[63:32] = outD[1];
    assign outD_flat[31:0] = outD[2];

    wire [95:0] elemA_row1, elemA_row2, elemA_row3, elemB_row1, elemB_row2, elemB_row3, acc_row1, acc_row2, acc_row3;
    assign elemA_row1 = {elemA[0][0], elemA[0][1], elemA[0][2]};
    assign elemA_row2 = {elemA[1][0], elemA[1][1], elemA[1][2]};
    assign elemA_row3 = {elemA[2][0], elemA[2][1], elemA[2][2]};
    assign elemB_row1 = {elemB[0][0], elemB[1][0], elemB[2][0]};
    assign elemB_row2 = {elemB[0][1], elemB[1][1], elemB[2][1]};
    assign elemB_row3 = {elemB[0][2], elemB[1][2], elemB[2][2]};
    assign acc_row1 = {acc[0][0], acc[1][0], acc[2][0]};
    assign acc_row2 = {acc[0][1], acc[1][1], acc[2][1]};
    assign acc_row3 = {acc[0][2], acc[1][2], acc[2][2]};

    // multiply accumulate
    reg [31:0] elemA [0:2][0:2];
    reg [31:0] elemB [0:2][0:2];
    reg [31:0] acc [0:2][0:2];
    integer k, l;
    initial begin
        for (k = 0; k < 3; k = k + 1) begin
            for (l = 0; l < 3; l = l + 1) begin
                elemA[k][l] = 0;
                elemB[k][l] = 0;
                acc[k][l] = 0;
            end
        end
    end


    generate
        genvar i;
        genvar j;
        for (i = 0; i < 3; i = i+1) begin: outerloop
            for (j = 0; j < 3; j= j+1) begin: innerloop

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
                        elemA[i][j] <= 32'd0;
                        elemB[i][j] <= 32'd0;
                    end else begin
                        acc[i][j] <= acc[i][j] + (elemA[i][j] * elemB[i][j]);
                    end
                end
            end
        end
    endgenerate

    // assign output
    always @(negedge clk) begin
        if (counter >= 5 && counter <= 7) begin
            outD[0] <= acc[0][counter-5];
            outD[1] <= acc[1][counter-5];
            outD[2] <= acc[2][counter-5];
            output_rdy <= 1'b1;
        end else begin
            outD[0] <= 0;
            outD[1] <= 0;
            outD[2] <= 0;
            output_rdy <= 1'b0;
        end
    end
    
endmodule