/*******************************************************************************
*
*  NetFPGA-10G http://www.netfpga.org
*
*  File:
*        xge_intf.v
*
*  Project:
*
*
*  Author:
*        Marco Forconesi
*
*  Description:
*        Interfaces the user logic and the MAC with back pressure capable axis.
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

module xge_intf (

    // MAC Tx
    input                    m_axis_mac_aclk,
    input                    m_axis_mac_aresetn,
    output       [63:0]      m_axis_mac_tdata,
    output       [7:0]       m_axis_mac_tkeep,
    output                   m_axis_mac_tvalid,
    output                   m_axis_mac_tlast,
    output                   m_axis_mac_tuser,
    input                    m_axis_mac_tready,

    // MAC Rx
    input                    s_axis_mac_aclk,
    input                    s_axis_mac_aresetn,
    input        [63:0]      s_axis_mac_tdata,
    input        [7:0]       s_axis_mac_tkeep,
    input                    s_axis_mac_tvalid,
    input                    s_axis_mac_tlast,
    input                    s_axis_mac_tuser,

    // Usr Tx
    input                    s_axis_aclk,
    input                    s_axis_aresetn,
    input        [63:0]      s_axis_tdata,
    input        [7:0]       s_axis_tkeep,
    input                    s_axis_tvalid,
    input                    s_axis_tlast,
    output                   s_axis_tready,

    // Usr Rx
    input                    m_axis_aclk,
    input                    m_axis_aresetn,
    output       [63:0]      m_axis_tdata,
    output       [7:0]       m_axis_tkeep,
    output                   m_axis_tvalid,
    output                   m_axis_tlast,
    input                    m_axis_tready
    );

    //-------------------------------------------------------
    // mac2axis
    //-------------------------------------------------------
    mac2axis #(
        .AW(9)
    ) mac2axis_mod (
        // MAC Rx
        .s_axis_mac_aclk(s_axis_mac_aclk),                     // I
        .s_axis_mac_aresetn(s_axis_mac_aresetn),               // I
        .s_axis_mac_tdata(s_axis_mac_tdata),                   // I [63:0]
        .s_axis_mac_tkeep(s_axis_mac_tkeep),                   // I [7:0]
        .s_axis_mac_tvalid(s_axis_mac_tvalid),                 // I
        .s_axis_mac_tlast(s_axis_mac_tlast),                   // I
        .s_axis_mac_tuser(s_axis_mac_tuser),                   // I
        // Usr Rx
        .m_axis_aclk(m_axis_aclk),                             // I
        .m_axis_aresetn(m_axis_aresetn),                       // I
        .m_axis_tdata(m_axis_tdata),                           // O [63:0]
        .m_axis_tkeep(m_axis_tkeep),                           // O [7:0]
        .m_axis_tvalid(m_axis_tvalid),                         // O
        .m_axis_tlast(m_axis_tlast),                           // O
        .m_axis_tready(m_axis_tready)                          // I
        );

    //-------------------------------------------------------
    // axis2mac
    //-------------------------------------------------------
    axis2mac #(
        .AW(9)
    ) axis2mac_mod (
        // MAC Tx
        .m_axis_mac_aclk(m_axis_mac_aclk),                     // I
        .m_axis_mac_aresetn(m_axis_mac_aresetn),               // I
        .m_axis_mac_tdata(m_axis_mac_tdata),                   // O [63:0]
        .m_axis_mac_tkeep(m_axis_mac_tkeep),                   // O [7:0]
        .m_axis_mac_tvalid(m_axis_mac_tvalid),                 // O
        .m_axis_mac_tlast(m_axis_mac_tlast),                   // O
        .m_axis_mac_tuser(m_axis_mac_tuser),                   // O
        .m_axis_mac_tready(m_axis_mac_tready),                 // I
        // Usr Tx
        .s_axis_aclk(s_axis_aclk),                             // I
        .s_axis_aresetn(s_axis_aresetn),                       // I
        .s_axis_tdata(s_axis_tdata),                           // I [63:0]
        .s_axis_tkeep(s_axis_tkeep),                           // I [7:0]
        .s_axis_tvalid(s_axis_tvalid),                         // I
        .s_axis_tlast(s_axis_tlast),                           // I
        .s_axis_tready(s_axis_tready)                          // O
        );

endmodule // xge_intf

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////