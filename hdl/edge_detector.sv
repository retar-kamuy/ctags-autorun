/*!
 * edge_detector.sv v1.0.0
 *
 * Copyright (c) 2022 Takumi Hoshi
 *
 * Released under the MIT license.
 * see https://opensource.org/licenses/MIT
 */

module edge_detector #(
	parameter INITIAL_DATA = 1'b0
) (
	input clk,
	input rst_n,
	input level,
	output logic rise_edge,
	output logic fall_edge
);
	logic level_reg;

	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			level_reg <= INITIAL_DATA;
		end
		else begin
			level_reg <= level
		end
	end

	assign rise_edge = level & (~level_reg);
	assign fall_edge = ~level & level_reg;

endmodule
