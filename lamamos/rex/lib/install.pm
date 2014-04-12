



sub installBaseSysteme {

  `apt-get update`;

  if($CFG::config{'OCFS2Init'} == "0"){

    firstPartInstall();
    $CFG::config{'OCFS2Init'} = "1";
    writeCfg('/etc/lamamos/lamamos.conf');


    #put the nodes in standby mode (for reboot)
    `crm node standby server1`;
    `crm node standby server2`;
    `crm configure property maintenance-mode=true`;

    #ugly as hell, need to wait for the modifs in pacemaker to take effect
    sleep(10);

    `/etc/init.d/pacemaker stop`;
    `/etc/init.d/corosync stop`;

    `shutdown -r 1`;

  }elsif($CFG::config{'OCFS2Init'} == "1"){

    secondPartInstall();
    $CFG::config{'OCFS2Init'} = "2";
    writeCfg('/etc/lamamos/lamamos.conf');


    #put the nodes in standby mode (for reboot)
    #`crm node standby server1`;
    #`crm node standby server2`;
    #`crm configure property maintenance-mode=true`;

    #ugly as hell, need to wait for the modifs in pacemaker to take effect
    #sleep(10);

    #`/etc/init.d/pacemaker stop`;
    #`/etc/init.d/corosync stop`;

    #`shutdown -r 1`;
  }elsif($CFG::config{'OCFS2Init'} == "2"){

    `/etc/init.d/pacemaker start`;
    while(!Service::pacemaker::isPacemakerRunning()){

      print("We are waitting for pacemakert to start\n");
      sleep(2);
    };

    #hugly as hell, we need to wait for pacemaker to finish to start
    sleep(15);
  }

}















sub firstPartInstall {

  #install drbd
  Service::drbd::define();




  #folder for the shared hard drives
  mkdir "/data",
    owner   => "root",
    group   => "root",
    mode    => 755;




  #pacemaker	
  Service::pacemaker::define({

    'enable_secauth'    => 1,
    'authkey_path'      => '/etc/corosync/authkey',
    'bind_address'      => '192.168.56.0',
    'multicast_address' => '226.99.5.1',
  });


  Service::pacemaker::service::define({

    'name'    => 'pacemaker',
    'version' => '1',
  });

  #TODO : check this works fine
  Service::pacemaker::waitForTwoServToConnect();

  #ugly as hell, we wait for the two server to detet that they are connected
  sleep(5);	



  #we now define the first server as primari (needed for the first synchronisation)
  if($CFG::hostName eq $CFG::config{'firstServHostName'}){

    Service::pacemaker::property::define({

      'name' => 'no-quorum-policy',
      'value' => 'ignore',
    });

    Service::pacemaker::property::define({

      'name' => 'stonith-enabled',
      'value' => 'false',
    });

    Service::pacemaker::rsc_defaults::define({

      'name' => 'resource-stickiness',
      'value' => '100',
    });



    # primitive p_drbd_ocfs2 ocf:linbit:drbd params drbd_resource="r0"
    Service::pacemaker::primitive::define({

      'primitive_name' => 'p_drbd_ocfs2',
      'primitive_class' => 'ocf',
      'provided_by' => 'linbit',
      'primitive_type' => 'drbd',
      'parameters' => {'drbd_resource' => 'r0',},
    });

    # ms ms_drbd_ocfs2 p_drbd_ocfs2 meta master-max=2 clone-max=2 notify=true
    Service::pacemaker::master::define({

      'name' => 'ms_drbd_ocfs2',
      'primitive' => 'p_drbd_ocfs2',
      'meta' => {
        'master-max' => '2',
        'clone-max' => '2',
        'notify' => 'true',
      },
    });



    # primitive resDLM ocf:pacemaker:controld
    Service::pacemaker::primitive::define({

      'primitive_name' => 'resDLM',
      'primitive_class' => 'ocf',
      'provided_by' => 'pacemaker',
      'primitive_type' => 'controld',
    });

    # clone cloneDLM resDLM meta globally-unique="false" interleave="true"
    Service::pacemaker::clone::define({

      'name' => 'cloneDLM',
      'primitive' => 'resDLM',
      'meta' => {'globally-unique' => 'false', 'interleave' => 'true',},
    });

    # colocation colDLMDRBD inf: cloneDLM ms_drbd_ocfs2:Master
    Service::pacemaker::colocation::define({

      'name' => 'colDLMDRBD',
      'score' => 'INFINITY',
      'primitives' => ['cloneDLM', 'ms_drbd_ocfs2:Master'],
    });

    # order ordDRBDDLM inf: ms_drbd_ocfs2:promote cloneDLM
    Service::pacemaker::order::define({

      'name' => 'ordDRBDDLM',
      'score' => '0',
      'first' => 'ms_drbd_ocfs2:promote',
      'second' => 'cloneDLM',
    });




    # primitive resO2CB ocf:pacemaker:o2cb
    Service::pacemaker::primitive::define({

      'primitive_name' => 'resO2CB',
      'primitive_class' => 'ocf',
      'provided_by' => 'pacemaker',
      'primitive_type' => 'o2cb',
    });

    # clone cloneO2CB resO2CB meta globally-unique="false" interleave="true"
    Service::pacemaker::clone::define({

      'name' => 'cloneO2CB',
      'primitive' => 'resO2CB',
      'meta' => {'globally-unique' => 'false', 'interleave' => 'true',},
    });

    # colocation colO2CBDLM inf: cloneO2CB cloneDLM
    Service::pacemaker::colocation::define({

      'name' => 'colO2CBDLM',
      'score' => 'INFINITY',
      'primitives' => ['cloneO2CB', 'cloneDLM'],
    });

    # order ordDLMO2CB inf: cloneDLM cloneO2CB
    Service::pacemaker::order::define({

      'name' => 'ordDLMO2CB',
      'score' => '0',
      'first' => 'cloneDLM',
      'second' => 'cloneO2CB',
    });


  }


  #TODO : check if this works fine
  communication::waitOtherServ('firstInstall', 1);

}





