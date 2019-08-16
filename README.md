# SuspendFix

### Problem

After installing openSUSE on my MacBook Air (mid-2013), I found an issue about suspending: after a few times of closing and opening lids, the machine cannot go to sleep and wake up immediately after closing the lids.

### Solution

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

These enabled devices causes the computer to wake up immediately after suspending.

To change the status of a device, for example, `XHC1`, run the following command:

```bash
echo XHC1 | sudo tee /proc/acpi/wakeup
```

After that, the status of `XHC1` will change:

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
XHC1      S3    *disabled  pci:0000:00:14.0
ADP1      S3    *disabled  platform:ACPI0003:00
LID0      S3    *enabled   platform:PNP0C0D:00
```

Change the status of all devices except `LID0` to disabled, and try to suspend. The suspending function will work properly now.

If you set the status of `LID0` to disabled, you will lose the function of waking up the computer by opening its lid. Instead, you have to press the power button. So I recommend to leave it enabled.

### Automation Script

I have written a script (`SuspendFix.sh`) to disable all devices except `LID0`:

```bash
#!/bin/bash
echo RP01 | tee /proc/acpi/wakeup
echo RP02 | tee /proc/acpi/wakeup
echo RP03 | tee /proc/acpi/wakeup
echo RP05 | tee /proc/acpi/wakeup
echo RP06 | tee /proc/acpi/wakeup
echo XHC1 | tee /proc/acpi/wakeup
```

Test it with root permission:

```bash
sudo ./SuspendFix.sh
```

And examine the effect with `cat /proc/acpi/wakeup`.

Copy the script to `/usr/bin`:

```bash
sudo cp SuspendFix.sh /usr/bin/
```

### Autostart

To run this script each time the machine starts automatically, I wrote a service (`SuspendFix.service`):

```bash
[Unit]
Description=SuspendFix

[Service]
ExecStart=/bin/bash SuspendFix.sh

[Install]
WantedBy=multi-user.target
```

If you have not copied `Suspend.sh` to `/usr/bin`, you have to change the line `ExecStart` in `SuspendFix.service` and ensure that the location of the script is correct.

Copy `SuspendFix.service` to `/etc/systemd/system/`:

```bash
sudo cp SuspendFix.service /etc/systemd/system/
```

Then enable it:

```bash
sudo systemctl daemon-reload
sudo systemctl enable SuspendFix.service
```

Restart the machine and run `cat /proc/acpi/wakeup`. All devices except `LID0` will be set to disabled and suspending might works properly.
