
locals {

  nsg_default_security_rules_raw = var.validate_yaml != true ? yamldecode(can(yamldecode(file(var.default_nsg_rules_yaml))) ? file(var.default_nsg_rules_yaml) : "[]") : yamldecode(file(var.default_nsg_rules_yaml))

  #nsg_persona_defaultrules_raw = var.validate_yaml != true ? yamldecode(can(yamldecode(file(var.nsg_persona_defaultrules_yaml))) ? file(var.nsg_persona_defaultrules_yaml) : "[]") : yamldecode(file(var.nsg_persona_defaultrules_yaml))
  nsg_persona_defaultrules_raw = [[yamldecode(file(var.nsg_persona_defaultrules_yaml)), []][can(yamldecode(file(var.nsg_persona_defaultrules_yaml))) ? 0 : 1], yamldecode(file(var.nsg_persona_defaultrules_yaml))][var.validate_yaml == true ? 0 : 1]
  nsg_persona_defaultrules_flatten = [flatten([
    for nsg_persona in local.nsg_persona_defaultrules_raw : {
      persona_name           = nsg_persona.persona_name
      default_security_rules = nsg_persona.default_security_rules
    }
  ]), []][local.nsg_persona_defaultrules_raw != [] ? 0 : 1]
  nsg_persona_defaultrules_map = [{ for nsg_persona_config in local.nsg_persona_defaultrules_flatten : nsg_persona_config.persona_name => nsg_persona_config }, {}][local.nsg_persona_defaultrules_flatten != [] ? 0 : 1]

  #nsg_persona_defaultrules_raw = var.validate_yaml != true ? yamldecode(can(yamldecode(file(var.nsg_persona_defaultrules_yaml))) ? file(var.nsg_persona_defaultrules_yaml) : "[]") : yamldecode(file(var.nsg_persona_defaultrules_yaml))
  # nsg_persona_defaultrules_flatten = local.nsg_persona_defaultrules_raw != [] ? flatten([
  #   for nsg_persona in local.nsg_persona_defaultrules_raw : {
  #     persona_name           = nsg_persona.persona_name
  #     default_security_rules = nsg_persona.default_security_rules
  #   }
  # ]) : tolist("[]")
  # nsg_persona_defaultrules_map = [{ for nsg_persona_config in local.nsg_persona_defaultrules_flatten : nsg_persona_config.persona_name => nsg_persona_config }, {}][local.nsg_persona_defaultrules_flatten != [] ? 0 : 1]

  # local.nsg_persona_defaultrules_flatten != tolist("[]") ? { for nsg_persona_config in local.nsg_persona_defaultrules_flatten : nsg_persona_config.persona_name => nsg_persona_config } : {}
  # [lookup(local.nsg_persona_defaultrules_map, nsg.persona, null).default_security_rules, []][nsg.apply_persona_rules == true ? 0 : 1],

  // LEAVE FOR REFERENCE:
  # nsg_default_security_rules_raw = yamldecode(file(var.default_nsg_rules_yaml))

  # nsg_persona_defaultrules_raw = yamldecode(file(var.nsg_persona_defaultrules_yaml))
  # nsg_persona_defaultrules_flatten = flatten([
  #   for nsg_persona in local.nsg_persona_defaultrules_raw : {
  #     persona_name           = nsg_persona.persona_name
  #     default_security_rules = nsg_persona.default_security_rules
  #   }
  # ])
  # nsg_persona_defaultrules_map = { for nsg_persona_config in local.nsg_persona_defaultrules_flatten : nsg_persona_config.persona_name => nsg_persona_config }

}
