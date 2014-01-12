module packetIn(reset,start,packet3,packet2,packet1,packet0,clock,fourth,dest3, dest2, dest1, dest0, in3, in2, in1, in0,
		Valid3,Valid2,Valid1,Valid0,old3,old2,old1,old0,go);

// inputs
input [7:0] packet3,packet2,packet1,packet0;
input fourth, clock, start, reset, Valid3, Valid2, Valid1, Valid0;

// outputs
output [1:0] dest3, dest2, dest1, dest0;
output [7:0] in3, in2, in1, in0;
output old3,old2,old1,old0,go;

// nets and registers
reg [7:0] PacketIn3, PacketIn2, PacketIn1, PacketIn0;
reg [1:0] Destination3, Destination2, Destination1, Destination0;
reg oldflag3,oldflag2,oldflag1,oldflag0;
reg goFlag;
reg resetGoFlag;

always@(*)
	casex ({start,reset,fourth,resetGoFlag})
	4'b1xxx : goFlag <= 1'b1;
	4'b01xx : goFlag <= 1'b0;
	4'b0011 : goFlag <= 1'b1;
	4'b0010 : goFlag <= goFlag;
	4'b0001 : goFlag <= goFlag;
	4'b0000 : goFlag <= goFlag;
	endcase


always@(posedge clock)
	begin
	if (fourth)
	begin
		if (goFlag)
		resetGoFlag <= 1'b0;
		else
		resetGoFlag <= 1'b1;
	Destination3 <= packet3[1:0];
	Destination2 <= packet2[1:0];
	Destination1 <= packet1[1:0];
	Destination0 <= packet0[1:0];
	if (!Valid3)
		oldflag3 <= 1'b1;
	else
		oldflag3 <= 1'b0;
	if (!Valid2)
		oldflag2 <= 1'b1;
	else
		oldflag2 <= 1'b0;
	if (!Valid1)
		oldflag1 <= 1'b1;
	else
		oldflag1 <= 1'b0;
	if (!Valid0)
		oldflag0 <= 1'b1;
	else
		oldflag0 <= 1'b0;
	end
	end

always@(posedge clock)
	begin
	PacketIn3 <= packet3;
	PacketIn2 <= packet2;
	PacketIn1 <= packet1;
	PacketIn0 <= packet0;
	end

assign in3 = (Valid3 | old3) & !reset & (goFlag) ? PacketIn3 : 8'hxx;
assign in2 = (Valid2 | old2) & !reset & (goFlag) ? PacketIn2 : 8'hxx;
assign in1 = (Valid1 | old1) & !reset & (goFlag) ? PacketIn1 : 8'hxx;
assign in0 = (Valid0 | old0) & !reset & (goFlag) ? PacketIn0 : 8'hxx;
assign dest3 = (Valid3 | old3) & !reset & (goFlag) ? Destination3 : 2'bxx;
assign dest2 = (Valid2 | old2) & !reset & (goFlag) ? Destination2 : 2'bxx;
assign dest1 = (Valid1 | old1) & !reset & (goFlag) ? Destination1 : 2'bxx;
assign dest0 = (Valid0 | old0) & !reset & (goFlag) ? Destination0 : 2'bxx;
assign old3 = oldflag3;
assign old2 = oldflag2;
assign old1 = oldflag1;
assign old0 = oldflag0;
assign go = goFlag;

endmodule

module fourCounter (start,clock,reset,enable,fourth);

// inputs

input clock,reset,enable,start;

// outputs

output fourth;

// nets and registers

reg [1:0] value;
reg carryout;

always@(posedge clock)
	begin
	if (start)
		begin
		value <= 2'b00;
		//carryout <= 1'b1;
		end
	else if (&value)
		begin
		//carryout <= 1'b1;
		value <= value + 1'b1;
		end
	else if (enable)
		begin
		value <= value + 1'b1;
		//carryout <= 1'b0;
		end
	end

always@(negedge clock)
	begin
	if (start)
		carryout <= 1'b1;
	else if (&value)
		carryout <= 1'b1;
	else if (enable)
		carryout <= 1'b0;
	end


assign fourth = carryout;

endmodule

module validChecker(start,reset,clock,fourth, dest3, dest2, dest1, dest0, ValidBit3, ValidBit2, ValidBit1, ValidBit0, 
			nand32, nand31,nand30,nand21,nand20,nand10,old3,old2,old1,old0,go);

