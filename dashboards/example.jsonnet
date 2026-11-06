local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

g.dashboard.new('Hello World')
+ g.dashboard.withUid('hello-world-dashboard')
+ g.dashboard.withDescription('A Hello world dashboard')
+ g.dashboard.withPanels([
  g.panel.text.new('Welcome')
  + g.panel.text.options.withContent('# Hello, world!')
  + g.panel.text.options.withMode('markdown')
  + g.panel.text.panelOptions.withGridPos(h=6, w=12, x=0, y=0),
])
