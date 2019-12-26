`timescale 1us/1ns

module main(CLOCK_27, GPIO, SW, LEDR, HEX1, HEX2, HEX3, KEY, in, out);

input CLOCK_27;
input [0:0] SW;
input [0:0] KEY;
input in;


output [6:0] HEX1;
output [6:0] HEX2;
output [6:0] HEX3;
output [1:0] LEDR;
output out;

inout [0:0] GPIO;

wire [15:0] temperature;
reg inp;
wire outp;
wire clk;
//wire in;


assign GPIO[0] = out ? 1'bz : 1'b0;
assign LEDR[0] = temperature[12];
assign LEDR[1] = SW[0];

always @* begin
	inp <= GPIO[0];
end


//clock_div clock_div_0(CLOCK_27, clk, 27);

assign clk = CLOCK_27;

termometer ds18b20(in, out, clk, KEY[0], SW[0], temperature);

dec_7seg dec_7seg_0(temperature[3:0], HEX3);

dec_7seg dec_7seg_1(temperature[7:4], HEX2);

dec_7seg dec_7seg_2(temperature[11:8], HEX1);

endmodule


module clock_div(in_clock, out_clock, divider);
	input in_clock;
	input [9:0] divider;

	output reg out_clock;

	reg [9:0] counter;

	always @(posedge in_clock) begin
		if(!out_clock)
			counter = counter + 1;
		else
			counter = 0;
	end

	always @(posedge in_clock) begin
		out_clock <= (counter == divider-1);

	end

endmodule
