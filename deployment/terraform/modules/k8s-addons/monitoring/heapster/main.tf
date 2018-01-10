locals {
  count = "${var.enabled?1:0}"
}


//creating the heapster cluster addon for pushing k8s app metrics to influxdb


data "template_file" "heapster_cluster_addon_config" {
  template = "${file("${path.module}/templates/heapster-yaml.tpl")}"
  vars {
    influxdb_service_name = "${var.influxdb_servicename}"
    heapster_image = "${var.k8s_heapster_image}"
  }
  count = "${local.count}"

}

resource "null_resource" "k8s_heapster_addons" {
  triggers {
    template = "${data.template_file.heapster_cluster_addon_config.rendered}"
  }
  provisioner "local-exec" {
    command = "echo '${data.template_file.heapster_cluster_addon_config.rendered}' | ${var.kubectl_executable_name} create -f - --context ${var.k8s_cluster_name}"
  }
  provisioner "local-exec" {
    command = "echo '${data.template_file.heapster_cluster_addon_config.rendered}' | ${var.kubectl_executable_name} delete -f - --context ${var.k8s_cluster_name}"
    when = "destroy"
  }
  count = "${local.count}"
}