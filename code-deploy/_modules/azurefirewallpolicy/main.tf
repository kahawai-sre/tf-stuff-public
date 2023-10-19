
resource "azurerm_firewall_policy" "this" {
  name                                           = var.name
  resource_group_name                            = var.resource_group_name
  location                                       = var.location
  sku                                            = var.sku
  base_policy_id                                 = var.base_policy_id #// Optional, links this policy to a base policy to create a base:child pair
  dynamic "dns" {
    for_each = var.dns == null ? [] : var.dns
    content {
      servers = dns.value.servers #// List
      proxy_enabled = dns.value.proxy_enabled
    }
  }         
  threat_intelligence_mode                       = var.threat_intelligence_mode #// Optional
  dynamic "threat_intelligence_allowlist" {
    for_each = var.threat_intelligence_allowlist == null ? [] : var.threat_intelligence_allowlist
    content {
      ip_addresses = threat_intelligence_allowlist.value.ip_addresses #// Set of strings
      fqdns = threat_intelligence_allowlist.value.fqdns #// Set of strings 
    }
  }
  dynamic "identity" {
    for_each = var.identity == null ? [] : var.identity
    content{
      type = identity.value.type
      identity_ids = identity.value.identity_ids #// List
    }
  }
  dynamic "tls_certificate" {
    for_each = var.tls_certificate == null ? [] : var.tls_certificate
    content{
      key_vault_secret_id = tls_certificate.value.key_vault_secret_id #// ID of the keyvault Secret where CA is stored
      name =  tls_certificate.value.cert_name #// Name of the certificate stored in the keyvault>
    }
  }
  dynamic "intrusion_detection" {
    for_each = var.intrusion_detection == null ? [] : var.intrusion_detection
    content {
      mode = intrusion_detection.value.mode
      dynamic "signature_overrides" {
        for_each = intrusion_detection.value.signature_overrides == null ? [] : intrusion_detection.value.signature_overrides
        content {
          id = signature_overrides.value.id #// 12 digit ID of signature)
          state = signature_overrides.value.state #// Off, Alert, Deny
        }
      }
      dynamic "traffic_bypass" {
        for_each = intrusion_detection.value.traffic_bypass == null ? [] : intrusion_detection.value.traffic_bypass
        content {
          name = traffic_bypass.value.bypass_rule_name
          protocol = traffic_bypass.value.protocol
          description = try(traffic_bypass.value.description, null)
          source_addresses = try(traffic_bypass.value.source_addresses, null) #// List
          source_ip_groups = try(traffic_bypass.value.source_ip_groups, null)
          destination_addresses = try(traffic_bypass.value.destination_addresses, null) #// List
          destination_ip_groups = try(traffic_bypass.value.destination_ip_groups, null) #// List
          destination_ports = try(traffic_bypass.value.destination_ports, null) #// List
        }
      }
    }
  }
  dynamic "insights" {
    for_each = var.insights == null ? [] : var.insights
    content{
      enabled = insights.value.enabled
      default_log_analytics_workspace_id = insights.value.default_log_analytics_workspace_id #// Required, default LAW for AzFw insights logs, overridden by 
      retention_in_days = try(insights.value.retention_in_days, null) #// Optional
      dynamic "log_analytics_workspace" {
        for_each = insights.value.log_analytics_workspace == null ? [] : insights.value.log_analytics_workspace
        content {
          id = log_analytics_workspace.id
          firewall_location = log_analytics_workspace.firewall_location
        }
      }
    }
  }
  dynamic "explicit_proxy" {
    for_each = var.explicit_proxy == null ? [] : var.explicit_proxy
    content{
      enabled = try(explicit_proxy.value.enabled, null)
      http_port = try(explicit_proxy.value.http_port, null)
      https_port = try(explicit_proxy.value.https_port, null)
      enable_pac_file = try(explicit_proxy.value.enable_pac_file, null)
      pac_file_port = try(explicit_proxy.value.pac_file_port, null)
      pac_file = try(explicit_proxy.value.pac_file, null)
    }
  }
  tags = var.tags
}



