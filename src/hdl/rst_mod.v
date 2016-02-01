/*******************************************************************************
*
*  NetFPGA-10G http://www.netfpga.org
*
*  File:
*        rst_mod.v
*
*  Project:
*
*
*  Author:
*        Marco Forconesi
*
*  Description:
*        
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

module rst_mod (

    // Clks and resets
    input                    clk,
    input                    reset,
    input                    dcm_locked,

    // Output
    output reg               rst
    );

    // localparam
    localparam s0  = 8'b00000001;
    localparam s1  = 8'b00000010;
    localparam s2  = 8'b00000100;
    localparam s3  = 8'b00001000;
    localparam s4  = 8'b00010000;
    localparam s5  = 8'b00100000;
    localparam s6  = 8'b01000000;
    localparam s7  = 8'b10000000;

    //-------------------------------------------------------
    // Local gen_rst
    //-------------------------------------------------------
    reg          [7:0]       fsm = 'b1;

    ////////////////////////////////////////////////
    // gen_rst
    ////////////////////////////////////////////////
    always @(posedge clk or posedge reset) begin
        
        if (reset) begin  // reset
            rst <= 1'b1;
            fsm <= s0;
        end

        else begin  // not reset

            case (fsm)

                s0 : begin
                    rst <= 1'b1;
                    fsm <= s1;
                end

                s1 : fsm <= s2;
                s2 : fsm <= s3;
                s3 : fsm <= s4;

                s4 : begin
                    if (dcm_locked) begin
                        fsm <= s5;
                    end
                end

                s5 : begin
                    rst <= 1'b0;
                end

                default : begin
                    fsm <= s0;
                end

            endcase
        end     // not reset
    end  //always

endmodule // rst_mod

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////