# jabber_cat

Like irc_cat but jabber_cat. 

## Example

    jabber_cat.rb -p 9000 -k ~/.secretkey -w test@test.com/test

## Options

 * --port|-p: which port to listen on (default: 9999)
 * --host|-h: which host to listen on (default: localhost)
 * --whoto|-w: jabber JID to send notices to
 * --muc|-m: whether the jabber JID is a client or a conference
 * --config|-c: configuration file (default: $HOME/.jabber_cat)
 * --key|-k: shared key for authentication
 * --verbose|-v: spam stdout with chatter
 * --debug|-d: spam stdout with debugging
