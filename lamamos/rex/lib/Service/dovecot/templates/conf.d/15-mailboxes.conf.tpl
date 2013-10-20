##
## Mailbox definitions
##

# NOTE: Assumes "namespace inbox" has been defined in 10-mail.conf.
namespace inbox {

  #mailbox name {
    # auto=create will automatically create this mailbox.
    # auto=subscribe will both create and subscribe to the mailbox.
    #auto = no

    # Space separated list of IMAP SPECIAL-USE attributes as specified by
    # RFC 6154: \All \Archive \Drafts \Flagged \Junk \Sent \Trash
    #special_use =
  #}

  # These mailboxes are widely used and could perhaps be created automatically:
  inbox = yes

  mailbox Drafts {
    special_use = \Drafts
  }
  mailbox Junk {
    special_use = \Junk
  }
  mailbox Trash {
    special_use = \Trash
  }

  # For \Sent mailboxes there are two widely used names. We'll mark both of
  # them as \Sent. User typically deletes one of them if duplicates are created.
  mailbox Sent {
    special_use = \Sent
  }
  mailbox "Sent Messages" {
    special_use = \Sent
  }

  # If you have a virtual "All messages" mailbox:
  #mailbox virtual/All {
  # special_use = \All
  #}

  # If you have a virtual "Flagged" mailbox:
  #mailbox virtual/Flagged {
  # special_use = \Flagged
  #}
}
