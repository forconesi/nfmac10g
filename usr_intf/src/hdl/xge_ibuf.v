/*******************************************************************************
*
*  NetFPGA-10G http://www.netfpga.org
*
*  File:
*        xge_ibuf.v
*
*  Project:
*
*
*  Author:
*        Marco Forconesi
*
*  Description:
*        Internal buffers
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

module xge_ibuf # (
    parameter  AW = 10,
    parameter  DW = 64
    ) ( 

    input      [AW-1:0]     a,
    input      [DW-1:0]     d,
    input      [AW-1:0]     dpra,
    input                   clk,
    input                   qdpo_clk,
    output reg [DW-1:0]     qdpo
    );

    //-------------------------------------------------------
    // Local port a
    //-------------------------------------------------------
    reg     [AW-1:0]     a_reg;
    reg     [DW-1:0]     d_reg;
    reg     [DW-1:0]     dpram[(2**AW)-1:0];

    //-------------------------------------------------------
    // Local port b
    //-------------------------------------------------------
    //reg     [AW-1:0]     dpra_reg;
    reg     [DW-1:0]     qdpo_reg;

    ////////////////////////////////////////////////
    // port a
    ////////////////////////////////////////////////
    always @(posedge clk) begin
        a_reg <= a;
        d_reg <= d;
        dpram[a_reg] <= d_reg;
    end  //always

    ////////////////////////////////////////////////
    // port b
    ////////////////////////////////////////////////
    always @(posedge qdpo_clk) begin
        qdpo_reg <= dpram[dpra];
        qdpo <= qdpo_reg;
    end  //always

endmodule // xge_ibuf

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////