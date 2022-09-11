/**
 * ram_if.svh v1.0.0
 *
 * Copyright (c) 2022 Takumi Hoshi
 *
 * Released under the MIT license.
 * see https://opensource.org/licenses/MIT
 */

`ifndef __RAM_IF_SVH__
`define __RAM_IF_SVH__

interface ram_if #(
	parameter ADDR_WIDTH = 8,
	parameter DATA_WIDTH = 8
) (
	input clk,
	input rst_n
);
	logic [ADDR_WIDTH-1:0] addr;
	logic [DATA_WIDTH-1:0] data;
	logic wren;
	logic enable;
	logic [DATA_WIDH-1:0] ram_data;

	modport initiator (
		output addr,
		output data,
		output wren,
		output enable,
		input ram_data
	);

	modport target (
		input addr,
		input data,
		input wren,
		input enable,
		output ram_data
	);

endinterface

`endif
