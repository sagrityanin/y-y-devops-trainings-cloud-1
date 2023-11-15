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
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "helthcheck"
    port   = 30080
    protocol    = "tcp"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "out "
    from_port   = 15
    to_port     = 9091
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
}
