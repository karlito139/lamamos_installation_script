compatibility: whitetank

totem {
  version: 2
  token: 3000
  token_retransmits_before_loss_const: 10
  join: 60
  consensus: 3600
  vsftype: none
  max_messages: 20
  clear_node_high_bit: yes
  rrp_mode: none
  secauth: <%= $variables->{enable_secauth} %>
  threads: 1
  interface {
    ringnumber: 0
    bindnetaddr: <%= $variables->{bind_address} %>
    mcastaddr: <%= $variables->{multicast_address} %>
    mcastport: 5405
  }
}

logging {
  fileline: off
  to_stderr: yes
  to_logfile: no
  to_syslog: yes
  syslog_facility: daemon
  debug: off
  timestamp: on
  logger_subsys {
    subsys: AMF
    debug: off
    tags: enter|leave|trace1|trace2|trace3|trace4|trace6
  }
}

amf {
  mode: disabled
}

aisexec {
  user: root
  group: root
}
