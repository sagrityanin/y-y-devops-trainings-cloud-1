resource "yandex_lb_network_load_balancer" "foo" {
  name = "sagrityanin-lb"
  
  deletion_protection = "false"
  
  attached_target_group {
    target_group_id = yandex_compute_instance_group.catgpt-group.load_balancer.0.target_group_id
    healthcheck {
      name = "catgptcheck"
      interval            = 2
      timeout             = 1
      unhealthy_threshold = 2
      healthy_threshold   = 2
      http_options {
        port = 8080
        path = "/"
      }
    }
  }
}
