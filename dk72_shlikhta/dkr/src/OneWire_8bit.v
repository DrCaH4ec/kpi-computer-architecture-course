`timescale 1ns/1ps

module one_wire(WireIn, WireOut, busy, InData, OutData, SRstN, ReadData, WriteData, clk, presence);

localparam START = 0;
localparam DELAY_RESET = 1;
localparam WIRE_READ_PRESENCE = 2;
localparam WIRE_0 = 3;
localparam WIRE_WRITE = 4;
localparam WIRE_READ = 5;
localparam DELAY = 6;

localparam DELAY_RESET_COUNTER = 480;					//480us
localparam WIRE_READ_PRESENCE_COUNTER = 70;				//70us
localparam WRITE_DATA_COUNTER = 50;						//50us
localparam READ_DATA_COUNTER = 6;						//6us

localparam DATA_WIDTH = 8;


input WireIn;
input [DATA_WIDTH-1:0] InData;
input SRstN;
input ReadData;
input WriteData;
input clk;

output reg WireOut;
output reg busy;
output reg [DATA_WIDTH-1:0] OutData;
output reg presence;

reg [9:0] Counter;
reg CountEnable;
reg [7:0] state;
reg [7:0] CountBit;
reg rw; //0 - read, 1 - write

initial begin
	state = START;
	CountBit = 0;
	presence = 0;
	busy = 0;
end

always @(posedge clk) begin
	casez(state)
		START: begin
			WireOut <= 1;
			busy <= 0;
			CountEnable <= 0;
			if(!SRstN)begin
				busy <= 1;
				presence <= 0;
				state = DELAY_RESET;
			end
			else if(WriteData)begin
				rw = 1;
				busy <= 1;
				state = WIRE_0;
			end
			else if(ReadData) begin
				rw = 0;
				busy <= 1;
				state = WIRE_0;
			end
		end

		DELAY_RESET: begin
			WireOut <= 0;
			CountEnable <= 1;
			if(Counter == DELAY_RESET_COUNTER) begin
				state = WIRE_READ_PRESENCE;
				CountEnable <= 0;
			end
		end

		WIRE_READ_PRESENCE: begin
			WireOut <= 1;
			CountEnable <= 1;
			if(Counter == WIRE_READ_PRESENCE_COUNTER) begin
				presence <= ~WireIn;
			end
			if(Counter == DELAY_RESET_COUNTER) begin
				state = START;
				CountEnable <= 0;
			end
		end

		WIRE_0: begin
			WireOut <= 0;
			if(rw)
				state = WIRE_WRITE;
			else
				state = WIRE_READ;
		end

		WIRE_WRITE: begin
			if(InData[CountBit])
				WireOut <= 1;

			state = DELAY;
		end

		WIRE_READ: begin
			WireOut <= 1;
			CountEnable <= 1;
			if(Counter == READ_DATA_COUNTER) begin
				OutData[CountBit] <= WireIn;
				CountEnable <= 0;
				state = DELAY;
			end
		end

		DELAY: begin
			CountEnable <= 1;
			if(Counter == WRITE_DATA_COUNTER) begin
				CountEnable <= 0;
				WireOut <= 1;
				if(CountBit == DATA_WIDTH)begin
					CountBit = 0;
					state = START;
				end
				else begin
					CountBit = CountBit + 1;
					state = WIRE_0;
				end

			end
		end

	endcase
end

always @(posedge clk) begin
	if(CountEnable)
		Counter <= Counter + 1;
	else
		Counter <= 0;
end


endmodule