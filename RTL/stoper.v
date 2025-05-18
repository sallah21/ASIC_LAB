module stoper (
    input i_clk,
    input i_rst,
    output [23:0] o_bcd_time
);

// 24-bit output represents 6 BCD digits
// [23:20] - minutes (1 digit)
// [19:12] - seconds (2 digits)
// [11:0]  - milliseconds (3 digits)

reg [23:0] o_bcd_time_r;
reg [9:0] ms_counter;   // Binary counter for milliseconds (0-999)
reg [5:0] sec_counter;  // Binary counter for seconds (0-59)
reg [3:0] min_counter;  // Binary counter for minutes (0-9)

// BCD conversion registers
reg [3:0] ms_hundred;   // hundreds digit of milliseconds (0-9)
reg [3:0] ms_ten;       // tens digit of milliseconds (0-9)
reg [3:0] ms_one;       // ones digit of milliseconds (0-9)
reg [3:0] sec_ten;      // tens digit of seconds (0-5)
reg [3:0] sec_one;      // ones digit of seconds (0-9)
reg [3:0] min_one;      // ones digit of minutes (0-9)

// Counter logic
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        // Reset all counters
        ms_counter <= 10'd0;
        sec_counter <= 6'd0;
        min_counter <= 4'd0;
        
        // Reset all BCD digits
        ms_hundred <= 4'd0;
        ms_ten <= 4'd0;
        ms_one <= 4'd0;
        sec_ten <= 4'd0;
        sec_one <= 4'd0;
        min_one <= 4'd0;
        
        // Reset output
        o_bcd_time_r <= 24'd0;
    end else begin
        // Increment milliseconds counter
        ms_counter <= ms_counter + 1;
        
        // Check if milliseconds counter reaches 1000
        if (ms_counter == 10'd999) begin
            ms_counter <= 10'd0;
            sec_counter <= sec_counter + 1;
            
            // Check if seconds counter reaches 60
            if (sec_counter == 6'd59) begin
                sec_counter <= 6'd0;
                min_counter <= min_counter + 1;
                
                // Check if minutes counter reaches 10
                if (min_counter == 4'd9) begin
                    min_counter <= 4'd0;
                end
            end
        end
        
        // Convert binary counters to BCD
        // Milliseconds (0-999) to 3 BCD digits
        ms_hundred <= ms_counter / 100;
        ms_ten <= (ms_counter % 100) / 10;
        ms_one <= ms_counter % 10;
        
        // Seconds (0-59) to 2 BCD digits
        sec_ten <= sec_counter / 10;
        sec_one <= sec_counter % 10;
        
        // Minutes (0-9) to 1 BCD digit
        min_one <= min_counter;
        
        // Assemble the 24-bit BCD output
        o_bcd_time_r <= {min_one, sec_ten, sec_one, ms_hundred, ms_ten, ms_one};
    end
end

// Assign the register to the output
assign o_bcd_time = o_bcd_time_r;

endmodule