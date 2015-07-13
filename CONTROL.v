module CONTROL(
	instruct, IRQ, 
	PCSrc, RegDst, RegWr, 
	ALUSrc1, ALUSrc2, ALUOp, Sign, 
	MemWr, MemRd, MemToReg,
	EXTOp, LUOp
	);
	input [31:0] instruct;
	wire [5:0] OpCode;
	wire [5:0] funct;
	input IRQ;
	
	output reg [2:0] PCSrc;
	output reg [1:0] RegDst;
	output reg [2:0] ALUOp;
	output reg [1:0] MemToReg;
	output reg RegWr, ALUSrc2;
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
			begin
				ALUOp <= 3'h0;
				PCSrc <= (IRQ)?3'h4:3'h0;
				RegDst <= (IRQ)?2'h3:2'h1;
				RegWr <= (~OpCode[3])|OpCode[2];//lw:0x23,sw:0x2b,lui:0x0f
				ALUSrc2 <= 1;
				MemToReg <= (IRQ)?2:OpCode[5]; 
			//addi,addiu
			end
			6'b00_100x:
			begin
				ALUOp <= 3'h0;
				PCSrc <= (IRQ)?3'h4:3'h0;
				RegDst <= (IRQ)?2'h3:2'h1;
				RegWr <= (IRQ)?1:0;
				ALUSrc2 <= 1;
				MemToReg <= (IRQ)?2:0;
			end
			//andi
			6'b00_1100:
			begin
				ALUOp <= 3'h0;
				PCSrc <= (IRQ)?3'h4:3'h0;
				RegDst <= (IRQ)?2'h3:2'h1;
				RegWr <= (IRQ)?1:0;
				ALUSrc2 <= 1;
				MemToReg <= (IRQ)?2:0;
			end
			//slti,sltiu
			6'b00_101x:
			begin
				ALUOp <= 3'h3;
				PCSrc <= (IRQ)?3'h4:3'h0;
				RegDst <= (IRQ)?2'h3:2'h1;
				RegWr <= (IRQ)?1:0;
				ALUSrc2 <= 1;
				MemToReg <= (IRQ)?2:0;
			end
			//beq,bne,blez,bgtz,bgez
			6'b00_01xx, 6'b00_0001:
			begin
				ALUOp <= OpCode[2:0];
				PCSrc <= (IRQ)?3'h4:3'h1;
				RegDst <= (IRQ)?2'h3:2'h0;
				RegWr <= (IRQ)?1:0;
				ALUSrc2 <= 0;
				MemToReg <= (IRQ)?2:0;
			end
			//j
			6'h02:
			begin
				ALUOp <= 3'h0;
				PCSrc <= (IRQ)?3'h4:3'h2;
				RegDst <= (IRQ)?2'h3:2'h2;
				RegWr <= (IRQ)?1:0;
				ALUSrc2 <= 1;
				MemToReg <= 2;
			end
			//jal
			6'h03:
			begin
				ALUOp <= 3'h0;
				PCSrc <= (IRQ)?3'h4:3'h2;
				RegDst <= (IRQ)?2'h3:2'h2;
				RegWr <= 1;
				ALUSrc2 <= 1;
				MemToReg <= 2;
			end
			//R-type
			6'h0:
				casex(funct)
					6'b00_0000,6'b00_001x,6'b00_100x,6'b10_0xxx,6'b10_x01x:
					begin	
						ALUOp <= 3'h2;
						PCSrc <= (IRQ)?3'h4:3'h0;
						RegDst <= (IRQ)?2'h3:2'h0;
						RegWr <= 1;
						ALUSrc2 <= 0;
						MemToReg <= (IRQ)?2:0;
					end
					//jr
					6'h08:
					begin
						ALUOp <= 3'h0;
						PCSrc <= (IRQ)?3'h4:3'h3;
						RegDst <= (IRQ)?2'h3:2'h2;
						RegWr <= (IRQ)?1:0;
						ALUSrc2 <= 1;
						MemToReg <= (IRQ)?2:0;
					end
					//jalr
					6'h09:
					begin
						ALUOp <= 3'h0;
						PCSrc <= (IRQ)?3'h4:3'h3;
						RegDst <= (IRQ)?2'h3:2'h2;
						RegWr <= 1;
						ALUSrc2 <= 1;
						MemToReg <= (IRQ)?2:0;
					end
					//funct undefined
					default:
					begin
						ALUOp <= 3'h0;
						PCSrc <= 3'h5;
						RegDst <= 2'h3;
						RegWr <= 1;
						ALUSrc2 <= 1;
						MemToReg <= 2;
					end
				endcase
			//OpCode undefined
			default:
			begin
				ALUOp <= 3'h0;
				PCSrc <= 3'h5;
				RegDst <= 2'h3;
				RegWr <= 1;
				ALUSrc2 <= 1;
				MemToReg <= 2;
			end
		endcase
endmodule
