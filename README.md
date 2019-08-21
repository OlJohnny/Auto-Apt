# Auto-Apt

Simple Script to automatically update &amp; upgrade packages on a Debian based Linux System

## How to use

### When executing the script without any argument (``sudo ./auto-apt.sh``) the script will do the following (asking for verification at each step):
- ``remove`` common Desktop packages not needed in a VM-Environment (specific to my intended usecase, change if necessary: Line 31)
- ``update`` the package list and show the upgradeable packages
- ``upgrade`` all packages
- ``install`` commonly used packages (specific to my intended usecase, change if necessary: Line 38)
- ``autoremove`` no longer needed packages

### When executing the scripting with any argument (e.g. ``sudo ./auto-apt.sh c``) the script will automatically do the following (without asking for verification, intended for use in a cron-job):
- ``update`` the package list and show the upgradeable packages
- ``upgrade`` all packages
- ``autoremove`` no longer needed packages

Have feedback? Let me know via an 'Issue'