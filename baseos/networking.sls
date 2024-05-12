{% for interface in pillar['baseos_interfaces'] | default([]) -%}
interface_{{ interface.name }}:
  network.managed: {{ interface.config + [{"noifupdown": true}] }}
{% endfor %}

NetworkManager.service:
  service.running:
    - reload: true
    - enable: true
    - require:
        - interface_*

{%- for zone in pillar['baseos_firewalld_rules'] | default([]) -%}
firewalld_zone_{{ zone.name }}:
  firewalld.present:
    - name: {{ zone.name }}
    - ports: {{ zone.ports | default([]) }}
    - services: {{ zone.services | default([]) }}
    - interfaces: {{ zone.interfaces | default([]) }}
    - prune_ports: true
    - prune_interfaces: true
    - prune_services: true
    - require:
        - interface_*
{% endfor %}

