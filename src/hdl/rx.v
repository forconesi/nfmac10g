/*******************************************************************************
*
*  NetFPGA-10G http://www.netfpga.org
*
*  File:
*        rx.v
*
*  Project:
*
*
*  Author:
*        Marco Forconesi
*
*  Description:
*        Rx module.
*
*
*    This code is initially developed for the Network-as-a-Service (NaaS) project.
*
*  Copyright notice:
*        Copyright (C) 2015 University of Cambridge
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

module rx (

    // Clks and resets
    input                    clk,
    input                    rst,

    // Stats
    output       [31:0]      good_frames,
    output       [31:0]      bad_frames,

    // Conf vectors
    input        [79:0]      configuration_vector,

    // XGMII
    input        [63:0]      xgmii_rxd,
    input        [7:0]       xgmii_rxc,

    // AXIS
    input                    axis_aresetn,
    output       [63:0]      axis_tdata,
    output       [7:0]       axis_tkeep,
    output                   axis_tvalid,
    output                   axis_tlast,
    output       [0:0]       axis_tuser
    );

    //-------------------------------------------------------
    // Local xgmii2axis
    //-------------------------------------------------------
    //wire                     ??;

    //-------------------------------------------------------
    // Local 
    //-------------------------------------------------------
    //wire         [31:0]      ??;

    //-------------------------------------------------------
    // assigns
    //-------------------------------------------------------

    //-------------------------------------------------------
    // xgmii2axis
    //-------------------------------------------------------
    xgmii2axis xgmii2axis_mod (
        .clk(clk),                                             // I
        .rst(rst),                                             // I
        // Stats
        .good_frames(good_frames),                             // O [31:0]
        .bad_frames(bad_frames),                               // O [31:0]
        // Conf vectors
        .configuration_vector(configuration_vector),           // I [79:0]
        // XGMII
        .xgmii_d(xgmii_rxd),                                   // I [63:0]
        .xgmii_c(xgmii_rxc),                                   // I [7:0]
        // AXIS
        .aresetn(axis_aresetn),                                // I
        .tdata(axis_tdata),                                    // O [63:0]
        .tkeep(axis_tkeep),                                    // O [7:0]
        .tvalid(axis_tvalid),                                  // O
        .tlast(axis_tlast),                                    // O
        .tuser(axis_tuser)                                     // O [0:0]
        );

endmodule // rx

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////