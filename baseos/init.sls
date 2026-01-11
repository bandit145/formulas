{% import_yaml tpldir+"/defaults.yaml" as defaults %}
include:
  - .networking
{% if 'bootc_managed' not in grains %}
  - .packages
{% endif %}

{% if 'baseos_root_password_hash' in pillar %}
root:
  user.present:
    - password: {{ pillar['baseos_root_password_hash'] }}
{% endif %}

root_ssh_keys:
  ssh_auth.manage:
    - user: root
    - ssh_keys: {{ pillar['baseos_root_ssh_keys'] | default([]) }}

{% for key, value in (pillar['baseos_sysctls'] | default({})).items() %}
{{ key }}:
  sysctl.present:
    - value: {{ value }}
{% endfor %}


{% if grains['locale_info']['timezone'].lower() != "utc" %}
'timedatectl set-timezone UTC':
  cmd.run
{% endif %}

{% if pillar['baseos_hostname'] is defined and grains['nodename'] != pillar['baseos_hostname'] %}
"hostnamectl set-hostname {{ pillar['baseos_hostname'] }}":
  cmd.run
{% endif %}

/etc/ssh/sshd_config.d/60-baseos.conf:
  file.managed:
    - source: salt://{{ tpldir }}/files/60-baseos.conf
    - user: root
    - group: root
    - mode: 0644

/etc/ssh/sshd_config.d:
  file.directory:
    - user: root
    - group: root
    - mode: 0755
    - clear: True
    - require:
        - file: /etc/ssh/sshd_config.d/60-baseos.conf

restart_sshd_if_changes:
  service.running:
    - name: sshd.service
    - reload: true
    - watch:
        - /etc/ssh/sshd_config.d/60-baseos.conf

/etc/systemd/resolved.conf:
  file.managed:
    - source: salt://{{ tpldir }}/files/resolved.conf
    - user: root
    - group: root
    - mode: 0644
    - template: jinja

systemd-resolved.service:
  service.running:
    - enable: true
    - reload: true
    - watch:
        - /etc/systemd/resolved.conf
