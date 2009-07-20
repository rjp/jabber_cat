# jabber_cat

    # send to the test@test.com/test user anything we get on port 9000
    jabber_cat.rb -p 9000 -w test@test.com/test

jabber_cat performs a similar function to [irc_cat][] but with an output target of Jabber rather than IRC.

Messages sent to a socket are forwarded on to a Jabber user or muc.  Currently only single-line messages are supported.

[irc_cat]: http://irccat.rubyforge.org/


## Shared key

To prevent accidental or malicious usage, jabber_cat supports a "secret
key" where only input messages tagged with the correct key will be
passed to the jabber ouput.

Currently this is only specifiable as a filename: the contents of this
file (minus any terminating newline character) will be used as the
shared key.

If a shared key has been loaded, any incoming messages must be prefixed
with "%/$key/% " (percent, slash, shared key, slash, percent, space).

That is, they must match the regular expression (in ruby
syntax) `%r{^%/$key/% }` which will be stripped before the
message is sent onwards. If they do not match, the line will be silently
dropped.

## Options

If not specified in the configuration file, `whoto` must be specified
with the `--whoto` or `-w` option.

 * --port|-p: which port to listen on (default: 9999)
 * --host|-h: which host to listen on (default: localhost)
 * --whoto|-w: jabber JID to send notices to
 * --muc|-m: whether the jabber JID is a client or a conference
 * --config|-c: configuration file (default: $HOME/.jabber_cat)
 * --key|-k: shared key for authentication
 * --verbose|-v: spam stdout with chatter
 * --debug|-d: spam stdout with debugging

## Configuration file

Holds the Jabber connection information of the account messages are sent from.  

Can also contain any of the options listed above specified in their long form.

### Minimal example

jabber_cat listening on 127.0.0.1, port 9999, sending to client JID
specified on the commandline.

    myjid: iamklute@day.stillearth.world.com
    mypass: klaatu

### Maximal example

jabber_cat listening on listener.world.com, port 9809, sending
to non-muc client gort@moody.robots.com, using the shared key in
`$HOME/.jabber_cat.key` for authentication.

    myjid: iamklute@day.stillearth.world.com
    mypass: klaatu
    port: 9809
    host: listener.world.com
    whoto: gort@moody.robots.com
    muc: false
    key: ~/.jabber_cat.key
