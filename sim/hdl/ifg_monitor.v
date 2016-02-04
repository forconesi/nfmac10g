/*******************************************************************************
*
*  NetFPGA-10G http://www.netfpga.org
*
*  File:
*        ifg_monitor.v
*
*  Project:
*
*
*  Author:
*        Marco Forconesi
*
*  Description:
*        Check the output pkts
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
`define pr_err(msg) $display("IFG-mon: ERROR %s", msg);
`define pr(cnt) $display("IFG-mon: %d", cnt);

module ifg_monitor # (
    parameter C_RX_LINK = 1
    ) (

    // Clks and resets
    input                    clk,
    input                    reset,
    input                    dcm_locked,

    // XGMII
    input        [63:0]      xgmii_d,
    input        [7:0]       xgmii_c
    );

    // XGMII characters
    localparam S   = 8'hFB;
    localparam T   = 8'hFD;
    localparam E   = 8'hFE;
    localparam I   = 8'h07;

    localparam s0 = 8'b00000001;
    localparam s1 = 8'b00000010;
    localparam s2 = 8'b00000100;
    localparam s3 = 8'b00001000;
    localparam s4 = 8'b00010000;
    localparam s5 = 8'b00100000;
    localparam s6 = 8'b01000000;
    localparam s7 = 8'b10000000;

    //-------------------------------------------------------
    // Local ifg_monitor
    //-------------------------------------------------------
    reg          [63:0]      fsm;
    wire         [63:0]      d;
    wire         [7:0]       c;
    reg          [63:0]      idle_byte_cnt;

    //-------------------------------------------------------
    // assigns
    //-------------------------------------------------------
    assign d = xgmii_d;
    assign c = xgmii_c;

    ////////////////////////////////////////////////
    // ifg_monitor
    ////////////////////////////////////////////////
    always @(posedge clk) begin

        if (reset || !dcm_locked) begin
            fsm <= s0;
        end

        else begin

            case (fsm)

                s0 : begin
                    if (sop(d,c)) begin
                        fsm <= s1;
                    end
                end

                s1 : begin
                    if (eop(d,c)) begin
                        idle_byte_cnt = idle_bytes(d,c);
                        fsm <= s2;
                    end
                end

                s2 : begin
                    idle_byte_cnt = idle_byte_cnt + idle_bytes(d,c);
                    if (sop(d,c)) begin
                        `pr(idle_byte_cnt)
                        if (C_RX_LINK) begin
                            if (idle_byte_cnt < 5) begin
                                `pr_err("IFG is less than 5 in Rx")
                            end
                        end
                        else begin
                            if (idle_byte_cnt < 9) begin
                                `pr_err("IFG is less than 9 in Tx")
                                $finish;
                            end
                        end
                        fsm <= s1;
                    end
                end

            endcase
        end
    end

    ////////////////////////////////////////////////
    // eop
    ////////////////////////////////////////////////
    function eop;
        input        [63:0]      d;
        input        [7:0]       c;
        integer                  i;
        reg                      flag;
        reg          [63:0]      aux_d;
    begin
        flag = 0;
        aux_d = d;
        for (i = 0; i < 8; i = i + 1) begin
            if (c[i] && aux_d[7:0] == T) begin
                flag = 1;
            end
            aux_d = {8'b0, aux_d[63:8]};
        end

        eop = flag;
    end
    endfunction

    ////////////////////////////////////////////////
    // idle_bytes
    ////////////////////////////////////////////////
    function [63:0] idle_bytes;
        input        [63:0]      d;
        input        [7:0]       c;
        integer                  i;
        reg          [7:0]       idl_cnt;
        reg          [63:0]      aux_d;
    begin
        idl_cnt = 0;
        aux_d = d;
        for (i = 0; i < 8; i = i + 1) begin
            if (c[i]) begin
                if (aux_d[7:0] == I || aux_d[7:0] == T) begin
                    idl_cnt = idl_cnt + 1;
                end
            end
            aux_d = {8'b0, aux_d[63:8]};
        end

        idle_bytes = idl_cnt;
    end
    endfunction

    ////////////////////////////////////////////////
    // sop
    ////////////////////////////////////////////////
    function sop;
        input        [63:0]      d;
        input        [7:0]       c;
    begin
        if ((d[7:0] == S && c[0]) || (d[39:32] == S && c[4])) begin
            sop = 1;
        end
        else begin
            sop = 0;
        end
    end
    endfunction

endmodule // ifg_monitor

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////