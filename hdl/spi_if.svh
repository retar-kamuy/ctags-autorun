/**
 * spi_if.svh v1.0.0
 *
 * Copyright (c) 2022 Takumi Hoshi
 *
 * Released under the MIT license.
 * see https://opensource.org/licenses/MIT
 */

`ifndef __SPI_IF_SVH__
`define __SPI_IF_SVH__

interface spi_if;
	logic sck;
	logic ss;
	logic miso;
	logic mosi;

	modport initiator (
		output sck,
		output ss,
		output mosi,
		input miso
	);

	modport target (
		input sck,
		input ss,
		input mosi,
		output miso
	);

endinterface

`endif
