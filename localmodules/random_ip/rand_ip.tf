
resource "random_integer" "octet" {
  min = 0
  max = 255
  keepers = {
    netname = var.netname
  }
}