// inputs
input [1:0] dest3, dest2, dest1, dest0;
input clock,fourth,start,reset,old3,old2,old1,old0,go;

// outputs
output ValidBit3, ValidBit2, ValidBit1, ValidBit0, nand32, nand31, nand30, nand21, nand20, nand10;

// regs and nets
reg Valid3, Valid2, Valid1, Valid0;

always@(posedge clock)
	if (fourth)
	begin
	begin 
	if (start | reset | !go)
		begin
		Valid3 <= 1'b1;
		Valid2 <= 1'b1;
		Valid1 <= 1'b1;
		Valid0 <= 1'b1;
		end
	else
		begin
		if (!ValidBit3)
			Valid3 <= 1'b1;
		else
			Valid3 <= nand32 & nand31 & nand30;
		if (!ValidBit2)
			Valid2 <= 1'b1;
		else
			Valid2 <= nand32 & nand21 & nand20;
		if (!ValidBit1)
			Valid1 <= 1'b1;
		else
			Valid1 <= nand31 & nand21 & nand10;
		if (!ValidBit0)
			Valid0 <= 1'b1;
		else
			Valid0 <= nand30 & nand20 & nand10;
		end
	end
	end

assign nand32 = ((Valid3 & Valid2) | (old3 & old2)) ? ~&(dest3~^dest2) : nand32;
assign nand31 = ((Valid3 & Valid1) | (old3 & old1)) ? ~&(dest3~^dest1) : nand31;
assign nand30 = ((Valid3 & Valid0) | (old3 & old0)) ? ~&(dest3~^dest0) : nand30;
assign nand21 = ((Valid2 & Valid1) | (old2 & old1)) ? ~&(dest2~^dest1) : nand21;
assign nand20 = ((Valid2 & Valid0) | (old2 & old0)) ? ~&(dest2~^dest0) : nand20;
assign nand10 = ((Valid1 & Valid0) | (old1 & old0)) ? ~&(dest1~^dest0) : nand10;

assign ValidBit3 = Valid3;
assign ValidBit2 = Valid2;
assign ValidBit1 = Valid1;
assign ValidBit0 = Valid0;

endmodule

module collisionChecker(start,reset,clock,fourth,dest3,dest2,dest1,dest0,nand32,nand31,nand30,
			nand21,nand20,nand10,Collision3,Collision2,Collision1,Collision0,old3,old2,old1,old0,go);

// inputs
input [1:0] dest3,dest2,dest1,dest0;
input clock,fourth,nand32,nand31,nand30,nand21,nand20,nand10,start,reset,old3,old2,old1,old0,go;

// outputs
output Collision3,Collision2,Collision1,Collision0;

// regs and nets
reg collide3,collide2,collide1,collide0;
reg nand323,nand322,nand321,nand320,nand313,nand312,nand311,nand310,nand303,nand302,nand301,nand300,
	nand213,nand212,nand211,nand210,nand203,nand202,nand201,nand200,nand103,nand102,nand101,nand100;
reg [7:0] PacketOut3,PacketOut2,PacketOut1,PacketOut0;

always@(*)
	case (dest3)
	2'b00 : begin
		nand320 <= ~nand32;
		nand321 <= 1'b0;
		nand322 <= 1'b0;
		nand323 <= 1'b0;
		nand310 <= ~nand31;
		nand311 <= 1'b0;
		nand312 <= 1'b0;
		nand313 <= 1'b0;
		nand300 <= ~nand30;
		nand301 <= 1'b0;
		nand302 <= 1'b0;
		nand303 <= 1'b0;
		end
	2'b01 : begin
		nand320 <= 1'b0;
		nand321 <= ~nand32;
		nand322 <= 1'b0;
		nand323 <= 1'b0;
		nand310 <= 1'b0;
		nand311 <= ~nand31;
		nand312 <= 1'b0;
		nand313 <= 1'b0;
		nand300 <= 1'b0;
		nand301 <= ~nand30;
		nand302 <= 1'b0;
		nand303 <= 1'b0;
		end
	2'b10 : begin
		nand320 <= 1'b0;
		nand321 <= 1'b0;
		nand322 <= ~nand32;
		nand323 <= 1'b0;
		nand310 <= 1'b0;
		nand311 <= 1'b0;
		nand312 <= ~nand31;
		nand313 <= 1'b0;
		nand300 <= 1'b0;
		nand301 <= 1'b0;
		nand302 <= ~nand30;
		nand303 <= 1'b0;
		end
	2'b11 : begin
		nand323 <= ~nand32;
		nand322 <= 1'b0;
		nand321 <= 1'b0;
		nand320 <= 1'b0;
		nand313 <= ~nand31;
		nand312 <= 1'b0;
		nand311 <= 1'b0;
		nand310 <= 1'b0;
		nand303 <= ~nand30;
		nand302 <= 1'b0;
		nand301 <= 1'b0;
		nand300 <= 1'b0;
		end
	endcase

