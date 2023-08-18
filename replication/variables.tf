variable "subscription_id" {
    type = string
    default = "61323407-b144-4eac-883f-cc64a89b82e4"
}
variable "client_id" {
    type = string
    default = "a2cd9f5b-9606-4380-a30c-8185fde63936"
}
variable "tenant_id" {
    type = string
    default = "97984c2b-a229-4609-8185-ae84947bc3fc"
}
variable "client_secret" {
    type = string
    default = "pIM8Q~ZsliPrN1AMQT7sfrcGq6haoY3RtAJAgbh~"
}
variable "replicas" {
  description = "Names of additional replica databases to create"
  default     = [
  "replica1",
  "replica2"
  ]
}
