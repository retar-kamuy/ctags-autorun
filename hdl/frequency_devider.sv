/*!
 * frequency_devider.sv v1.0.0
 *
 * Copyright (c) 2022 Takumi Hoshi
 *
 * Released under the MIT license.
 * see https://opensource.org/licenses/MIT
 */

module frequency_devider #(
	parameter DIVIDE_BY 2
) (
	input clk,
	input rst_n,
	output logic devided_pulse
);
	localparam COUNTER_WIDTH = $clog2(DIVED_BY-1);

	logic [COUNTER_WIDTH-1:0] counter;
	logic limit;

	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			counter <= COUNTER_WIDTH'(0);
			devided_pulse <= 1'b0;
		end
		else begin
			if(limit) begin
				counter <= COUNTER_WIDTH'(0);
				devided_pulse <= 1'b1;
			end
			else begin
				counter <= counter + COUNTER_WIDTH'(1);
				devided_pulse <= 1'b0;
			end
		end
	end

	assign limit = counter == DEVIDE - 1;

endmodule
