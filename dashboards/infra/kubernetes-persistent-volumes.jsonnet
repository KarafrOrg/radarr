local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

local override = g.panel.table.standardOptions.override.byName;

local statOptions = {
  colorMode: 'background',
  orientation: 'auto',
  reduceOptions: {
    calcs: [
      'mean',
    ],
    fields: '',
    values: false,
  },
};
local forecastFields = {
  defaults: {
    color: {
      mode: 'thresholds',
    },
    decimals: 0,
    noValue: '--',
    thresholds: {
      mode: 'absolute',
      steps: [
        {
          color: 'light-green',
          value: 0,
        },
        {
          color: 'light-green',
          value: -0.0001,
        },
        {
          color: 'semi-dark-orange',
          value: 0.0001,
        },
      ],
    },
    unit: 'none',
  },
};
local organizeTransformations = [
  {
    id: 'organize',
    options: {},
  },
];
local statusFields = {
  defaults: {
    color: {
      mode: 'thresholds',
    },
    decimals: 0,
    noValue: '--',
    thresholds: {
      mode: 'absolute',
      steps: [
        {
          color: 'semi-dark-red',
          value: 0,
        },
        {
          color: 'light-green',
          value: -0.0001,
        },
        {
          color: 'semi-dark-red',
          value: 0.0001,
        },
      ],
    },
    unit: 'none',
  },
};
local usageRateOptions = {
  alertThreshold: true,
  legend: {
    calcs: [],
    displayMode: 'list',
    placement: 'bottom',
    showLegend: true,
  },
  tooltip: {
    hideZeros: false,
    mode: 'single',
    sort: 'none',
  },
};
local usageRateFields = {
  defaults: {
    color: {
      mode: 'palette-classic',
    },
    custom: {
      axisBorderShow: false,
      axisCenteredZero: false,
      axisColorMode: 'text',
      axisLabel: '',
      axisPlacement: 'auto',
      barAlignment: 0,
      barWidthFactor: 0.6,
      drawStyle: 'line',
      fillOpacity: 0,
      gradientMode: 'none',
      hideFrom: {
        legend: false,
        tooltip: false,
        viz: false,
      },
      insertNulls: false,
      lineInterpolation: 'linear',
      lineWidth: 1,
      pointSize: 5,
      scaleDistribution: {
        type: 'linear',
      },
      showPoints: 'auto',
      showValues: false,
      spanNulls: false,
      stacking: {
        group: 'A',
        mode: 'none',
      },
      thresholdsStyle: {
        mode: 'off',
      },
    },
    thresholds: {
      mode: 'absolute',
      steps: [
        {
          color: 'green',
          value: 0,
        },
        {
          color: 'red',
          value: 80,
        },
      ],
    },
  },
};

