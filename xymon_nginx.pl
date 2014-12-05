#!/usr/local/bin/perl -w

use warnings;
use strict;
use LWP::Simple;
use Data::Dumper;

use constant NGINX_STATUS_PAGE => '"http://10.0.7.10:82/"';

use constant XYMON_WWW_ROOT => '';
sub get_graph_html {
        my ($host, $service) = @_;
        '<table summary="'.$service.' Graph"><tr><td><A HREF="'.XYMON_WWW_ROOT.'/xymon-cgi/showgraph.sh?host='.$host.'&amp;service='.$service.'&amp;graph_width=576&amp;graph_height=120&amp;first=1&amp;count=1&amp;disp='.$host.'&amp;action=menu"><IMG BORDER=0 SRC="'.XYMON_WWW_ROOT.'/xymon-cgi/showgraph.sh?host='.$host.'&amp;service='.$service.'&amp;graph_width=576&amp;graph_height=120&amp;first=1&amp;count=1&amp;disp='.$host.'&amp;graph=hourly&amp;action=view" ALT="xymongraph '.$service.'"></A></td><td align="left" valign="top"><a href="'.XYMON_WWW_ROOT.'/xymon-cgi/showgraph.sh?host='.$host.'&amp;service='.$service.'&amp;graph_width=576&amp;graph_height=120&amp;first=1&amp;count=1&amp;disp='.$host.'&amp;graph_start=1350474056&amp;graph_end=1350646856&amp;graph=custom&amp;action=selzoom"><img src="'.XYMON_WWW_ROOT.'/xymon/gifs/zoom.gif" border=0 alt="Zoom graph" style=\'padding: 3px\'></a></td></tr></table>';
}

sub do_the_work {

  my $content = get(NGINX_STATUS_PAGE);
  return undef unless defined $content;
  return 0 unless $content =~ /Active connections: (?<active>\d+)\s*server accepts handled requests\s*(?<accepted_connections>\d+)\s+(?<handled_connections>\d+)\s+(?<handled_requests>\d+)\s*Reading: (?<reading>\d+) Writing: (?<writing>\d+) Waiting: (?<waiting>\d+)/;
  my %data = %+;
  return \%data;
}

my $values = do_the_work();

my $host = $ENV{MACHINEDOTS};
my $report_date = `/bin/date`;
my $color = 'red';
my $service = 'nginx';


my $data;
my $trends;
if ($values) {
  $color = 'clear';

  $trends = "
[nginx_connections.rrd]
DS:total:GAUGE:600:0:U ".$values->{active}."
DS:reading:GAUGE:600:0:U ".$values->{reading}."
DS:writing:GAUGE:600:0:U ".$values->{writing}."
DS:waiting:GAUGE:600:0:U ".$values->{waiting}."
[nginx_requests.rrd]
DS:accepted:DERIVE:600:0:U ".$values->{accepted_connections}."
DS:handconn:DERIVE:600:0:U ".$values->{handled_connections}."
DS:handreq:DERIVE:600:0:U ".$values->{handled_requests}."
";

  $data = "
<h2>Status</h2>
No status checked

<h2>Counters</h2>
".get_graph_html($host, 'nginx_connections')."
".get_graph_html($host, 'nginx_requests')."
";
}
else {
  $data = 'Error!';
  $trends = '';
}

system( ("$ENV{BB}", "$ENV{BBDISP}", "status $host.$service $color $report_date$data\n") );
if ($trends) {
  system( "$ENV{BB} $ENV{BBDISP} 'data $host.trends $trends'\n");
}
