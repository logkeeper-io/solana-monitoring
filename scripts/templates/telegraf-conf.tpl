# Global Agent Configuration
[agent]
  hostname = "${nodeName}" # set this to a name you want to identify your node in the grafana dashboard
  flush_interval = "15s"
  interval = "15s"
  logfile = "/var/log/telegraf/telegraf.log"
  debug = false

# Input Plugins
[[inputs.cpu]]
    percpu = true
    totalcpu = true
    collect_cpu_time = false
    report_active = false
[[inputs.disk]]
    ignore_fs = ["devtmpfs", "devfs"]
[[inputs.diskio]]
[[inputs.mem]]
[[inputs.net]]
[[inputs.system]]
[[inputs.swap]]
[[inputs.netstat]]
[[inputs.processes]]
[[inputs.kernel]]
[[inputs.diskio]]

# Output Plugin InfluxDB
[[outputs.influxdb]]
  database = "${influxDb}"
  urls = [ "${influxUrl}" ] # keep this to send all your metrics to the community dashboard otherwise use http://yourownmonitoringnode:8086
  username = "${influxUsername}" # keep both values if you use the community dashboard
  password = "${influxPassowrd}"

[[inputs.exec]]
  commands = ["sudo ${monitorCommand}"]
  interval = "${interval}"
  timeout = "${timeout}"
  data_format = "influx"
  data_type = "integer"