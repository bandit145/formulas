{% for interface in pillar['baseos_interfaces'] | default([]) %}
  {{ interface.name }}:
    network.managed: {{ interface.values.items }}
{% endfor %}
