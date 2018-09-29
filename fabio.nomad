job "fabio" {
  datacenters = ["dc1"]
  type = "system"

  group "fabio" {
    count = 1

    task "fabio" {
      driver       = "docker"

      resources {
        cpu    = 100
        memory = 128

        network {
          mbits = 10

          # Put Fabio on a well known ports so ALB can reach it
          port "http" {
            static = 9999
          }

          port "admin" {
            static = 9998
          }
        }
      }

      config {
        image        = "fabiolb/fabio"
        # Need host networking so Fabio can speak with the local Consul agent
        network_mode = "host"

        port_map {
	  http = 9999
        }

        port_map {
	  admin = 9998
        }
      }

      service {
        name = "fabio"
        tags = [ "fabio" ]
        port = "http"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

    } # end task
  } # end group
} # end job
