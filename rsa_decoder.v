`timescale 1ns/10ps
module rsa_decoder(
    clk,
    res,
    data_in,
    data_out
);
input           clk;
input           res;
input[15:0]     data_in;
output[15:0]    data_out;

//RSA相关参数 范围(0,65535)
parameter       p=67,q=53,n=3551,t=3432,e=5,d=1373;
	   
reg[1:0]        case_num;
reg[15:0]       d_reg;                      //幂指数寄存器
reg[31:0]       tmp;                        //中间计算结果
reg[15:0]       data_out;

//时钟上升沿或复位下降沿有效
always @(posedge clk or negedge res) begin
    if(~res) begin
        case_num<=0;
    end
    else begin
        case (case_num)
            //导入幂指数d和待解密数据
            2'd0:begin
                d_reg<=d;
                tmp<={16'd0,data_in};
                case_num<=2'd1;
            end
            //单次乘幂运算
            2'd1:begin
                tmp<=tmp*data_in;
                d_reg<=d_reg-1;
                case_num<=2'd2;
            end
            //求模 继续乘幂 or 输出
            2'd2:begin
                tmp<=tmp%n;
                if(d_reg>16'd1) begin
                    case_num<=2'd1;
                end
                else begin
                    case_num<=2'd3;
                end
            end
            //输出解密结果
            2'd3:begin
                data_out<=tmp;
            end
            // default: 
        endcase
    end  
end
endmodule

module rsa_decoder_tb;
reg			clk,res;
reg[15:0]	data_in;
wire[15:0]	data_out;

rsa_decoder rsa_decoder(
	.clk(clk),
    .res(res),
	.data_in(data_in),
	.data_out(data_out)
);

initial begin
			clk<=0;res<=0;
			data_in<=16'd2959;
    #7      res<=1;
	#50000	$stop;
end

always #5 clk<=~clk;

endmodule