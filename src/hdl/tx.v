/*******************************************************************************
*
*  NetFPGA-10G http://www.netfpga.org
*
*  File:
*        tx.v
*
*  Project:
*
*
*  Author:
*        Marco Forconesi
*
*  Description:
*        Tx module.
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

module tx (

    // Clks and resets
    input                    clk,
    input                    rst,

    // Conf vectors
    input        [79:0]      configuration_vector,

    // XGMII
    output       [63:0]      xgmii_txd,
    output       [7:0]       xgmii_txc,

    // AXIS
    input                    axis_aresetn,
    input        [63:0]      axis_tdata,
    input        [7:0]       axis_tkeep,
    input                    axis_tvalid,
    output                   axis_tready,
    input                    axis_tlast,
    input        [0:0]       axis_tuser
    );

    //-------------------------------------------------------
    // Local padding_ctrl
    //-------------------------------------------------------
    // S
    wire         [63:0]      s_axis_tdata;
    wire         [7:0]       s_axis_tkeep;
    wire                     s_axis_tvalid;
    wire                     s_axis_tready;
    wire                     s_axis_tlast;
    wire         [0:0]       s_axis_tuser;
    // M
    wire         [63:0]      m_axis_tdata;
    wire         [7:0]       m_axis_tkeep;
    wire                     m_axis_tvalid;
    wire                     m_axis_tready;
    wire                     m_axis_tlast;
    wire         [0:0]       m_axis_tuser;
    // internal
    wire                     lane4_start;
    wire         [1:0]       dic;

    //-------------------------------------------------------
    // assigns
    //-------------------------------------------------------
    assign s_axis_tdata = axis_tdata;
    assign s_axis_tkeep = axis_tkeep;
    assign s_axis_tvalid = axis_tvalid;
    assign axis_tready = s_axis_tready;
    assign s_axis_tlast = axis_tlast;
    assign s_axis_tuser = axis_tuser;

    //-------------------------------------------------------
    // padding_ctrl
    //-------------------------------------------------------
    padding_ctrl padding_ctrl_mod (
        .clk(clk),                                             // I
        .rst(rst),                                             // I
        // AXIS In
        .aresetn(axis_aresetn),                                // I
        .s_axis_tdata(s_axis_tdata),                           // I [63:0]
        .s_axis_tkeep(s_axis_tkeep),                           // I [7:0]
        .s_axis_tvalid(s_axis_tvalid),                         // I
        .s_axis_tready(s_axis_tready),                         // O
        .s_axis_tlast(s_axis_tlast),                           // I
        .s_axis_tuser(s_axis_tuser),                           // I [0:0]
        // AXIS Out
        .m_axis_tdata(m_axis_tdata),                           // O [63:0]
        .m_axis_tkeep(m_axis_tkeep),                           // O [7:0]
        .m_axis_tvalid(m_axis_tvalid),                         // O
        .m_axis_tready(m_axis_tready),                         // I
        .m_axis_tlast(m_axis_tlast),                           // O
        .m_axis_tuser(m_axis_tuser),                           // O [0:0]
        // internal
        .lane4_start(lane4_start),                             // I
        .dic(dic)                                              // I [1:0]
        );

    //-------------------------------------------------------
    // axis2xgmii
    //-------------------------------------------------------
    axis2xgmii axis2xgmii_mod (
        .clk(clk),                                             // I
        .rst(rst),                                             // I
        // Conf vectors
        .configuration_vector(configuration_vector),           // I [79:0]
        // internal
        .lane4_start(lane4_start),                             // O
        .dic_o(dic),                                           // O [1:0]
        // XGMII
        .xgmii_d(xgmii_txd),                                   // O [63:0]
        .xgmii_c(xgmii_txc),                                   // O [7:0]
        // AXIS
        .tdata(m_axis_tdata),                                  // I [63:0]
        .tkeep(m_axis_tkeep),                                  // I [7:0]
        .tvalid(m_axis_tvalid),                                // I
        .tready(m_axis_tready),                                // O
        .tlast(m_axis_tlast),                                  // I
        .tuser(m_axis_tuser)                                   // I [0:0]
        );

endmodule // tx

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////