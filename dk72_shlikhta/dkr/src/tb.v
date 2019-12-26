`timescale 1us/1ns

module tb();

reg CLOCK_27;
reg [0:0] SW;
reg [0:0] KEY;
reg in;


wire [6:0] HEX1;
wire [6:0] HEX2;
wire [6:0] HEX3;
wire [1:0] LEDR;
wire out;

wire [0:0] GPIO;

wire outp;
//wire in;

main main_0(CLOCK_27, GPIO, SW, LEDR, HEX1, HEX2, HEX3, KEY, in, out);

//assign in = GPIO[0];
assign GPIO[0] =  out ? 1'bz : 0;

initial begin
	CLOCK_27 = 0;
	forever #0.5 CLOCK_27 = ~CLOCK_27;
end

initial begin
	KEY[0] = 0;
	#10 KEY[0] = 1;

	SW = 1;
	in = 1;
	//GPIO[0] = 1;

	#2500 in = 0;
	//GPIO[0] = 0;

	#2000000 $stop();
	
end

endmodule
