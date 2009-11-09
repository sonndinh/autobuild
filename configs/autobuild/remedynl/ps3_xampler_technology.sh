#! /bin/sh
#
# $Id$

COMPILER="gcc"

create_config_page ()
{
  local ROOT=$1
  local DESC=$2
  CFG_FILES=$ROOT/ace/config.h
  CFG_FILES="$CFG_FILES $ROOT/bin/MakeProjectCreator/config/default.features"
  CFG_FILES="$CFG_FILES $ROOT/include/makeinclude/platform_macros.GNU"

  for cfg_file in $CFG_FILES; do
    if [ -r $cfg_file ]; then
      echo "<TR><TD>ACE+TAO Configuration for $DESC</TD><TD>`basename $cfg_file`</TD></TR>"
      echo '<TR><TD colspan="2"><PRE>'
      cat $cfg_file
      echo '</PRE></TD></TR>'
    fi
  done
}

###############################################################################
#
# create_index_page
#
###############################################################################
create_index_page ()
{
  echo "<html>"
  echo "<head><title>$TITLE</title></head>"
  echo '<style><!--'
  echo 'body,td,a,p,.h{font-family:arial,sans-serif;}'
  echo '.h{font-size: 20px;}'
  echo '.q{text-decoration:none; color:#0000cc;}'
  echo '//-->'
  echo '</style>'
  echo '<body text = "#000000" link="#000fff" vlink="#ff0f0f" bgcolor="#ffffff">'
  echo "<br><center><h1>$TITLE</h1></center><br><hr>"

  echo '<P>All the experiments run on the system described below. '
  echo 'The machine is running Linux ('

  if [ -e "/etc/SuSE-release" ]; then
    cat /etc/SuSE-release
  fi

  if [ -e "/etc/redhat-release" ]; then
    cat /etc/redhat-release
  fi

  echo "), and we use " $COMPILER " version "

  $COMPILER -dumpversion > compilerversion.txt 2>&1
  cat compilerversion.txt

  echo ' to compile '$BASE_TITLE'. </P>'

  if [ -z "$MPC_ROOT" ]; then
    MPC_ROOT=$ACE_ROOT/MPC
  fi

  echo '<TABLE border="2"><TBODY>'

  create_config_page "/home/build/ACE/regular/ACE_wrappers/" "TAO Regular"
  create_config_page "/home/build/ACE/CORBAemicro/ACE_wrappers/" "CORBA/e micro"
  create_config_page "/home/build/ACE/CORBAemicrostatic/ACE_wrappers/" "CORBA/e micro static"

  echo '<TR><TD>CPU Information</TD><TD>/proc/cpuinfo</TD></TR>'
  echo '<TR><TD colspan="2"><PRE>'

  cat /proc/cpuinfo

  echo '</PRE></TD></TR><TR><TD>Available Memory</TD><TD>/proc/meminfo</TD></TR>'
  echo '<TR><TD colspan="2"><PRE>'

  cat /proc/meminfo

  echo '</PRE></TD></TR><TR><TD>OS Version</TD><TD>uname -a</TD></TR>'
  echo '<TR><TD colspan="2"><PRE>'

  /bin/uname -a

  echo '</PRE></TD></TR><TR><TD>Compiler Version</TD><TD>'$COMPILER' -v</TD></TR>'
  echo '<TR><TD colspan="2">'

  $COMPILER -v > compiler.txt 2>&1
  cat compiler.txt

  if [ -e "/lib/libc.so.6" ]; then
    echo '</TD></TR><TR><TD>Library Version</TD><TD>/lib/libc.so.6</TD></TR>'
    echo '<TR><TD colspan="2"><PRE>'

    /lib/libc.so.6 | sed -e 's/</\&lt;/g' -e 's/>/\&gt;/g'
  fi

  echo '</PRE></TD></TR></TBODY></TABLE>'
  echo '</body></html>'
}

###############################################################################
#
# create_html
#
###############################################################################
create_html ()
{
  echo "create_html()"

}

create_front_page ()
{
  date  > date.txt 2>&1
  echo 'These results were generated on '
  cat date.txt
}

###############################################################################
#
# main program
#
###############################################################################

INFILE=""
DEST=""
TARGETS=""
DATE=""
METRIC="Compilation"
FUDGE_FACTOR=0
BASE_ROOT=$ACE_ROOT
DEFAULT_TITLE=ACE+TAO
BASE_TITLE=$DEFAULT_TITLE

create_front_page > /home/build/ACE/Avenger/_Templt/Template-Display/_Report/index-front.php
create_index_page > /home/build/ACE/Avenger/_Templt/Template-Display/_Report/index-technology.php