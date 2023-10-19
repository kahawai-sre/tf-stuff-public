
#// Subscriptions for targetting resource deployments - will create one provider alias for each in _providers.tf
variable "subid_corp01" {
  type    = string
  default = "29c7e3d4-e589-4555-a1d8-ac60fcc05a2c"
}

variable "subid_connectivity01" {
  type    = string
  default = "e4ceae51-a8d0-484e-ac75-046919675c83"
}

variable "primary_location" {
  type    = string
  default = "australiaeast"
}

#// Default NSG rules - apply to all subs
variable "default_nsg_rules_yaml" {
  default = "../config-networkprotection/_nsg-defaults/nsg-global-defaults.yaml"
  validation {
    condition = alltrue([
      can(fileexists(var.default_nsg_rules_yaml)),
      can(file(var.default_nsg_rules_yaml))
    ])
    error_message = "ERROR: Error processing yaml config file ${var.default_nsg_rules_yaml} due to YAML syntax, or file does not exist at the specified path!!"
  }
}

#// Per-persona default NSG rules - enables customisation of sets of default rules based on requirements
variable "nsg_persona_defaultrules_yaml" {
  default = "../config-networkprotection/_nsg-defaults/nsg-persona-defaults.yaml"
  validation {
    condition = alltrue([
      can(fileexists(var.nsg_persona_defaultrules_yaml)),
      can(file(var.nsg_persona_defaultrules_yaml))
    ])
    error_message = "ERROR: Error processing yaml config file ${var.nsg_persona_defaultrules_yaml} due to YAML syntax, or file does not exist at the specified path!!"
  }
}

variable "validate_yaml" {
  // IMPORTANT: 
  // 1. When = FALSE, code will handle empty .YAML config files (i.e. it will not attempt to process and deploy resources, and fail with errors)
  // 2. This is useful when first building config or when there is a requirement to delete all instances of a resource via the config (by commenting out or removing all of the YAML in the config file)
  // 3. HOWEVER, this also means terraform code treats a badly formatted YAML config file as an empty file (because there is no way to natively check for an empty YAML file, other than by catching an error on read)
  // 4. When = FALSE, IF there are **existing resources deployed for that config**, in both cases below, TERRAFORM APPLY will DELETE any existing resource instances for that config:
  //    (i)  YAML File is empty or fully commented out - this is desired behaviour
  //    (ii) YAML file has **syntax errors** - this is not desired behaviour
  // 5. Based on the above, it is critical that a TERRAFORM PLAN is run, and proposed changes (resource deletes in this case), are carefully audited during the PLAN stage before approving changes.
  default = false
}



