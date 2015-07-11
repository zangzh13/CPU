module control(
	OpCode, funct, IRQ, 
	PCSrc, RegDst, RegWr, 
	ALUSrc1, ALUSrc2, ALUFun, Sign, 
	MemWr, MemRd, MemToReg,
	EXTOp, LUOp
	)
	input [31:0] instruct;
	wire [5:0] OpCode;
	wire [5:0] funct;
	input IRQ;
	output [2:0] PCSrc;
	output [1:0] RegDst;
	output RegWr, ALUSrc1, ALUSrc2, ALUFun, Sign, MemWr, MemRd;
	output [1:0] MemToReg;
	output EXTOp, LUOp;
	
	assign OpCode = instruct[31:26];
	assign funct = instruct[5:0];
	
	always @(*)
		case(OpCode)
			//lw
			6'h23:
			//sw
			6'h2b:
			//lui
			6'h2f:
			//addi
			6'h08:
			//addiu
			6'h09:
			//andi
			6'h0c
			//slti
			6'h0a:
			//sltiu
			6'h0b:
			//beq
			6'h04:
			//bne
			6'h05:
			//blez
			6'h06:
			//bgtz
			6'h07:
			//bgez
			6'h01:
			//j
			6'h02:
			//jal
			6'h03:
			//
			6'h0:
				case(funct)
					//add
					6'h20:
					//addu
					6'h21:
					//sub
					6'h22:
					//subu
					6'h23:
					//and
					6'h24:
					//or
					6'h25:
					//xor
					6'h26:
					//nor
					6'h27:
					//sll，nop
					6'h00:
					//srl
					6'h02:
					//sra
					6'h03:
					//slt
					6'h2a:
					//sltu
					6'h2b:
					//jr
					6'h08:
					//jalr
					6'h09:
	assign PCSrc = (OpCode == 6'h4 || OpCode == 6'h5 || OpCode == 6'h6 || OpCode == 6'h7 || OpCode == 6'h1)?1:
					(OpCode ==6'h2 || OpCode == 6'h3)?2:
					(OpCode == 6'h23 || OpCode == 6'h2b || OpCode == 6'hf || OpCode == 6'h8 ||
						OpCode == 6'h9 || OpCode == 6'hc || OpCode == 6'ha || OpCode == 6'hb ||)?0:
					(OpCode == 0)?
						(funct == 0 || funct == 6'h20 || funct == 6'h21 || funct == 6'h22 ||
							funct == 6'h23 || funct == 6'h24 ||)