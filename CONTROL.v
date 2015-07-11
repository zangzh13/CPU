module control(
	OpCode, funct, IRQ, 
	PCSrc, RegDst, RegWr, 
	ALUSrc1, ALUSrc2, ALUop, Sign, 
	MemWr, MemRd, MemToReg,
	EXTOp, LUOp
	)
	input [31:0] instruct;
	wire [5:0] OpCode;
	wire [5:0] funct;
	input IRQ;
	
	output reg [2:0] PCSrc;
	output reg [1:0] RegDst;
	output reg [2:0] ALUOp;
	output reg [1:0] MemToReg;
	output reg RegWr, ALUSrc2, ;
	output ALUSrc1, Sign, MemWr, MemRd, EXTOp, LUOp;
	
	assign OpCode = instruct[31:26];
	assign funct = instruct[5:0];
	assign ALUSrc1 = (OpCode==0&&(funct==0||funct==6'h02||funct==6'h03))?1:0;
	assign Sign = (OpCode==0&&(funct==6'h20||funct==6'h22)||OpCode==6'h08)?1:0;
	assign MemWr = (OpCode==6'h2b)?1:0;
	assign MemRd = (OpCode==6'h23)?1:0;
	assign EXTOp = (OpCode==6'h09||OpCode==6'h0c||OpCode==6'h0b)?0:1;
	assign LUOp = (OpCode==6'h0f)?1:0;
	
	always @(*)
		casex(OpCode)
			//lw,sw,lui
			6'b10_x011,6'b00_1111:
				ALUOp <= 3'h0;
				PCSrc <= (IRQ)?3'h4:3'h0;
				RegDst <= (IRQ)?2'h3:2'h1;
				RegWr <= (~OpCode[3])|OpCode[2];//lw:0x23,sw:0x2b,lui:0x0f
				ALUSrc2 <= 1;
				MemToReg <= (IRQ)?2:OpCode[5]; 
			//addi,addiu
			6'b00_100x:
				ALUOp <= 3'h0;
				PCSrc <= (IRQ)?3'h4:3'h0;
				RegDst <= (IRQ)?2'h3:2'h1;
				RegWr <= (IRQ)?1:0;
				ALUSrc2 <= 1;
				MemToReg <= (IRQ)?2:0;
			//andi
			6'b00_1100:
				ALUOp <= 3'h0;
				PCSrc <= (IRQ)?3'h4:3'h0;
				RegDst <= (IRQ)?2'h3:2'h1;
				RegWr <= (IRQ)?1:0;
				ALUSrc2 <= 1;
				MemToReg <= (IRQ)?2:0;
			//slti,sltiu
			6'b00_101x:
				ALUOp <= 3'h3;
				PCSrc <= (IRQ)?3'h4:3'h0;
				RegDst <= (IRQ)?2'h3:2'h1;
				RegWr <= (IRQ)?1:0;
				ALUSrc2 <= 1;
				MemToReg <= (IRQ)?2:0;
			//beq,bne,blez,bgtz,bgez
			6'b00_01xx, 6'b00_0001:
				ALUOp <= OpCode[2:0];
				PCSrc <= (IRQ)?3'h4:3'h1;
				RegDst <= (IRQ)?2'h3:2'h0;
				RegWr <= (IRQ)?1:0;
				ALUSrc2 <= 0;
				MemToReg <= (IRQ)?2:0;
			//j
			6'h02:
				ALUOp <= 3'h0;
				PCSrc <= (IRQ)?3'h4:3'h2;
				RegDst <= (IRQ)?2'h3:2'h2;
				RegWr <= (IRQ)?1:0;
				ALUSrc2 <= 1;
				MemToReg <= 2;
			//jal
			6'h03:
				ALUOp <= 3'h0;
				PCSrc <= (IRQ)?3'h4:3'h2;
				RegDst <= (IRQ)?2'h3:2'h2;
				RegWr <= 1;
				ALUSrc2 <= 1;
				MemToReg <= 2;
			//R-type
			6'h0:
				casex(funct)
					6'b00_0000,6'b00_001x,6'b00_100x,6'b10_0xxx,6'b10_x01x:
						ALUOp <= 3'h2;
						PCSrc <= (IRQ)?3'h4:3'h0;
						RegDst <= (IRQ)?2'h3:2'h0;
						RegWr <= 1;
						ALUSrc2 <= 0;
						MemToReg <= (IRQ)?2:0;
					//jr
					6'h08:
						ALUOp <= 3'h0;
						PCSrc <= (IRQ)?3'h4:3'h3;
						RegDst <= (IRQ)?2'h3:2'h2;
						RegWr <= (IRQ)?1:0;
						ALUSrc2 <= 1;
						MemToReg <= (IRQ)?2:0;
					//jalr
					6'h09:
						ALUOp <= 3'h0;
						PCSrc <= (IRQ)?3'h4:3'h3;
						RegDst <= (IRQ)?2'h3:2'h2;
						RegWr <= 1;
						ALUSrc2 <= 1;
						MemToReg <= (IRQ)?2:0;
					//funct undefined
					default:
						ALUOp <= 3'h0;
						PCSrc <= 3'h5;
						RegDst <= 2'h3;
						RegWr <= 1;
						ALUSrc2 <= 1;
						MemToReg <= (IRQ)?2:0;
				endcase
			//OpCode undefined
			default:
		endcase
endmodule

module ALUCtl(ALUOp, funct, ALUFun)
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