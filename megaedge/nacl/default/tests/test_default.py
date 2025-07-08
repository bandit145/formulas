import pytest
import testinfra

import time

@pytest.fixture(scope="session")
def net_setup():
    edge = testinfra.get_host("docker://nacl_megaedge_default_instance")
    c1 = testinfra.get_host("docker://nacl_megaedge_default_customer1")
    c2 = testinfra.get_host("docker://nacl_megaedge_default_customer2")
    
    addr = edge.interface("eth1").addresses[0]
    edge_pub1 = edge.file("/etc/pki/customers/4210000000.pub").content_string.strip()
    edge_pub2 = edge.file("/etc/pki/customers/4220000000.pub").content_string.strip()

    ports = edge.run("wg show | grep port | awk '{print $3}'").stdout.split("\n")[:-1]

    if "peer" not in c1.run("wg show").stdout:
        res = c1.run(f"wg set wg0 listen-port 51820 private-key /wg_priv_key peer {edge_pub1} allowed-ips  fe80:4210:0:ff::/56 endpoint {addr}:{ports[0]}")
        assert res.rc == 0
    if "peer" not in c2.run("wg show").stdout:
        res = c2.run(f"wg set wg0 listen-port 51820 private-key /wg_priv_key peer {edge_pub2} allowed-ips  fe80:4220:0:ff::/56 endpoint {addr}:{ports[1]}")
        assert res.rc == 0

def test_megaedge(net_setup):
    edge = testinfra.get_host("docker://nacl_megaedge_default_instance")

    res = edge.run("vtysh -c 'show bgp summary'")

    assert "fe80:4210:0:ff::2 4 4210000000" in res.stdout
    assert "fe80:4220:0:ff::2 4 4220000000" in res.stdout

    start = time.time()
    res = edge.run("vtysh -c 'show bgp ipv6' | grep '*>' | wc -l")
    while time.time() - start <= 30 and res.stdout.strip() != '2':
        time.sleep(1)
        res = edge.run("vtysh -c 'show bgp ipv6' | grep '*>' | wc -l")


    res = edge.run("vtysh -c 'show bgp ipv6'")
    assert "fd00:0:156e:f00::/56" in res.stdout
    assert "fd00:0:414:be00::/56" in res.stdout