/* EXAMPLE YAML SCHEMA FOR INPUT AS MAP:

- name: "fwpol-childpolicy"
  resource_name: "fwpol-childpolicy"
  location: "australiaeast"
  resource_group_name: "rg-azurefw-test" # Must be same Resource Group as per AzureFirewallSubnet VNET
  sku: "Standard" # Standard, Premium
  base_policy_name: "fwpol-basepolicy" # maps to 'base_policy_id' - optional
  threat_intelligence_mode: "Alert" # Alert, Deny, Off
  threat_intelligence_allowlist: # single block, optional
    - name: "child-threatintel-config"
      ip_addresses: "200.10.10.12,200.10.10.13" # Maps to subnet_id which is the target AzureFirewallSubnet instance (must exist)
      fqdns: "www.childcompanywebsite1.com,www.childcompanywebsite2.com"
  dns: # single block, optional
  - name: "azfw-dns-config" 
    servers: "192.168.200.10,192.168.200.11" # List
    proxy_enabled: true # true/false
  identity: # single block, optional
  - name: "child-identity-config"
    type: "UserAssigned" #// Currently only UserAssigned is supported, used to access KeyVault for TLS cert, plus future scenarios
    fqdns: "UserAssignedID_1,UserAssignedID_2" #// List
  tls_certificate: # single block, optional
  - name: "azfw-test-threatintel-child-config"
    key_vault_secret_id: "/dcdf/d/sdsd/d" #// Key ID in keyvault for 
    name: "AzFwTLSCertv1" #// Name of the cert in keyvault
  explicit_proxy: # single block, optional, all settings are optional
  - name: "azfw-test-threatintel-child-config"
    enabled: false
    http_port: "8085"
    https_port: "8086"
    enable_pac_file: false
    pac_file_port: "8000" #// Port AzFw uses to serve the PAC file to clients
    pac_file: "" #// SAS URL for PAC file on Storage Account
  network_rule_collections: #blocks
    - name: "networkrules-core-allow"
      priority: "400" 
      action: "Allow"
      rules: #blocks
      - name: "allow-onprem-azure-any"
        protocols: ["Any"] # Any, TCP, UDP, ICMP - List
        source_addresses: ["192.168.0.0/16"] # list
        source_ip_groups: [] # list of names of source IP group names
        destination_addresses: ["10.0.0.0/8"]
        destination_ip_groups: [] # list of names of target IP group names
        destination_fqdns: [] # list
        destination_ports: ["*"] #list
      - name: "allow-azure-onprem-any"
        protocols: ["Any"] # Any, TCP, UDP, ICMP - List
        source_addresses: ["10.0.0.0/8"] # list
        source_ip_groups: [] # list of names of source IP group names
        destination_addresses: ["192.168.0.0/16"]
        destination_ip_groups: [] # list of names of target IP group names
        destination_fqdns: [] # list
        destination_ports: ["*"] #list
  intrusion_detection:
    - name: "child-intrusiondetection-config"
        mode: "Alert" #// Alert, Deny, or Off
        signature_overrides: #blocks
        - name: "override-sig1"
          id: "xxxxxxxxx" #// 12 digit ID of signature
          state: "Off" #// Off, Alert, Deny
        - name: "override-sig2"
          id: "yyyyyyyyy" #// 12 digit ID of signature
          state: "Alert" #// Off, Alert, Deny
        traffic_bypass: #blocks
        - name: "bypass1" #// Required, maps to name of the bypass rule in policy
          protocol: "TCP" #// Required. ANY, TCP, ICMP, or UDP
          description: #// Optional
          source_addresses = ["10.96.0.0/16","10.92.0.0/16"] #// List, optional
          source_ip_groups = [] #// List, optional
          destination_addresses = ["*"] #// List, optional
          destination_ip_groups = [] #// List, optional
          destination_ports = ["443"] #// List, optional
        - name: "bypass2" #// Required, maps to name of the bypass rule in policy
          protocol: "TCP" #// Required. ANY, TCP, ICMP, or UDP
          description: #// Optional
          source_addresses = ["10.196.0.0/16"] #// List, optional
          source_ip_groups = [] #// List, optional
          destination_addresses = ["*"] #// List, optional
          destination_ip_groups = [] #// List, optional
          destination_ports = ["443"] #// List, optional
  insights:
    - name: "child-insights-config"
        enabled: true #// Alert, Deny, or Off
        default_log_analytics_workspace_id: "xxxxxxxxx"
        retention_in_days: "xx"
        log_analytics_workspace: #blocks
        - name: "child-law-association"
          id: "xxxxxxxxx" #// Reqd. ID of LA workspace that AzFws associated with this policy send ther logs to, when locations match firewall_location
          firewall_location: "xxxxxxx" #// Reqd as above.
  tags:
    cost_center: "1234"
    environment: "prod"
    security_dimension: "xxx"
*/



