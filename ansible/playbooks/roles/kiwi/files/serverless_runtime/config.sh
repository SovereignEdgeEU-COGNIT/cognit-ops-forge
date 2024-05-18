#!/bin/bash

##################
# openSUSE stuff #
##################

#================
# FILE          : config.sh
#----------------
# PROJECT       : OpenSuSE KIWI Image System
# COPYRIGHT     : (c) 2006 SUSE LINUX Products GmbH. All rights reserved
#               :
# AUTHOR        : Marcus Schaefer <ms@suse.de>
#               :
# BELONGS TO    : Operating System images
#               :
# DESCRIPTION   : configuration script for SUSE based
#               : operating systems
#               :
#               :
# STATUS        : BETA
#----------------
#======================================
# Functions...
#--------------------------------------
test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile

#======================================
# Greeting...
#--------------------------------------
echo "Configure image: [$kiwi_iname]..."

#======================================
# Setup baseproduct link
#--------------------------------------
suseSetupProduct

#======================================
# Activate services
#--------------------------------------
suseInsertService sshd
suseInsertService grub_config
suseInsertService dracut_hostonly

#======================================
# Setup default target, multi-user
#--------------------------------------
baseSetRunlevel 3

##############
# OpenNebula #
##############

# Set kernel command line (net.ifnames=0 is particularily important),
# then update initramfs/initrd and grub2.

rm -rf /etc/default/grub.d/

# Drop unwanted.

gawk -i inplace -f- /etc/default/grub <<'EOF'
/^GRUB_CMDLINE_LINUX_DEFAULT=/ { gsub(/\<quiet\>/, "") }
/^GRUB_CMDLINE_LINUX_DEFAULT=/ { gsub(/\<splash\>/, "") }
/^GRUB_CMDLINE_LINUX_DEFAULT=/ { gsub(/\<console=ttyS[^ ]*\>/, "") }
/^GRUB_CMDLINE_LINUX_DEFAULT=/ { gsub(/\<earlyprintk=ttyS[^ ]*\>/, "") }
/^GRUB_CMDLINE_LINUX_DEFAULT=/ { gsub(/\<crashkernel=[^ ]*\>/, "crashkernel=no") }
{ print }
EOF

# Ensure required.

gawk -i inplace -f- /etc/default/grub <<'EOF'
/^GRUB_CMDLINE_LINUX=/ { found = 1 }
/^GRUB_CMDLINE_LINUX=/ && !/net.ifnames=0/ { gsub(/"$/, " net.ifnames=0\"") }
/^GRUB_CMDLINE_LINUX=/ && !/biosdevname=0/ { gsub(/"$/, " biosdevname=0\"") }
{ print }
ENDFILE { if (!found) print "GRUB_CMDLINE_LINUX=\" net.ifnames=0 biosdevname=0\"" }
EOF

gawk -i inplace -f- /etc/default/grub <<'EOF'
BEGIN { update = "GRUB_TIMEOUT=0" }
/^GRUB_TIMEOUT=/ { $0 = update; found = 1 }
{ print }
ENDFILE { if (!found) print update }
EOF

# Cleanup.

gawk -i inplace -f- /etc/default/grub <<'EOF'
{ gsub(/(" *| *")/, "\""); gsub(/  */, " ") }
{ print }
EOF

grub2-mkconfig -o /boot/grub2/grub.cfg

# Install OpenNebula context package

CONTEXT_VERSION=6.10.0
CONTEXT_PKG_URL=https://github.com/OpenNebula/one-apps/releases/download/v${CONTEXT_VERSION}/one-context-${CONTEXT_VERSION}-1.suse.noarch.rpm
CONTEXT_LOCAL=/root/context.rpm

curl $CONTEXT_PKG_URL -Lfo $CONTEXT_LOCAL
zypper --non-interactive --no-gpg-checks install -y $CONTEXT_LOCAL
rm $CONTEXT_LOCAL
systemctl enable haveged

# Configure critical settings for OpenSSH server.

exec 1>&2
set -eux -o pipefail

gawk -i inplace -f- /etc/ssh/sshd_config <<'EOF'
BEGIN { update = "PasswordAuthentication no" }
/^[#\s]*PasswordAuthentication\s/ { $0 = update; found = 1 }
{ print }
ENDFILE { if (!found) print update }
EOF

gawk -i inplace -f- /etc/ssh/sshd_config <<'EOF'
BEGIN { update = "ChallengeResponseAuthentication no" }
/^[#\s]*ChallengeResponseAuthentication\s/ { $0 = update; found = 1 }
{ print }
ENDFILE { if (!found) print update }
EOF

gawk -i inplace -f- /etc/ssh/sshd_config <<'EOF'
BEGIN { update = "PermitRootLogin without-password" }
/^[#\s]*PermitRootLogin\s/ { $0 = update; found = 1 }
{ print }
ENDFILE { if (!found) print update }
EOF

gawk -i inplace -f- /etc/ssh/sshd_config <<'EOF'
BEGIN { update = "UseDNS no" }
/^[#\s]*UseDNS\s/ { $0 = update; found = 1 }
{ print }
ENDFILE { if (!found) print update }
EOF

rm -f /etc/ssh/sshd_config.d/*-cloud-init.conf

##########
# Cognit #
##########

# Install python 3.10

curl https://pyenv.run | bash
echo -e '\n# Add pyenv to PATH\nexport PYENV_ROOT="$HOME/.pyenv"\nexport PATH="$PYENV_ROOT/bin:$PATH"\n\n# Initialize pyenv\neval "$(pyenv init --path)"' >> ~/.bashrc
source ~/.bashrc
pyenv install 3.10

# Install Serverless Runtime

SR_DIR=/root/serverless-runtime
git clone https://github.com/SovereignEdgeEU-COGNIT/serverless-runtime.git "$SR_DIR"
cd $SR_DIR
pyenv local 3.10
python3 -m pip install --upgrade pip
python3 -m venv serverless-env
source serverless-env/bin/activate
pip3 install -r requirements.txt
deactivate
cd -

# Cleanup

zypper -n purge-kernels
zypper remove --clean-deps -y salt salt-minion ||:
zypper clean --all

rm -f /etc/hostname

# Remove jeos-firstboot file
# https://github.com/openSUSE/jeos-firstboot
rm -f /var/lib/YaST2/reconfig_system

sync
