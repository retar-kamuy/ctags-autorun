/*!
 * state_machime.sv v1.0.0
 *
 * Copyright (c) 2022 Takumi Hoshi
 *
 * Released under the MIT license.
 * see https://opensource.org/licenses/MIT
 */

module state_machime (
	input clk,
	input rst_n,
	input spe,
	input set_spdr,
	input locked,
	input complete_tx,
	output launch_tx
);
	typedef enum logic [$clog2(4)-1:0] {
		IDLE,
		STANDBY,
		WAIT_LOCKED,
		TRANSFER
	} States;

	States state;

	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			state <= IDLE;
		end
		else begin
			case(state)
				IDLE:
					if(spe)
						state <= STANDBY;
					else
						state <= IDLE;
				STANDBY:
					if(~spe)
						state <= IDLE;
					else if(set_spdr & locked)
						state <= TRANSFER;
					else if(set_spdr)
						state <= WAIT_LOCKED;
					else
						state <= STANDBY;
				WAIT_LOCKED:
					if(~spe)
						state <= IDLE;
					else if(locked)
						state <= TRANSFER;
					else
						state <= WAIT_LOCKED;
				TRANSFER:
					if(complete_tx & ~spe)
						state <= IDLE;
					else if(complete_tx & spe)
						state <= STANDBY;
					else
						state <= TRANSFER;
			endcase
		end
	end

	assign launch_tx = state == TRANSFER;

endmodule
