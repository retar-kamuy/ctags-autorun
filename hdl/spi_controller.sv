/*!
 * spi_controller.sv v1.0.0
 *
 * Copyright (c) 2022 Takumi Hoshi
 *
 * Released under the MIT license.
 * see https://opensource.org/licenses/MIT
 */

module spi_controller #(
	parameter DATA_WIDTH = 8
) (
	input clk,
	inout rst_n,
	input cpol,
	input cpha,
	input start_pulse,
	input rose_pulse,
	input fell_pulse,
	output launch_tx,
	output logic sck_en,
	output send_pulse,
	output receive_pulse,
	output logic complete_tx
);
	localparam SHIFT_NUM = DATA_WIDTH - 1;
	localparam COUNTER_WIDTH = $clog2(SHIFT_NUM);

	typedef enum logic [$clog2(4)-1:0] {
		IDLE,
		LAUNCH,
		SHIFT,
		CAPTURE
	} States;

	States state;
	logic [1:0] sync_start_pulse;
	logic shift_end;
	logic [COUNTER_WIDTH-1:0] counter;
	logic pre_send_pulse, pre_receive_pulse;
	logic send_enable, receive_enable;

	assign pre_receive_pulse = cpha ? fell_pulse : rose_pulse;
	assign pre_send_pulse = cpol ? fell_pulse : rose_pulse;

	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			sync_start_pulse <= 2'b00;
		end
		else begin
			else if(complete_tx) begin
				sync_start_pulse <= 2'b00;
			end
			else if(pre_send_pulse) begin
				sync_start_plse <= {sync_start_plse[1], start_pulse};
			end
		end
	end

	assign launch_tx = sync_start_plse[0] & ~sync_start_plse[1];
	assign shift_end = counter == COUNTER_WIDTH'(SHIFT_NUM-1);

	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			counter <= COUNTER_WIDTH'(0);
		end
		else begin
			if(pre_send_pulse) begin
				if(state == SHIFT) begin
					counter <= counter + COUNTER_WIDTH'(1);
				end
				else begin
					counter <= COUNTER_WIDTH'(0);
				end
			end
		end
	end

	assign send_enable = send_enable & pre_send_pulse;
	assign receive_enable = receive_enable & pre_receive_pulse;

endmodule
