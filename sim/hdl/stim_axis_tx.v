/*******************************************************************************
*
*  NetFPGA-10G http://www.netfpga.org
*
*  File:
*        stim_axis_tx.v
*
*  Project:
*
*
*  Author:
*        Marco Forconesi
*
*  Description:
*        Push pkts into Tx interface
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
`define pr_err(msg) $display("In-Stim: ERROR %s", msg);
`define pr(msg) $display("In-Stim: INFO %s", msg);

module stim_axis_tx (

    // Clks and resets
    input                    clk,
    input                    reset,
    input                    tx_dcm_locked,
    input                    rx_dcm_locked,

    // Tx AXIS
    input                    tx_axis_aresetn,
    output       [63:0]      tx_axis_tdata,
    output       [7:0]       tx_axis_tkeep,
    output                   tx_axis_tvalid,
    input                    tx_axis_tready,
    output                   tx_axis_tlast,
    output       [0:0]       tx_axis_tuser,

    // Sim info
    output reg               input_pkts_done,
    output reg   [63:0]      aborted_pkts,
    output reg   [63:0]      pushed_pkts
    );

    `include "localparam.dat"
    `include "sim_stim.dat"

    localparam DELAY_START = 50;

    localparam s0 = 8'b00000001;
    localparam s1 = 8'b00000010;
    localparam s2 = 8'b00000100;
    localparam s3 = 8'b00001000;
    localparam s4 = 8'b00010000;
    localparam s5 = 8'b00100000;
    localparam s6 = 8'b01000000;
    localparam s7 = 8'b10000000;

    //-------------------------------------------------------
    // Local input_proc
    //-------------------------------------------------------
    reg          [63:0]      fsm;
    reg          [63:0]      i;
    reg          [63:0]      wait_count;
    reg          [74:0]      map_axis;
    reg                      aborted_flag;

    //-------------------------------------------------------
    // assigns
    //-------------------------------------------------------
    assign tx_axis_tvalid = map_axis[0];
    assign tx_axis_tlast  = map_axis[1];
    assign tx_axis_tuser  = map_axis[2];
    assign tx_axis_tkeep  = map_axis[10:3];
    assign tx_axis_tdata  = map_axis[74:11];

    ////////////////////////////////////////////////
    // stim_axis_tx
    ////////////////////////////////////////////////
    always @(posedge clk) begin

        if (reset || !tx_dcm_locked || !tx_axis_aresetn || !rx_dcm_locked) begin
            i <= 0;
            wait_count = 0;
            map_axis <= 'b0;
            aborted_pkts <= 'b0;
            pushed_pkts <= 'b0;
            input_pkts_done <= 1'b0;
            fsm <= s0;
        end

        else begin

            case (fsm)

                s0 : begin
                    map_axis <= 'b0;
                    wait_count = wait_count +1;
                    if (wait_count == DELAY_START) begin
                        fsm <= s1;
                    end
                end

                s1 : begin
                    if (i == DATA_SIZE) begin
                        map_axis <= 'b0;
                        fsm <= s4;
                    end
                    else begin
                        i <= i + 1;
                        if (is_sof_val(din[i])) begin
                            map_axis <= din[i];
                            fsm <= s2;
                        end
                    end
                    aborted_flag <= 1'b0;
                end

                s2 : begin
                    if (tx_axis_tready) begin
                        if (is_explic_underrun(map_axis)) begin
                            aborted_pkts <= aborted_pkts + 1;
                            aborted_flag <= 1'b1;
                        end

                        if (is_last(map_axis)) begin
                            if (!aborted_flag) begin
                                pushed_pkts <= pushed_pkts + 1;
                            end
                            else begin
                                aborted_flag <= 1'b0;
                            end
                            if (i == DATA_SIZE) begin
                                map_axis <= 'b0;
                                fsm <= s4;
                            end
                            else if (is_sof_val(din[i])) begin
                                map_axis <= din[i];
                                i <= i + 1;
                            end
                            else begin
                                map_axis <= 'b0;
                                fsm <= s1;
                            end
                        end
                        else if (is_valid(din[i])) begin
                            map_axis <= din[i];
                            if (i == DATA_SIZE) begin
                                fsm <= s3;
                            end
                            else begin
                                i <= i + 1;
                            end
                        end
                        else begin // implicit underrun
                            map_axis <= 'b0;
                            aborted_pkts <= aborted_pkts + 1;
                            fsm <= s1;
                        end
                    end
                end

                s3 : begin
                    if (tx_axis_tready) begin
                        map_axis <= 'b0;
                        if (is_last(map_axis)) begin
                            pushed_pkts <= pushed_pkts + 1;
                        end
                        else begin
                            aborted_pkts <= aborted_pkts + 1;
                        end
                        fsm <= s4;
                    end
                end

                s4 : begin
                    input_pkts_done <= 1'b1;
                    `pr("input_data_finishes")
                    fsm <= s5;
                end

                s5 : begin
                end

            endcase
        end
    end

    ////////////////////////////////////////////////
    // is_valid
    ////////////////////////////////////////////////
    function is_valid;
        input        [74:0]      d;
    begin
        if (d[0]) begin
            is_valid = 1'b1;
        end
        else begin
            is_valid = 1'b0;
        end
    end
    endfunction

    ////////////////////////////////////////////////
    // is_explic_underrun
    ////////////////////////////////////////////////
    function is_explic_underrun;
        input        [74:0]      d;
    begin
        if (d[2] && is_valid(d)) begin
            is_explic_underrun = 1'b1;
        end
        else begin
            is_explic_underrun = 1'b0;
        end
    end
    endfunction

    ////////////////////////////////////////////////
    // is_last
    ////////////////////////////////////////////////
    function is_last;
        input        [74:0]      d;
    begin
        if (d[1] && is_valid(d)) begin
            is_last = 1'b1;
        end
        else begin
            is_last = 1'b0;
        end
    end
    endfunction

    ////////////////////////////////////////////////
    // is_sof_val
    ////////////////////////////////////////////////
    function is_sof_val;
        input        [74:0]      d;
    begin
        if (is_valid(d) && !is_last(d) && !is_explic_underrun(d)) begin
            is_sof_val = 1'b1;
        end
        else begin
            is_sof_val = 1'b0;
        end
    end
    endfunction

endmodule // stim_axis_tx

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////