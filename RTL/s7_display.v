module s7_display #
(
    parameter DISPLAYS_NUM = 4,
    parameter MULTIPLEX_CLK_COUNT = 10
)
(
    input                           i_clk,
    input                           i_rst,
    input  [(DISPLAYS_NUM*4) - 1:0] i_bcd_data,
    
    output [6:0]                    o_segments,
    output [DISPLAYS_NUM-1:0]       o_segments_sel
);
 
 wire [3:0]              bcd_muxed;
 wire [DISPLAYS_NUM-1:0] bcd_sel;
 
 bcd_mux #
 (
   .DISPLAYS_NUM        (DISPLAYS_NUM),
   .MULTIPLEX_CLK_COUNT (MULTIPLEX_CLK_COUNT)   
 )
 bcd_mux_i
 (
   .i_clk         (i_clk),
   .i_rst         (i_rst),
   .i_bcd_data    (i_bcd_data),
   
   .o_bcd_muxed   (bcd_muxed),
   .o_bcd_sel     (bcd_sel)
 );
 
 decoder decoder_i
 (
   .i_bcd           (bcd_muxed),
   .o_segments      (segments)
 );
 
 assign o_segments = segments;
 assign o_segments_sel = bcd_sel;
 
 endmodule