{% for file in salt['file.find']('/etc/yum.repos.d/', mindepth=1, iname="*.repo") %}
{% if file.split('/')[-1] != "repos.repo" %}
{{ file }}:
  file.absent:
    - order: 4
{% endif %}
{% endfor %}

/etc/yum.repos.d/repos.repo:
  file.managed:
    - source: salt://{{ tpldir }}/files/repos.repo
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - order: 5

