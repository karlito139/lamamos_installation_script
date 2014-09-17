=pod
 Copyright (C) 2013-2014 Clément Roblot

This file is part of lamamos.

Lamadmin is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Lamadmin is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Lamadmin.  If not, see <http://www.gnu.org/licenses/>.
=cut

package Service::drbd;

use Data::Dumper;
use Rex -base;

task define => sub {

  if($CFG::config{'OCFS2Init'} == "0"){

    print("We start to install drbd\n");

    installSystem();

    print("We write that drbd is installed\n");

    $CFG::config{'OCFS2Init'} = "1";
  }

  print("We install packages\n");

  install ["drbd8-utils", "ocfs2-tools"];

  print("We set the configuration of drbd\n");

  my $variables = {};
  $variables->{'drbdSharedSecret'} = $CFG::config{'drbdSharedSecret'};
  $variables->{'ddName'} = $CFG::config{'ddName'};
  $variables->{'firstServIP'} = $CFG::config{'firstServIP'};
  $variables->{'SeconServIP'} = $CFG::config{'SeconServIP'};
  $variables->{'firstServHostName'} = $CFG::config{'firstServHostName'};
  $variables->{'SeconServHostName'} = $CFG::config{'SeconServHostName'};

  print("We write the configuration of drbd\n");

  file "/etc/drbd.conf",
    content 	=> template("templates/drbd_install_2.conf.tpl", variables => $variables),
    owner		=> "root",
    group		=> "root",
    mode		=> "640",
    on_change	=> sub{ service "drbd" => "restart"; };

  print("We start drbd\n");

  service drbd => ensure => "started";

};




sub installSystem {


	install 'drbd8-utils';

	#We consider the hard drive as zeroed out. It might be a good idea to test the assumbtion here.

    print("We are defining the variables\n");

	#We insert the first configuration of drbd
    my $variables = {};
    $variables->{'drbdSharedSecret'} = $CFG::config{'drbdSharedSecret'};
    $variables->{'ddName'} = $CFG::config{'ddName'};
    $variables->{'firstServIP'} = $CFG::config{'firstServIP'};
    $variables->{'SeconServIP'} = $CFG::config{'SeconServIP'};
    $variables->{'firstServHostName'} = $CFG::config{'firstServHostName'};
    $variables->{'SeconServHostName'} = $CFG::config{'SeconServHostName'};

    print("We are creating the conf file\n");

    file "/etc/drbd.conf",
            content         => template("templates/drbd_install_1.conf.tpl", variables => $variables),
            owner           => "root",
            group           => "root",
            mode            => "640",
            on_change       => sub{ service "drbd" => "restart"; };

    print("We are creating the md r0\n");

	#We now create the r0 drive
	`drbdadm create-md r0`;

    print("We are restarting drbd\n");

	#We then start drbd in order to synchronise it (we use restart in case the deamon was already running)
	#!!Certanly useless considering that the fact of changing the config file already restarted the deamon
	`/etc/init.d/drbd restart`;

    print("We are waiting fot eh other server to connect\n");

	#we wait for the two servers to be connected
	while(!areTwoServConnected()){

		print("We are waitting for the other node to connect\n");
		sleep(3);
	}

    print("We are testing if we are the first server\n");

	#we now define the first serveur as primari (needed for the first synchronisation)
	if($CFG::hostName eq $CFG::config{'firstServHostName'}){

        print("We are defining the first server as reference\n");

		`drbdadm -- --overwrite-data-of-peer primary all`
	}

    print("We are waiting for the servers to sync\n");

	#we then wait for the two servers to be synchronised 
	while(!areTwoServSync()){

		print("We are waitting for the two servers to synchronise.\n");
		sleep(3);
	}

    print("We are stoping drbd\n");

	#We stop drbd, in order to configure it and enable dual primarie
	`/etc/init.d/drbd stop`;

    print("We are reconfiguring drbd\n");

	#we configure drbd (last config)
    $variables = {};
    $variables->{'drbdSharedSecret'} = $CFG::config{'drbdSharedSecret'};
    $variables->{'ddName'} = $CFG::config{'ddName'};
    $variables->{'firstServIP'} = $CFG::config{'firstServIP'};
    $variables->{'SeconServIP'} = $CFG::config{'SeconServIP'};
    $variables->{'firstServHostName'} = $CFG::config{'firstServHostName'};
    $variables->{'SeconServHostName'} = $CFG::config{'SeconServHostName'};

    print("We are saving the new config of drbd\n");

    file "/etc/drbd.conf",
            content         => template("templates/drbd_install_2.conf.tpl", variables => $variables),
            owner           => "root",
            group           => "root",
            mode            => "640";

    print("We are restarting drbd\n");

	#we restart the drbd deamon
	`/etc/init.d/drbd restart`;

    print("We install ocfs2\n");

	#we install the soft for OCFS2
	#install 'ocfs2-tools';
    install ["ocfs2-tools", "dlm-pcmk", "ocfs2-tools-pacemaker", "openais"];

    print("We test if we are the first server\n");

	#we format the media in OCFS2. The first server is the one that does it.
    if($CFG::hostName eq $CFG::config{'firstServHostName'}){

        print("We make the ocfs2 volume\n");

        `mkfs -t ocfs2 -N 2 -L ocfs2_drbd0 /dev/drbd0`;
    }

    communication::waitOtherServ('drbd', 1);

    print("We set the last configuration for ocfs2\n");

    $variables = {};
    $variables->{'firstServIP'} = $CFG::config{'firstServIP'};
    $variables->{'SeconServIP'} = $CFG::config{'SeconServIP'};
    $variables->{'firstServHostName'} = $CFG::config{'firstServHostName'};
    $variables->{'SeconServHostName'} = $CFG::config{'SeconServHostName'};

    print("We save the ocfs2 configuration\n");

    file "/etc/ocfs2/cluster.conf",
            content         => template("templates/cluster.conf.tpl", variables => $variables),
            owner           => "root",
            group           => "root",
            mode            => "640";

	#finaly we load the kernel modul
	#`/etc/init.d/o2cb load`;

    print("We quit the install of drbd\n");

	return 1;
};


