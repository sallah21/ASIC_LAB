module s7_display #
(
    parameter DIS_NUM = 4,
    parameter MLT_CNT = 10
)
(
    input                           clk_i, // clock
    input                           i_rst, // reset
    input  [(DIS_NUM*4) - 1:0] i_bcd_data, // bcd data input
    
    output [6:0]                    o_segments, // segments output
    output [DIS_NUM-1:0]       o_segments_sel // segments select output
);
 
 wire [3:0]              bcd_muxed;
 wire [DIS_NUM-1:0] bcd_sel;
 wire [6:0]              segments;
 bcd_mux #
 (
   .DIS_NUM        (DIS_NUM),
   .MLT_CNT (MLT_CNT)   
 )
 U_bcd_mux
 (
   .clk_i         (clk_i),
   .i_rst         (i_rst),
   .i_bcd_data    (i_bcd_data),
   
   .o_bcd_muxed   (bcd_muxed),
   .o_bcd_sel     (bcd_sel)
 );
 
 decoder U_decoder
 (
   .i_bcd           (bcd_muxed),
   .o_segments      (segments)
 );
 
 assign o_segments = segments;
 assign o_segments_sel = bcd_sel;
 
 endmodule