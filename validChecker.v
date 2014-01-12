module validChecker(clock, dest3, dest2, dest1, dest0, ValidBit3, ValidBit2, ValidBit1, ValidBit0, nand32, nand31, nand30,
			nand21,nand20,nand10);

// inputs
input [1:0] dest3, dest2, dest1, dest0;
input clock;

// outputs
output ValidBit3, ValidBit2, ValidBit1, ValidBit0, nand32, nand31, nand30, nand21, nand20, nand10;

// regs and nets
reg Valid3, Valid2, Valid1, Valid0;

always@(posedge clock)
	begin
	Valid3 <= nand32 & nand31 & nand30;
	Valid2 <= nand32 & nand21 & nand20;
	Valid1 <= nand31 & nand21 & nand10;
	Valid0 <= nand30 & nand20 & nand10;
	end

assign nand32 = ~&(dest3~^dest2);
assign nand31 = ~&(dest3~^dest1);
assign nand30 = ~&(dest3~^dest0);
assign nand21 = ~&(dest2~^dest1);
assign nand20 = ~&(dest2~^dest0);
assign nand10 = ~&(dest1~^dest0);

assign ValidBit3 = Valid3;
assign ValidBit2 = Valid2;
assign ValidBit1 = Valid1;
assign ValidBit0 = Valid0;

endmodule
