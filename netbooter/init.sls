{% for file in salt['file.find']('/tftpboot/', mindepth=1) %}
{{ file }}:
  file.managed:
    - source: {{ file }}
    - name: /var/lib/tftpboot/{{ file.split('/')[-1] }}
{% endfor %}

/usr/share/nginx/html/netboot:
  file.directory:
    - user: nginx
    - group: nginx
    - mode: 0775

/usr/share/nginx/html/netboot/install:
  file.directory:
    - user: nginx
    - group: nginx
    - mode: 0775
    - require:
        - /usr/share/nginx/html/netboot

/usr/share/nginx/html/netboot/os:
  file.directory:
    - user: nginx
    - group: nginx
    - mode: 0775
    - require:
        - /usr/share/nginx/html/netboot

/etc/nginx/nginx.conf:
  file.managed:
    - source: salt://{{ tpldir }}/files/nginx.conf
    - user: root
    - group: root
    - mode: 0644

nginx.service:
  service.running:
    - enable: true
    - reload: true
    - watch:
        - file: /etc/nginx/nginx.conf

kea-dhcp4.service:
  service.running:
    - enable: true
    - watch:
        - /etc/kea/kea-dhcp4.conf

kea-ctrl-agent.service:
  service.running:
    - enable: true

/var/lib/tftpboot/pxelinux.cfg:
  file.directory:
    - user: root
    - group: root
    - mode: 0644

{% for instance in pillar['netbooter_instances'] | default([]) %}
/var/lib/tftpboot/pxelinux.cfg/{{ instance['mac'].lower() | replace(':', '-') }}-1e:
  file.managed:
    - source: salt://{{ tpldir }}/files/pxe-file.jinja
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - defaults:
        instance: {{ instance }}
    - require:
        - /var/lib/tftpboot/pxelinux.cfg
{% endfor %}

#Prune unneeded hosts
{% set desired_instances = pillar['netbooter_instances'] | default([]) | json_query('[*].mac') %}
{% for mac in salt['file.find']('/var/lib/tftpboot/pxelinux.cfg', mindepth=1) %}
{% if mac.split('/')[-1] | regex_replace('-1e$', '') | replace('-', ':') not in desired_instances %}
{{ mac }}:
  file.absent
{% endif %}
{% endfor %}

/etc/kea/kea-dhcp4.conf:
  file.managed:
    - source: salt://{{ tpldir }}/files/kea-dhcp4.conf
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"

{% for instance in pillar['netbooter_instances'] | default([]) %}
/usr/share/nginx/html/netboot/install/{{ instance['hostname'] }}.ks:
  file.managed:
    - contents: {{ (instance['kickstart'] | default('')).split('\n') }}
    - user: nginx
    - group: nginx
    - mode: "0644"
    - require:
        - /usr/share/nginx/html/netboot/install
{% endfor %}
