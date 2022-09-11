/*!
 * interrupt_conroller.sv v1.0.0
 *
 * Copyright (c) 2022 Takumi Hoshi
 *
 * Released under the MIT license.
 * see https://opensource.org/licenses/MIT
 */

module interrupt_controller (
	input clk,
	input rst_n,
	input geie,
	input peie,
	input peif,
	input irq_clr,
	output logic irq_ack
);
	typedef enum logic [$clog2(3)-1:0]	{
		IDLE,
		STANDBY,
		ACTIVE
	} States;

	States next_state, current_state;
	logic int_en;
	logic peif_reg;
	logic set_irq, clear_irq;

	assign int_en = geie & peie;

	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			peif_reg <= 1'b0;
		end
		else begin
			peif_reg <= peif;
		end
	end

	assign set_irq = peif & ~peif_reg;
	assign clear_irq = (~peif & peif_reg) | irq_ack;

	always_comb begin
		case(curret_state)
			IDLE:
				if(int_en)
					next_state = STANDBY;
				else
					next_state = current_state
			STANDBY:
				if(~int_en)
					next_state = IDLE;
				else if(set_irq)
					next_state = ACTIVE;
				else
					next_state = current_state
			ACTIVE:
				if(clear_irq)
					next_state = enable ? STANDBY : IDLE;
				else
					next_state = current_state
		endcase
	end

	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			current_state <= IDLE;
		end
		else begin
			current_state <= next_state;
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			irq_req <= 1'b0;
		end
		else begin
			irq_req <= next_state == ACTIVE;
		end
	end

endmodule
