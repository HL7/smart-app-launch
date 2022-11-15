Profile: TaskEhrLaunch
Id: task-ehr-launch
Description: """
  Defines a Task that indicates the user should launch an application using the SMART on FHIR EHR launch.
  See [Launch Task](./task-launch.html) for requirements, usage notes, and examples.
"""
Parent: Task
* code 1..1 MS
* code from SmartLaunchTypes
* code = SmartOnFhirCodes#launch-app-ehr
* input 1..*
* input ^slicing.discriminator.type = #value
* input ^slicing.discriminator.path = "type"
* input ^slicing.rules = #open
* input contains launchurl 1..1 and launchcontext 0..1
* input[launchurl].type from SmartLaunchInformation
* input[launchurl].type = SmartOnFhirCodes#smartonfhir-application
* input[launchurl].value[x] only url
* input[launchurl].valueUrl 1..1
* input[launchcontext].type from SmartLaunchInformation
* input[launchcontext].type = SmartOnFhirCodes#smartonfhir-appcontext
* input[launchcontext].value[x] only string

Instance: TaskEhrLaunchExample1
InstanceOf: TaskEhrLaunch
Title: "Example Task requesting SMART on FHIR EHR launch 1"
Description: """
  Task instance requesting the launch of a SMART app using the EHR launch mechanism without appcontext, patient or encounter references.
  """
Usage: #example
* status = #requested
* intent = #order
* code = SmartOnFhirCodes#launch-app-ehr   "Launch application using the SMART EHR launch"
* input[launchurl]
  * type = SmartOnFhirCodes#smartonfhir-application "SMART on FHIR application URL."
  * valueUrl = "https://www.example.org/theapp"

Instance: TaskEhrLaunchExample2
InstanceOf: TaskEhrLaunch
Title: "Example Task requesting SMART on FHIR EHR launch 2"
Description: """
  Task instance requesting the launch of a SMART app using the EHR launch mechanism, referring to a patient and encounter and holds appcontext values.
  """
Usage: #example
* status = #requested
* intent = #proposal
* code = SmartOnFhirCodes#launch-app-ehr  "Launch application using the SMART EHR launch"
* for.reference = "https://example.org/fhir/Patient/123"
* encounter.reference = "https://example.org/fhir/Encounter/456"

* input[launchurl]
  * type = SmartOnFhirCodes#smartonfhir-application "SMART on FHIR application URL."
  * valueUrl = "https://www.example.org/theapp"
* input[launchcontext]
  * type = SmartOnFhirCodes#smartonfhir-appcontext "Application context related to this launch."
  * valueString = """
    "{"field1":"value"}"
    """


Profile: TaskStandaloneLaunch
Id: task-standalone-launch
Description: """
  Defines a Task that indicates the user should launch an application as a standalone application.
  See [Launch Task](./task-launch.html) for requirements, usage notes, and examples.
"""
Parent: Task
* code 1..1 MS
* code from SmartLaunchTypes
* code = SmartOnFhirCodes#launch-app-standalone
* input 1..*
* input ^slicing.discriminator.type = #value
* input ^slicing.discriminator.path = "type"
* input ^slicing.rules = #open
* input contains launchurl 1..1 and launchcontext 0..1
* input[launchurl].type from SmartLaunchInformation
* input[launchurl].type = SmartOnFhirCodes#smartonfhir-application
* input[launchurl].value[x] only url
* input[launchurl].valueUrl 1..1
* input[launchcontext].type from SmartLaunchInformation
* input[launchcontext].type = SmartOnFhirCodes#smartonfhir-appcontext
* input[launchcontext].value[x] only string


Instance: TaskStandaloneLaunchExample1
InstanceOf: TaskStandaloneLaunch
Title: "Example Task requesting SMART on FHIR standalone launch 1"
Description: """
  Task instance requesting the standalone launch of a SMART app without patient and encounter references.
  """
Usage: #example
* status = #requested
* intent = #order
* code = SmartOnFhirCodes#launch-app-standalone
* input[launchurl]
  * type = SmartOnFhirCodes#smartonfhir-application "SMART on FHIR application URL."
  * valueUrl = "https://www.example.org/theapp"

Instance: TaskStandaloneLaunchExample2
InstanceOf: TaskStandaloneLaunch
Title: "Example Task requesting SMART on FHIR standalone launch 2"
Description: """
  Task instance requesting the standalone launch of a SMART app that includes a Patient and Encounter reference.
  """
Usage: #example
* status = #requested
* intent = #proposal
* code = SmartOnFhirCodes#launch-app-standalone "Launch application using the SMART standalone launch"
* for.reference = "https://example.org/fhir/Patient/123"
* encounter.reference = "https://example.org/fhir/Encounter/456"
* input[launchurl]
  * type = SmartOnFhirCodes#smartonfhir-application "SMART on FHIR application URL."
  * valueUrl = "https://www.example.org/myapplication"



ValueSet: SmartLaunchTypes
Id: smart-launch-types
Title: "Launch Types for tasks to application launches"
Description: "Defines Launch Type codes for Tasks that request launch of SMART applications."
* ^experimental = true
* SmartOnFhirCodes#launch-app-ehr "Launch application using the SMART EHR launch"
* SmartOnFhirCodes#launch-app-standalone "Launch application using the SMART standalone launch"

ValueSet: SmartLaunchInformation
Id: smart-launch-info
Title: "Codes for tasks to application launches"
Description: "Defines codes for Tasks that request launch of SMART applications."
* ^experimental = true
* SmartOnFhirCodes#smartonfhir-application "SMART on FHIR application URL."
* SmartOnFhirCodes#smartonfhir-appcontext "Application context related to this launch."

CodeSystem: SmartOnFhirCodes
Id: smart-codes
Title: "SMART on FHIR terminology."
Description: "Codes used to in profiles related to SMART on FHIR."
* ^caseSensitive = true
* ^experimental = true
* #launch-app-ehr "Launch application using the SMART EHR launch"
  "The task suggest launching an application using the SMART on FHIR EHR launch."
* #launch-app-standalone "Launch application using the SMART standalone launch"
  "The task suggest launching an application using the SMART on FHIR standalone launch."
* #smartonfhir-application "SMART on FHIR application URL."
  "The URL of a SMART on FHIR application."
* #smartonfhir-appcontext "Application context related to this launch."
  "The application context (appContext) to be passed to the application after launch."
