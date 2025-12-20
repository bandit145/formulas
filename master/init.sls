/etc/salt/master:
  file.managed:
    source: salt://{{ tpldir }}/files/master.conf
    user: salt
    group: salt
    mode: 0700
    template: jinja

{% if not salt.gpg.get_key(keyid=master_gpg_keyid, user="salt") %}
	import_pub_key:
	  module.run:
	    - gpg.import_key:
	        - text: {{ master_gpg_pub_key }}
		- user: "salt"
	    - gpg.import_key:
	        - text: {{ master_gpg_priv_key }}
		- user: "salt"
{% endif %}

salt-master.service:
  service.running:
    - enable: true
    - reload: true
    - watch:
        - file: /etc/salt/master
