module ALUCtl(ALUOp, funct, ALUFun);
	input [2:0] ALUOp;
	input [5:0] funct;
	output reg [5:0] ALUFun;
	always @(*)
		case(ALUOp)
			3'h0:ALUFun<=6'h00;
			3'h2:
				casex(funct)
					6'b10_000x:ALUFun<=6'h00;
					6'b10_001x:ALUFun<=6'h01;
					6'h24:ALUFun<=6'h18;
					6'h25:ALUFun<=6'h1e;
					6'h26:ALUFun<=6'h16;
					6'h27:ALUFun<=6'h11;
					6'h00:ALUFun<=6'h20;
					6'h02:ALUFun<=6'h21;
					6'h03:ALUFun<=6'h23;
					6'b10_101x:ALUFun<=6'h35;
					default:ALUFun<=6'h00;
				endcase
			3'h3:ALUFun<=6'h35;
			3'h4:ALUFun<=6'h33;
			3'h5:ALUFun<=6'h31;
			3'h6:ALUFun<=6'h3d;
			3'h7:ALUFun<=6'h3f;
			3'h1:ALUFun<=6'h39;
		endcase
endmodule