g.dashboard.new('kubernetes-persistent-volumes')
+ g.dashboard.withDescription('Monitors all persistent volumes that exists within a Kubernetes cluster. Prometheus is used as datasource. ')
+ g.dashboard.withRefresh('1m')
+ g.dashboard.withAnnotations([
  {
    builtIn: 1,
    datasource: {
      uid: '-- Grafana --',
    },
    enable: true,
    hide: true,
    iconColor: 'rgba(0, 211, 255, 1)',
    limit: 100,
    name: 'Annotations & Alerts',
    showIn: 0,
    type: 'dashboard',
  },
])
+ g.dashboard.time.withFrom('now-24h')
+ g.dashboard.time.withTo('now')
+ g.dashboard.withVariables([
  g.dashboard.variable.datasource.new('datasource', 'prometheus') + {
    current: {
      text: 'Mimir',
      value: 'mimir',
    },
    includeAll: false,
    label: 'Datasource',
    options: [],
    refresh: 1,
    regex: '',
  },
  g.dashboard.variable.query.new('k8s_namespace') + {
    allValue: '.*',
    current: {
      text: [
        'All',
      ],
      value: [
        '$__all',
      ],
    },
    datasource: 'mimir',
    definition: 'label_values(namespace)',
    includeAll: true,
    label: 'Namespace',
    multi: true,
    options: [],
    query: 'label_values(namespace)',
    refresh: 2,
    regex: '',
    sort: 1,
  },
  g.dashboard.variable.textbox.new('warning_threshold', '80') + {
    current: {
      text: '80',
      value: '80',
    },
    hide: 2,
    label: 'PVC % Used Warning Threshold',
    options: [
      {
        selected: true,
        text: '80',
        value: '80',
      },
    ],
  },
])
+ g.dashboard.withPanels([
  g.panel.row.new('Alerts')
  + g.panel.row.withId(26)
  + g.panel.row.withGridPos(0)
  + g.panel.row.withPanels([]),
  g.panel.stat.new('PVCs Full in 2 days - Based on Daily Usage')
  + g.panel.stat.panelOptions.withGridPos(h=4, w=8, x=0, y=1)
  + g.panel.stat.queryOptions.withDatasource('prometheus', 'mimir')
  + g.panel.stat.queryOptions.withTargets([
    g.query.prometheus.new('mimir', '(\n  count (\n    (kubelet_volume_stats_available_bytes{namespace=~"${k8s_namespace}"})\n    and\n    (predict_linear(kubelet_volume_stats_available_bytes{namespace=~"${k8s_namespace}"}[1d], 2 * 24 * 60 * 60) < 0)\n  )\n)\nor\nvector(0)')
    + g.query.prometheus.withInstant(true)
    + g.query.prometheus.withRefId('A'),
  ])
  + { id: 22, pluginVersion: '12.3.1' }
  + { options: statOptions, fieldConfig: forecastFields }
  + g.panel.stat.queryOptions.withTransformations(organizeTransformations),
  g.panel.stat.new('PVCs Full in 5 days - Based on Daily Usage')
  + g.panel.stat.panelOptions.withGridPos(h=4, w=8, x=8, y=1)
  + g.panel.stat.queryOptions.withDatasource('prometheus', 'mimir')
  + g.panel.stat.queryOptions.withTargets([
    g.query.prometheus.new('mimir', '(\n  count (\n    (kubelet_volume_stats_available_bytes{namespace=~"${k8s_namespace}"})\n    and\n    (predict_linear(kubelet_volume_stats_available_bytes{namespace=~"${k8s_namespace}"}[1d], 5 * 24 * 60 * 60) < 0)\n  )\n)\nor\nvector(0)')
    + g.query.prometheus.withInstant(true)
    + g.query.prometheus.withRefId('A'),
  ])
  + { id: 28, pluginVersion: '12.3.1' }
  + { options: statOptions, fieldConfig: forecastFields }
  + g.panel.stat.queryOptions.withTransformations(organizeTransformations),
  g.panel.stat.new('PVCs Full in 1 Week - Based on Daily Usage')
  + g.panel.stat.panelOptions.withGridPos(h=4, w=8, x=16, y=1)
  + g.panel.stat.queryOptions.withDatasource('prometheus', 'mimir')
  + g.panel.stat.queryOptions.withTargets([
    g.query.prometheus.new('mimir', '(\n  count (\n    (kubelet_volume_stats_available_bytes{namespace=~"${k8s_namespace}"})\n    and\n    (predict_linear(kubelet_volume_stats_available_bytes{namespace=~"${k8s_namespace}"}[1d], 7 * 24 * 60 * 60) < 0)\n  )\n)\nor\nvector(0)')
    + g.query.prometheus.withInstant(true)
    + g.query.prometheus.withRefId('A'),
  ])
  + { id: 27, pluginVersion: '12.3.1' }
  + { options: statOptions, fieldConfig: forecastFields }
  + g.panel.stat.queryOptions.withTransformations(organizeTransformations),
  g.panel.stat.new('PVCs Above Warning Threshold')
  + g.panel.stat.panelOptions.withGridPos(h=4, w=8, x=0, y=5)
  + g.panel.stat.queryOptions.withDatasource('prometheus', 'mimir')
  + g.panel.stat.queryOptions.withTargets([
    g.query.prometheus.new('mimir', 'count (max by (persistentvolumeclaim,namespace) (kubelet_volume_stats_used_bytes{namespace=~"${k8s_namespace}"} ) and (max by (persistentvolumeclaim,namespace) (kubelet_volume_stats_used_bytes{namespace=~"${k8s_namespace}"} )) / (max by (persistentvolumeclaim,namespace) (kubelet_volume_stats_capacity_bytes{namespace=~"${k8s_namespace}"} )) >= (${warning_threshold} / 100)) or vector (0)')
    + g.query.prometheus.withInstant(true)
    + g.query.prometheus.withRefId('A'),
  ])
  + { id: 21, pluginVersion: '12.3.1' }
  + { options: statOptions, fieldConfig: {
    defaults: {
      color: {
        mode: 'thresholds',
      },
      noValue: '--',
      thresholds: {
        mode: 'absolute',
        steps: [
          {
            color: 'semi-dark-red',
            value: 0,
          },
          {
            color: 'light-green',
            value: -0.0001,
          },
          {
            color: 'semi-dark-red',
            value: 0.0001,
          },
        ],
      },
      unit: 'none',
    },
  } },
  g.panel.stat.new('PVCs in Pending State')
  + g.panel.stat.panelOptions.withGridPos(h=4, w=8, x=8, y=5)
  + g.panel.stat.queryOptions.withDatasource('prometheus', 'mimir')
  + g.panel.stat.queryOptions.withTargets([
    g.query.prometheus.new('mimir', 'count((kube_persistentvolumeclaim_status_phase{namespace=~"${k8s_namespace}",phase="Pending"}==1)) or vector(0)')
    + g.query.prometheus.withInstant(true)
    + g.query.prometheus.withRefId('A'),
  ])
  + { id: 24, pluginVersion: '12.3.1' }
  + { options: statOptions, fieldConfig: statusFields }
  + g.panel.stat.queryOptions.withTransformations(organizeTransformations),
  g.panel.stat.new('PVCs in Lost State')
  + g.panel.stat.panelOptions.withGridPos(h=4, w=8, x=16, y=5)
  + g.panel.stat.queryOptions.withDatasource('prometheus', 'mimir')
  + g.panel.stat.queryOptions.withTargets([
    g.query.prometheus.new('mimir', 'count((kube_persistentvolumeclaim_status_phase{namespace=~"${k8s_namespace}",phase="Lost"}==1)) or vector(0)')
    + g.query.prometheus.withInstant(true)
    + g.query.prometheus.withRefId('A'),
  ])
  + { id: 23, pluginVersion: '12.3.1' }
  + { options: statOptions, fieldConfig: statusFields }
  + g.panel.stat.queryOptions.withTransformations(organizeTransformations),
  g.panel.row.new('Usage statistics')
  + g.panel.row.withId(17)
  + g.panel.row.withGridPos(9)
  + g.panel.row.withPanels([]),
  g.panel.table.new('Persistent Volume Claim')
  + g.panel.table.panelOptions.withGridPos(h=12, w=24, x=0, y=10)
  + g.panel.table.queryOptions.withDatasource('prometheus', 'mimir')
  + g.panel.table.queryOptions.withTargets([
    g.query.prometheus.new('mimir', ' sum by (persistentvolumeclaim,namespace,storageclass,volumename) (kube_persistentvolumeclaim_info{namespace=~"${k8s_namespace}"})')
    + g.query.prometheus.withFormat('table')
    + g.query.prometheus.withInstant(true)
    + g.query.prometheus.withRefId('A'),
    g.query.prometheus.new('mimir', 'sum by (persistentvolumeclaim) (kubelet_volume_stats_capacity_bytes{namespace=~"${k8s_namespace}"}/1024/1024/1024)')
    + g.query.prometheus.withFormat('table')
    + g.query.prometheus.withInstant(true)
    + g.query.prometheus.withRefId('B'),
    g.query.prometheus.new('mimir', 'sum by (persistentvolumeclaim) (kubelet_volume_stats_used_bytes{namespace=~"${k8s_namespace}"}/1024/1024/1024)')
    + g.query.prometheus.withFormat('table')
    + g.query.prometheus.withInstant(true)
    + g.query.prometheus.withRefId('C'),
    g.query.prometheus.new('mimir', 'sum by (persistentvolumeclaim) (kubelet_volume_stats_available_bytes{namespace=~"${k8s_namespace}"}/1024/1024/1024)')
    + g.query.prometheus.withFormat('table')
    + g.query.prometheus.withInstant(true)
    + g.query.prometheus.withRefId('D'),
    g.query.prometheus.new('mimir', 'sum(kube_persistentvolumeclaim_status_phase{namespace=~"${k8s_namespace}",phase=~"(Pending|Lost)"}) by (persistentvolumeclaim) + sum(kube_persistentvolumeclaim_status_phase{namespace=~"${k8s_namespace}",phase=~"(Lost)"}) by (persistentvolumeclaim)')
    + g.query.prometheus.withFormat('table')
    + g.query.prometheus.withInstant(true)
    + g.query.prometheus.withRefId('E'),
    g.query.prometheus.new('mimir', 'sum by (persistentvolumeclaim) (kubelet_volume_stats_used_bytes{namespace=~"${k8s_namespace}"}/kubelet_volume_stats_capacity_bytes{namespace=~"${k8s_namespace}"} * 100)')
    + g.query.prometheus.withFormat('table')
    + g.query.prometheus.withInstant(true)
    + g.query.prometheus.withRefId('F'),
  ])
  + { id: 29, pluginVersion: '12.3.1' }
  + { options: {
    frameIndex: 2,
    sortBy: [
      {
        desc: false,
        displayName: 'PersistentVolumeClaim',
      },
    ],
  }, fieldConfig: {
    defaults: {
      color: {
        mode: 'thresholds',
      },
      custom: {
        align: 'auto',
        cellOptions: {
          type: 'auto',
        },
        filterable: false,
        footer: {
          reducers: [],
        },
        inspect: false,
      },
      noValue: '--',
      thresholds: {
        mode: 'absolute',
        steps: [
          {
            color: 'light-green',
            value: 0,
          },
        ],
      },
      unit: 'none',
    },
  } }
  + g.panel.table.standardOptions.withOverrides([
    override.new('Used (%)')
    + override.withProperty('custom.cellOptions', { mode: 'gradient', type: 'gauge' })
    + override.withProperty('thresholds', {
      mode: 'absolute',
      steps: [
        { color: 'light-green', value: 0 },
        { color: 'semi-dark-yellow', value: 70 },
        { color: 'dark-red', value: 80 },
      ],
    })
    + override.withProperty('decimals', 1),
    override.new('Status')
    + override.withProperty('custom.cellOptions', { mode: 'gradient', type: 'color-background' })
    + override.withProperty('mappings', [{
      type: 'value',
      options: {
        '0': { text: 'Bound' },
        '1': { text: 'Pending' },
        '2': { text: 'Lost' },
      },
    }])
    + override.withProperty('thresholds', {
      mode: 'absolute',
      steps: [
        { color: 'light-green', value: 0 },
        { color: 'light-green', value: 0 },
        { color: 'semi-dark-orange', value: 1 },
        { color: 'semi-dark-red', value: 2 },
      ],
    })
    + override.withProperty('noValue', '--')
    + override.withProperty('custom.align', 'center'),
  ] + [
    override.new(column.name) + override.withProperty('custom.width', column.width)
    for column in [
      { name: 'Namespace', width: 120 },
      { name: 'Status', width: 80 },
      { name: 'Capacity (GiB)', width: 120 },
      { name: 'Used (GiB)', width: 120 },
      { name: 'Available (GiB)', width: 120 },
      { name: 'StorageClass', width: 150 },
      { name: 'PersistentVolumeClaim', width: 370 },
    ]
  ])
  + g.panel.table.queryOptions.withTransformations([
    {
      id: 'seriesToColumns',
      options: {
        byField: 'persistentvolumeclaim',
      },
    },
    {
      id: 'organize',
      options: {
        excludeByName: {
          Time: true,
          'Time 1': true,
          'Time 2': true,
          'Time 3': true,
          'Time 4': true,
          'Time 5': true,
          'Time 6': true,
          'Value #A': true,
        },
        indexByName: {},
        renameByName: {
          'Time 1': '',
          'Time 2': '',
          'Time 3': '',
          'Time 4': '',
          'Time 5': '',
          'Time 6': '',
          'Value #A': '',
          'Value #B': 'Capacity (GiB)',
          'Value #C': 'Used (GiB)',
          'Value #D': 'Available (GiB)',
          'Value #E': 'Status',
          'Value #F': 'Used (%)',
          namespace: 'Namespace',
          persistentvolumeclaim: 'PersistentVolumeClaim',
          storageclass: 'StorageClass',
          volumename: 'PhysicalVolume',
        },
      },
    },
  ]),
  g.panel.table.new('Storage Class')
  + g.panel.table.panelOptions.withGridPos(h=5, w=24, x=0, y=22)
  + g.panel.table.queryOptions.withDatasource('prometheus', 'mimir')
  + g.panel.table.queryOptions.withTargets([
    g.query.prometheus.new('mimir', 'kube_storageclass_info')
    + g.query.prometheus.withFormat('table')
    + g.query.prometheus.withRefId('A'),
  ])
  + { id: 7, pluginVersion: '12.3.1' }
  + { options: {
    sortBy: [
      {
        desc: true,
        displayName: 'Status',
      },
    ],
  }, fieldConfig: {
    defaults: {
      custom: {
        align: 'auto',
        cellOptions: {
          type: 'auto',
        },
        filterable: false,
        footer: {
          reducers: [],
        },
        inspect: false,
      },
      thresholds: {
        mode: 'absolute',
        steps: [
          {
            color: 'green',
            value: 0,
          },
        ],
      },
    },
  } }
  + g.panel.table.queryOptions.withTransformations([
    {
      id: 'organize',
      options: {
        excludeByName: {
          Time: true,
          Value: true,
          __name__: true,
          app_kubernetes_io_instance: true,
          app_kubernetes_io_name: true,
          instance: true,
          job: true,
          kubernetes_namespace: true,
          kubernetes_pod_name: true,
          pod_template_hash: true,
        },
        indexByName: {
          Time: 1,
          Value: 13,
          __name__: 2,
          app_kubernetes_io_instance: 3,
          app_kubernetes_io_name: 4,
          instance: 5,
          job: 6,
          kubernetes_namespace: 7,
          kubernetes_pod_name: 8,
          pod_template_hash: 9,
          provisioner: 10,
          reclaimPolicy: 11,
          storageclass: 0,
          volumeBindingMode: 12,
        },
        renameByName: {
          provisioner: 'Provisioner',
          reclaimPolicy: 'ReclaimPolicy',
          storageclass: 'StorageClass',
          volumeBindingMode: 'VolumeBindingMode',
        },
      },
    },
    {
      id: 'groupBy',
      options: {
        fields: {
          Provisioner: {
            aggregations: [],
            operation: 'groupby',
          },
          ReclaimPolicy: {
            aggregations: [],
            operation: 'groupby',
          },
          StorageClass: {
            aggregations: [],
            operation: 'groupby',
          },
          VolumeBindingMode: {
            aggregations: [],
            operation: 'groupby',
          },
        },
      },
    },
  ]),
  g.panel.row.new('Graphical usage data ')
  + g.panel.row.withId(15)
  + g.panel.row.withGridPos(27)
  + g.panel.row.withPanels([]),
  g.panel.timeSeries.new('All Running PVCs Used Bytes')
  + g.panel.timeSeries.panelOptions.withGridPos(h=12, w=24, x=0, y=28)
  + g.panel.timeSeries.queryOptions.withDatasource('prometheus', 'mimir')
  + g.panel.timeSeries.queryOptions.withTargets([
    g.query.prometheus.new('mimir', '(max by (persistentvolumeclaim,namespace) (kubelet_volume_stats_used_bytes{namespace=~"${k8s_namespace}"}))')
    + g.query.prometheus.withLegendFormat('{{namespace}} ({{persistentvolumeclaim}})')
    + g.query.prometheus.withRefId('A'),
  ])
  + { id: 9, pluginVersion: '12.3.1' }
  + { options: {
    alertThreshold: true,
    legend: {
      calcs: [
        'mean',
        'lastNotNull',
        'max',
        'min',
      ],
      displayMode: 'table',
      placement: 'right',
      showLegend: true,
    },
    tooltip: {
      hideZeros: false,
      mode: 'multi',
      sort: 'desc',
    },
  }, fieldConfig: {
    defaults: {
      color: {
        mode: 'palette-classic',
      },
      custom: {
        axisBorderShow: false,
        axisCenteredZero: false,
        axisColorMode: 'text',
        axisLabel: '',
        axisPlacement: 'auto',
        barAlignment: 0,
        barWidthFactor: 0.6,
        drawStyle: 'line',
        fillOpacity: 0,
        gradientMode: 'none',
        hideFrom: {
          legend: false,
          tooltip: false,
          viz: false,
        },
        insertNulls: false,
        lineInterpolation: 'linear',
        lineWidth: 1,
        pointSize: 5,
        scaleDistribution: {
          type: 'linear',
        },
        showPoints: 'never',
        showValues: false,
        spanNulls: false,
        stacking: {
          group: 'A',
          mode: 'none',
        },
        thresholdsStyle: {
          mode: 'off',
        },
      },
      thresholds: {
        mode: 'absolute',
        steps: [
          {
            color: 'green',
            value: 0,
          },
          {
            color: 'red',
            value: 80,
          },
        ],
      },
      unit: 'bytes',
    },
  } },
  g.panel.row.new('Usage Rate')
  + g.panel.row.withId(19)
  + g.panel.row.withGridPos(40)
  + g.panel.row.withPanels([]),
  g.panel.timeSeries.new('Hourly Volume Usage Rate')
  + g.panel.timeSeries.panelOptions.withGridPos(h=7, w=24, x=0, y=41)
  + g.panel.timeSeries.queryOptions.withDatasource('prometheus', 'mimir')
  + g.panel.timeSeries.queryOptions.withTargets([
    g.query.prometheus.new('mimir', 'rate(kubelet_volume_stats_used_bytes{namespace=~"${k8s_namespace}"}[1h])')
    + g.query.prometheus.withInstant(false)
    + g.query.prometheus.withLegendFormat('{{namespace}} ({{persistentvolumeclaim}})')
    + g.query.prometheus.withRefId('A'),
  ])
  + { id: 11, pluginVersion: '12.3.1' }
  + { options: usageRateOptions, fieldConfig: usageRateFields },
  g.panel.timeSeries.new('Daily Volume Usage Rate')
  + g.panel.timeSeries.panelOptions.withGridPos(h=7, w=24, x=0, y=48)
  + g.panel.timeSeries.queryOptions.withDatasource('prometheus', 'mimir')
  + g.panel.timeSeries.queryOptions.withTargets([
    g.query.prometheus.new('mimir', 'rate(kubelet_volume_stats_used_bytes{namespace=~"${k8s_namespace}"}[1d])')
    + g.query.prometheus.withLegendFormat('{{namespace}} ({{persistentvolumeclaim}})')
    + g.query.prometheus.withRefId('A'),
  ])
  + { id: 12, pluginVersion: '12.3.1' }
  + { options: usageRateOptions, fieldConfig: usageRateFields },
  g.panel.timeSeries.new('Weekly Volume Usage Rate')
  + g.panel.timeSeries.panelOptions.withGridPos(h=7, w=24, x=0, y=55)
  + g.panel.timeSeries.queryOptions.withDatasource('prometheus', 'mimir')
  + g.panel.timeSeries.queryOptions.withTargets([
    g.query.prometheus.new('mimir', 'rate(kubelet_volume_stats_used_bytes{namespace=~"${k8s_namespace}"}[1w])')
    + g.query.prometheus.withInstant(false)
    + g.query.prometheus.withLegendFormat('{{namespace}} ({{persistentvolumeclaim}})')
    + g.query.prometheus.withRefId('A'),
  ])
  + { id: 13, pluginVersion: '12.3.1' }
  + { options: usageRateOptions, fieldConfig: usageRateFields },
], setPanelIDs=false)
