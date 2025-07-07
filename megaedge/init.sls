/etc/pki/customers:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 0755

{% for customer in pillar.customers %}
{{ customer.asn }}_wg_gen_key:
  cmd.run:
    - name: "wg genkey | tee /etc/pki/customers/{{ customer.asn }} | wg pubkey | tee /etc/pki/customers/{{ customer.asn }}.pub && chmod 0660 /etc/pki/customers/{{ customer.asn }} && chown root:systemd-network /etc/pki/customers/{{ customer.asn }}"
    - creates:
      - /etc/pki/customers/{{ customer.asn }}
      - /etc/pki/customers/{{ customer.asn }}.pub

/etc/systemd/network/{{ customer.asn }}.netdev:
  file.managed:
    - source: salt://{{ tpldir }}/files/wg.netdev
    - template: jinja
    - context:
        customer_name: {{ customer.name }}
        customer_asn: {{ customer.asn }}
        private_key_file: /etc/pki/customers/{{ customer.asn }}
        customer_v6_subnet: {{ customer.subnet }}

/etc/systemd/network/{{ customer.asn }}.network:
  file.managed:
    - source: salt://{{ tpldir }}/files/wg.network
    - template: jinja
    - context:
        customer_name: {{ customer.name }}
        customer_asn: {{ customer.asn }}
    - require:
        - /etc/systemd/network/{{ customer.asn }}.netdev

{% endfor %}

systemd-networkd.service:
  module.run:
    - name: service.reload
    - m_name: systemd-networkd.service

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
