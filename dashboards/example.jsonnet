local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
g.dashboard.new('Example dashboard')
+ g.dashboard.withUid('example-dashboard')
+ g.dashboard.withDescription('Example Dashboard')
