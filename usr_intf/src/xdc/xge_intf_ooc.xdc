# Marco Forconesi

create_clock -period 6.400 [get_ports m_axis_mac_aclk]
create_clock -period 6.400 [get_ports s_axis_mac_aclk]
create_clock -period 6.400 [get_ports s_axis_aclk]
create_clock -period 6.400 [get_ports m_axis_aclk]
