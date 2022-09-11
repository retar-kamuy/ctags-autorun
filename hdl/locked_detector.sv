/*!
 * locked_detector.sv v1.0.0
 *
 * Copyright (c) 2022 Takumi Hoshi
 *
 * Released under the MIT license.
 * see https://opensource.org/licenses/MIT
 */

module locked_detector (
	input clk,
	input rst_n,
	input clear,
	input rise_edge,
	output logic locked
);
	typedef enum logic [$clog2(4)-1:0]	{
		UNLOCK,
		FIRST_RISE,
		SECOND_RISE,
		LOCK
	} States;

	States state;

	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			state <= UNLOCK;
		end
		else begin
			if(clear) begin
				state <= UNLOCK;
			end
			else begin
				case(state)
					UNLOCK:
						if(rise_edge)
							state <= FIRST_RISE;
						else
							state <= state;
					FIRST_RISE:
						if(rise_edge)
							state <= SECOND_RISE;
						else
							state <= state;
					SECOND_RISE:
						if(rise_edge)
							state <= LOCK;
						else
							state <= state;
					default:
						state <= state;
				endcase
			end
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			locked <= 1'b0;
		end
		else begin
			locked <= state == LOCK;
		end
	end

endmodule
