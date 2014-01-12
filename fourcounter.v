module fourcounter (clock,reset,enable,fourth);

// inputs

input clock;
input reset;
input enable;

// outputs

output fourth;

// nets and registers

reg [1:0] value = 2'b00;
reg carryout = 1'b0;

always@(posedge clock)
	begin
	if (reset)
		begin
		value <= 2'b00;
		carryout <= 1'b0;
		end
	else if (&value)
		begin
		carryout <= 1'b1;
		value <= value + 1'b1;
		end
	else if (enable)
		begin
		value <= value + 1'b1;
		carryout <= 1'b0;
		end
	end

assign fourth = carryout;

endmodule
