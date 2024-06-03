/etc/frr/daemons:
  file.managed:
    - source: salt://{{ tpldir }}/files/frr_daemons
    - user: frr
    - group: frr
    - mode: "0640"

/etc/frr/frr.conf:
  file.managed:
    - source: salt://{{ tpldir }}/files/frr.conf
    - user: frr
    - group: frr
    - mode: "0640"
    - template: jinja
    - defaults:
        machine_id: {{ grains['machine_id'] }}
        hostname: {{ pillar['baseos_hostname'] }}

frr.service:
  service.running:
    - enable: true
    - reload: true
    - watch:
        - /etc/frr/frr.conf
        - /etc/frr/daemons
