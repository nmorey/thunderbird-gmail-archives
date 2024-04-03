# Fix thunderbird archiving for GMail

For some reason, Thunderbird disables the usual archive mode for GMail IMAP mailboxes.
For those of us, used to sorting old emails per year, year/month and so on, this is very annoying.

Luckily the code just works, it is just disabled when TB detects a GMail server.
This patches TB internal JS so any IMAP server is never detected as GMail.
With this, regular archiving can be enabled and setup the way you want it to.

It requires:
- patch
- zip
- a non-system (ie user modifiable) TB install

Supported versions are listed in the patches directory
If the patch does not apply, it won't change anything to TB, so very low risk.

With thunderbird not started, simply run:
`fix-thunderbird.sh /path/to/TB/install/directory`
The original omni.ja is saved in /path/to/TB/install/directory/omni.ja.bak