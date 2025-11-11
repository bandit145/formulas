{% for zone in pillar['baseos_firewalld_rules'] | default([]) %}
firewalld_zone_{{ zone.name }}:
  firewalld.present:
    - name: {{ zone.name }}
    - ports: {{ zone.ports | default([]) }}
    - services: {{ zone.services | default([]) }}
    - interfaces: {{ zone.interfaces | default([]) }}
    - prune_ports: true
    - prune_interfaces: true
    - prune_services: true
    - order: 3
{% endfor %}
