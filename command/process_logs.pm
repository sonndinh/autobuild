#
# $Id$
#

package Process_Logs;

use strict;
use warnings;

use common::prettify;
use DirHandle;
use File::Copy;
use FileHandle;
use POSIX;
use Time::Local;
use File::Path;

###############################################################################
# Forward Declarations

sub move_log ();
sub clean_logs ($);
sub prettify_log ($);
sub index_logs ();

my $newlogfile;

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
    if (!defined $root) {
        print STDERR __FILE__, ": Requires \"root\" variable\n";
        return 0;
    }

    my $log_root = main::GetVariable ('log_root');
    if (!defined $log_root) {
        print STDERR __FILE__, ": Requires \"log_root\" variable\n";
        return 0;
    }

    my $log_file = main::GetVariable ('log_file');
    if (!defined $log_file) {
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
    my $keep = 10;
    my $moved = 0;
    my $log_root = main::GetVariable ('log_root');
    my $root = main::GetVariable ('root');

    # replace all '\x22' with '"'
    $options =~ s/\\x22/"/g;

    if (!-r $log_root || !-d $log_root) {
        mkpath($log_root);
    }

    if (!-r $root || !-d $root) {
        mkpath($root);
    }

    if ($main::verbose == 1 ) {
        main::PrintStatus ('Processing Logs', '');
    }

    # Move the logs

    if ($options =~ m/move/) {
        $moved = 1;
        my $retval = $self->move_log ();
        return 0 if ($retval == 0);
    }

    # Prettify the logs

    if ($options =~ m/prettify/) {
        my $retval = $self->prettify_log ($moved);
        return 0 if ($retval == 0);
    }

    # Clean the logs

    if ($options =~ m/clean='([^']*)'/ || $options =~ m/clean=([^\s]*)/) {
        my $retval = $self->clean_logs ($1);
        return 0 if ($retval == 0);
    }
    elsif ($options =~ m/clean/) {
        my $retval = $self->clean_logs ($keep);
        return 0 if ($retval == 0);
    }
    
    # Create an index

    if ($options =~ m/index/) {
        my $retval = $self->index_logs ();
        return 0 if ($retval == 0);
    }

    return 1;
}

##############################################################################

sub clean_logs ($)
{
    my $self = shift;
    my $log_root = main::GetVariable ('log_root');
    my $keep = shift;
    my @existing;

    # chop off trailing slash
    if ($log_root =~ m/^(.*)\/$/) {
        $log_root = $1;
    }

    my $dh = new DirHandle ($log_root);

    # Load the directory contents into the @existing array

    if (!defined $dh) {
        print STDERR __FILE__, ": Could not read directory $log_root\n";
        return 0;
    }

    while (defined($_ = $dh->read)) {
        if ($_ =~ m/^(...._.._.._.._..).txt/) {
            push @existing, $log_root . '/' . $1;
        }
    }
    undef $dh;

    @existing = reverse sort @existing;

    # Remove the latest $keep logs from the list

    for (my $i = 0; $i < $keep; ++$i) {
        shift @existing;
    }

    # Delete anything left in the list

    foreach my $file (@existing) {
        unlink $file . ".txt";
        unlink $file . "_Full.html";
        unlink $file . "_Brief.html";
        unlink $file . "_Totals.html";
        unlink $file . "_Config.html";
    }
    return 1;
}

sub move_log ()
{
    my $self = shift;
    my $root = main::GetVariable ('root');
    my $log_root = main::GetVariable ('log_root');
    my $log_file = main::GetVariable ('log_file');

    # chop off trailing slash
    if ($log_root =~ m/^(.*)\/$/) {
        $log_root = $1;
    }

    # chop off trailing slash
    if ($root =~ m/^(.*)\/$/) {
        $root = $1;
    }

    $log_file = $root . "/" . $log_file;

    if (!defined $log_file) {
        print STDERR __FILE__, ": Requires \"logfile\" variable\n";
        return 0;
    }
    if (!-r $log_file) {
        print STDERR __FILE__, ": Cannot read logfile: $log_file\n";
        return 0;
    }

    my $timestamp = POSIX::strftime("%Y_%m_%d_%H_%M", gmtime);
    $newlogfile = $log_root . "/" . $timestamp . ".txt";

    # Use copy/unlink instead of move so on Win32 it inherits
    # the destination dir's permissions
    if ($main::verbose == 1) {
        print "Moving $log_file to $newlogfile\n";
    }

    my $ret;
    ## copy returns the number of successfully copied files
    $ret = copy ($log_file, $newlogfile);
    if ( $ret < 1 ) {
        print STDERR __FILE__, "Problem copying $log_file to $newlogfile: $!\n";
    } 
    else {
        ## unlink returns the number of successfully copied files
        $ret = unlink ($log_file);
        if ( $ret < 1 ) {
            print STDERR __FILE__, "Problem deleting $log_file\n";
        }
    }

    # Make sure it has the correct permissions
    chmod (0644, $newlogfile);
    return 1;
}


