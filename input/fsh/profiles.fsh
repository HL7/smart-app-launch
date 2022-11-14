Profile:     SMARTAppStateBasic
Id:          smart-app-state-basic
Parent:      Basic
Title:       "SMART App State"
Description: """
    SMART App State profile on Basic resource

    **See [App State capability](./app-state.html) for requirements, usage notes, and examples.**
"""
* subject.reference 0..1
* code.coding 1..1
* extension.value[x] only string

Instance: AppStateExample
InstanceOf: SMARTAppStateBasic
Description: "App State Example"
Usage: #example
* subject.reference = "https://ehr.example.org/fhir/Practitioner/123"
* code.coding[0].system = "https://myapp.example.org"
* code.coding[0].code = "display-preferences"
* extension[0].url = "https://myapp.example.org/display-preferences-v2.0.1"
* extension[0].valueString = "{\"defaultView\":\"problem-list\",\"colorblindMode\":\"D\",\"resultsPerPage\":150}"
