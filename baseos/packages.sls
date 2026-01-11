
install_packages:
  pkg.installed:
    - pkgs: {{ defaults["baseos_packages"] + pillar["baseos_packages"] | default([]) }}

{% set repos = defaults["baseos_repos"] %}
{% do repos.update(pillar["baseos_repos"] | default({})) %}

/etc/yum.repos.d/repos.repo:
  file.managed:
    - source: salt://{{ tpldir }}/files/repos.repo
    - user: root
    - group: root
    - mode: 0644
    - template: jinja
    - context:
       repos: {{ repos }}

