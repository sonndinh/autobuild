#!/bin/sh
# $Id$
#
PATH=/usr/local/bin:$PATH;export PATH
#
# Update the doc_autobuild scripts.
echo [`/usr/bin/date`]: Updating doc_autobuild
cd /var/mounts/sun16/users/tao/doc_autobuild
svn update autobuild
cd /usr/users/tao/hp1/doc_scoreboard/aCC373/standard
#
echo [`/usr/bin/date`]: Starting HPUX11_ACC373_Standard build
perl /var/mounts/sun16/users/tao/doc_autobuild/autobuild/autobuild.pl /var/mounts/sun16/users/tao/doc_autobuild/autobuild/configs/autobuild/prism/HPUX11_ACC373_Standard.xml
echo [`/usr/bin/date`]: Finished
