`timescale 1us / 1ps

module s7_stoper_tb;

  // Parameters
  parameter DISPLAYS_NUM = 6; // 6 seven-segment displays
  
  // Inputs
  reg i_clk;
  reg i_rst;

  // Outputs
  wire [6:0] o_segments;         // 7-segment signals
  wire [DISPLAYS_NUM-1:0] o_segments_sel; // Display select signals
  
  // Internal test signals
  reg [31:0] errors = 0;
  reg [31:0] test_count = 0;
  
  // For display purposes
  reg [23:0] expected_bcd_time;
  
  // Instantiate the Unit Under Test (UUT)
  // Note: Without parameter override since DISPLAYS_NUM is hardcoded in s7_stoper module
  s7_stoper uut (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .o_segments(o_segments),
    .o_segments_sel(o_segments_sel)
  );
 
  // Decode 7-segment display to check time
  function [3:0] decode_7seg;
    input [6:0] segments;
    begin
      case (segments)
        7'b0000001: decode_7seg = 4'd0; // "0"
        7'b1001111: decode_7seg = 4'd1; // "1"
        7'b0010010: decode_7seg = 4'd2; // "2"
        7'b0000110: decode_7seg = 4'd3; // "3"
        7'b1001100: decode_7seg = 4'd4; // "4"
        7'b0100100: decode_7seg = 4'd5; // "5"
        7'b0100000: decode_7seg = 4'd6; // "6"
        7'b0001111: decode_7seg = 4'd7; // "7"
        7'b0000000: decode_7seg = 4'd8; // "8"
        7'b0000100: decode_7seg = 4'd9; // "9"
        default: decode_7seg = 4'hF;    // Invalid
      endcase
    end
  endfunction
  
  // Print the current state of segment displays
  task display_segments;
    begin
      $display("Time %0t: 7-segment display status:", $time);
      $display("  Active segment selection: %b", o_segments_sel);
      $display("  Segment pattern: %b", o_segments);
      $display("  Decoded digit: %0d", decode_7seg(o_segments));
    end
  endtask
  
  // Clock generation (1ms period = 1kHz frequency)
  always begin
    #500 i_clk = ~i_clk;
  end
  
  // Test procedure
  initial begin
    // Initialize inputs
    i_clk = 0;
    i_rst = 1;  // Active reset
    
    // Initialize expected values
    expected_bcd_time = 24'h000000;
    
    // File for waveform dumping
    $dumpfile("s7_stoper_tb.vcd");
    $dumpvars(0, s7_stoper_tb);
    
    // Apply reset for 100us
    #100;
    
    // Release reset
    i_rst = 0;
    
    // Display initial state
    $display("\n==== TEST START ====");
    $display("Reset released, timer should start counting from 00:00.000");
    
    // Test for 100ms (should display 00:00.100)
    #100000;
    expected_bcd_time = 24'h000100;
    $display("\n==== TEST POINT 1 ====");
    $display("After 100ms, timer should be at 00:00.100");
    display_segments();
    test_count = test_count + 1;
    
    // Test for 1s (should display 00:01.000)
    #900000;
    expected_bcd_time = 24'h001000;
    $display("\n==== TEST POINT 2 ====");
    $display("After 1s, timer should be at 00:01.000");
    display_segments();
    test_count = test_count + 1;
    
    // Test for 10s (should display 00:10.000)
    #9000000;
    expected_bcd_time = 24'h010000;
    $display("\n==== TEST POINT 3 ====");
    $display("After 10s, timer should be at 00:10.000");
    display_segments();
    test_count = test_count + 1;
    
    // Test for 1min (should display 01:00.000)
    #50000000;
    expected_bcd_time = 24'h100000;
    $display("\n==== TEST POINT 4 ====");
    $display("After 1min, timer should be at 01:00.000");
    display_segments();
    test_count = test_count + 1;
    
    // Test reset functionality (should go back to 00:00.000)
    i_rst = 1;
    #1000;
    i_rst = 0;
    expected_bcd_time = 24'h000000;
    $display("\n==== TEST POINT 5 ====");
    $display("After reset, timer should be at 00:00.000");
    display_segments();
    test_count = test_count + 1;
    
    // Run for a short while after reset
    #10000;
    $display("\n==== TEST POINT 6 ====");
    $display("After 10ms post-reset, timer should be at 00:00.010");
    display_segments();
    test_count = test_count + 1;
    
    // End simulation
    $display("\n==== TEST COMPLETE ====");
    $display("Ran %0d test points.", test_count);
    $display("Note: Visual inspection of display patterns is required.");
    
    // Finish simulation
    #1000;
    $finish;
  end
  
  // Monitor display changes (optional, can be commented out)
  always @(o_segments_sel) begin
    display_segments();
  end

endmodule
