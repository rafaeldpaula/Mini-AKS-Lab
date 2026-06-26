variable "project_name" {
  type        = string
  description = "Base name used by the Azure resources."
  default     = "testetecnico"
}

variable "environment" {
  type        = string
  description = "Deployment environment name."
  default     = "dev"
}

variable "location" {
  type        = string
  description = "Azure region where the resources will be created."
  default     = "eastus"
}

variable "node_count" {
  type        = number
  description = "Initial number of nodes in the AKS system node pool."
  default     = 1
}

variable "node_vm_size" {
  type        = string
  description = "Virtual machine size used by the AKS nodes."
  default     = "Standard_B2s"
}

variable "kubernetes_version" {
  type        = string
  description = "Optional AKS Kubernetes version. Leave null to use the default supported version from Azure."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Additional tags applied to Azure resources."
  default     = {}
}
