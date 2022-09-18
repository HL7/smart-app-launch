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