sub prettify_log ($)
{
    my $self = shift;
    my $moved = shift;
    my $root = main::GetVariable ('root');
    my $log_file = main::GetVariable ('log_file');

    if ($moved) {
        $log_file = $newlogfile;
    }

    Prettify::Process ($log_file);
    return 1;
}

sub index_logs ()
{
    my $self = shift;
    my $log_root = main::GetVariable ('log_root');
    my $name = main::GetVariable ('name');
    my @files;
    
    # chop off trailing slash
    if ($log_root =~ m/^(.*)\/$/) {
        $log_root = $1;
    }
    
    my $dh = new DirHandle ($log_root);

    # Load the directory contents into the @existing array

    if (!defined $dh) {
        print STDERR __FILE__, ": Could not read directory $log_root\n";
        return 0;
    }

    while (defined($_ = $dh->read)) {
        if ($_ =~ m/^(...._.._.._.._..).txt/) {
            push @files, $1;
        }
    }
    undef $dh;

    @files = reverse sort @files;

    my $fh = new FileHandle ($log_root . '/index.html', 'w');
    
    if (!defined $fh) {
        print STDERR __FILE__, ": Cannot create index.html in $log_root\n";
        return 0;
    }
    
    my $title = 'Build History';
    
    if (defined $name) {
        $title .= " for $name";
    }
    
    print $fh "<html>\n<head>\n<title>$title</title>\n</head>\n";
    print $fh "<body bgcolor=\"white\"><h1>$title</h1>\n<hr>\n";
    print $fh "<table border=\"1\">\n<th>Timestamp</th><th>Setup</th><th>Compile</th><th>Test</th>\n";
    
    foreach my $file (@files) {
        my $totals_fh = new FileHandle ($log_root . '/' . $file . '_Totals.html', 'r');
        
        print $fh '<tr>';
        
        if (defined $totals_fh) {
            print $fh "<td><a href=\"${file}_Totals.html\">$file</a></td>";
            while (<$totals_fh>) {
                if (m/^<!-- BUILD_TOTALS\:/) {
                    if (m/Setup: (\d+)-(\d+)-(\d+)/) {
                        print $fh '<td>';
                        
                        if ($2 > 0) {
                            print $fh "<font color=\"red\">$2 Error(s)</font> ";
                        }
                        
                        if ($3 > 0) {
                            print $fh "<font color=\"orange\">$3 Warning(s)</font>";
                        }
                        
                        if ($2 == 0 && $3 == 0) {
                            print $fh '&nbsp';
                        }
                        
                        print $fh '</td>';
                    }
                    else {
                        print $fh '<td>&nbsp;</td>';
                    }
                    
                    if (m/Compile: (\d+)-(\d+)-(\d+)/) {
                        print $fh '<td>';
                        
                        if ($2 > 0) {
                            print $fh "<font color=\"red\">$2 Error(s)</font> ";
                        }
                        
                        if ($3 > 0) {
                            print $fh "<font color=\"orange\">$3 Warning(s)</font>";
                        }
                        
                        if ($2 == 0 && $3 == 0) {
                            print $fh '&nbsp';
                        }
                        
                        print $fh '</td>';
                    }
                    else {
                        print $fh '<td>&nbsp;</td>';
                    }

                    if (m/Test: (\d+)-(\d+)-(\d+)/) {
                        print $fh '<td>';
                        
                        if ($2 > 0) {
                            print $fh "<font color=\"red\">$2 Error(s)</font> ";
                        }
                        
                        if ($3 > 0) {
                            print $fh "<font color=\"orange\">$3 Warning(s)</font>";
                        }
                        
                        if ($2 == 0 && $3 == 0) {
                            print $fh '&nbsp';
                        }
                        
                        print $fh '</td>';
                    }
                    else {
                        print $fh '<td>&nbsp;</td>';
                    }

                    last;
                }
            }
        }
        else {
            print $fh "<td>$file</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>";
        }
        print $fh "</tr>\n";
    }
    
    print $fh "</table>\n</body>\n</html>\n";
    return 1;
}

##############################################################################

main::RegisterCommand ("process_logs", new Process_Logs ());
