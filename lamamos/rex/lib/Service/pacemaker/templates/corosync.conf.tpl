totem {
	version: 2

	# How long before declaring a token lost (ms)
	token: 5000

	# How many token retransmits before forming a new configuration
	token_retransmits_before_loss_const: 20

	# How long to wait for join messages in the membership protocol (ms)
	join: 1000

	# How long to wait for consensus to be achieved before starting a new round of membership configuration (ms)
	consensus: 7500

	# Turn off the virtual synchrony filter
	vsftype: none

	# Number of messages that may be sent by one processor on receipt of the token
	max_messages: 20

	# Limit generated nodeids to 31-bits (positive signed integers)
	clear_node_high_bit: yes

	# Disable encryption
 	secauth: <%= $variables->{enable_secauth} %>

	# How many threads to use for encryption/decryption
 	threads: 0

	# Optionally assign a fixed node id (integer)
	# nodeid: 1234

	# This specifies the mode of redundant ring, which may be none, active, or passive.
 	rrp_mode: none

 	interface {
		# The following values need to be set based on your environment 
		ringnumber: 0
		bindnetaddr: <%= $variables->{bind_address} %> 
		mcastaddr: <%= $variables->{multicast_address} %>
		mcastport: 5405
	}
}

amf {
	mode: disabled
}

service {
 	# Load the Pacemaker Cluster Resource Manager
 	ver:       1
 	name:      pacemaker
}

aisexec {
        user:   root
        group:  root
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
