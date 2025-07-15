#!/usr/bin/perl
# Modification of https://xbarapp.com/docs/plugins/Dev/Vagrant/vagrant.2m.pl.html by @axeloz
# <xbar.title>Vagrant (Modified)</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.author.github>arturbalabanov</xbar.author.github>
# <xbar.author>Artur Balabanov</xbar.author>
# <xbar.desc>Vagrant status checker.</xbar.desc>
# <xbar.dependencies>perl,vagrant</xbar.dependencies>
# <xbar.image>https://i.imgur.com/Yzrcz9k.png</xbar.image>

use strict;
use Cwd 'abs_path';

my @output;
my @found;
my $machinePath;
my $readablePath;
my $machineId;
my $machineName;
my $machineProvider;
my $machineState;
my $me = abs_path($0);
my $content;
my $vagrant;
my $running = 0;
my $total = 0;
my $kitty_new_win = "$ENV{HOME}/.local/bin/kitty-new-win";

# HACK as $PATH is incorrect when Bitbar run the script
# Must add /usr/local/bin manually
my $path = $ENV{PATH}.':/usr/local/bin';

# This function allows me to run Apple Scripts
sub osascript($) { system 'osascript', map { ('-e', $_) } split(/\n/, $_[0]); }

# Locating the Vagrant binary
foreach $a (split(/:/, $path)) {
	if (-x $a."/vagrant") {
		$vagrant = $a."/vagrant";
		last;
	}
}

# If Vagrant could not be found
if (! defined $vagrant) {
	print "⚠️\n";
	print "---\n";
	print "Vagrant binary could not be found in paths. Is it installed?";
	exit 1;
}

