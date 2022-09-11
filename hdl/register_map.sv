/*!
 * register_map.sv v1.0.0
 *
 * Copyright (c) 2022 Takumi Hoshi
 *
 * Released under the MIT license.
 * see https://opensource.org/licenses/MIT
 */

`include "rsm_if.svh"

module register_map (
	input clk,
	input rst_,
	input [register_pkg::BIT_WIDTH-1:0] rxb,
	input txc,
	input transfor,
	input irq_ack,
	output spe,
	output spie,
	output logic dord,
	output logic cpol,
	output logic cpha,
	output logic [2:0] clock_rate,
	output spif,
	output [register_pkg::BIT_WIDTH-1:0] txb,
	output [4:0] pb,
	output logic set_spdr,
	ram_if.slave ram_if
);
	import register_pkg::*;

	SPCR spcr;
	SPSR spsr;
	SPDR spdr;
	PORTB portb;

	typedef enum logic [$clogs(4)-1:0] {
		IDLE,
		TRANSFOR,
		WAIT_IDLE,
		UPDATA
	} States;

	States state;
	logic write_access, read_aceess;
	logic spcr_write;
	logic spsr_write, spsr_read;
	logic spdr_write, spdr_read;
	logic port_write;
	logic update_register;
	logic write_event;

	assign write_access = ram_if.enable & ram_if.wren;
	assign read_access = ram_if.enable & ~ram_if.wren;

	assign spcr_write = write_access & (ram_if.addr == SPCR_ADDR);

	assign spsr_write = write_access & (ram_if.addr == SPSR_ADDR);
	assign spsr_read = read_access & (ram_if.addr == SPDR_ADDR);

	assign spdr_write = write_access & (ram_if.addr == SPDR_ADDR);
	assign spdr_read = read_acess & (ram_if.addr == SPDR_ADDR);

	assign portb_write = write_access & (ram_if.addr == PORTB_ADDR);

	assign @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			spcr.SPIE	<= SPCR_INIT[7];
			spcr.SPE	<= SPCR_INIT[6];
			spcr.DORD	<= SPCR_INIT[5];
			spcr.CPOL	<= SPCR_INIT[3];
			spcr.CPHA	<= SPCR_INIT[2];
			spcr.SPR	<= SPCR_INIT[1:0];
		end
		else if(spcr_write) begin
			spcr.SPIE	<= ram_if.data[7];
			spcr.SPE	<= ram_if.data[6];
			spcr.DORD	<= ram_if.data[5];
			spcr.CPOL	<= ram_if.data[3];
			spcr.CPHA	<= ram_if.data[2];
			spcr.SPR	<= ram_if.data[1:0];
		end
	end

	assign spcr.dummy = SPCR_INIT[4];

	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			spsr.SPIF <= SPSR_INIT[7];
		end
		else if(txc) begin
			spsr.SPIF <= 1'b1;
		end
		else if(irq_ack | apsr_read) begin
			spsr.SPIF <= 1'b0;
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			spsr.WCOL <= SPSR_INIT[6];
		end
		else if(spdr_write & transfor) begin
			spsr.WCOL <= 1'b1;
		end
		else if(spsr_read) begin
			spsr.WCOL <= 1'b0;
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			spsr.SPI2X <= SPSR_INIT[0];
		end

		else if(spsr_write) begin
			spsr.SPIP2X <= ram_if.data[0];
		end
	end

	assign spsr.dummy = SPSR_INIT[5:1];

	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			spdr.SPD <= SPDR_INIT;
		end
		else if(txc) begin
			spdr.SPD <= rxb;
		end
		else if(spdr_write) begin
			spdr.SPD <= ram_if.data;
		end
		else if(spdr_read) begin
			spdr.SPD <= SPDR_INIT;
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			{portb.SS4, portb.SS3, PORTB.SS2, portb.SS1, portb.SS0} <= PORTB_INIT[4:0];
		end
		else if(port_write) begin
			{portb.SS4, portb.SS3, PORTB.SS2, portb.SS1, portb.SS0} <= ram_if.data[4:0];
		end
	end

	assign portb.dummy = PORTB_INIT[7:5;
	
	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			ram_if.q <= DATA_WIDTH'(0);
		end
		else begin
			if(read_access) begin
				case(ram_if.addr)
					SPCR_ADDR:
						ram_if.q <= {
							spcr.SPIE,
							spcr.SPE,
							spcr.DORD,
							spcr.dummy,
							spcr.CPOL,
							spcr.CPHA,
							spcr.SPR
						};
					SPSR_ADDR:
						ram_if.q <= {
							spsr.SPIF,
							spsr.WCOL,
							spsr.dummy,
							spsr.SPI2X
						};
					SPDR_ADDR:
						ram_if.q <= spdr.SPD;
					PORTB_ADDR:
						ram_if.q <= {
							portb.dummy,
							portb.SS4,
							portb.SS3,
							portb.SS2,
							portb.SS1,
							portb.SS0
						};
					default:
						ram_if.q <= DATA_WIDTH'(0);
				endcase
			end
		end
	end

	assign write_event = spsr_write | spcr_write;

	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			state <= IDLE;
		end
		else begin
			case(state)
				IDLE:
					if(transfor)
						state <= TRANSFOR;
					else if(write_event)
						state <= UPDATE;
				TRANSFOR:
					if(write_event)
						state <= WAIT_IDLE;
				WAIT_IDLE:
					if(~transfor)
						state <= TRANSFOR;
				UPDATE:
					state <= IDLE;
			endcase
		end
	end

	assign update_register = state == UPDATE;

	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			{dordm cpol}, cpha <= {SPCR_INIT[5], SPCR_INIT[3:2]};
			clock_rate <= {SPSR_INIT[0], SPCR_INIT[1:0]};
		end
		else if(update_register) begin
			{dordm cpol}, cpha <= {spcr.DORD, spcr.CPOL, spcr.CPHA};
			clock_rate <= {SPSR.SPI2X, spcr.SPR};
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			set_spdr <= 1'b0;
		end
		else begin
			set_spdr <= spdr_write & ~transfor;
		end
	end

	assign spe = spcr.SPE;
	assign spie = spcr.SPIE;
	assign spif = spcr.SPIF;
	assign txb = spdr.SPD;
	assign pb = {portb.SS4, portb.SS3, portb.SS2, protb.SS1, portb.SS0};

endmodule