always@(*)
	case (dest2)
	2'b00 : begin
		nand210 <= ~nand21;
		nand211 <= 1'b0;
		nand212 <= 1'b0;
		nand213 <= 1'b0;
		nand200 <= ~nand20;
		nand201 <= 1'b0;
		nand202 <= 1'b0;
		nand203 <= 1'b0;
		end
	2'b01 : begin
		nand211 <= ~nand21;
		nand212 <= 1'b0;
		nand213 <= 1'b0;
		nand210 <= 1'b0;
		nand201 <= ~nand20;
		nand202 <= 1'b0;
		nand203 <= 1'b0;
		nand200 <= 1'b0;
		end
	2'b10 : begin
		nand212 <= ~nand21;
		nand213 <= 1'b0;
		nand211 <= 1'b0;
		nand210 <= 1'b0;
		nand202 <= ~nand20;
		nand203 <= 1'b0;
		nand201 <= 1'b0;
		nand200 <= 1'b0;
		end
	2'b11 : begin
		nand213 <= ~nand21;
		nand212 <= 1'b0;
		nand211 <= 1'b0;
		nand210 <= 1'b0;
		nand203 <= ~nand20;
		nand202 <= 1'b0;
		nand201 <= 1'b0;
		nand200 <= 1'b0;
		end
	endcase

always@(*)
	case (dest0)
	2'b00 : begin
		nand100 <= ~nand10;
		nand101 <= 1'b0;
		nand102 <= 1'b0;
		nand103 <= 1'b0;
		end
	2'b01 : begin
		nand101 <= ~nand10;
		nand102 <= 1'b0;
		nand103 <= 1'b0;
		nand100 <= 1'b0;
		end
	2'b10 : begin
		nand102 <= ~nand10;
		nand103 <= 1'b0;
		nand101 <= 1'b0;
		nand100 <= 1'b0;
		end
	2'b11 : begin
		nand103 <= ~nand10;
		nand102 <= 1'b0;
		nand101 <= 1'b0;
		nand100 <= 1'b0;
		end
	endcase
		

always@(posedge clock)
	if (fourth)
	begin
	if (start | reset | !go)
		begin
		collide3 <= 1'b0;
		collide2 <= 1'b0;
		collide1 <= 1'b0;
		collide0 <= 1'b0;
		end
	else
		begin
		collide3 <= nand323 | nand313 | nand303 | nand213 | nand203 | nand103;
		collide2 <= nand322 | nand312 | nand302 | nand212 | nand202 | nand102;
		collide1 <= nand321 | nand311 | nand301 | nand211 | nand201 | nand101;
		collide0 <= nand320 | nand310 | nand300 | nand210 | nand200 | nand100;
		end
	end

assign Collision3 = (old3 | old2 | old1 | old0) ? 1'b0 : collide3;
assign Collision2 = (old3 | old2 | old1 | old0) ? 1'b0 : collide2;
assign Collision1 = (old3 | old2 | old1 | old0) ? 1'b0 : collide1;
assign Collision0 = (old3 | old2 | old1 | old0) ? 1'b0 : collide0;

endmodule

module packetOut(clock,nand32,nand31,nand30,nand21,nand20,nand10,dest3,dest2,dest1,dest0,in3,in2,in1,in0,
		collision3,collision2,collision1,collision0,out3,out2,out1,out0);

// inputs
input clock,nand32,nand31,nand30,nand21,nand20,nand10,collision3,collision2,collision1,collision0;
input [7:0] in3,in2,in1,in0;
input [1:0] dest3,dest2,dest1,dest0;

// outputs
output [7:0] out3,out2,out1,out0;

