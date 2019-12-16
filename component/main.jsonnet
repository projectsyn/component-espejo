// main template for espejo
local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local inv = kap.inventory();
// The hiera parameters for the component
local params = inv.parameters.espejo;

local namespace = kube.Namespace(params.namespace);

local cluster_role = kube.ClusterRole('syn-espejo') {
    rules: params.cluster_role_rules,
};

local service_account = kube.ServiceAccount('espejo') {
    metadata+: {
        namespace: params.namespace
    },
};

local cluster_role_binding = kube.ClusterRoleBinding('syn-espejo') {
    subjects_: [service_account],
    roleRef_: cluster_role,
};

local deployment = kube.Deployment('espejo') {
    metadata+: {
        namespace: params.namespace,
        labels: {
            app: 'espejo'
        },
    },
    spec+: {
        template+: {
            spec+: {
                containers_+: {
                    espejo: kube.Container('espejo') {
                        image: params.images.espejo.image + ':' + params.images.espejo.tag,
                        env_+: {
                            'WATCH_NAMESPACE': params.watch_namespace,
                            'POD_NAME': kube.FieldRef('metadata.name'),
                            'OPERATOR_NAME': 'espejo',
                        },
                    },
                },
                serviceAccountName: service_account.metadata.name
            },
        },
    },
};

// Define outputs below
{
  '01_namespace': namespace,
  '05_rbac': [cluster_role, service_account, cluster_role_binding],
  '10_deployment': deployment,
}
