baseos_hostname: instance
baseos_interfaces:
  - name: eth0
    config:
      - enabled: true
      - type: eth
      - proto: dhcp
      - enable_ipv6: true
baseos_firewalld_rules:
  - name: mgmt
    services:
      - ssh
    interfaces:
      - eth0
baseos_dns_servers: ['8.8.8.8', '8.8.4.4']
baseos_repositories:
  - id: baseos
    name: CentOS Stream $releasever - BaseOS
    metalink: https://mirrors.centos.org/metalink?repo=centos-baseos-$stream&arch=$basearch&protocol=https,http
    gpgkey: file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosoffical
    gpgcheck: 1
    repo_gpgcheck: 0
    metadata_expire: 6h
    countme: 1
    enabled: 1
  - id: appstream
    name: CentOS Stream $releasever - AppStream
    metalink: https://mirrors.centos.org/metalink?repo=centos-appstream-$stream&arch=$basearch&protocol=https,http
    gpgkey: file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosoffical
    gpgcheck: 1
    repo_gpgcheck: 0
    metadata_expire: 6h
    countme: 1
    enabled: 1
  - id: crb
    name: CentOS Stream $releasever - CRB
    metalink: https://mirrors.centos.org/metalink?repo=centos-crb-$stream&arch=$basearch&protocol=https,http
    gpgkey: file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosoffical
    gpgcheck: 1
    repo_gpgcheck: 0
    metadata_expire: 6h
    countme: 1
    enabled: 1
  - id: epel
    name: Extra Packages for Enterprise Linux $releasever - $basearch
    metalink: https://mirrors.fedoraproject.org/metalink?repo=epel-$releasever&arch=$basearch&infra$infra&content$contentdir
    gpgkey: https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-$releasever
    gpgcheck: 1
    repo_gpgcheck: 0
    metadata_expire: 6h
    enabled: 1
  - id: epel-next
    name: Extra Packages for Enterprise Linux $releasever - Next - $basearch
    metalink: https://mirrors.fedoraproject.org/metalink?repo=epel-next-$releasever&arch=$basearch&infra$infra&content$contentdir
    gpgkey: https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-$releasever
    gpgcheck: 1
    repo_gpgcheck: 0
    metadata_expire: 6h
    enabled: 1
