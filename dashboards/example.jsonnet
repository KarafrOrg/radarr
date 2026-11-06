local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

local dashboard =
  g.dashboard.new('Hello World')
  + g.dashboard.withUid('hello-world-dashboard')
  + g.dashboard.withDescription('A Hello world dashboard')
  + g.dashboard.withPanels([
    g.panel.text.new('Welcome')
    + g.panel.text.options.withContent('# Hello, world!')
    + g.panel.text.options.withMode('markdown')
    + g.panel.text.panelOptions.withGridPos(h=6, w=12, x=0, y=0),
  ]);

{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: 'hello-world-dashboard',
    labels: {
      grafana_dashboard: '1',
    },
  },
  data: {
    'hello-world.json': std.manifestJson(dashboard),
  },
}