# When script is called with arguments
# $ARGV[0] : the action (up, halt, suspend, resume, ssh)
# $ARGV[1] : the path of the Vagrant environment
# $ARGV[2] : the ID of the VM
# $ARGV[3] : the name of the VM (optional)
if ( ($#ARGV + 1) == 3 || ($#ARGV + 1) == 4 ) {
	my $title;
	if ( ($#ARGV + 1) == 4 ) {
		$title = "Vagrant machine $ARGV[3] ($ARGV[2])";
	} else {
		$title = "Vagrant machine $ARGV[2]";
	}
	
	my $description = "";
	my $newstatus = "unknown";

	# Running the SSH action
	if ($ARGV[0] eq 'ssh') {
		my $ssh_command = "source ~/.zprofile && cd \"$ARGV[1]\" && TERM=xterm-256color $vagrant ssh \"$ARGV[2]\" -c /bin/bash";
		system("$kitty_new_win --title \"$title\" --no-hold \"$ssh_command\"");
		$description = "You are now connected to your Vagrant machine";
	}
	else {
		if ($ARGV[0] eq "up" || $ARGV[0] eq "resume") {
			$newstatus = "running";
		}
		elsif  ($ARGV[0] eq "halt" || $ARGV[0] eq "suspend") {
			$newstatus = "stopped";
		}
		elsif ($ARGV[0] eq "reload") {
			$newstatus = "reloaded";
		}

		system("export PATH=$path && cd $ARGV[1] && $vagrant $ARGV[0] $ARGV[3]");
		$description = "Vagrant virtual machine status is now ".$newstatus;
	}
	
	# Checking the result of the action
	if ($? eq 0) {
		&osascript (
		 'display notification "'.$description.'" with title "'.$title.'"'
		);
		exit 0;
	}
	else {
		&osascript (
		 'display notification "Could not execute operation" with title "'.$title.'"'
		);
		exit 1;
	}
	# Not needed, just safer...
	exit 0
}

# Getting the list of all Vagrant VMs
@output = `$vagrant global-status |tail -n +3`;

# Checking whether there is at least one VM
# TODO: clean this
foreach $a (@output) {
	if ($a =~ "There are no active") {
		print "⍱ | color=gray size=16\n";
		print "---\n";
		print "⚠️ There is no Vagrant VMs yet.";
		exit 0;
	}
}


# Looping in the list
foreach $a (@output) {
	# Triming spaces
	$a =~ s/^\s+|\s+$//g;
	# Removing excessive spaces
	$a =~ s/ {1,}/ /g;

	# Cutting output on first empty line as Vagrant is too verbose
	last if ($a eq '');
	
	# Counting total
	$total ++;

	# Exploding row on spaces
	@found = split / /, $a;

	$machinePath  = join("\\ ", @found[4..$#found]);
	$readablePath = join(" ", @found[4..$#found]);

	$machineId = $found[0];
	$machineName = $found[1];
	$machineProvider = $found[2];
	$machineState = $found[3];
	
	# This VM is currently running
	if ($machineState eq 'running') {
		# Counting the running VMs
		$running ++;

		$content .= "✅ Machine $machineName ($machineId) is running | size=14 color=green\n";
		$content .= " $readablePath | size=11 \n";
		$content .= "  | size=14 color=black \n";

		$content .= "#️⃣ SSH $machineName ($machineId) | size=12 bash=\"$me\" param1=ssh param2=\"".$machinePath."\" param3=\"".$machineId."\" param4=\"$machineName\" terminal=false refresh=false \n";
		$content .= "🔄 Reload $machineName ($machineId) | size=12 bash=\"$me\" param1=reload param2=\"".$machinePath."\" param3=\"".$machineId."\" terminal=false refresh=true \n";
		$content .= "🔽 Suspend $machineName ($machineId) | size=12 bash=\"$me\" param1=suspend param2=\"".$machinePath."\" param3=\"".$machineId."\" terminal=false refresh=true \n";
		$content .= "⏬ Stop $machineName ($machineId) | size=12 bash=\"$me\" param1=halt param2=\"".$machinePath."\" param3=\"".$machineId."\" terminal=false refresh=true \n";
	}
	# This VM is currently saved
	elsif ($machineState eq 'saved' || $machineState eq 'suspended') {
		$content .= "📴 Machine $machineName ($machineId) is suspended | size=14 color=orange\n";
		$content .= " $readablePath | size=11 \n";
		$content .= "  | size=14 color=black \n";
		$content .= "▶️ Resume $machineName ($machineId) | size=12 bash=\"$me\" param1=resume param2=\"".$machinePath."\" param3=\"".$machineId."\" terminal=false refresh=true \n";
		$content .= "⏬ Stop $machineName ($machineId) | size=12 bash=\"$me\" param1=halt param2=\"".$machinePath."\" param3=\"".$machineId."\" terminal=false refresh=true \n";
	}
	# This VM is currently powered off
	elsif ($machineState eq 'poweroff' || $machineState eq 'aborted' || $machineState eq 'stopped' || ($machineState eq 'not' && $found[4] eq "running")) {
		if ($machineState eq 'not' && $found[4] eq "running") {
			$machinePath  = join("\\ ", @found[5..$#found]);
			$readablePath = join(" ", @found[5..$#found]);
		}
		$content .= "🚫 Machine $machineName ($machineId) is stopped | size=14 color=red\n";
		$content .= " $readablePath | size=11 \n";
		$content .= "  | size=14 color=black \n";
		$content .= "▶️ Start $machineName ($machineId) | size=12 bash=\"$me\" param1=up param2=\"".$machinePath."\" param3=\"".$machineId."\" terminal=false refresh=true \n";
	}
	# This VM is in an unknown state
	else {
		$content .= "❓ Machine $machineName ($machineId) is ".$machineState." | size=14 color=red\n";
		$content .= " $machinePath | size=11 \n";
		$content .= "  | size=14 color=black \n";
		$content .= "This is an unknown state\n";
	}

	# Adding the terminal separator
	$content .= "---\n";
}

# Adding the menu title with the number of running VMs
print "⍱ $running/$total | size=16\n";
print "---\n";
print $content unless !defined $content;
exit 0;
