##
## IMAP specific settings
##

protocol imap {
  # Maximum IMAP command line length. Some clients generate very long command
  # lines with huge mailboxes, so you may need to raise this if you get
  # "Too long argument" or "IMAP command line too large" errors often.
  #imap_max_line_length = 64k

  # Maximum number of IMAP connections allowed for a user from each IP address.
  # NOTE: The username is compared case-sensitively.
  mail_max_userip_connections = <%= $variables->{mail_max_userip_connections} %>

  # Space separated list of plugins to load (default is global mail_plugins).
  #mail_plugins = $mail_plugins

  # IMAP logout format string:
  # %i - total number of bytes read from client
  # %o - total number of bytes sent to client
  #imap_logout_format = bytes=%i/%o

  # Override the IMAP CAPABILITY response. If the value begins with '+',
  # add the given capabilities on top of the defaults (e.g. +XFOO XBAR).
  #imap_capability =

  # How long to wait between "OK Still here" notifications when client is
  # IDLEing.
  #imap_idle_notify_interval = 2 mins

  # ID field names and values to send to clients. Using * as the value makes
  # Dovecot use the default value. The following fields have default values
  # currently: name, version, os, os-version, support-url, support-email.
  #imap_id_send =

  # ID fields sent by client to log. * means everything.
  #imap_id_log =

  # Workarounds for various client bugs:
  # delay-newmail:
  # Send EXISTS/RECENT new mail notifications only when replying to NOOP
  # and CHECK commands. Some clients ignore them otherwise, for example OSX
  # Mail (<v2.1). Outlook Express breaks more badly though, without this it
  # may show user "Message no longer in server" errors. Note that OE6 still
  # breaks even with this workaround if synchronization is set to
  # "Headers Only".
  # tb-extra-mailbox-sep:
  # With mbox storage a mailbox can contain either mails or submailboxes,
  # but not both. Thunderbird separates these two by forcing server to
  # accept '/' suffix in mailbox names in subscriptions list.
  # The list is space-separated.
  #imap_client_workarounds =
}
