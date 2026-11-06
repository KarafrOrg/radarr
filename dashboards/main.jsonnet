{
  apiVersion: 'v1',
  kind: 'List',
  items: [
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
    },
    {
      apiVersion: 'v1',
      kind: 'ConfigMap',
      metadata: {
        name: 'infra-dashboards',
        labels: {
          grafana_dashboard: '1',
        },
        annotations: {
          grafana_folder: 'infra',
        },
      },
      data: {
        'kubernetes-persistent-volumes.json': std.manifestJson(import 'infra/kubernetes-persistent-volumes.jsonnet'),
        'sync-to-internal-registry.json': std.manifestJson(import 'infra/sync-to-internal-registry.jsonnet'),
      },
    },
  ],
}
