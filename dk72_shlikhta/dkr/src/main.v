`timescale 1us/1ns

module main(CLOCK_50, GPIO_0, SW, LEDR, HEX1, HEX2, HEX3, KEY);

input CLOCK_50;
input [0:0] SW;
input [0:0] KEY;
//input in;


output [6:0] HEX1;
output [6:0] HEX2;
output [6:0] HEX3;
output [2:0] LEDR;
//output out;

inout [1:0] GPIO_0;

wire [15:0] temperature;
wire in;
wire out;
wire clk;


assign GPIO_0[1] = out ? 1'bz : 1'b0;
assign in = GPIO_0[1];

assign LEDR[0] = temperature[12];
assign LEDR[1] = SW[0];


//clock_div clock_div_0(CLOCK_50, clk, 50);

mypll mypll_0(
		 CLOCK_50,   //  refclk.clk
		!KEY[0],      //   reset.reset
		clk, // outclk0.clk
		LEDR[2]    //  locked.export
	);


termometer ds18b20(in, out, clk, KEY[0], SW[0], temperature);

dec_7seg dec_7seg_0(temperature[3:0], HEX3);

dec_7seg dec_7seg_1(temperature[7:4], HEX2);

dec_7seg dec_7seg_2(temperature[11:8], HEX1);

endmodule


