Alias: $exp = http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation

Instance: smart-app-state-server
InstanceOf: CapabilityStatement
Usage: #definition
* url = "http://hl7.org/fhir/smart-app-launch/CapabilityStatement/smart-app-state-server"
* name = "AppStateServerCapabilityStatement"
* title = "App State Server CapabilityStatement"
* status = #active
* format = #json
* date = "2022-09-19"
* kind = #requirements
* description = "Required capabilities for App State Server"
* fhirVersion = #4.0.1
* rest.mode = #server
* rest.resource[+].type = #Basic
* rest.resource[=].extension[0].url = $exp
* rest.resource[=].extension[0].valueCode = #SHALL
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[=].interaction[+].code = #create
* rest.resource[=].interaction[+].code = #update
* rest.resource[=].interaction[+].code = #delete