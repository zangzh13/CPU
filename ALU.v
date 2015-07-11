
module ADD(A, B, S, ALUFun, Z, V, N, out);
	input [31:0] A, B;
	input [5:0] ALUFun;
	input S;
	output [31:0] out;
	reg [32:0] tmp;
	output Z, N, V;
	
	assign Z = (out == 0);
	assign N = (out[31] == 0 & S ==1);
	assign V = (sign==1)?(A[31]&B[31]&(~tmp[31])) || (~(A[31]|B[31])&tmp[31]):tmp[32];
	assign out = tmp[31:0];

	always @(*)
		case (ALUFun[0])
			0: tmp <= A+B;
			1: tmp <= A+~B+1;
		endcase
endmodule

module CMP(ALUFun, Z, V, N, out)
	input Z, N, V;
	input [5:0] ALUFun;
	output reg out;
		always @(*)
		case (ALUFun[3:1])
			3'b001: out <= Z; //EQ
			3'b000: out <= ~Z; //NEQ
			3'b010: out <= N; //LT
			3'b110: out <= N|Z;//LEZ
			3'b100: out <= ~Z;//GEZ
			3'b111: out <= ~(N|Z)//GTZ
			
		endcase
endmodule
	
	
	