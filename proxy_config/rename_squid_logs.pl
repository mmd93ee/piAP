#!/usr/bin/env perl

# Take the squid log file specified as the first argument when calling this script,
# then split all entries in to separate files for each day.

use strict;
use warnings;
use File::Basename;
use POSIX;

sub isoDate {
    return strftime("%Y-%m-%d", localtime(shift or time));
}

my $logtype = "access";

my $previousDate = '';
my $logfile;
while (<>) {
    my $line = $_;
    my $timeStamp = 0;
    if ($line =~ /^(\d+)\..*/) {
        $timeStamp = $1;
    }
    my $currentDate = isoDate($timeStamp);
    if ($currentDate ne $previousDate || !$logfile) {
        if ($logfile) {
            close($logfile);
        }
        open $logfile, ">>", "$logtype.$currentDate"
            or die "Could not open $logtype.$currentDate: $!";
    }
    print $logfile $line;
}