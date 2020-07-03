/**
 * \file espejo.libsonnet
 * \brief Helpers to create Espejo SyncConfig ojbects.
 */

local com = import 'lib/commodore.libjsonnet';
local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.espejo;

/**
  * \brief Helper to create SyncConfig object.
  *
  * Creates a bare bone SyncConfig in the namespace where Espejo is watching them.
  * Objects of the same kind in the same namespace must have unique names.
  * It is suggested to prefix the name with the name of the component calling it.
  *
  * \arg The name of the sync config.
  * \return A SyncConfig object.
  */
local syncConfig(name) = kube._Object('sync.appuio.ch/v1alpha1', 'SyncConfig', name) {
  'metadata+': {
    namespace: params.namespace,
  },
  spec: {},
};

{
  syncConfig: syncConfig,
}
