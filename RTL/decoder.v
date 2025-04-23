module decoder
(
    input  [3:0]    i_bcd,
    output [6:0]    o_segments
);

  reg [6:0]  segments;  
    
    always @(i_bcd)
    begin
        case (i_bcd)
                  0 : segments = 7'b0000001;
                  1 : segments = 7'b1001111;
                  2 : segments = 7'b0010010;
                  3 : segments = 7'b0000110;
                  4 : segments = 7'b1001100;
                  6 : segments = 7'b0100000;
                  7 : segments = 7'b0001111;
                  8 : segments = 7'b0000000;
                  9 : segments = 7'b0000100;
                  default: segments = 7'b0000000;
        endcase
    end
    
    assign o_segments = segments; 
                      
endmodule
                      