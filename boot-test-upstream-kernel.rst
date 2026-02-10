Booting a Linux Distrubtion with an Upstream or Stable Kernel
=============================================================

This document describes how to **build, install, and boot an upstream or stable
Linux kernel on a distribution** (Ubuntu validated) for **patch testing and
validation**.

It is intended for contributors who already understand upstream development
and want to **test their changes on a real distribution kernel**.

Target audience
---------------
- Kernel contributors
- LFX mentees
- Developers validating upstream or stable patches

------------------------------------------------------------

1. Clone Linux Kernel Source
===========================

Stable kernel
-------------
::

    git clone https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
    cd linux

Mainline kernel (Maintained by Linus Torvalds)
---------------------------------------------
::

    git clone https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
    cd linux

------------------------------------------------------------

2. Install Required Tools
========================

Base build tools
----------------
::

    sudo apt update
    sudo apt install -y \
        git gcc make bc bison flex \
        libssl-dev libelf-dev \
        dwarves pahole \
        python3 rsync wget curl

------------------------------------------------------------

3. Kernel Configuration for Distribution Boot
==============================================

For booting an upstream or stable kernel on a distribution, it is recommended
to reuse the configuration of the currently running kernel to preserve hardware
support.

Copy the running kernel configuration
-------------------------------------
::

    cp /boot/config-$(uname -r) .config

Disable certificate-related options
-----------------------------------
::

    scripts/config --disable SYSTEM_TRUSTED_KEYS
    scripts/config --disable SYSTEM_REVOCATION_KEYS

Update configuration
--------------------
::

    make olddefconfig

Why olddefconfig
----------------
- Avoids interactive configuration prompts
- Automatically selects defaults for new options
- Preferred when rebasing onto newer kernels

------------------------------------------------------------

4. Build the Kernel
==================
::

    make -j$(nproc)

------------------------------------------------------------

5. Install Kernel and Modules
=============================
::

    sudo make modules_install
    sudo make install

------------------------------------------------------------

6. Ubuntu-Specific GRUB Notes
=============================

To simplify kernel selection and aid debugging during upstream testing, adjust
GRUB configuration settings.

Edit GRUB configuration
-----------------------
::

    sudo nano /etc/default/grub

Recommended settings
--------------------
::

    GRUB_TIMEOUT=10
    # GRUB_TIMEOUT_STYLE=hidden
    GRUB_CMDLINE_LINUX="earlyprintk=vga"

Update GRUB configuration
------------------------
::

    sudo update-grub

------------------------------------------------------------

7. Boot the New Kernel (Ubuntu)
===============================

Reboot the system
-----------------
::

    reboot

At the GRUB menu:
- Select **Advanced options**
- Choose the newly installed kernel

Verify running kernel
---------------------
::

    uname -r

------------------------------------------------------------

8. Collecting Logs
==================

These logs are commonly requested during upstream review and bug reports.

Allow unrestricted dmesg access
-------------------------------
::

    sudo sysctl kernel.dmesg_restrict=0

Collect runtime information
---------------------------
::

    lsmod > $(uname -r)-lsmod
    sudo dmesg -t > dmesg_current.log
    sudo dmesg -t -k > dmesg_kernel.log
    sudo dmesg -t -l emerg > dmesg_current_emerg.log
    sudo dmesg -t -l alert > dmesg_current_alert.log
    sudo dmesg -t -l crit > dmesg_current_crit.log
    sudo dmesg -t -l err > dmesg_current_err.log
    sudo dmesg -t -l warn > dmesg_current_warn.log
    sudo dmesg -t -l info > dmesg_current_info.log

------------------------------------------------------------

9. Notes
========

- Document validated on Ubuntu
- Bootloader behavior may vary across distributions
- Always keep at least one known-good kernel installed
- Fedora and other distributions can be added once validated
