# SuspendFix

After installing openSUSE on my MacBook Air (mid-2013), I found an issue about suspending: after a few times of closing and opening lids, the machine cannot go to sleep and wake up immediately after closing the lids.

Running `cat /proc/acpi/wakeup` gets following results:

```bash
Device  S-state   Status   Sysfs node
P0P2      S3    *disabled
EC        S3    *disabled  platform:PNP0C09:00
HDEF      S3    *disabled  pci:0000:00:1b.0
RP01      S3    *enabled   pci:0000:00:1c.0
RP02      S3    *enabled   pci:0000:00:1c.1
RP03      S3    *enabled   pci:0000:00:1c.2
ARPT      S4    *disabled  pci:0000:03:00.0
RP05      S3    *enabled   pci:0000:00:1c.4
RP06      S3    *enabled   pci:0000:00:1c.5
SPIT      S3    *disabled
XHC1      S3    *enabled   pci:0000:00:14.0
ADP1      S3    *disabled  platform:ACPI0003:00
LID0      S3    *enabled   platform:PNP0C0D:00
```

My solution is: disable all devices here except `LID0`. If you set the state of `LID0` to disabled, you will lose the functionality of waking up automatically after opening the lid, and have to press the power button to wake up the machine.

I wrote the bash script `wakeup.sh` to disable those enabled devices:

```bash
#!/bin/bash
echo RP01 > /proc/acpi/wakeup
echo RP02 > /proc/acpi/wakeup
echo RP03 > /proc/acpi/wakeup
echo RP05 > /proc/acpi/wakeup
echo RP06 > /proc/acpi/wakeup
echo XHC1 > /proc/acpi/wakeup
```

After running it, the output of `cat /proc/acpi/wakeup` will be:

```bash
Device  S-state   Status   Sysfs node
P0P2      S3    *disabled
EC        S3    *disabled  platform:PNP0C09:00
HDEF      S3    *disabled  pci:0000:00:1b.0
RP01      S3    *disabled  pci:0000:00:1c.0
RP02      S3    *disabled  pci:0000:00:1c.1
RP03      S3    *disabled  pci:0000:00:1c.2
ARPT      S4    *disabled  pci:0000:03:00.0
RP05      S3    *disabled  pci:0000:00:1c.4
RP06      S3    *disabled  pci:0000:00:1c.5
SPIT      S3    *disabled
XHC1      S3    *disabled  pci:0000:00:14.0
ADP1      S3    *disabled  platform:ACPI0003:00
LID0      S3    *enabled   platform:PNP0C0D:00
```

Run this script first and then try to suspend and wakeup. There will be no problems.

To run this script each time the machine starts, I wrote `wakeupfix.service` to run it at boot time:

```bash
[Unit]
Description=wakeup-fix

[Service]
ExecStart=/bin/bash -c '/home/zhao/Documents/Projects/SuspendFix/wakeup.sh'

[Install]
WantedBy=multi-user.target
```

Modify the path to the real location of the script.

Copy `wakeupfix.service` to `/etc/systemd/system/`:

```bash
sudo cp wakeupfix.service /etc/systemd/system/
```

Then enable it:

```bash
sudo systemctl daemon-reload
sudo systemctl enable wakeupfix.service
```

Restart the machine and run `cat /proc/acpi/wakeup` to see whether it works or not.
