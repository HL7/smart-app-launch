Profile: TaskEhrLaunch
Id: task-ehr-launch
Description: "Defines a Task that indicates the user should launch an application using the SMART on FHIR EHR launch."
Parent: Task
* code 1..1 MS
* code from SmartLaunchTypes
* code = SmartOnFhirCodes#launch-app-ehr
* input 1..*
* input ^slicing.discriminator.type = #value
* input ^slicing.discriminator.path = "type"
* input ^slicing.rules = #open
* input contains launchurl 1..1 and launchcontext 0..1
* input[launchurl].type = SmartOnFhirCodes#smartonfhir-application
* input[launchurl].value[x] only url
* input[launchurl].valueUrl 1..1
* input[launchcontext].type = SmartOnFhirCodes#smartonfhir-appcontext
* input[launchcontext].value[x] only string

Profile: TaskStandaloneLaunch
Id: task-standalone-launch
Description: "Defines a Task that indicates the user should launch an application as a standalone application."
Parent: Task
* code 1..1 MS
* code from SmartLaunchTypes
* code = SmartOnFhirCodes#launch-app-standalone
* input 1..*
* input ^slicing.discriminator.type = #value
* input ^slicing.discriminator.path = "type"
* input ^slicing.rules = #open
* input contains launchurl 1..1 and launchcontext 0..1
* input[launchurl].type = SmartOnFhirCodes#smartonfhir-application
* input[launchurl].value[x] only url
* input[launchurl].valueUrl 1..1
* input[launchcontext].type = SmartOnFhirCodes#smartonfhir-appcontext
* input[launchcontext].value[x] only string

ValueSet: SmartLaunchTypes
Id: smart-launch-types
Title: "Launch Types for tasks to application launches"

Description: "Defines Launch Type codes for Tasks that request launch of SMART applications."
* ^experimental = false
* SmartOnFhirCodes#launch-app-ehr "Launch application using the SMART EHR launch"
* SmartOnFhirCodes#launch-app-standalone "Launch application using the SMART standalone launch"

ValueSet: SmartLaunchInformation
Id: smart-launch-info
Title: "Codes for tasks to application launches"
Description: "Defines codes for Tasks that request launch of SMART applications."
* ^experimental = false
* SmartOnFhirCodes#smartonfhir-application "SMART on FHIR application URL."
* SmartOnFhirCodes#smartonfhir-appcontext "Application context related to this launch."

CodeSystem: SmartOnFhirCodes
Id: smart-codes
Title: "SMART on FHIR terminology."
Description: "Codes used to in profiles related to SMART on FHIR."
* ^caseSensitive = true
* ^experimental = false
* #launch-app-ehr "Launch application using the SMART EHR launch"
  "The task suggest launching an application using the SMART on FHIR EHR launch."
* #launch-app-standalone "Launch application using the SMART standalone launch"
  "The task suggest launching an application using the SMART on FHIR standalone launch."
* #smartonfhir-application "SMART on FHIR application URL."
  "The URL of a SMART on FHIR application."
* #smartonfhir-appcontext "Application context related to this launch."
  "The application context (appContext) to be passed to the application after launch."
