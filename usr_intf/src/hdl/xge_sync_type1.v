/*******************************************************************************
*
*  NetFPGA-10G http://www.netfpga.org
*
*  File:
*        xge_sync_type1.v
*
*  Project:
*
*
*  Author:
*        Marco Forconesi
*
*  Description:
*        Synchronizes signals that cross clock domains. Other modules do not have
*        to care about Synchronization.
*
*
*    This code is initially developed for the Network-as-a-Service (NaaS) project.
*
*  Copyright notice:
*        Copyright (C) 2014 University of Cambridge
*
*  Licence:
*        This file is part of the NetFPGA 10G development base package.
*
*        This file is free code: you can redistribute it and/or modify it under
*        the terms of the GNU Lesser General Public License version 2.1 as
*        published by the Free Software Foundation.
*
*        This package is distributed in the hope that it will be useful, but
*        WITHOUT ANY WARRANTY; without even the implied warranty of
*        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
*        Lesser General Public License for more details.
*
*        You should have received a copy of the GNU Lesser General Public
*        License along with the NetFPGA source package.  If not, see
*        http://www.gnu.org/licenses/.
*
*/

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
//`default_nettype none

module xge_sync_type1 # (
    parameter W = 32,
    parameter OUT_PRESET = 'b0
    ) (

    input                    clk_out,         // freq(clk_out) > freq(clk_in)
    input                    rst_out,

    input                    clk_in,
    input                    rst_in,

    input        [W-1:0]     in,
    output       [W-1:0]     out
    );

    // localparam
    localparam s0 = 8'b00000000;
    localparam s1 = 8'b00000001;
    localparam s2 = 8'b00000010;
    localparam s3 = 8'b00000100;
    localparam s4 = 8'b00001000;
    localparam s5 = 8'b00010000;
    localparam s6 = 8'b00100000;
    localparam s7 = 8'b01000000;
    localparam s8 = 8'b10000000;

    //-------------------------------------------------------
    // Local a
    //-------------------------------------------------------
    reg          [7:0]       fsm_a;
    reg                      sync;
    reg          [W-1:0]     cross;

    //-------------------------------------------------------
    // Local b
    //-------------------------------------------------------
    reg          [7:0]       fsm_b;
    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *)reg sync_reg0;
    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *)reg sync_reg1;
    (* ASYNC_REG = "TRUE" *)reg [W-1:0] async;

    //-------------------------------------------------------
    // assigns
    //-------------------------------------------------------
    assign out = async;

    ////////////////////////////////////////////////
    // a
    ////////////////////////////////////////////////
    always @(posedge clk_in) begin

        if (rst_in) begin  // rst
            sync <= 1'b0;
            fsm_a <= s0;
        end
        
        else begin  // not rst

            sync <= 1'b0;

            case (fsm_a)

                s0 : begin
                    fsm_a <= s1;
                end

                s1 : begin
                    cross <= in;
                    fsm_a <= s2;
                end

                s2 : begin
                    sync <= 1'b1;
                    fsm_a <= s3;
                end

                s3 : fsm_a <= s4;
                s4 : fsm_a <= s5;
                s5 : fsm_a <= s6;
                s6 : fsm_a <= s7;
                s7 : fsm_a <= s0;

            endcase
        end     // not rst
    end  //always

    ////////////////////////////////////////////////
    // b
    ////////////////////////////////////////////////
    always @(posedge clk_out) begin

        sync_reg0 <= sync;
        sync_reg1 <= sync_reg0;

        if (rst_out) begin  // rst
            fsm_b <= s0;
        end
        
        else begin  // not rst

            case (fsm_b)

                s0 : begin
                    sync_reg0 <= 1'b0;
                    sync_reg1 <= 1'b0;
                    async <= OUT_PRESET;
                    fsm_b <= s1;
                end

                s1 : begin
                    if (sync_reg1) begin
                        async <= cross;
                    end
                end

            endcase
        end     // not rst
    end  //always

endmodule // xge_sync_type1

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////