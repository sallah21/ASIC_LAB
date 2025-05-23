module bcd_mux #
(
    parameter DIS_NUM        = 4,
    parameter MLT_CNT = 10
)
(
    input                           clk_i, // clock
    input                           i_rst, // reset
    input  [(DIS_NUM*4) - 1:0] i_bcd_data, // bcd data input
    
    output [3:0]                    o_bcd_muxed, // bcd data output
    output [DIS_NUM-1:0]       o_bcd_sel // bcd select output
);
 
   reg  [clogb2(MLT_CNT)-1:0] r_sel_counter;
   wire [clogb2(MLT_CNT)-1:0] sel_counter;
   wire                                   allow_display_count;
                                                     
   always @ (posedge clk_i or negedge i_rst)
        if (!i_rst) r_sel_counter <= 0;
         else
            begin
                if (r_sel_counter == (MLT_CNT-1)) r_sel_counter <= 0;
                else r_sel_counter <= r_sel_counter + 1;    
            end
   
    reg [clogb2(DIS_NUM)-1:0]  r_display_count;
    wire [clogb2(DIS_NUM)-1:0] display_count;
    assign display_count = (!allow_display_count)? r_display_count :
                            (r_display_count == DIS_NUM)? 0 : r_display_count + 1;
    wire [0:3]                      bcd_out;
    
    wire [DIS_NUM-1:0]         bcd_sel;
    always @ (posedge clk_i or negedge i_rst)
            if (!i_rst) r_display_count <= 0;
            else
                begin
                    r_display_count <= display_count;
                end
   assign allow_display_count = (r_sel_counter == (MLT_CNT-1)) ? 1 : 0;
   assign bcd_out = i_bcd_data[4*(DIS_NUM - r_display_count - 1)+:4];

   assign o_bcd_muxed = bcd_out;
   
   assign bcd_sel = {{(DIS_NUM-1){1'b0}},1'b1} << r_display_count;
   assign o_bcd_sel = bcd_sel;

   // Function to calculate the ceiling of log base 2 of an integer
   function automatic integer clogb2;
   input integer value; // value to be converted
   begin
       value = value - 1;
       for (clogb2 = 0; value > 0; clogb2 = clogb2 + 1) begin
           value = value >> 1;
       end
   end
endfunction 
endmodule    


              