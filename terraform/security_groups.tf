resource "yandex_vpc_security_group" "group1" {
  name        = "My security group"
  description = "description for my security group"
  network_id  = "${yandex_vpc_network.foo.id}"
  labels = {
    my-label = "catgpt-sg"
  }
  ingress {
    description = "Allow Inbound HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow Inbound HTTP"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow Inbound ssh"
    port   = 22
    protocol    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "helthcheck"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    v4_cidr_blocks = ["198.18.235.0/24", "198.18.248.0/24"]
  }
  egress {
    description = "test in "
    from_port   = 0
    to_port     = 65535
    protocol    = "Any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "out "
    from_port   = 0
    to_port     = 65535
    protocol    = "Any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "out "
    port   = 80
    protocol    = "Any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "dns"
    port   = 53
    protocol    = "Udp"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "cloud"
    port   = 68
    protocol    = "Udp"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "cloud2"
    port   = 58
    protocol    = "Any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol          = "TCP"
    description       = "The rule allows availability checks from the load balancer address range. It is required for the operation of a fault-tolerant cluster and load balancer services."
    predefined_target = "loadbalancer_healthchecks"
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "ANY"
    description       = "The rule allows master to node and node to node communication inside a security group."
    predefined_target = "self_security_group"
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol       = "ICMP"
    description    = "Rule allows debugging ICMP packets from internal subnets."
    v4_cidr_blocks = ["172.16.0.0/12", "10.0.0.0/8", "192.168.0.0/16"]
  }
  egress {
    protocol       = "ANY"
    description    = "Rule allows all outgoing traffic. Nodes can connect to {{ container-registry-full-name }}, {{ objstorage-name }}, Docker Hub, and so on."
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}
