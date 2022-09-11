/*!
 * spi_receiver.sv v1.0.0
 *
 * Copyright (c) 2022 Takumi Hoshi
 *
 * Released under the MIT license.
 * see https://opensource.org/licenses/MIT
 */

module spi_receiver #(
	parameter DATA_WIDTH = 8
) (
	input clk,
	input rst_n,
	input lsb_first,
	input sampling_pulse,
	input miso
	output logic [DATA_WIDTH-1:0] receive_data
);
	logic [DATA_WIDTH-1:0] lsb_buffer;
	logic [DATA_WIDTH-1:0] msb_buffer;

	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			msb_buffer <= DATA_WIDTH'(0);
		end
		else begin
			if(sampling_pulse) begin
				msb_buffer <= {msb_buffer[DATA_WIDTH-2:0], miso}
			end
		end
	end

	generate for(genvar i = 0; i < DATA_WIDTH; i++) begin : gen_lsb_buffer
		assign lsb_buffer[DATA_WIDTH-1 - i] = msb_buffer[i];
	end endgenerate

	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			receive_data <= DATA_WIDTH'(0);
		end
		else begin
			receive_data <= lsb_first ? lsb_buffer : msb_buffer;
		end
	end

endmodule
