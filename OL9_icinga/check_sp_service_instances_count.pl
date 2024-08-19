#!/usr/bin/env perl

use strict;

my %ERRORS=('OK'=>0,'WARNING'=>1,'CRITICAL'=>2,'UNKNOWN'=>3);
my ($host, $mysql_user, $mysql_pass, $mysql_arg) = ('') x 4;
my $cfgfile = '/etc/servicepattern/cfgserver.cfg';
my @cfg = ();
my @tmp = ();
my @sql_result = ();
my $service_critical = 0;
my $debug = 0;

sub SyntaxError {
    print "Syntax Error!\n";
    print "Usage: $0 -service1 <instances_number>  -service2 <instances_number> ...\n";
    print "\n";
    print "Example: $0 -stat 1 -elasticsync 0 -config 3\n";
    print "\n";
    print "Valid keys (parameters):\n";
    print "\t-activityserver\n";
    print "\t-ad\n";
    print "\t-agent\n";
    print "\t-calldiagnostics\n";
    print "\t-clientweb\n";
    print "\t-config\n";
    print "\t-crmserver\n";
    print "\t-db\n";
    print "\t-elasticsync\n";
    print "\t-emailserver\n";
    print "\t-emiserver\n";
    print "\t-integrationapi\n";
    print "\t-portal\n";
    print "\t-pwrdialer\n";
    print "\t-remoteassist\n";
    print "\t-aggregator\n";
    print "\t-reportingapi\n";
    print "\t-router\n";
    print "\t-rtdataprovider\n";
    print "\t-rtp\n";
    print "\t-scenario\n";
    print "\t-scheduler\n";
    print "\t-screenrecorder\n";
    print "\t-sms\n";
    print "\t-stat\n";
    print "\t-switch\n";
    print "\t-usersauth\n";
    
    exit $ERRORS{"UNKNOWN"};
}

my ($arg,
    $activityserver,
    $ad,
    $agent,
    $calldiagnostics,
    $clientweb,
    $config,
    $crmserver,
    $db,
    $elasticsync,
    $emailserver,
    $emiserver,
    $integrationapi,
    $portal,
    $pwrdialer,
    $remoteassist,
    $aggregator,
    $reportingapi,
    $router,
    $rtdataprovider,
    $rtp,
    $scenario,
    $scheduler,
    $screenrecorder,
    $sms,
    $stat,
    $switch,
    $usersauth);

#
# Hash table with standard numbers of services.
# If a cluster has different numbers for services then the standard numbers will be overriden by values given from parsed script parameters.
# We only pass the parameters which are different from the standard ones: if a parameter for some service is absent then we use the standard one.
#
# Example1. If some cluster has 3 RTP servers instead of 2: active_services.pl -rtp 3
# Example2. If some cluster has 1 STAT server and no ELASTIC: active_services.pl -stat 1 -elasticsync 0
#

my %services = (
    "ACTIVITYSERVER" => 2,
    "AD" => 2,
    "AGENT" => 2,
    "CALL_DIAGNOSTICS" => 2,
    "CLIENTWEB" => 2,
    "CONFIG" => 3,
    "CRM_SERVER" => 2,
    "DB" => 2,
    "ELASTIC_SYNC" => 1,
    "EMAIL_SERVER" => 2,
    "EMISERVER" => 2,
    "INTERNAL_INTEGRATION_API" => 2,
    "PORTAL" => 2,
    "PWRDIALER" => 2,
    "REMOTEASSIST" => 2,
    "REPORTINGAGGREGATOR" => 1,
    "REPORTINGAPI" => 2,
    "ROUTER" => 2,
    "RTDATAPROVIDER" => 2,
    "RTP" => 2,
    "SCENARIO" => 2,
    "SCHEDULER" => 2,
    "SCREEN_RECORDER" => 2,
    "SMS" => 2,
    "STAT" => 2,
    "SWITCH" => 2,
    "USERS_AUTH" => 2);


#
# Parsing the command line agruments (if any) and amending the standard values in %services with the arguments
#

