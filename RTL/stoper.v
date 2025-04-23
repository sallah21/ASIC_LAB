module stoper (
    input i_clk,
    input i_rst,
    output [23:0] o_bcd_time
);

reg [23:0] o_bcd_time_r;
reg [3:0] separate_numbers [5:0];
reg [2:0] number_sel;
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        o_bcd_time_r <= 24'b0;
        number_sel <= 3'b0;
        genvar i;
        for (i = 0; i < 6; i = i + 1) begin
            separate_numbers[i] <= 4'b0;
        end
    end else begin
        // bit dumb but works

        o_bcd_time_r <= {separate_numbers[5], separate_numbers[4], separate_numbers[3], separate_numbers[2], separate_numbers[1], separate_numbers[0]};
        separate_numbers[0] <= separate_numbers[0] + 1;
        if (separate_numbers[0] == 9) begin
            separate_numbers[0] <= 0;
            separate_numbers[1] <= separate_numbers[1] + 1;
            if (separate_numbers[1] == 9) begin
                separate_numbers[1] <= 0;
                separate_numbers[2] <= separate_numbers[2] + 1;
                if (separate_numbers[2] == 9) begin
                    separate_numbers[2] <= 0;
                    separate_numbers[3] <= separate_numbers[3] + 1;
                    if (separate_numbers[3] == 9) begin
                        separate_numbers[3] <= 0;
                        separate_numbers[4] <= separate_numbers[4] + 1;
                        if (separate_numbers[4] == 5) begin
                            separate_numbers[4] <= 0;
                            separate_numbers[5] <= separate_numbers[5] + 1;
                            if (separate_numbers[5] == 9) begin
                                separate_numbers[5] <= 0;
                            end
                        end
                    end
                end
            end
        end
    end
end 

assign o_bcd_time = o_bcd_time_r;
endmodule