#!/bin/sh
#
# $Id$
#
cd $HOME/ACE/autobuild

svn up

sh $HOME/ACE/autobuild/configs/autobuild/remedynl/fc13_valgrind.sh && sh $HOME/ACE/autobuild/configs/autobuild/remedynl/fc13_gcc.sh
