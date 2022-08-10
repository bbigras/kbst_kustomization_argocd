terraform {
  required_providers {
    kustomization = {
      source  = "kbst/kustomization"
      version = "0.9.0"
    }
  }
}

provider "kustomization" {
  kubeconfig_path = "~/.kube/config"
}

data "kustomization_build" "test" {
  path = "argocd"
  kustomize_options {
    load_restrictor = "none"
    enable_helm     = true
    helm_path       = "helm"
  }
}

resource "kustomization_resource" "p0" {
  for_each = data.kustomization_build.test.ids_prio[0]

  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_build.test.manifests[each.value])
    : data.kustomization_build.test.manifests[each.value]
  )
}

# then loop through resources in ids_prio[1]
# and set an explicit depends_on on kustomization_resource.p0
resource "kustomization_resource" "p1" {
  for_each = data.kustomization_build.test.ids_prio[1]

  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_build.test.manifests[each.value])
    : data.kustomization_build.test.manifests[each.value]
  )

  depends_on = [kustomization_resource.p0]
}

# finally, loop through resources in ids_prio[2]
# and set an explicit depends_on on kustomization_resource.p1
resource "kustomization_resource" "p2" {
  for_each = data.kustomization_build.test.ids_prio[2]

  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_build.test.manifests[each.value])
    : data.kustomization_build.test.manifests[each.value]
  )

  depends_on = [kustomization_resource.p1]
}
