---
title: Building Midnight Commander on Synology NAS
date: 2019-11-03T23:49:50+01:00
---

We’ve got an ancient Synology NAS: DS212 from 2012. Now, we want to build a `mc`, so we can see a shiny blue double-panel file manager.

To make things more funny, let’s build from sources.

# Where are we?

Just out of curiosity, let’s see the version:

```shell
uname -a
```

Something like this should show up:

```text
Linux Vault 2.6.32.12 #24922 Tue Apr 23 17:32:06 CST 2019 armv5tel GNU/Linux synology_88f6282_212
```

# Let’s switch to root

For the sake of simplicity, let’s switch to the `root` user. This will save us many of `sudo` ed commands.

```shell
sudo su -
```

# Check the package manager status

Let’s assume that the package manager — `ipkg` is available.

Let’s update the list of available packages:

```shell
ipkg update
```

We should see an overview:

```
Downloading http://ipkg.nslu2-linux.org/optware-ng/buildroot-armv5eabi-ng/Packages.gz.
Inflating http://ipkg.nslu2-linux.org/optware-ng/buildroot-armv5eabi-ng/Packages.gz.
Updated list of available packages in /opt/lib/ipkg/lists/packages.
```

# Install all necessary packages

Since we’ll build `mc` from the scratch, we need the compilation toolchain.

```shell
ipkg install make gcc binutils gettext glib slang gconv-modules 
```

With fresh NAS installation, there is almost nothing available. Not even `make`, not even `gcc` and friends.

Some packages might take some time to download, no need to panic. The most heavy is the `gcc` with its 70MB of download.

# Download sources

Let’s create a temporary directory for `mc` sources:

```shell
mkdir /volume1/@tmp/mc
```

Then, let’s switch to that directory:

```shelll
cd /volume1/@tmp/mc
```

Time to download the sources via `wget`! We will pick the `.bz2` variant, as this one can be uncompressed without any additional fancy tools:

```shell
wget http://ftp.midnight-commander.org/mc-4.8.23.tar.bz2
```

Now let’s deflate:

```shell
tar xvjf mc-4.8.23.tar.bz2
```

As a reminder, the `j` parameter stands for `bz2` decompression.

Now, let’s dive into the deflated directory:

```
cd mc-4.8.23
```

Build from sources
==================

## Configure

Now is the time for the usual `configure` → `make`  → `make install`. 

However, `configure` will complain:

```
We might have old version of glib in global

checking for GLIB... no
configure: error: glib-2.0 not found or version too old (must be >= 2.26)
```

It’s attempting to pickup `glib` from Synology core system. Sadly, that one is really old. 

However, we have a newer version, installed locally via `ipkg`, in `/opt/lib`. Let’s export the necessary environment variables `GLIB_LIBS` and `GLIB_FLAGS`, pointing to proper locations.

```shell
export GLIB_LIBS="-L/opt/lib -lglib-2.0"
export GLIB_CFLAGS="-I/opt/include/glib-2.0 -I/opt/lib/glib-2.0/include"
```

Now, it’s `configure` time! Let’s run this from the `mc` sources root.

```shell
./configure --prefix=/opt --with-screen=slang --with-slang-includes=/opt/include --with-slang-libs=/opt/lib --enable-charset
```

Alternatively, we might run the one-liner:

```shell
GLIB_LIBS="-L/opt/lib -lglib-2.0" \
  GLIB_CFLAGS="-I/opt/include/glib-2.0 -I/opt/lib/glib-2.0/include" \
  ./configure --prefix=/opt --with-screen=slang --with-slang-includes=/opt/include --with-slang-libs=/opt/lib --enable-charset
```

## Make

Now that the project is configured, let’s simply build it:

```shell
make
```

After 20 minutes or so, the project will be compiled, built and prepared for installation. (Remember, that this is a poor ancient DS212 with 1.6GHz single-core).

## Install

Now let’s install it.

```shell
make install
```

The binary will be made available in the `/opt/bin/mc`.

Command the midnight! (And troubleshoot)
========================================

The resulting binary is rather tricky.

## Does the user have a home directory?

Verify that your user that is used to `ssh` has a properly set home directory. Otherwise, `mc` will complain:

```
admin@ds212:/$ /opt/bin/mc
Failed to run:
Cannot create /var/services/homes/admin/.config/mc directory
```

The obvious solution is to `sudo su -` to `root`.

## Is the `TERMINFO` properly set?

On some installation, the `TERMINFO` is not properly set. To be on the safe side, let’s verify:

```
admin@ds212:/$ echo $TERMINFO
/usr/share/terminfo
```

Let’s fix this:

```
export TERMINFO=/opt/share/terminfo
```

## Is the `TERM` properly set?

On some operating systems and some terminals, (ahm, MacOS + **iTerm2**), the `TERM` might not be properly understood by `mc`.

Let’s verify and fix:

```
admin@ds212:/$ echo $TERM
xterm-256color

export TERM=xterm
```

## Does `mc` show question marks in filenames?

Some term+OS combinations do not show international characters properly. Especially, blue panels show question marks instead of cyrillic or äôľščť.

Looks like this is connected to the `LC_` environment variables.

Let’s use the verified combo that should fix the issue.

```shell
export LANG="en_US.UTF-8" LC_COLLATE="en_US.UTF-8" LC_CTYPE="en_US.UTF-8" LC_MESSAGES="en_US.UTF-8" LC_MONETARY="en_US.UTF-8" LC_NUMERIC="en_US.UTF-8" LC_TIME="en_US.UTF-8" LC_ALL="";mc -X "/volume1/Data/Zalohy/downloads"
```

The relevant issue and workaround in `mc` ticket repository [has number 3827](https://midnight-commander.org/ticket/3827).

### Verify display bits

Make sure that *Options | Display Bits* is properly set:

- *Input / Display Code Page*: UTF-8
- *Full 8 bits input* is checked.

# Creating an overall running script

Let’s create a nifty script. As a `root`:

```shell
touch /opt/bin/mc-run.sh
chmod +x /opt/bin/mc-run.sh
vim /opt/bin/mc-run.sh
```

The contents will be simple:

```shell
export TERMINFO=/opt/share/terminfo TERM=xterm LANG="en_US.UTF-8" LC_COLLATE="en_US.UTF-8" LC_CTYPE="en_US.UTF-8" LC_MESSAGES="en_US.UTF-8" LC_MONETARY="en_US.UTF-8" LC_NUMERIC="en_US.UTF-8" LC_TIME="en_US.UTF-8" LC_ALL="";mc -c "$@"
```

## Aliasing

Now, we can edit the profile file, and alias `mc` properly, to save many keystrokes:

Let’s run the editor

```powershell
vim /root/.profile
```

Let’s add a simple line:

```
alias mc="/opt/bin/mc-run.sh
```

All future sessions will use the aliased `mc` command. In the current session, as a `root`, we can `source ~/.profile` to apply changes instantly.

References
==========

- The old Synology forum provides an archived approach, [in Russian](https://web.archive.org/web/20130109030330/http://www.synology-forum.ru/wiki/index.php/Midnight_Commander).

