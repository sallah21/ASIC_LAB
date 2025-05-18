module s7_stoper #(
  parameter DIS_NUM = 6
  ) (
  i_clk, i_rst,
  o_segments, o_segments_sel
);

input  i_clk;
input  i_rst;
output [6:0]                o_segments;
output [DIS_NUM-1:0]        o_segments_sel;

wire [23:0] stoper_data;

s7_display #(
  .DIS_NUM(DIS_NUM)
) mod_display (
  .clk_i(i_clk),
  .i_rst(i_rst),
  .i_bcd_data(stoper_data),
  .o_segments(o_segments),
  .o_segments_sel(o_segments_sel)
);

stoper mod_stoper (
  .i_clk(i_clk),
  .i_rst(i_rst),
  .o_bcd_time(stoper_data)
);

endmodule // s7_stoper