/etc/pki/customers:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 0755

{% set wg_files = salt['file.find']('/etc/systemd/network/', regex='\d{10}\.netdev') %}
{% set customer_asns = pillar.customers | default([]) | json_query('[].to_string(asn)') %}

{% for customer in pillar.customers | default ([]) %}
{{ customer.asn }}_wg_gen_key:
  cmd.run:
    - name: "wg genkey | tee /etc/pki/customers/{{ customer.asn }} | wg pubkey | tee /etc/pki/customers/{{ customer.asn }}.pub && chmod 0660 /etc/pki/customers/{{ customer.asn }} && chown root:systemd-network /etc/pki/customers/{{ customer.asn }}"
    - creates:
      - /etc/pki/customers/{{ customer.asn }}
      - /etc/pki/customers/{{ customer.asn }}.pub

/etc/systemd/network/{{ customer.asn }}.netdev:
  file.managed:
    - source: salt://{{ tpldir }}/files/wg.netdev
    - user: root
    - group: root
    - mode: 0644
    - template: jinja
    - context:
        customer_name: {{ customer.name }}
        customer_asn: {{ customer.asn }}
        private_key_file: /etc/pki/customers/{{ customer.asn }}
        customer_v6_subnet: {{ customer.subnet }}
        peer_public_key: {{ customer.peer_public_key | default('') }}

/etc/systemd/network/{{ customer.asn }}.network:
  file.managed:
    - source: salt://{{ tpldir }}/files/wg.network
    - user: root
    - group: root
    - mode: 0644
    - template: jinja
    - context:
        customer_name: {{ customer.name }}
        customer_asn: {{ customer.asn }}
    - require:
        - /etc/systemd/network/{{ customer.asn }}.netdev

{% endfor %}

{% for remove_file in wg_files %}
{% set asn = remove_file.split('/')[-1].split('.')[0] %}

{% if asn not in customer_asns %}
{% set remove = true %}
remove_/etc/systemd/network/{{ asn }}.netdev:
  file.absent:
    - name: /etc/systemd/network/{{ asn }}.netdev

remove_/etc/systemd/network/{{ asn }}.network:
  file.absent:
    - name: /etc/systemd/network/{{ asn }}.network

remove_/etc/pki/customers/{{ asn }}.pub:
  file.absent:
    - name: /etc/pki/customers/{{ asn }}.pub

remove_/etc/pki/customers/{{ asn }}:
  file.absent:
    - name: /etc/pki/customers/{{ asn }}

{% endif %}

{% endfor %}

systemd-networkd.service:
  module.wait:
    - name: service.reload
    - m_name: systemd-networkd.service
{% if pillar.customers | default([]) != [] %}
    - watch:
{% if remove is defined %}
        - file: remove_/etc/systemd/network/*
{% endif %}
        - file: /etc/systemd/network/*
{% endif %}

/etc/frr/frr.conf:
  file.managed:
    - source: salt://{{ tpldir }}/files/frr.conf
    - mode: 0640
    - user: root
    - group: root
    - template: jinja
    - check_cmd: /usr/libexec/frr/bgpd -S -C -f

reload_frr:
  module.wait:
    - name: service.reload
    - m_name: frr
    - watch:
        - file: /etc/frr/frr.conf
        - frr.service

/etc/frr/daemons:
  file.replace:
    - repl: bgpd=yes
    - append_if_not_found: true
    - pattern: "^bgpd=no$"

frr.service:
  service.running:
    - enable: true
    - require:
        - file: /etc/frr/frr.conf
        - file: /etc/frr/daemons
