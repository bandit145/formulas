netbooter_packages:
  pkg.installed:
    - pkgs:
        - tftp-server
        - syslinux-tftpboot
        - nginx
        - kea

{% for file in salt['file.find']('/tftpboot/', mindepth=1) %}
{{ file }}:
  file.managed:
    - source: {{ file }}
    - name: /var/lib/tftpboot/{{ file.split('/')[-1] }}
{% endfor %}

/usr/share/nginx/html/netboot:
  file.directory:
    - owner: root
    - group: root
    - mode: 0755

nginx.service:
  service.running:
    - enable: true

/var/lib/tftpboot/pxelinux.cfg:
  file.directory:
    - user: root
    - group: root
    - mode: 0644

{% for instance in pillar['netboot_instances'] | default([]) %}
/var/lib/tftpboot/pxelinux.cfg/{{ instance['mac'].lower() | replace(':', '-') }}-1e:
  file.managed:
    - source: salt://{{ tpldir }}/files/pxe-file.jinja
    - user: root
    - group: root
    - mode: 0644
    - template: jinja
    - defaults:
        instance: {{ instance }}
{% endfor %}

#Prune unneeded hosts
{% set desired_instances = pillar['netboot_instances'] | default([]) | json_query('[*].mac') %}
{% for mac in salt['file.find']('/var/lib/tftpboot/pxelinux.cfg', mindepth=1) %}
{% if mac.split('/')[-1] | regex_replace('-1e$', '') | replace('-', ':') not in desired_instances %}
{{ mac }}:
  file.absent
{% endif %}
{% endfor %}

