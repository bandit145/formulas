baseos_hostname: instance
baseos_firewalld_rules:
  - name: mgmt
    services:
      - ssh
    interfaces:
      - eth0
baseos_dns_servers: ['8.8.8.8', '8.8.4.4']

