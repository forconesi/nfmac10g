/*******************************************************************************
*
*  NetFPGA-10G http://www.netfpga.org
*
*  File:
*        xgmii_connect.v
*
*  Project:
*
*
*  Author:
*        Marco Forconesi
*
*  Description:
*        Test bench
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
`timescale 1ns / 100ps
//`default_nettype none

module xgmii_connect (

    // Clks and resets
    input                    clk,
    input                    reset,
    input                    tx_dcm_locked,
    input                    rx_dcm_locked,

    // XGMII
    input        [63:0]      xgmii_txd,
    input        [7:0]       xgmii_txc,
    output       [63:0]      xgmii_rxd,
    output       [7:0]       xgmii_rxc,

    // Sim info
    output       [63:0]      pkts_detected,
    output       [63:0]      corrupted_pkts
    );

    //-------------------------------------------------------
    // Local clk
    //-------------------------------------------------------

    //-------------------------------------------------------
    // xgmii_corrupt
    //-------------------------------------------------------
    xgmii_corrupt xgmii_corrupt_mod (
        // Clks and resets
        .clk(clk),                                             // I
        .reset(reset),                                         // I
        .tx_dcm_locked(tx_dcm_locked),                         // I
        .rx_dcm_locked(rx_dcm_locked),                         // I
        // XGMII
        .xgmii_txd(xgmii_txd),                                 // I [63:0]
        .xgmii_txc(xgmii_txc),                                 // I [7:0]
        .xgmii_rxd(xgmii_rxd),                                 // O [63:0]
        .xgmii_rxc(xgmii_rxc),                                 // O [7:0]
        // Sim info
        .pkts_detected(pkts_detected),                         // O [63:0]
        .corrupted_pkts(corrupted_pkts)                        // O [63:0]
        );

    //-------------------------------------------------------
    // ifg_monitor
    //-------------------------------------------------------
    ifg_monitor # (
        .C_RX_LINK(0)
    ) tx_ifg_monitor_mod (
        // Clks and resets
        .clk(clk),                                             // I
        .reset(reset),                                         // I
        .dcm_locked(tx_dcm_locked),                            // I
        // XGMII
        .xgmii_d(xgmii_txd),                                   // I [63:0]
        .xgmii_c(xgmii_txc)                                    // I [7:0]
        );

endmodule // xgmii_connect

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////