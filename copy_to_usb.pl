#!perl -w
use strict;
use Data::Dumper;

my $target = shift || usage();
my $count = shift || usage();

my @list_of_files = `find . -type f -exec ls -lt  {} +`;

# print Dumper @list_of_files;

my $counter = 0;
foreach my $row (@list_of_files) {
	chomp $row;
	next if ($row =~ /copy_to_usb\.pl/);
	next if $counter++ >= $count;
	if ($row =~ m/^.*\.\/(.*)\/(.*)$/g) {
		print `mkdir "$target/$1"` if (! -d "$target/$1");
		print "[$counter] Running: cp -v \"./$1/$2\" $target/$1/\n";
		print `cp -v "./$1/$2" "$target/$1/"`;
	} else {
		print "No Match\n";
	}

}

sub usage{
	die "copy_to_usb <TARGET PATH> <NUMBER OF FILES TO COPY>\n";

}
