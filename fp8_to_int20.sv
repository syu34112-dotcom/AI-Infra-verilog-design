`timescale 1ns/1ps
module fp8_to_int20(
    input wire [7:0] fp8_din,
    output wire [19:0] int20_dout
);

    // e4m3
    wire        sign;
    wire [3:0]  exp;
    wire [2:0]  mantissa;
    wire [3:0]  frac; // 带隐含位
    wire signed [4:0]  exp_nobias;
    wire        left_shift;
    wire [9:0]  frac_addition_6b0;

    wire   is_sub, is_norm;
    assign is_sub  = (exp == 4'd0) && (mantissa != 3'd0);   
    assign is_norm = (exp != 4'd0) && (exp != 4'd15);      
    
    wire  [19:0] int_val;

    assign sign = fp8_din[7];
    assign exp = fp8_din[6:3];
    assign mantissa = fp8_din[2:0];
    assign frac = (exp == 4'd0) ? {1'b0, mantissa} : {1'b1, mantissa}; 
    assign frac_addition_6b0 = {frac,6'b0};
    assign left_shift = (exp_nobias >= 0);


    
    always_comb begin : sub_exp
        if (is_norm) begin
            exp_nobias = {1'b0,exp} - 5'd7;
        end
        else if(is_sub)begin
            exp_nobias = -6;
        end
        else begin
            exp_nobias = 0;
        end
    end

    always_comb begin
        if (left_shift) begin
            int_val = {10'd0,frac_addition_6b0} << exp_nobias;
        end
        else begin
            int_val = {10'd0,frac_addition_6b0} >> (-exp_nobias);
        end
    end
    
    always_comb begin
        if(sign == 1)begin
            int20_dout = -int_val;
        end
        else begin
            int20_dout = int_val;
        end
    end

endmodule