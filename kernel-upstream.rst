Linux Kernel Upstream Patch Submission Guide
============================================

This document describes an **end-to-end, practical workflow** for contributing
patches to the Linux kernel.  
It covers source cloning, tool installation, cross-compilation, patch creation,
validation, maintainer identification, and upstream submission via email.

Target audience
---------------
- Embedded Linux developers
- Kernel contributors (new and experienced)
- Engineers preparing for upstream / LFX / kernel interviews

------------------------------------------------------------

1. Clone Linux Kernel Source
============================


Stable kernel
-------------
::

    git clone https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
    cd linux

Mainline kernel (Maintain by Linus Torvalds)
--------------------------------------------
::

    git clone https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
    cd linux

Linux-next (Integration of all subsystem maintainer tree)
---------------------------------------------------------
::

    git clone https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
    cd linux-next

Configure author identity (mandatory) and preferred editor
----------------------------------------------------------
::

    git config --global user.name "Your Name"
    git config --global user.email "your.email@gmail.com"
    git config --global format.signoff "true"
    git config --global core.editor "vim"

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
        ccache \
        python3 python3-pip \
        rsync wget curl

Kernel contribution tools
-------------------------
::

    sudo apt install -y \
        git-email \
        patchutils \
        b4

------------------------------------------------------------

3. Install Cross Toolchains
==========================

ARM64 (AArch64)
---------------
::

    sudo apt install -y gcc-aarch64-linux-gnu

ARM (32-bit)
------------
::

    sudo apt install -y gcc-arm-linux-gnueabihf

RISC-V
------
::

    sudo apt install -y gcc-riscv64-linux-gnu

------------------------------------------------------------

4. Build the Kernel
==================

x86_64 (native build)
--------------------
::

    make defconfig
    make -j$(nproc)

ARM64
-----
::

    export ARCH=arm64
    export CROSS_COMPILE=aarch64-linux-gnu-

    make defconfig
    make -j$(nproc)

ARM (32-bit)
------------
::

    export ARCH=arm
    export CROSS_COMPILE=arm-linux-gnueabihf-

    make multi_v7_defconfig
    make -j$(nproc)

RISC-V
------
::

    export ARCH=riscv
    export CROSS_COMPILE=riscv64-linux-gnu-

    make defconfig
    make -j$(nproc)

------------------------------------------------------------

5. Create Patch
===============

Make your changes and commit them
---------------------------------
::

    git status
    git diff
    git commit -s

Generate patch
--------------
Single patch:
::

    git format-patch -1

Patch series with cover letter:
::
    
    git format-patch origin/master --cover-letter -n

------------------------------------------------------------

6. Patch Quality Checks (MANDATORY)
==================================

Run checkpatch
--------------
::

    ./scripts/checkpatch.pl 0001-*.patch

Rules
-----
- All ``ERROR:`` **must** be fixed
- ``WARNING:`` should be fixed unless clearly justified
- Avoid introducing new warnings

------------------------------------------------------------

7. Identify Maintainers and Mailing Lists
=========================================

Use kernel-provided script
--------------------------
::

    scripts/get_maintainer.pl 0001-*.patch

Typical output
--------------
::

    Maintainer Name <maintainer@kernel.org> (maintainer: SUBSYSTEM)
    linux-subsystem@vger.kernel.org
    linux-kernel@vger.kernel.org

Usage rule
----------
- Maintainers → ``--to``
- Mailing lists → ``--cc``

Generate `git send-email` command using shell
---------------------------------------------
::

    echo git send-email \
    $(scripts/get_maintainer.pl 000*.patch \
    | sed -n \
        -e '/maintainer/ s/.*<\(.*\)>.*/--to \1/p' \
        -e '/open list/ s/.*<\(.*\)>.*/--cc \1/p' \
        -e '/maintainer/!{/open list/! s/.*<\(.*\)>.*/--cc \1/p}')

------------------------------------------------------------

8. Configure git send-email (Gmail)
==================================

Gmail prerequisites
-------------------
- Enable **2-Step Verification**
- Generate **App Password**

Git configuration
-----------------
Edit ``~/.gitconfig``:
::

    [sendemail]
        smtpserver = smtp.gmail.com
        smtpserverport = 587
        smtpencryption = tls
        smtpuser = yourname@gmail.com
        from = Your Name <yourname@gmail.com>
        confirm = auto
        suppresscc = all

Test email
----------
::
    
    echo "Dummy patch for testing" > test.patch
    git send-email --to yourname@gmail.com test.patch

------------------------------------------------------------

9. Send Patch to Upstream
========================

Single patch
------------
::

    git send-email 0001-*.patch \
        --to maintainer@kernel.org \
        --cc linux-subsystem@vger.kernel.org \
        --cc linux-kernel@vger.kernel.org

Patch series
------------
::

    git send-email 000*.patch \
        --to maintainer@kernel.org \
        --cc linux-subsystem@vger.kernel.org \
        --cc linux-kernel@vger.kernel.org

------------------------------------------------------------

10. Verify Patch Submission
===========================

After sending, confirm your patch appears on:
::

    https://lore.kernel.org/all/

Search using:
- Your name
- Patch subject

If visible, the patch is **successfully submitted upstream**.

------------------------------------------------------------

11. Handle Review Feedback
=========================

- Reply inline to reviewer comments
- Fix issues locally
- Generate next version

Example (v2):
::
    
    git format-patch -v2 origin/master --cover-letter -n
    git send-email 000*.patch

------------------------------------------------------------

12. Using b4 (Recommended)
=========================

Fetch patch series
------------------
::

    b4 am <message-id>

Prepare next revision
---------------------
::

    b4 prep --edit cover

------------------------------------------------------------

13. Pre-Submission Checklist
============================

- [ ] Correct subsystem and mailing list
- [ ] ``Signed-off-by`` present
- [ ] ``checkpatch.pl`` clean
- [ ] Kernel builds without errors
- [ ] No whitespace or formatting issues
- [ ] Clear and concise commit message
- [ ] Tested on relevant architecture

------------------------------------------------------------

References
==========

- Linux kernel patch submission:
  https://www.kernel.org/doc/html/latest/process/submitting-patches.html

- b4 documentation:
  https://b4.docs.kernel.org/

- Mailing list archive:
  https://lore.kernel.org