sub areTwoServConnected {

	my $status1 = `/etc/init.d/drbd status | tail -1 | awk {'print \$3'} | cut --delimiter="/" -f1 | sed 's\/\\n\$\/\/'`;
        my $status2 = `/etc/init.d/drbd status | tail -1 | awk {'print \$3'} | cut --delimiter="/" -f2 | sed 's\/\\n\$\/\/'`;

	#the sed at the end remove the \n at the end of the string (if there is one) and it adds an \n every times.
	#That means that status1 and status2 are ended by only one \n, all the time.

	if( ($status1 eq "Unknown\n") || ($status2 eq "Unknown\n") ){

		return FALSE;
	}else{

		return TRUE;
	}
}

sub areTwoServSync {

        my $status1 = `/etc/init.d/drbd status | tail -1 | awk {'print \$4'} | cut --delimiter="/" -f1 | sed 's\/\\n\$\/\/'`;
        my $status2 = `/etc/init.d/drbd status | tail -1 | awk {'print \$4'} | cut --delimiter="/" -f2 | sed 's\/\\n\$\/\/'`;

        #the sed at the end remove the \n at the end of the string (if there is one) and it adds an \n every times.
        #That means that status1 and status2 are ended by only one \n, all the time.

        if( (($status1 eq "UpToDate\n") && ($status2 eq "UpToDate\n")) || (!areTwoServConnected()) ){

                return TRUE;
        }else{

                return FALSE;
        }
}



sub finalConfig {

        my $variables = {};
        $variables->{'drbdSharedSecret'} = $CFG::config{'drbdSharedSecret'};
        $variables->{'ddName'} = $CFG::config{'ddName'};
        $variables->{'firstServIP'} = $CFG::config{'firstServIP'};
        $variables->{'SeconServIP'} = $CFG::config{'SeconServIP'};
        $variables->{'firstServHostName'} = $CFG::config{'firstServHostName'};
        $variables->{'SeconServHostName'} = $CFG::config{'SeconServHostName'};

        file "/etc/drbd.conf",
                content         => template("templates/drbd.conf.tpl", variables => $variables),
                owner           => "root",
                group           => "root",
                mode            => "640";

}




1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Service::drbd/;
  
 task yourtask => sub {
    Service::drbd::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
