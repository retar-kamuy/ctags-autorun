/**
 * clock_generator.sv v1.0.0
 *
 * Copyright (c) 2022 Takumi Hoshi
 *
 * Released under the MIT license.
 * see https://opensource.org/licenses/MIT
 */

module clock_generator (
	input clk,
	input rst_n,
	input [2:0] clock_rate,
	output logic rose_pulse,
	output logic fell_pulse,
	output logic tx_clk,
	output locked
);
	typedef struct packed {
		logic rose;
		logic fell;
	} Edge;

	logic by_2, by_4, by_8, by_16, by_32, by_64, by_128;
	logic clear, rise_edge;

	locked_detector locked_detector (
		.clk,
		.rst_n,
		.clear,
		.rise_edge,
		.locked
	);

	frequency_devider #(
		.DEVIDED_BY (2)
	) frequency_devider_by_2 (
		.clk,
		.rst_n,
		.devided_pulse (by_2)
	);

	frequency_devider #(
		.DEVIDED_BY (4)
	) frequency_devider_by_4 (
		.clk,
		.rst_n,
		.devided_pulse (by_4)
	);

	frequency_devider #(
		.DEVIDED_BY (8)
	) frequency_devider_by_8 (
		.clk,
		.rst_n,
		.devided_pulse (by_8)
	);

	frequency_devider #(
		.DEVIDED_BY (16)
	) frequency_devider_by_16 (
		.clk,
		.rst_n,
		.devided_pulse (by_16)
	);

	frequency_devider #(
		.DEVIDED_BY (32)
	) frequency_devider_by_32 (
		.clk,
		.rst_n,
		.devided_pulse (by_32)
	);

	frequency_devider #(
		.DEVIDED_BY (64)
	) frequency_devider_by_64 (
		.clk,
		.rst_n,
		.devided_pulse (by_64)
	);

	frequency_devider #(
		.DEVIDED_BY (128)
	) frequency_devider_by_128 (
		.clk,
		.rst_n,
		.devided_pulse (by_128)
	);

	edge_detector #(.INITIAL_DATA(1'b0)) edge_detector_by_2   (.clk, .rst_n, .level(by_2  ), .rise_edge(rise_edge_by_2  ), .fall_edge(fall_edge_by_2  ));
	edge_detector #(.INITIAL_DATA(1'b0)) edge_detector_by_4   (.clk, .rst_n, .level(by_4  ), .rise_edge(rise_edge_by_4  ), .fall_edge(fall_edge_by_4  ));
	edge_detector #(.INITIAL_DATA(1'b0)) edge_detector_by_8   (.clk, .rst_n, .level(by_8  ), .rise_edge(rise_edge_by_8  ), .fall_edge(fall_edge_by_8  ));
	edge_detector #(.INITIAL_DATA(1'b0)) edge_detector_by_16  (.clk, .rst_n, .level(by_16 ), .rise_edge(rise_edge_by_16 ), .fall_edge(fall_edge_by_16 ));
	edge_detector #(.INITIAL_DATA(1'b0)) edge_detector_by_32  (.clk, .rst_n, .level(by_32 ), .rise_edge(rise_edge_by_32 ), .fall_edge(fall_edge_by_32 ));
	edge_detector #(.INITIAL_DATA(1'b0)) edge_detector_by_64  (.clk, .rst_n, .level(by_64 ), .rise_edge(rise_edge_by_64 ), .fall_edge(fall_edge_by_64 ));
	edge_detector #(.INITIAL_DATA(1'b0)) edge_detector_by_128 (.clk, .rst_n, .level(by_128), .rise_edge(rise_edge_by_128), .fall_edge(fall_edge_by_128));

	assign rose_index = {
		rose_by_64,
		rose_by_32,
		rose_by_8,
		rose_by_2,
		rose_by_128,
		rose_by_64,
		rose_by_16,
		rose_by_4
	};

	assign fall_index = {
		fell_by_64,
		fell_by_32,
		fell_by_8,
		fell_by_2,
		fell_by_128,
		fell_by_64,
		fell_by_16,
		fell_by_4
	};

	function logic select_clock_rate (logic [2:0] clock_rate, logic [7:0] rate);
		case(clock_rate)
			3'b0_00: select_clock_rate = rate[0];
			3'b0_01: select_clock_rate = rate[1];
			3'b0_10: select_clock_rate = rate[2];
			3'b0_11: select_clock_rate = rate[3];
			3'b1_00: select_clock_rate = rate[4];
			3'b1_01: select_clock_rate = rate[5];
			3'b1_10: select_clock_rate = rate[6];
			3'b1_11: select_clock_rate = rate[7];
		endcase
	endfunction

	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			tx_clk <= 1'b0;
		end
		else begin
			tx_clk <= select_clock_rate(clock_rate, rate_index);
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			rose_edge <= 1'b0;
			fell_edge <= 1'b0;
		end
		else begin
			rose_edge <= select_clock_rate(clock_rate, rose_index);
			fell_edge <= select_clock_rate(clock_rate, fell_index);
		end
	end

endmodule
