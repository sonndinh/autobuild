#
# $Id$
#

package Log;

use strict;

use Cwd;
use FileHandle;
use Time::Local;

###############################################################################
# Constructor

sub new
{
    my $proto = shift;
    my $class = ref ($proto) || $proto;
    my $self = {};

    bless ($self, $class);
    return $self;
}

##############################################################################

sub CheckRequirements ()
{
    my $self = shift;
    my $root = main::GetVariable ('root');
    my $buildname = main::GetVariable ('build_name');
    my $logfile = main::GetVariable ('log_file');

    if (!defined $root) {
        print STDERR __FILE__, ": Requires \"root\" variable\n";
        return 0;
    }
    if (!-r $root) {
        print STDERR __FILE__, ": Cannot read root dir: $root\n";
        return 0;
    }

    if (!defined $logfile) {
        print STDERR __FILE__, ": Requires \"log_file\" variable\n";
        return 0;
    }

    return 1;
}

##############################################################################

sub Run ($)
{
    my $self = shift;
    my $options = shift;
    my $root = main::GetVariable ('root');
    my $logfile = main::GetVariable ('log_file');

    # chop off trailing slash
    if ($root =~ m/^(.*)\/$/) {
        $root = $1;
    }

    my $current_dir = getcwd ();

    if (!chdir $root) {
        print STDERR __FILE__, ": Cannot change to $root\n";
        return 0;
    }


    if (uc $options eq "ON") {
        # Make copies of current handles
    
        open (OLDOUT, ">&STDOUT");
        open (OLDERR, ">&STDERR");
    
        # Redirect to the logfile
    
        if (!open (STDOUT, "> $logfile")) {
            print STDERR __FILE__, ": Can't redirect stdout: $!\n";
            return 0;
        }
        if (!open (STDERR, ">&STDOUT")) {
            print STDERR __FILE__, ": Can't dup stdout: $!\n";
            return 0;
        }
    
        print "\n#################### Begin\n\n";
        print "Command starting at ", (scalar gmtime(time())), " UTC\n\n";
    }
    elsif (uc $options eq "OFF") {
        print "\n#################### End\n\n";
        print "Command starting at ", (scalar gmtime(time())), " UTC\n\n";
            
        # Close the logging filehandles
        
        if (!close (STDOUT)) {
            print OLDERR __FILE__, ": Error closing logging stdout: $!\n";
            return 0;
        }
        if (!close (STDERR)) {
            print OLDERR __FILE__, ": Error closing logging stderr: $!\n";
            return 0;
        }

        # Restore the old handles

        if (!open (STDERR, ">&OLDERR")) {
            print OLDERR __FILE__, ": Error restoring stderr: $!\n";
            return 0;
        }
        if (!open (STDOUT, ">&OLDOUT")) {
            print OLDERR __FILE__, ": Error restoring stdout: $!\n";
            return 0;
        }

        # Close the duplicate handles
        if (!close (OLDOUT)) {
            print STDERR __FILE__, ": Error closing OLDOUT: $!\n";
            return 0;
        }
        if (!close (OLDERR)) {
            print STDERR __FILE__, ": Error closing OLDERR: $!\n";
            return 0;
        }
    }

    chdir $current_dir;

    return 1;
}

##############################################################################

main::RegisterCommand ("log", new Log ());
