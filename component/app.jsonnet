local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.espejo;
local argocd = import 'lib/argocd.libjsonnet';

local app = argocd.App('espejo', params.namespace, secrets=false);

{
  espejo: app,
}
