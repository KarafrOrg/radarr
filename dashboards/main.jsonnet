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
    'hello-world.json': std.manifestJson(import 'example.jsonnet'),
  },
}
