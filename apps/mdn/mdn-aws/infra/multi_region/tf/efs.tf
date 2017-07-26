resource "aws_efs_file_system" "mdn-shared" {
  performance_mode = "generalPurpose"
  # also supported, maxIO

  tags {
    Name = "MDN shared"
  }
}

resource "aws_efs_mount_target" "mdn-shared-mt" {
  # split the subnet variable into a list, then take the length of the list
  count           = "${length(split(",", var.subnets))}"
  # use the EFS filesystem we created above
  file_system_id = "${aws_efs_file_system.mdn-shared.id}"
  # split the subnet variable into a list, then get the count.index subnet id
  subnet_id      = "${element(split(",", var.subnets), count.index)}"
}

output "efs_dns" {
  # all AZ's return the same dns name, just use the first
  value = "${aws_efs_mount_target.mdn-shared-mt.0.dns_name}"
}
