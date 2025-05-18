`timescale 1us / 1ps

module stoper_tb;

  // Inputs
  reg i_clk;
  reg i_rst;
  
  // Outputs
  wire [23:0] o_bcd_time;
  
  // Signals for verification
  wire [3:0] ms_ones;
  wire [3:0] ms_tens;
  wire [3:0] ms_hundreds;
  wire [3:0] sec_ones;
  wire [3:0] sec_tens;
  wire [3:0] min_ones;
  
  // Test status and expected values
  reg [31:0] errors = 0;
  reg [31:0] test_number = 0;
  
  // Instantiate the Unit Under Test (UUT)
  stoper uut (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .o_bcd_time(o_bcd_time)
  );

  s7_stoper s7uut ();
  
  // Extract individual BCD digits from the output
  assign ms_ones     = o_bcd_time[3:0];    // Milliseconds ones
  assign ms_tens     = o_bcd_time[7:4];    // Milliseconds tens
  assign ms_hundreds = o_bcd_time[11:8];   // Milliseconds hundreds
  assign sec_ones    = o_bcd_time[15:12];  // Seconds ones
  assign sec_tens    = o_bcd_time[19:16];  // Seconds tens
  assign min_ones    = o_bcd_time[23:20];  // Minutes ones
  
  // Clock generation (1ms period = 1kHz frequency)
  // 1ms = 1000us, so half period is 500us
  always begin
    #500 i_clk = ~i_clk;
  end
  
  // Check if the time matches expected values
  task check_time;
    input [3:0] exp_min;
    input [3:0] exp_sec_tens;
    input [3:0] exp_sec_ones;
    input [3:0] exp_ms_hundreds;
    input [3:0] exp_ms_tens;
    input [3:0] exp_ms_ones;
    begin
      test_number = test_number + 1;
      
      if (min_ones !== exp_min || 
          sec_tens !== exp_sec_tens || 
          sec_ones !== exp_sec_ones || 
          ms_hundreds !== exp_ms_hundreds || 
          ms_tens !== exp_ms_tens || 
          ms_ones !== exp_ms_ones) begin
        
        errors = errors + 1;
        $display("ERROR at time %0t: Test #%0d", $time, test_number);
        $display("Expected: %0d:%0d%0d.%0d%0d%0d", 
                 exp_min, exp_sec_tens, exp_sec_ones, 
                 exp_ms_hundreds, exp_ms_tens, exp_ms_ones);
        $display("Got:      %0d:%0d%0d.%0d%0d%0d", 
                 min_ones, sec_tens, sec_ones, 
                 ms_hundreds, ms_tens, ms_ones);
      end
      else begin
        $display("PASS at time %0t: Test #%0d - Time %0d:%0d%0d.%0d%0d%0d", 
                 $time, test_number, 
                 min_ones, sec_tens, sec_ones, 
                 ms_hundreds, ms_tens, ms_ones);
      end
    end
  endtask
  
  // Test procedure
  initial begin
    // Initialize inputs
    i_clk = 0;
    i_rst = 1;  // Active reset
    
    // Wait 100us with reset active
    #100;
    
    // Release reset
    i_rst = 0;
    
    // Wait 10ms and check if time is 0:00.010
    #10000;
    check_time(0, 0, 0, 0, 1, 0);
    
    // Wait 90ms and check if time is 0:00.100
    #90000;
    check_time(0, 0, 0, 1, 0, 0);
    
    // Wait 900ms and check if time is 0:01.000
    #900000;
    check_time(0, 0, 1, 0, 0, 0);
    
    // Wait 9s and check if time is 0:10.000
    #9000000;
    check_time(0, 1, 0, 0, 0, 0);
    
    // Wait 50s and check if time is 0:59.000
    #50000000;
    check_time(0, 5, 9, 0, 0, 0);
    
    // Wait 1s and check if time is 1:00.000
    #1000000;
    check_time(1, 0, 0, 0, 0, 0);
    
    // Wait 8min 59s and check if time is 9:59.000
    #539000000;
    check_time(9, 5, 9, 0, 0, 0);
    
    // Wait 1s and check if time rolled over to 0:00.000
    #1000000;
    check_time(0, 0, 0, 0, 0, 0);
    
    // Test complete
    if (errors == 0)
      $display("All tests passed successfully!");
    else
      $display("%0d errors encountered during testing.", errors);
    
    $finish;
  end
  
  // Monitor time changes
  initial begin
    $monitor("Time: %0d:%0d%0d.%0d%0d%0d", 
             min_ones, sec_tens, sec_ones, 
             ms_hundreds, ms_tens, ms_ones);
  end

endmodule
