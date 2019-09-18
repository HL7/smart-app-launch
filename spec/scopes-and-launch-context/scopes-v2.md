---
title: SMART App Launch Framework
layout: default
---

## Placeholder for SMART Scopes v2 (work in progress)

"sub-resource scopes"

Human-centric scopes like:

* contact info
* work history
* addiction/social hx
* sexual hx
* mental health
* genomics

In practice, applying these labels an guaranteeing their accuracy is an unsolved research problem, though there are promising approaches.

---

Functional requirements:

* All resources with a specific tag
* All resources without a specific tag
* Observations by category
* Conditions by category
* DiagnosticReport
* DocuemntReference
* Any Resource with a category by categry

## So the basic data model is

* Scoping context: patient|user|system
* Resource type: Observation
* Allowed Category: http://terminology.hl7.org/CodeSystem/observation-category#laboratory
* Interaction: read|create|update|delete|?search


Notes
* category is near-term, low-hanging, practical
* tag is outlet / forward-looking opportunity for more sophisticated behaviors, even if there's not widely supportefd automatic labeling deployed today

## Looking at syntaxes


```
patient/Observation:http://terminology.hl7.org/CodeSystem/observation-category#laboratory.read
{"context": "patient","resourceType": "Observation", "category": "http://terminology.hl7.org/CodeSystem/observation-category#laboratory", "interaction": "read"}

patient/Observation:http://terminology.hl7.org/CodeSystem/observation-category#social-history.read
{"context": "patient","resourceType": "Observation", "category": "http://terminology.hl7.org/CodeSystem/observation-category#social-history", "interaction": "read"}

patient/Observation:http://terminology.hl7.org/CodeSystem/observation-category#exam.read
{"context":"patient","resourceType":"Observation","category":"http://terminology.hl7.org/CodeSystem/observation-category#exam","interaction":"read"}
```

These are long... especially if you have a lot of them. But each one is straightforward, at least. Each one can be treated independently (i.e., they're OR'd together).

Still, this quickly starts to suggests a combined syntax like:

```js
[{
  "context": "patient",
  "resourceType": ["Observation"],
  "interaction": ["read", "search", "create", "update"],
  "category": [
    "#laboratory",
    "#vital-signs",
    "#social-history",
  ]
  "tagRequired": [],
  "tagExcluded": [],
  "securityLabelRequired": []
  "securityLabelExcluded": ["http://terminology.hl7.org/CodeSystem/v3-Confidentiality Code Display#V"]
}]
```
