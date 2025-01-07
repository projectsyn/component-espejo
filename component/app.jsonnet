local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.espejo;
local argocd = import 'lib/argocd.libjsonnet';

local app = argocd.App('espejo', params.namespace, secrets=false);

local appPath =
  local project = std.get(std.get(app, 'spec', {}), 'project', 'syn');
  if project == 'syn' then 'apps' else 'apps-%s' % project;

{
  ['%s/espejo' % appPath]: app,
}
