job "hw" {
  datacenters = ["dc1"]
  type = "service"

  group "tomcat" {
    count = 3
    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    task "hello" {
      driver = "raw_exec"

      artifact {
        source      = "https://s3.amazonaws.com/public-demo-assets/jake/nomad/simple_raw_exec/helloworld.war"
        destination = "/local/tomcat/webapps"
      }

      artifact {
        source      = "https://s3.amazonaws.com/public-demo-assets/jake/nomad/simple_raw_exec/server.xml"
        destination = "/local/tomcat/conf"
      }

      resources {
        network {
          mbits = 10
          port "http" {}
        }
      }

      env {
        CATALINA_OPTS = "-Dport.http=$NOMAD_PORT_http -Ddefault.context=$NOMAD_TASK_DIR"
        JAVA_HOME     = "/usr/lib/jvm/jre"
        CATALINA_HOME = "/usr/local/tomcat"
      }

      config {
        command = "/usr/local/tomcat/bin/catalina.sh"
        args    = ["run", "-config", "$NOMAD_TASK_DIR/tomcat/conf/server.xml"]
      }

      service {
        tags = ["urlprefix-/helloworld"]
        port = "http"

        check {
          name     = "index_check"
          type     = "http"
          path     = "/helloworld/index.html"
          interval = "10s"
          timeout  = "2s"
        }
      }
    } # end task
  } # end group
} # end job
