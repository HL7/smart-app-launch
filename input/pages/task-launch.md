### Task profile for launch SMART applications (EXPERIMENTAL)


This section defines a set of profiles of the FHIR Task resource that requests launch of a SMART application. These tasks could be used to instruct staff to run an application or as a result of a Clinical Reasoning deployment.

Two profiles are defined:

* [task-ehr-launch](StructureDefinition-task-ehr-launch.html), requests an EHR launch with optional appContext.
* [task-standalone-launch](StructureDefinition-task-standalone-launch.html), requests a standalone launch.

#### Requesting an EHR launch

A Task with the profile [task-ehr-launch](StructureDefinition-task-ehr-launch.html), requests an EHR launch with optional appContext.

The subject field, if present indicates the patient resource to be used in the launch context.

the encounter field, if present indicates the encounter reource to be used in the launch context.
 
The input field contains:
* the url of the application to be launched
* optional appContext to be included in the token response as is specified in a [CDShooks Link](https://cds-hooks.org/specification/current/#link)

An example of such Task is presented below: 

```js
{
  "resourceType": "Task",
  "status": "requested",
  "intent": "proposal",
  "code": 
  {
    "coding": [{
      "system": "http://hl7.org/fhir/smart-app-launch/CodeSystem/smart-codes",
      "code": "launch-app-ehr",
      "display": "Request launch of an application using SMART of FHIR EHR launch."
    }]
  },
  "for": "Patient/asdjksaj",
  "encounter": "Encounter/djsafioir",
  "input": [
  {
    "type": {
        "coding":[{
          "system": "http://hl7.org/fhir/smart-app-launch/CodeSystem/smart-codes",
          "code": "smartonfhir-application",
          "display": "URL of the application to be launched."
        }]
    },
    "valueUrl": "https://www.example.org/myapplication"
  },
  {
    "type": {
        "coding":[{
          "system": "http://hl7.org/fhir/smart-app-launch/CodeSystem/smart-codes",
          "code": "smartonfhir-appcontext",
          "display": "Application context related to this launch."
        }]
    },
    "valueString": "{\"field1\":\"value\"}"
  }]
}
```

#### Requesting an standalone launch

A Task according to the profile [task-standalone-launch](StructureDefinition-task-standalone-launch.html), requests an standalone launch.

The input field contains:

* the url of the application to be launched

An example of such Task is presented below: 

```js
{
  "resourceType": "Task",
  "status": "requested",
  "intent": "proposal",
  "code": 
  {
    "coding": [{
      "system": "http://hl7.org/fhir/smart-app-launch/CodeSystem/smart-codes",
      "code": "launch-standalone-ehr",
      "display": "Request launch of an application using SMART of FHIR standalone launch."
    }]
  },
  "for": "Patient/asdjkdadasdasaj",
  "encounter": "Encounter/djsaeiruiurwfioir",
  "input": [
  {
    "type": {
        "coding":[{
          "system": "http://hl7.org/fhir/smart-app-launch/CodeSystem/smart-codes",
          "code": "smartonfhir-application",
          "display": "URL of the application to be launched."
        }]
    },
    "valueUrl": "https://www.example.org/myapplication"
  }]
}
```


