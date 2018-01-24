//api elb security group
resource "aws_security_group" "api-elb" {
  name = "api-elb.${var.haystack_cluster_name}"
  vpc_id = "${var.aws_vpc_id}"
  description = "Security group for api ELB"

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  tags = {
    Product = "Haystack"
    Component = "K8s"
    ClusterName = "${var.haystack_cluster_name}"
    Role = "${var.haystack_cluster_name}-k8s-masters-elb"
    Name = "${var.haystack_cluster_name}-k8s-masters-elb"
  }

}


//node elb security group
resource "aws_security_group" "nodes-elb" {
  name = "nodes-elb.${var.haystack_cluster_name}"
  vpc_id = "${var.aws_vpc_id}"
  description = "Security group for nodes ELB"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  tags = {
    Product = "Haystack"
    Component = "K8s"
    ClusterName = "${var.haystack_cluster_name}"
    Role = "${var.haystack_cluster_name}-k8s-nodes-elb"
    Name = "${var.haystack_cluster_name}-k8s-nodes-elb"

  }
}



//node elb security group
resource "aws_security_group" "monitoring-elb" {
  name = "monitoring-elb.${var.haystack_cluster_name}"
  vpc_id = "${var.aws_vpc_id}"
  description = "Security group for nodes ELB"
  ingress {
    from_port = 2003
    to_port = 2003
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  tags = {
    Product = "Haystack"
    Component = "K8s"
    ClusterName = "${var.haystack_cluster_name}"
    Role = "${var.haystack_cluster_name}-k8s-monitoring-elb"
    Name = "${var.haystack_cluster_name}-k8s-monitoring-elb"

  }
}

//node instance security group

//This is prevent the cyclic dependency
resource "aws_security_group_rule" "all-master-to-node" {
  type = "ingress"
  security_group_id = "${aws_security_group.nodes.id}"
  source_security_group_id = "${aws_security_group.masters.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
}
resource "aws_security_group_rule" "all-node-to-node" {
  type = "ingress"
  security_group_id = "${aws_security_group.nodes.id}"
  source_security_group_id = "${aws_security_group.nodes.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
}

resource "aws_security_group" "nodes" {
  name = "nodes.${var.haystack_cluster_name}"
  vpc_id = "${var.aws_vpc_id}"
  description = "Security group for nodes"

  ingress {
    from_port = "${var.reverse_proxy_port}"
    to_port = "${var.reverse_proxy_port}"
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.nodes-elb.id}"]
  }

  ingress {
    from_port = "${var.graphite_node_port}"
    to_port = "${var.graphite_node_port}"
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.monitoring-elb.id}"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  tags = {
    Product = "Haystack"
    Component = "K8s"
    ClusterName = "${var.haystack_cluster_name}"
    Role = "${var.haystack_cluster_name}-k8s-nodes"
    Name = "${var.haystack_cluster_name}-k8s-nodes"
  }
}


//master instance security group
resource "aws_security_group_rule" "all-master-to-master" {
  type = "ingress"
  security_group_id = "${aws_security_group.masters.id}"
  source_security_group_id = "${aws_security_group.masters.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
}
resource "aws_security_group" "masters" {
  name = "masters.${var.haystack_cluster_name}"
  vpc_id = "${var.aws_vpc_id}"
  description = "Security group for masters"

  ingress {
    from_port = "443"
    to_port = "443"
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.api-elb.id}"]
  }
  ingress {
    from_port = 0
    to_port = 65535
    protocol = "4"
    security_groups = [
      "${aws_security_group.nodes.id}"]
  }

  ingress {
    from_port = 1
    to_port = 2379
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.nodes.id}"]
  }
  ingress {
    from_port = 2382
    to_port = 4001
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.nodes.id}"]
  }

  ingress {
    from_port = 4003
    to_port = 65535
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.nodes.id}"]
  }
  ingress {
    from_port = 1
    to_port = 65535
    protocol = "udp"
    security_groups = [
      "${aws_security_group.nodes.id}"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  tags = {
    Product = "Haystack"
    Component = "K8s"
    ClusterName = "${var.haystack_cluster_name}"
    Role = "${var.haystack_cluster_name}-k8s-masters"
    Name = "${var.haystack_cluster_name}-k8s-masters"
  }
}

