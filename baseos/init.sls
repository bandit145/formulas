{% import_yaml tpldir+"/defaults.yaml" as defaults %}
include:
  - .networking
  - .repositories
{% if 'baseos_root_password_hash' in pillar %}
root:
  user.present:
    - password: {{ pillar['baseos_root_password_hash'] }}
{% endif %}

root_ssh_keys:
  ssh_auth.manage:
    - user: root
    - ssh_keys: {{ pillar['baseos_root_ssh_keys'] | default([]) }}

{% if grains['locale_info']['timezone'].lower() != "utc" %}
'timedatectl set-timezone UTC':
  cmd.run
{% endif %}

{% if grains['nodename'] != pillar['baseos_hostname'] %}
"hostnamectl set-hostname {{ pillar['baseos_hostname'] }}":
  cmd.run
{% endif %}

ensure_base_packages:
  pkg.installed:
    - pkgs: {{ defaults.packages + pillar['baseos_packages'] | default([]) }}
    - order: 6

/etc/ssh/sshd_config.d/60-baseos.conf:
  file.managed:
    - source: salt://{{ tpldir }}/files/60-baseos.conf
    - user: root
    - group: root
    - mode: 0644

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