// nets and registers
reg [7:0] PacketOut3,PacketOut2,PacketOut1,PacketOut0,Out3Buffer1,Out3Buffer2,Out3Buffer3
	,Out2Buffer1,Out2Buffer2,Out2Buffer3,Out1Buffer1,Out1Buffer2,Out1Buffer3,Out0Buffer1,
	Out0Buffer2,Out0Buffer3,route33,route32,route31,route30,route23,route22,route21,route20,
	iroute23,iroute22,iroute21,iroute20,route13,route12,route11,route10,
	iroute13,iroute12,iroute11,iroute10,route03,route02,route01,route00,iroute03,
	iroute02,iroute01,iroute00,valid2,invalid2,
	valid1,invalid1,valid0,invalid0,Out3Buffer4,Out2Buffer4,Out1Buffer4,Out0Buffer4;

always@(*)
	case (dest3)
	2'b00 : begin
		route33 <= 8'h00;
		route32 <= 8'h00;
		route31 <= 8'h00;
		route30 <= in3;
		end
	2'b01 : begin
		route33 <= 8'h00;
		route32 <= 8'h00;
		route31 <= in3;
		route30 <= 8'h00;
		end
	2'b10 : begin
		route33 <= 8'h00;
		route32 <= in3;
		route31 <= 8'h00;
		route30 <= 8'h00;
		end
	2'b11 : begin
		route33 <= in3;
		route32 <= 8'h00;
		route31 <= 8'h00;
		route30 <= 8'h00;
		end
	endcase

always@(*)
	begin
	if (nand32)
		begin
		iroute23 <= 8'h00;
		iroute22 <= 8'h00;
		iroute21 <= 8'h00;
		iroute20 <= 8'h00;
		case (dest2)
	2'b00 : begin
		route23 <= 8'h00;
		route22 <= 8'h00;
		route21 <= 8'h00;
		route20 <= in2;
		end
	2'b01 : begin
		route23 <= 8'h00;
		route22 <= 8'h00;
		route21 <= in2;
		route20 <= 8'h00;
		end
	2'b10 : begin
		route23 <= 8'h00;
		route22 <= in2;
		route21 <= 8'h00;
		route20 <= 8'h00;
		end
	2'b11 : begin
		route23 <= in2;
		route22 <= 8'h00;
		route21 <= 8'h00;
		route20 <= 8'h00;
		end
		endcase	
		end
	else
		begin
		route23 <= 8'h00;
		route22 <= 8'h00;
		route21 <= 8'h00;
		route20 <= 8'h00;
		case (dest2)
	2'b00 : begin
		iroute23 <= 8'h00;
		iroute22 <= 8'h00;
		iroute21 <= 8'h00;
		iroute20 <= in2;
		end
	2'b01 : begin
		iroute23 <= 8'h00;
		iroute22 <= 8'h00;
		iroute21 <= in2;
		iroute20 <= 8'h00;
		end
	2'b10 : begin
		iroute23 <= 8'h00;
		iroute22 <= in2;
		iroute21 <= 8'h00;
		iroute20 <= 8'h00;
		end
	2'b11 : begin
		iroute23 <= in2;
		iroute22 <= 8'h00;
		iroute21 <= 8'h00;
		iroute20 <= 8'h00;
		end
		endcase
		end
	end

always@(*)
	begin
	if (nand31 & nand21)
		begin
		iroute13 <= 8'h00;
		iroute12 <= 8'h00;
		iroute11 <= 8'h00;
		iroute10 <= 8'h00;
		case (dest1)
	2'b00 : begin
		route13 <= 8'h00;
		route12 <= 8'h00;
		route11 <= 8'h00;
		route10 <= in1;
		end
	2'b01 : begin
		route13 <= 8'h00;
		route12 <= 8'h00;
		route11 <= in1;
		route10 <= 8'h00;
		end
	2'b10 : begin
		route13 <= 8'h00;
		route12 <= in1;
		route11 <= 8'h00;
		route10 <= 8'h00;
		end
	2'b11 : begin
		route13 <= in1;
		route12 <= 8'h00;
		route11 <= 8'h00;
		route10 <= 8'h00;
		end
		endcase
		end	
	else
		begin
		route13 <= 8'h00;
		route12 <= 8'h00;
		route11 <= 8'h00;
		route10 <= 8'h00;
		case (dest1)
	2'b00 : begin
		iroute13 <= 8'h00;
		iroute12 <= 8'h00;
		iroute11 <= 8'h00;
		iroute10 <= in1;
		end
	2'b01 : begin
		iroute13 <= 8'h00;
		iroute12 <= 8'h00;
		iroute11 <= in1;
		iroute10 <= 8'h00;
		end
	2'b10 : begin
		iroute13 <= 8'h00;
		iroute12 <= in1;
		iroute11 <= 8'h00;
		iroute10 <= 8'h00;
		end
	2'b11 : begin
		iroute13 <= in1;
		iroute12 <= 8'h00;
		iroute11 <= 8'h00;
		iroute10 <= 8'h00;
		end
		endcase
		end
	end