while(@ARGV) {
    $arg = shift(@ARGV);
    if ($arg eq '-activityserver') {
	$activityserver = shift(@ARGV);
	$services{'ACTIVITYSERVER'} = $activityserver;
    }
    elsif ($arg eq '-ad') {
	$ad = shift(@ARGV);
	$services{'AD'} = $ad;
    }
    elsif ($arg eq '-agent') {
	$agent = shift(@ARGV);
	$services{'AGENT'} = $agent;
    }
    elsif ($arg eq '-calldiagnostics') {
	$agent = shift(@ARGV);
	$services{'CALL_DIAGNOSTICS'} = $calldiagnostics;
    }
    elsif ($arg eq '-clientweb') {
	$clientweb = shift(@ARGV);
	$services{'CLIENTWEB'} = $clientweb;
    }
    elsif ($arg eq '-config') {
	$config = shift(@ARGV);
	$services{'CONFIG'} = $config;
    }
    elsif ($arg eq '-crmserver') {
	$crmserver = shift(@ARGV);
	$services{'CRM_SERVER'} = $crmserver;
    }
    elsif ($arg eq '-db') {
	$db = shift(@ARGV);
	$services{'DB'} = $db;
    }
    elsif ($arg eq '-elasticsync') {
	$elasticsync = shift(@ARGV);
	$services{'ELASTIC_SYNC'} = $elasticsync;
    }
    elsif ($arg eq '-emailserver') {
	$emailserver = shift(@ARGV);
	$services{'EMAIL_SERVER'} = $emailserver;
    }
    elsif ($arg eq '-emiserver') {
	$emiserver = shift(@ARGV);
	$services{'EMISERVER'} = $emiserver;
    }
    elsif ($arg eq '-integrationapi') {
	$integrationapi = shift(@ARGV);
	$services{'INTERNAL_INTEGRATION_API'} = $integrationapi;
    }
    elsif ($arg eq '-portal') {
	$portal = shift(@ARGV);
	$services{'PORTAL'} = $portal;
    }
    elsif ($arg eq '-pwrdialer') {
	$pwrdialer = shift(@ARGV);
	$services{'PWRDIALER'} = $pwrdialer;
    }
    elsif ($arg eq '-remoteassist') {
	$remoteassist = shift(@ARGV);
	$services{'REMOTEASSIST'} = $remoteassist;
    }
    elsif ($arg eq '-aggregator') {
	$aggregator = shift(@ARGV);
	$services{'REPORTINGAGGREGATOR'} = $aggregator;
    }
    elsif ($arg eq '-reportingapi') {
	$reportingapi = shift(@ARGV);
	$services{'REPORTINGAPI'} = $reportingapi;
    }
    elsif ($arg eq '-router') {
	$router = shift(@ARGV);
	$services{'ROUTER'} = $router;
    }
    elsif ($arg eq '-rtdataprovider') {
	$rtdataprovider = shift(@ARGV);
	$services{'RTDATAPROVIDER'} = $rtdataprovider;
    }
    elsif ($arg eq '-rtp') {
	$rtp = shift(@ARGV);
	$services{'RTP'} = $rtp;
    }
    elsif ($arg eq '-scenario') {
	$scenario = shift(@ARGV);
	$services{'SCENARIO'} = $scenario;
    }
    elsif ($arg eq '-scheduler') {
	$scheduler = shift(@ARGV);
	$services{'SCHEDULER'} = $scheduler;
    }
    elsif ($arg eq '-screenrecorder') {
	$screenrecorder = shift(@ARGV);
	$services{'SCREEN_RECORDER'} = $screenrecorder;
    }
    elsif ($arg eq '-sms') {
	$sms = shift(@ARGV);
	$services{'SMS'} = $sms;
    }
    elsif ($arg eq '-stat') {
	$stat = shift(@ARGV);
	$services{'STAT'} = $stat;
    }
    elsif ($arg eq '-switch') {
	$switch = shift(@ARGV);
	$services{'SWITCH'} = $switch;
    }
    elsif ($arg eq '-usersauth') {
	$usersauth = shift(@ARGV);
	$services{'USERS_AUTH'} = $usersauth;
    }
    elsif ($arg eq '-debug') {
	$debug = 1;
    }
    else {
        SyntaxError();
    }
}


#
# Opening /etc/servicepattern/cfgserver.cfg and getting MySQL credentials (for current cluster) from there
#

open (CFGFILE, "$cfgfile") or die "Opening $cfgfile - $!";

@cfg = <CFGFILE>;
@tmp = grep(/jdbc_host=/,@cfg);
$host = substr(@tmp[0],index(@tmp[0],'=') + 1);
chomp($host);
@tmp = grep(/jdbc_username=/,@cfg);
$mysql_user = substr(@tmp[0],index(@tmp[0],'=') + 1);
chomp($mysql_user);
@tmp = grep(/jdbc_password=/,@cfg);
$mysql_pass = substr(@tmp[0],index(@tmp[0],'=') + 1);
chomp($mysql_pass);
# print $host,"\n",$mysql_user,"\n",$mysql_pass,"\n";

close (CFGFILE);


#
# Main checking loop
#

foreach (keys %services) {
    #
    # Getting the service name from %services hash keys, one by one, put it to MySQL query as a patameter and execute the query
    # The query returns the actual number of running services of the name
    # If the actual number is less than the number in %services (either standard or passed by a command line parameter then raise an error)
    #
    $mysql_arg = " -s -r -h $host -u $mysql_user -p$mysql_pass -e 'SELECT count(id) FROM sp_config.servers where role=\"ACTIVE\" and type=\"$_\";'";
    @sql_result = `mysql $mysql_arg`;
    chomp(@sql_result[0]);    
    
    # debug
    print $_," -> ", @sql_result[0], " (actual), should be -> ", $services{$_},".\n" if $debug;

    if (@sql_result[0] < $services{$_}) {
	$service_critical = 1;
        print $_," instances number is ",@sql_result[0],", should be ",$services{$_},".\n";
    }
}

exit $ERRORS{"CRITICAL"} if $service_critical;

print "All SP service instances are up and running.\n";
exit $ERRORS{"OK"};
