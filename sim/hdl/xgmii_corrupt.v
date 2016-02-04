/*******************************************************************************
*
*  NetFPGA-10G http://www.netfpga.org
*
*  File:
*        xgmii_corrupt.v
*
*  Project:
*
*
*  Author:
*        Marco Forconesi
*
*  Description:
*        Loopback XGMII interface and introduce channel errors
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

module xgmii_corrupt (

    // Clks and resets
    input                    clk,
    input                    reset,
    input                    tx_dcm_locked,
    input                    rx_dcm_locked,

    // XGMII
    input        [63:0]      xgmii_txd,
    input        [7:0]       xgmii_txc,
    output reg   [63:0]      xgmii_rxd,
    output reg   [7:0]       xgmii_rxc,

    // Sim info
    output       [63:0]      pkts_detected,
    output reg   [63:0]      corrupted_pkts
    );

    `include "localparam.dat"
    `include "corr_pkt.dat"

    localparam s0 = 8'b00000001;
    localparam s1 = 8'b00000010;
    localparam s2 = 8'b00000100;
    localparam s3 = 8'b00001000;
    localparam s4 = 8'b00010000;
    localparam s5 = 8'b00100000;
    localparam s6 = 8'b01000000;
    localparam s7 = 8'b10000000;

    //-------------------------------------------------------
    // Local
    //-------------------------------------------------------
    reg          [63:0]      fsm;
    reg          [63:0]      i, trn;

    //-------------------------------------------------------
    // assigns
    //-------------------------------------------------------
    assign pkts_detected = i;

    ////////////////////////////////////////////////
    // xgmii_corrupt
    ////////////////////////////////////////////////
    always @(posedge clk) begin

        if (reset || !tx_dcm_locked || !rx_dcm_locked) begin
            xgmii_rxd <= xgmii_txd;
            xgmii_rxc <= xgmii_txc;
            i <= 0;
            trn <= 0;
            corrupted_pkts <= 0;
            fsm <= s0;
        end

        else begin

            xgmii_rxd <= xgmii_txd;
            xgmii_rxc <= xgmii_txc;

            case (fsm)

                s0 : begin
                    if (xgmii_txc != 8'hFF) begin
                        trn <= 1;
                        fsm <= s1;
                    end
                end

                s1 : begin
                    trn <= trn + 1;
                    if (trn == 3) begin
                        if (corrupt_pkt[i]) begin
                            corrupted_pkts <= corrupted_pkts + 1;
                            xgmii_rxd <= {xgmii_txd[63:1], ~xgmii_txd[0]};
                            xgmii_rxc <= xgmii_txc;
                        end
                    end

                    if (xgmii_txc) begin
                        i <= i + 1;
                        fsm <= s0;
                    end
                end

            endcase
        end
    end

endmodule // xgmii_corrupt

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////