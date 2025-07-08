install_packages:
  pkg.installed:
    - pkgs:
      - tcpdump
      - procps-ng
      - wireguard-tools
      - frr

{% if grains.nodename == 'customer1' %}
/etc/frr/daemons:
  file.replace:
    - repl: bgpd=yes
    - append_if_not_found: true
    - pattern: "^bgpd=no$"

"ip link add dev wg0 type wireguard":
  cmd.run

"ip addr add fe80:4210:0:ff::2/56 dev wg0":
  cmd.run

"ip link add dev dummy0 type dummy":
  cmd.run

"ip addr add fd00:0000:156e:0f00::/56 dev dummy0":
  cmd.run

"ip link set up dev dummy0":
  cmd.run

"ip link set up dev wg0":
  cmd.run

/wg_priv_key:
  file.managed:
    - contents:
        - {{ grains.wg_priv_key }}

/etc/frr/frr.conf:
  file.managed:
    - source: salt://{{ tpldir }}/customer1_frr.conf

frr.service:
  service.running:
    - require:
        - file: /etc/frr/frr.conf

{% endif %}

{% if grains.nodename == 'customer2' %}
/etc/frr/daemons:
  file.replace:
    - repl: bgpd=yes
    - append_if_not_found: true
    - pattern: "^bgpd=no$"

"ip link add dev wg0 type wireguard":
  cmd.run

"ip addr add fe80:4220:0:ff::2/56 dev wg0":
  cmd.run

"ip link add dev dummy0 type dummy":
  cmd.run

"ip addr add fd00:0000:0414:be00::/56 dev dummy0":
  cmd.run

"ip link set up dev dummy0":
  cmd.run

"ip link set up dev wg0":
  cmd.run

/wg_priv_key:
  file.managed:
    - contents:
        - {{ grains.wg_priv_key }}

/etc/frr/frr.conf:
  file.managed:
    - source: salt://{{ tpldir }}/customer2_frr.conf

frr.service:
  service.running:
    - require:
        - file: /etc/frr/frr.conf

{% endif %}
