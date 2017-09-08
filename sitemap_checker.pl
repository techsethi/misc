#!perl -w

use strict;
use XML::Simple;
use Data::Dumper;
	
use WWW::Curl::Simple;


use LWP::Simple;
my $content = get("http://timescity.com/robots.txt");

die "Couldn't get it!" unless $content;

# print $content;

my $done_sitemaps;

if (-e "done_sitemaps.txt")
{
	print "Done file exists. Opening for reading\n";
	open (DONE, "done_sitemaps.txt") || die "couldn't open file for reading: $!";
	while (<DONE>)
	{
		chop;
		$done_sitemaps->{$_} = 1;
	}
	print Dumper $done_sitemaps;
	close DONE;
} else
{
	print "Done file doesn't exist.";
}

# die "bye";

open(DONE, ">>done_sitemaps.txt") || die "couldn't open file for writing";


my @lines = split /\n/, $content;

my $curl = WWW::Curl::Simple->new;

# $curl->connection_timeout(25);

        
my $sitemap_count = 0;
my $sitemap_entry_count = 0;
my $url_to_check_count = 0;

foreach my $line (@lines)
{
	if ($line =~ /Sitemap: (.*)/i)
	{
		print "Loading Sitemap Index: $1\n";
		$sitemap_count += 1;
		my $sitemap_to_load = $1;
		my $sitemap_content = get($sitemap_to_load);
		my $ref = XMLin( $sitemap_content);
		foreach my $sitemap_entry (@{$ref->{'sitemap'}})
		{
			# print Dumper $sitemap_entry;
			$sitemap_entry_count += 1;
			print "Loading Sitemap: " . $sitemap_entry->{'loc'} . "\n" ;
			my $sitemap_entry_content = get($sitemap_entry->{'loc'});
			my $sitemap_entry_ref = XMLin($sitemap_entry_content);
			# print Dumper $sitemap_entry_ref;
			foreach my $url_to_check (@{$sitemap_entry_ref->{'url'}})
			{
				$url_to_check_count += 1;
				print "Checking " . $url_to_check->{'loc'} ;
				
		        # my $res = $curl->get($url_to_check->{'loc'});
				my $res = head($url_to_check->{'loc'});
				
				# print $response_code;
				
				print ".";
				
				my $response_code = $res->{'_rc'};
				if ($response_code != 200)
				{
							print("Invalid response code: $response_code for " . $url_to_check->{'loc'} . "\n");
		        } else {
		                # Error code, type of error, error message
						print "...[$response_code] Ok.\n";
		        }
				
			    # print Dumper $url_to_check;
			}
			print DONE $sitemap_entry->{'loc'};
			
		}
	
	}
	
	
}
close DONE;

print "Total Sitemaps: $sitemap_count\n";
print "Total Sitemap Entries: $sitemap_entry_count\n";
print "Total URLs: $url_to_check_count\n";
