/*!
 * spi_sender.sv v1.0.0
 *
 * Copyright (c) 2022 Takumi Hoshi
 *
 * Released under the MIT license.
 * see https://opensource.org/licenses/MIT
 */

module spi_sender #(
	parameter DATA_WIDTH = 8
) (
	input clk,
	input rst_n,
	input lsb_first,
	input cpol,
	input launch_tx,
	input sck_en,
	input send_puse,
	input tx_clk,
	input [DATA_WIDTH-1:0] txb,
	output logic sck,
	output logic mosi
);
	logic [DATA_WIDTH-1:0] lsb_buffer;
	logic [DATA_WIDTH-1:0] msb_buffer;

	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			sck <= 1'b0;
		end
		else begin
			if(sck_en) begin
				sck <= cpol ? ~tx_clk : tx_clk;
			end
			else begin
				sck <= cpol;
			end
		end
	end

	generate for(genvar i = 0; i < DATA_WIDTH; i++) begin : gen_lsb_buffer
		assign lsb_buffer[DATA_WIDTH-1 - i] = txb[i];
	end endgenerate

	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			msb_buffer <= DATA_WIDTH'(0);
		end
		else begin
			if(launch_tx) begin
				msb_buffer <= lsb_first ? lsb_buffer : txb;
			end
			else if(send_pulse) begin
				msb_buffer <= msb_buffer << 1;
			end
		end
	end

	assign mosi = msb_buffer[DATA_WIDTH-1];

endmodule
