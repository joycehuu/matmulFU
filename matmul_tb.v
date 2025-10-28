`timescale 1ns / 1ps
module matmul_tb();
    // I/O for the FU
    reg clk = 0, rst = 0, input_start;

    wire output_rdy; 
    reg [31:0] matrixA [0:3][0:3];
    reg [31:0] matrixB [0:3][0:3];
    reg [31:0] matrixResult [0:3][0:3];

    wire [127:0] rowResult_flat;
    wire [31:0] rowResult [0:3];

    reg [31:0] inA [0:3];
    reg [31:0] inB [0:3];
    reg [3:0] counter;
    reg [2:0] index;

    // unflattening result
    assign rowResult[0] = rowResult_flat[127:96];
    assign rowResult[1] = rowResult_flat[95:64];
    assign rowResult[2] = rowResult_flat[63:32];
    assign rowResult[3] = rowResult_flat[31:0];

    // initializing stuff to 0
    integer i, j, k, l;
    initial begin
        // Assign matrixA
        matrixA[0][0] = 1;  matrixA[0][1] = 2;  matrixA[0][2] = 3;  matrixA[0][3] = 4;
        matrixA[1][0] = 5;  matrixA[1][1] = 6;  matrixA[1][2] = 7;  matrixA[1][3] = 8;
        matrixA[2][0] = 9;  matrixA[2][1] = 10; matrixA[2][2] = 11; matrixA[2][3] = 12;
        matrixA[3][0] = 13; matrixA[3][1] = 14; matrixA[3][2] = 15; matrixA[3][3] = 16;

        // Assign matrixB
        matrixB[0][0] = 2;  matrixB[0][1] = 7;  matrixB[0][2] = 0;  matrixB[0][3] = 0;
        matrixB[1][0] = 0;  matrixB[1][1] = 2;  matrixB[1][2] = 0;  matrixB[1][3] = 8;
        matrixB[2][0] = 4;  matrixB[2][1] = 0;  matrixB[2][2] = 2;  matrixB[2][3] = 0;
        matrixB[3][0] = 0;  matrixB[3][1] = 0;  matrixB[3][2] = 0;  matrixB[3][3] = 1;

        index = 0;
        counter = 0;
        for (k = 0; k < 4; k = k + 1)
            for (l = 0; l < 4; l = l + 1)
                matrixResult[k][l] = 0;

        // pulse input_start at beginning for two clock cycles
        input_start = 0;   // start low
        #5;                // optional small delay before first pulse
        input_start = 1;   // set high for one clock cycle
        @(posedge clk);    // wait for next rising edge
        @(posedge clk);
        input_start = 0;   // turn off permanently

        #700
        $finish;
    end
    

    always @(posedge clk) begin
        if (rst | input_start) begin
            counter = 0;
            index = 0;
        end else begin
            counter = counter + 1;
        end

        // hardcoding the inputs for every cycle
        case (counter)
            7'd1: begin
                inA[0] = matrixA[0][3];
                inA[1] = 32'b0;
                inA[2] = 32'b0;
                inA[3] = 32'b0;

                inB[0] = matrixB[3][0];
                inB[1] = 32'b0;
                inB[2] = 32'b0;
                inB[3] = 32'b0;
            end
            7'd2: begin
                inA[0] = matrixA[0][2];
                inA[1] = matrixA[1][3];
                inA[2] = 32'b0;
                inA[3] = 32'b0;

                inB[0] = matrixB[2][0];
                inB[1] = matrixB[3][1];
                inB[2] = 32'b0;
                inB[3] = 32'b0;
            end
            7'd3: begin
                inA[0] = matrixA[0][1];
                inA[1] = matrixA[1][2];
                inA[2] = matrixA[2][3];
                inA[3] = 32'b0;

                inB[0] = matrixB[1][0];
                inB[1] = matrixB[2][1];
                inB[2] = matrixB[3][2];
                inB[3] = 32'b0;
            end
            7'd4: begin
                inA[0] = matrixA[0][0];
                inA[1] = matrixA[1][1];
                inA[2] = matrixA[2][2];
                inA[3] = matrixA[3][3];

                inB[0] = matrixB[0][0];
                inB[1] = matrixB[1][1];
                inB[2] = matrixB[2][2];
                inB[3] = matrixB[3][3];
            end
            7'd5: begin
                inA[0] = 32'b0;
                inA[1] = matrixA[1][0];
                inA[2] = matrixA[2][1];
                inA[3] = matrixA[3][2];

                inB[0] = 32'b0;
                inB[1] = matrixB[0][1];
                inB[2] = matrixB[1][2];
                inB[3] = matrixB[2][3];
            end
            7'd6: begin
                inA[0] = 32'b0;
                inA[1] = 32'b0;
                inA[2] = matrixA[2][0];
                inA[3] = matrixA[3][1];

                inB[0] = 32'b0;
                inB[1] = 32'b0;
                inB[2] = matrixB[0][2];
                inB[3] = matrixB[1][3];
            end
            7'd7: begin
                inA[0] = 32'b0;
                inA[1] = 32'b0;
                inA[2] = 32'b0;
                inA[3] = matrixA[3][0];

                inB[0] = 32'b0;
                inB[1] = 32'b0;
                inB[2] = 32'b0;
                inB[3] = matrixB[0][3];
            end
            default: begin
                inA[0] = 32'b0;
                inA[1] = 32'b0;
                inA[2] = 32'b0;
                inA[3] = 32'b0;

                inB[0] = 32'b0;
                inB[1] = 32'b0;
                inB[2] = 32'b0;
                inB[3] = 32'b0;
            end
        endcase

        // whenever a new row is ready, fill in matrix result
        if(output_rdy) begin
            for (j = 0; j < 4; j = j + 1) begin : assign_row
                matrixResult[index][j] = rowResult[j];
            end
            index = index + 1;
        end
    end

    wire [127:0] flat_A, flat_B;
    assign flat_A = {inA[0], inA[1], inA[2], inA[3]};
    assign flat_B = {inB[0], inB[1], inB[2], inB[3]};
    matmul matmultest(.clk(clk), .rst(rst), .input_start(input_start), .output_rdy(output_rdy), .outD_flat(rowResult_flat), .inA_flat(flat_A), .inB_flat(flat_B), .counter(counter));

    always 
    	#20 clk = !clk;
    
    // displaying matrix output
    always @(posedge output_rdy) begin
        #5;
        $display("matrixA:");
        for (i = 0; i < 4; i = i + 1) begin
            $write("[ ");
            for (j = 0; j < 4; j = j + 1) begin
                $write("%0d ", matrixA[i][j]);
            end
            $write("]\n");
        end

        $display("matrixB:");
        for (i = 0; i < 4; i = i + 1) begin
            $write("[ ");
            for (j = 0; j < 4; j = j + 1) begin
                $write("%0d ", matrixB[i][j]);
            end
            $write("]\n");
        end
    end
    always @(posedge clk) begin
        if (output_rdy) begin
            #5
            $display("matrixResult:");
            for (i = 0; i < 4; i = i + 1) begin
                $write("[ ");
                for (j = 0; j < 4; j = j + 1) begin
                    $write("%0d ", matrixResult[i][j]);
                end
                $write("]\n");
            end
        end
    end
    
    // Define output waveform properties
    initial begin
        // output file name
        $dumpfile("matmul.vcd");
        // module to capture and what level, 0 means all wires
        $dumpvars(0, matmul_tb);
    end

endmodule 