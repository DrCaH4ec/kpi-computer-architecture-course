`timescale 1ns/1ps

`define DATA_MEMORY_MIN 0
`define DATA_MEMORY_MAX 127

`define GPIO_MIN 128
`define GPIO_MAX 130

module data_control #(parameter WIDTH = 1)(addr, mem_write_in, mem_write_out, d_out_addr);

localparam ADDR_WIDTH = $clog2(WIDTH);

input [WIDTH-1:0] addr;
input mem_write_in;

output [WIDTH-1:0] mem_write_out;
output reg [ADDR_WIDTH-1:0] d_out_addr;

decod dec_0(d_out_addr, mem_write_out, mem_write_in);

always @* begin
	if(`DATA_MEMORY_MIN <= addr && addr <= `DATA_MEMORY_MAX) begin
		d_out_addr <= 0;
	end
	else if(`GPIO_MIN <= addr && addr <= `GPIO_MAX) begin
		d_out_addr <= 1;
	end
	else d_out_addr <= 31;
end
	
endmodule


module decod(addr, d_out, en);

input [4:0] addr;
input en;

output [31:0] d_out;

assign d_out = en ? 32'b00000000000000000000000000000001 << addr : 0;

endmodule