sub secondPartInstall {

  `/etc/init.d/drbd start`;
  #Ugly, should be waitting for the two node to be synchronised
  sleep(5);

  `/etc/init.d/pacemaker start`;
  while(!Service::pacemaker::isPacemakerRunning()){

    print("We are waitting for pacemakert to start\n");
    sleep(2);
  };

  #hugly as hell, we need to wait for pacemaker to finish to start
  sleep(5);

  print("start to relaunch every nodes");
  if($CFG::hostName eq $CFG::config{'firstServHostName'}){

    #put the nodes in online mode (because of the reboot)
    `crm node online server1`;
    print("le serv1 est en ligne\n");
    sleep(2);
    `crm node online server1`;
    print("le serv1 est en ligne\n");
    sleep(2);
    `crm node online server2`;
    print("le serv2 est en ligne\n");
    sleep(2);
    `crm configure property maintenance-mode=false`;
    print("sortie du mode maintenance\n");

    #need to wait for drbd to be launched
    #ugly as hell, but should be fine for now (to wait for drbd to start)
    sleep(5);
  }

  communication::waitOtherServ('secondInstall', 1);

  #Now that drbd is launched we configure every serv into primary mode
  `drbdadm primary all`;
  sleep(10);  #wait for the config to take effect


  if($CFG::hostName eq $CFG::config{'firstServHostName'}){

    `tunefs.ocfs2 --yes --update-cluster-stack /dev/drbd0`;

    #ajout du montage du filse systeme.
    # primitive p_fs_ocfs2 ocf:heartbeat:Filesystem params device="/dev/drbd0" directory="/data" fstype="ocfs2" options="rw,noatime"
    Service::pacemaker::primitive::define({

      'primitive_name' => 'p_fs_ocfs2',
      'primitive_class' => 'ocf',
      'provided_by' => 'heartbeat',
      'primitive_type' => 'Filesystem',
      'parameters' => {'device' => '/dev/drbd0', 'directory' => '/data', 'fstype' => 'ocfs2', 'options' => 'rw,noatime',},
    });

    # clone cl_fs_ocfs2 p_fs_ocfs2
    Service::pacemaker::clone::define({

      'name' => 'cl_fs_ocfs2',
      'primitive' => 'p_fs_ocfs2',
    });

    # colocation c_ocfs2 inf: cl_fs_ocfs2 cloneO2CB
    Service::pacemaker::colocation::define({

      'name' => 'c_ocfs2',
      'score' => 'INFINITY',
      'primitives' => ['cl_fs_ocfs2', 'cloneO2CB'],
    });

    # order o_ocfs2 inf: cloneO2CB cl_fs_ocfs2:start
    Service::pacemaker::order::define({

      'name' => 'o_ocfs2',
      'score' => 'INFINITY',
      'first' => 'cloneO2CB',
      'second' => 'cl_fs_ocfs2:start',
    });
  }

  #TODO : check that it works fine
  communication::waitOtherServ('secondInstall', 2);

  #Service::drbd::finalConfig();

  #TODO : (need to change the split brain management)

  #we relaunch the mounting of the file systeme (some time it doesn't work fine the first time
  sleep(10);
  `crm resource cleanup cl_fs_ocfs2`;

}



1;