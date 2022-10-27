resource "local_file" "instance_status" {
  for_each = local.instances

  filename = "${local.instance_root}/${each.key}/status.yml"

  content = yamlencode({
    status      = "succeeded"
    description = ""
  })

  file_permission = "0644"

  depends_on = [
    module.instance
  ]
}


resource "local_file" "binding_status" {
  for_each = local.bindings

  filename = "${local.instance_root}/${each.value.serviceInstanceId}/bindings/${each.key}/status.yml"

  content = yamlencode({
    status      = "succeeded"
    description = ""
  })

  file_permission = "0644"

  depends_on = [
    module.instance
  ]
}
