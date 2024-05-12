netbooter_dhcp4_interface: "eth0"
netbooter_dhcp4_subnet: "192.168.200.0/24"
netbooter_boot_server: "192.168.200.3"
netbooter_dhcp4_subnet_pool: "192.168.200.3 - 192.168.200.254"
netbooter_instances:
  - hostname: instance.test.com 
    mac: 00:23:24:82:a8
    vmlinuz_uri: blablah
    append: boot append
    kickstart: |
      # Basic setup
      text
      network --bootproto=dhcp --device=link --activate
      # Basic partitioning
      clearpart --all --initlabel --disklabel=gpt
      reqpart --add-boot
      part / --grow --fstype xfs
      ostreecontainer --url quay.io/centos-bootc/centos-bootc:stream9
      firewall --enabled
      services --enabled=sshd
      rootpw --iscrypted locked
      sshkey --username root "<your key here>"
      reboot

