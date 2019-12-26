`timescale 1us/1ns

`define SKIP_ROM 8'hCC
`define MATCH_ROM 8'h55
`define READ_ROM 8'h33
`define SEARCH_ROM 8'hF0

`define CONVER_T 8'h44

module termometer(DIn, DOut, clk, ARstN, En, temp);

input DIn;
input clk;
input ARstN;
input En;

output DOut;
output [15:0] temp;

localparam START = 0;
localparam RESET = 1;
localparam SKIP = 2;
localparam CONVERT = 3;
localparam WAIT = 4;
localparam RESET_WAIT = 5;
localparam SKIP_WAIT = 6;
localparam CONVERT_WAIT = 7;
localparam READ_SCRATCHCPAD_FB = 8;
localparam READ_SCRATCHCPAD_FB_WAIT = 9;
localparam READ_SCRATCHCPAD_SB = 10;
localparam READ_SCRATCHCPAD_SB_WAIT = 11;
localparam RESET_AFTER_READ = 12;
localparam RESET_AFTER_READ_WAIT = 13;

localparam COUNTER_FOR_MAIN_WAIT = 750000; //it's time for convertion of temperature 750ms


wire Busy;
wire [7:0] OutData;
wire Presence;
wire [7:0] InData_W;

wire [15:0] temp_buf;

reg [7:0] InData;
reg ResetN;
reg R;
reg W;

reg [7:0] state;
reg [15:0] temperature;
reg [31:0] counter;

assign InData_W =  InData;

// assign temp_buf = temperature & 16'h07FF;
// assign temp[3:0]  = (temp_buf[3:0] * 10) >> 4;
// assign temp[7:4] = (((temp_buf[7:4] * 10) >> 4) >= 4'd10) ? (((temp_buf[7:4] * 10) >> 4) - 'd10) : ((temp_buf[7:4] * 10) >> 4);
// assign temp[11:8] = (((temp_buf[7:4] * 10) >> 4) >= 4'd10) ? (((temp_buf[11:8] * 10) >> 4) + 'd1) + 'd2 : ((temp_buf[11:8] * 10) >> 4) + 'd2;

assign temp[3:0] = temperature[7:4];
assign temp[7:4] = temperature[11:8];

assign temp[15:12] = temperature[12] ? 1 : 0;

one_wire one_wire_0(DIn, DOut, Busy, InData_W, OutData, ResetN, R, W, clk, Presence);

always @(posedge clk or negedge ARstN) begin
	if(!ARstN)begin
		state = START;
		ResetN <= 1;
		W <= 0;
		R <= 0;
		counter = 0;
	end

	casez(state)
		START:begin
			ResetN <= 1;

			if(En)
				state = RESET;
		end

		RESET: begin
			ResetN <= 0;
			state = RESET_WAIT;
		end

		RESET_WAIT: begin
			if(Busy)
				ResetN <= 1;
			else if(!Busy && Presence && ResetN)
				state = SKIP;
			else if(!Presence)
				state = START;			
		end

		SKIP: begin
			InData = `SKIP_ROM;
			W <= 1;
			state = SKIP_WAIT;
		end

		SKIP_WAIT: begin
			if(Busy)
				W <= 0;
			if(!Busy && !W)
				state = CONVERT;			
		end

		CONVERT: begin
			InData = `CONVER_T;
			W <= 1;
			state = CONVERT_WAIT;

		end

		CONVERT_WAIT: begin
			if(Busy)
				W <= 0;

			if(!Busy && !W)
				state = WAIT;			
		end

		WAIT: begin
			if(counter == COUNTER_FOR_MAIN_WAIT) begin
				counter = 0;
				state = READ_SCRATCHCPAD_FB;
			end
			else
				counter = counter + 1;
		end

		READ_SCRATCHCPAD_FB: begin
			R <= 1;
			state = READ_SCRATCHCPAD_FB_WAIT;
		end

		READ_SCRATCHCPAD_FB_WAIT: begin
			if(Busy)
				R <= 0;

			if(!Busy && !R)begin
				temperature[7:0] = OutData;
				state = READ_SCRATCHCPAD_SB;	
			end			
		end

		READ_SCRATCHCPAD_SB: begin
			R <= 1;
			state = READ_SCRATCHCPAD_SB_WAIT;
		end

		READ_SCRATCHCPAD_SB_WAIT: begin
			if(Busy)
				R <= 0;

			if(!Busy && !R)begin
				temperature[15:8] = OutData;
				state = RESET_AFTER_READ;	
			end			
		end

		RESET_AFTER_READ: begin
			ResetN <= 0;
			state = RESET_AFTER_READ_WAIT;
		end

		RESET_AFTER_READ_WAIT: begin
			if(Busy)
				ResetN <= 1;
			else if(!Busy && ResetN)
				state = START;		
		end

	endcase
end

endmodule
