#!/pkg/gnu/bin/bash
#
# $Id$
#

PATH=/opt/SUNWspro_6.2/SUNWspro/bin:/pkg/perl-5.6.1/bin:/pkg/gnu/bin:$PATH
export PATH

/pkg/perl-5.6.1/bin/perl $HOME/autobuild/autobuild.pl \
                             $HOME/autobuild/configs/autobuild/danzon/CROSS_COMPILE_TAO_IDL.xml  


SRCDIR=/export1/project/danzontmp1/bugzilla/CROSS_COMPILE/ACE_wrappers
DESTDIR=/project/acetmp/bugzilla/cross_compile_dir

BINARIES="bin/gperf TAO/TAO_IDL/tao_idl"

for i in $BINARIES; do
  if [ ! -x $SRCDIR/$i ]; then
    echo "Cannot find $i, aborting IDL compiler installation"
    exit 0
  fi
done

cd $DESTDIR/bin
for i in $BINARIES; do
  BASE=`basename $i`
  cp $SRCDIR/$i $BASE.$$ || exit 1
done

cd $DESTDIR/bin
for i in $BINARIES; do
  BASE=`basename $i`
  mv $BASE $BASE.bak.$$
  mv $BASE.$$ $BASE
  rm $BASE.bak.$$
done

exit 0


