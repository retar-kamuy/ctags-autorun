/**
 * register_pkg.svh v1.0.0
 *
 * Copyright (c) 2022 Takumi Hoshi
 *
 * Released under the MIT license.
 * see https://opensource.org/licenses/MIT
 */

`ifndef __REGISTER_PKG_SVH__
`define __REGISTER_PKG_SVH__

package regster_pkg;
	localparam DATA_WIDTH = 8;
	localparam STATE_NUM = 4;

	localparam SPI_BASE_ADDR = 8'h0;

	localparam [DATA_WIDTH-1:0] SPCR_ADDR = 8'h00 + SPI_BASE_ADDR;
	localparam [DATA_WIDTH-1:0] SPSR_ADDR = 8'h10 + SPI_BASE_ADDR;
	localparam [DATA_WIDTH-1:0] SPDR_ADDR = 8'h20 + SPI_BASE_ADDR;
	localparam [DATA_WIDTH-1:0] PORTB_ADDR = 8'h40 + SPI_BASE_ADDR;

	localparam [DATA_WIDTH-1:0] SPCR_INIT = 8'h00;
	localparam [DATA_WIDTH-1:0] SPSR_INIT = 8'h10;
	localparam [DATA_WIDTH-1:0] SPDR_INIT = 8'h20;
	localparam [DATA_WIDTH-1:0] PORTB_INIT = 8'h1F;

	typedef struct packed {
		logic SPIE;
		logic SPE;
		logic DORD;
		logic dummy;
		logic CPOL;
		logic CPHA;
		logic [1:0] SPR;
	} Spcr;

	typedef struct packed {
		logic SPIF;
		logic WCOL;
		logic [4:0] dummy;
		logic SPI2X;
	} Spsr;

	typedef struct packed {
		logic [7:0] SPD;
	}Spdr;

	typedef struct packed {
		logic [2:0] dummy;
		logic SS4;
		logic SS3;
		logic SS2;
		logic SS1;
		logic SS0;
	} Portb;
endpackage

`endif
