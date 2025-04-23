module bcd_mux #
(
    parameter DISPLAYS_NUM        = 4,
    parameter MULTIPLEX_CLK_COUNT = 10
)
(
    input                           i_clk,
    input                           i_rst,
    input  [(DISPLAYS_NUM*4) - 1:0] i_bcd_data,
    
    output [3:0]                    o_bcd_muxed,
    output [DISPLAYS_NUM-1:0]       o_bcd_sel
);
 
   reg  [clogb2(MULTIPLEX_CLK_COUNT)-1:0] r_sel_counter;
   wire [clogb2(MULTIPLEX_CLK_COUNT)-1:0] sel_counter;
   wire                                   allow_display_count;
                                                     
   always @ (posedge i_clk or negedge i_rst)
        if (!i_rst) r_sel_counter <= 0;
         else
            begin
                if (r_sel_counter == (MULTIPLEX_CLK_COUNT-1)) r_sel_counter <= 0;
                else r_sel_counter <= r_sel_counter + 1;    
            end
   
    reg [clogb2(DISPLAYS_NUM)-1:0]  r_display_count;
    wire [clogb2(DISPLAYS_NUM)-1:0] display_count;
    assign display_count = (!allow_display_count)? r_display_count :
                            (r_display_count == DISPLAYS_NUM)? 0 : r_display_count + 1;
    wire [0:3]                      bcd_out;
    
    wire [DISPLAYS_NUM-1:0]         bcd_sel;
    always @ (posedge i_clk or negedge i_rst)
            if (!i_rst) r_display_count <= 0;
            else
                begin
                    r_display_count <= display_count;
                end
   assign allow_display_count = (r_sel_counter == (MULTIPLEX_CLK_COUNT-1)) ? 1 : 0;
   assign bcd_out = i_bcd_data[4*(DISPLAYS_NUM - r_display_count - 1)+:4];

   assign o_bcd_muxed = bcd_out;
   
   assign bcd_sel = {{(DISPLAYS_NUM-1){1'b0}},1'b1} << r_display_count;
      
endmodule    

function integer clogb2;
    input integer value;
    begin
        value = value - 1;
        for (clogb2 = 0; value > 0; clogb2 = clogb2 + 1) begin
            value = value >> 1;
        end
    end
endfunction 
              