always@(*)
	begin
	if (nand30 & nand20 & nand10)
		begin
		iroute03 <= 8'h00;
		iroute02 <= 8'h00;
		iroute01 <= 8'h00;
		iroute00 <= 8'h00;
		case (dest0)
	2'b00 : begin
		route03 <= 8'h00;
		route02 <= 8'h00;
		route01 <= 8'h00;
		route00 <= in0;
		end
	2'b01 : begin
		route03 <= 8'h00;
		route02 <= 8'h00;
		route01 <= in0;
		route00 <= 8'h00;
		end
	2'b10 : begin
		route03 <= 8'h00;
		route02 <= in0;
		route01 <= 8'h00;
		route00 <= 8'h00;
		end
	2'b11 : begin
		route03 <= in0;
		route02 <= 8'h00;
		route01 <= 8'h00;
		route00 <= 8'h00;
		end
		endcase
		end	
	else
		begin
		route03 <= 8'h00;
		route02 <= 8'h00;
		route01 <= 8'h00;
		route00 <= 8'h00;
		case (dest0)
	2'b00 : begin
		iroute03 <= 8'h00;
		iroute02 <= 8'h00;
		iroute01 <= 8'h00;
		iroute00 <= in0;
		end
	2'b01 : begin
		iroute03 <= 8'h00;
		iroute02 <= 8'h00;
		iroute01 <= in0;
		iroute00 <= 8'h00;
		end
	2'b10 : begin
		iroute03 <= 8'h00;
		iroute02 <= in0;
		iroute01 <= 8'h00;
		iroute00 <= 8'h00;
		end
	2'b11 : begin
		iroute03 <= in0;
		iroute02 <= 8'h00;
		iroute01 <= 8'h00;
		iroute00 <= 8'h00;
		end
		endcase
		end
	end

always@(posedge clock)
	begin
	Out3Buffer1 <= iroute23 | iroute13 | iroute03;
	Out2Buffer1 <= iroute22 | iroute12 | iroute02;
	Out1Buffer1 <= iroute21 | iroute11 | iroute01;
	Out0Buffer1 <= iroute20 | iroute10 | iroute00;
	Out3Buffer2 <= Out3Buffer1;
	Out3Buffer3 <= Out3Buffer2;
	Out2Buffer2 <= Out2Buffer1;
	Out2Buffer3 <= Out2Buffer2;
	Out1Buffer2 <= Out1Buffer1;
	Out1Buffer3 <= Out1Buffer2;
	Out0Buffer2 <= Out0Buffer1;
	Out0Buffer3 <= Out0Buffer2;
	Out3Buffer4 <= Out3Buffer3;
	Out2Buffer4 <= Out2Buffer3;
	Out1Buffer4 <= Out1Buffer3;
	Out0Buffer4 <= Out0Buffer3;
	end

always@(posedge clock)
	begin
	if (collision3)
		PacketOut3 <= Out3Buffer4;
	else
		PacketOut3 <= (route33 | route23 | route13 | route03);
	if (collision2)
		PacketOut2 <= Out2Buffer4;
	else
		PacketOut2 <= (route32 | route22 | route12 | route02);
	if (collision1)
		PacketOut1 <= Out1Buffer4;
	else
		PacketOut1 <= (route31 | route21 | route11 | route01);
	if (collision0)
		PacketOut0 <= Out0Buffer4;
	else
		PacketOut0 <= (route30 | route20 | route10 | route00);
	end

assign out3 = PacketOut3;
assign out2 = PacketOut2;
assign out1 = PacketOut1;
assign out0 = PacketOut0;

endmodule
		
	

	
