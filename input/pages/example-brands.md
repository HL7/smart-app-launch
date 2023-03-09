{% capture SQUARE %}<span style="font-size:1em">&#9634;</span>{% endcapture %}

*The brands below are fabricated for the purpose of these examples.*

### Bundle Example 1: Lab with Thousands of Locations Nationwide

* One national brand
* Locations in thousands of cities

The configuration below establishes a single top-level Brand with a long list of associated addresses. (The organization can also group  their locations into sub-brands such as "ExampleLabs Alaska")


<div class="bg-info" markdown="1">

![](https://i.imgur.com/Kv5gq3Z.png) **ExampleLabs** ([examplelabs.com](https://example.org/examplelabs.com)

|Source|API|Portal|
|--|--|--|
|**RxampleLabs Patient™ portal**|{{SQUARE}} Connect|{{SQUARE}} View |
{:.grid style="background-color: white"}

Nearest location: 1 mile (Madison)

</div><!-- info -->

The FHIR server's `.well-known/smart-configuration` file would include a link like

    "patientAccessBrands": "https://examplelabs.example.com/branding.json"
    
And the hosted` Patient Access Brands Bundle file would look like:

[ExampleLabs Brands Bundle](Bundle-example1.html)

```javascript
{
  "resourceType": "Bundle",
  "type": "collection",
  "meta": {
    "lastUpdated": "2022-03-14T15:09:26.535Z"
  },
  "entry": [
    {
      "fullUrl": "https://examplelabs.example.org/Endpoint/fhir-r4",
      "resource": {
        "resourceType": "Endpoint",
        "id": "bch-r4",
        "address": "https://fhir.examplelabs.example.org/r4",
        "name": "FHIR R4 Endpoint for RxampleLabs",
        "managingOrganization": {
          "reference": "Organization/examplelabs"
        },
        "extension": [
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/endpoint-fhir-version",
            "valueCode": "4.0.1"
          },
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/patient-access-developer-url",   \\<<<<<Where is this extension defined?>>>>>
            "valueUrl": "https://www.examplelabs.com/help/contact-info-for-patient/patient-portal-inquiry"
          }
        ],
        "connectionType": {
          "system": "http://terminology.hl7.org/CodeSystem/endpoint-connection-type",
          "code": "hl7-fhir-rest"
        }
      }
    },
    {
      "fullUrl": "https://examplelabs.example.org/Organization/examplelabs",
      "resource": {
        "resourceType": "Organization",
        "id": "examplelabs",
        "extension": [
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/brand-logo",
            "valueUrl": "https://www.examplelabs.com/themes/custom/examplelabs/images/newbrand/RxampleLabs_Logo.svg"
          },
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/patient-access-url", \\\\<<<<<Where is this extension defined?>>>>>
            "valueUrl": "https://patient.examplelabs.com/landing"
          },
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/patient-access-name", \\\\<<<<<Where is this extension defined?>>>>>
            "valueString": "RxampleLabs Patient™ portal"
          }
        ],
        "name": "LabCorp",
        "alias": [],
        "identifier": [
          {
            "system": "urn:ietf:rfc:3986",
            "value": "https://examplelabs.com"
          }
        ],
        "telecom": [
          {
            "system": "url",
            "value": "https://www.examplelabs.com"
          }
        ],
        "address": [
          {
            "line": [
              "4015 Lake Otis Pkwy"
            ],
            "city": "Anchorage",
            "state": "AK",
            "postalCode": "99508"
          },
          {
            "line": [
              "3223 Palmer Wasilla Hwy",
              "Suite 4"
            ],
            "city": "Wasilla",
            "state": "AK",
            "postalCode": "99654"
          },
          {
            "line": [
              "1626 30Th Avenue"
            ],
            "city": "Fairbanks",
            "state": "AK",
            "postalCode": "99701"
          },
          {
            "...": "etc, etc for ~2000 other locations"
          }
        ]
      }
    }
  ]
}
```



### UnityPoint: regional health system with independently branded affiliates

* Regional health system ("UnityPoint")
* Multiple locations in/around 12 cities
* Provides EHR for many affiliates (distinctly branded sites like "Associated Physicians Madison" or "Steward Memorial Community Hospital")

The system displays the following cards to a user:



<div class="bg-info" markdown="1">
![](https://i.imgur.com/dP83Tuq.png)  **UnityPoint Health** ([unitypoint.org](https://www.unitypoint.org))

|Source|API|Portal|
|--|--|--|
|**MyUnityPoint**| {{SQUARE}}  Connect|{{SQUARE}} View |
{:.grid style="background-color: white"}

Nearest location: 13 miles (Madison)

</div><!-- info -->

<div class="bg-info" markdown="1">
![](https://i.imgur.com/1RbPNCv.png) **Associated Physicians of Madison** ([apmadison.com](https://www.apmadison.com/))

|Source|API|Portal|
|--|--|--|
|**MyUnityPoint**| {{SQUARE}}  Connect|{{SQUARE}} View |
{:.grid style="background-color: white"}

Nearest location: 1 mile (Madison)
</div><!-- info -->

<div class="bg-info" markdown="1">
![](https://i.imgur.com/GjS3s6U.png)  **Stewart Memorial Community Hospital** ([stewartmemorial.org](https://www.stewartmemorial.org/))

|Source|API|Portal|
|--|--|--|
|**MyUnityPoint**| {{SQUARE}}  Connect|{{SQUARE}} View |
{:.grid style="background-color: white"}

Nearest location: 120 miles (Lake City)
</div><!-- info -->

(And two more cards for other affiliated brands sharing the MyUnityPoint portal.)

```javascript
{
  "resourceType": "Bundle",
  "type": "collection",
  "meta": {
    "lastUpdated": "2022-03-14T15:09:26.535Z"
  },
  "entry": [
    {
      "fullUrl": "https://epic.example.org/Endpoint/unity-point-r4",
      "resource": {
        "resourceType": "Endpoint",
        "id": "unity-point-r4",
        "address": "https://epicfhir.unitypoint.org/ProdFHIR/api/FHIR/R4",
        "name": "FHIR R4 Endpoint for UnityPoint Health",
        "managingOrganization": {
          "reference": "Organization/unity-point"
        },
        "extension": [
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/endpoint-fhir-version",
            "valueCode": "4.0.1"
          },
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/patient-access-developer-url",
            "valueUrl":  "https://open.epic.com"
          }
 
        ],
        "connectionType": {
          "system": "http://terminology.hl7.org/CodeSystem/endpoint-connection-type",
          "code": "hl7-fhir-rest"
        }
      }
    },
    {
      "fullUrl": "https://epic.example.org/Endpoint/unity-point-r2",
      "resource": {
        "resourceType": "Endpoint",
        "id": "unity-point-r2",
        "address": "https://epicfhir.unitypoint.org/ProdFHIR/api/FHIR/DSTU2",
        "name": "FHIR DSTU2 Endpoint for UnityPoint Health",
        "managingOrganization": {
          "reference": "Organization/unity-point"
        },
        "extension": [
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/endpoint-fhir-version",
            "valueCode": "1.0.2"
          },
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/patient-access-developer-url",
            "valueUrl":  "https://open.epic.com"
          }
 
        ],
        "connectionType": {
          "system": "http://terminology.hl7.org/CodeSystem/endpoint-connection-type",
          "code": "hl7-fhir-rest"
        }
      }
    },
    {
      "fullUrl": "https://epic.example.org/Organization/unity-point",
      "resource": {
        "resourceType": "Organization",
        "id": "unity-point",
        "extension": [
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/brand-logo",
            "valueUrl": "https://unitypoint.org/logo/main.1024x102.png"
          },
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/patient-access-url",
            "valueUrl": "https://chart.myunitypoint.org"
          },
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/patient-access-name",
            "valueString": "MyUnityPoint"
          }
        ],
        "name": "UnityPoint Health",
        "alias": [
          "Meriter   Hospital",
          "Eyerly Ball Mental Health"
        ],
        "identifier": [
          {
            "system": "urn:ietf:rfc:3986",
            "value": "https://unitypoint.org"
          }
        ],
        "telecom": [
          {
            "system": "url",
            "value": "https://www.unitypoint.org"
          }
        ],
        "address": [
          {
            "city": "Madison",
            "state": "WI"
          },
          {
            "city": "Anamosa",
            "state": "IA"
          },
          {
            "city": "Cedar Rapids",
            "state": "IA"
          },
          {
            "city": "Des Moines",
            "state": "IA"
          },
          {
            "city": "Dubuque",
            "state": "IA"
          },
          {
            "city": "Fort Dodge",
            "state": "IA"
          },
          {
            "city": "Grinnell",
            "state": "IA"
          },
          {
            "city": "Marshalltown",
            "state": "IA"
          },
          {
            "city": "Peoria",
            "state": "IA"
          },
          {
            "city": "Pekin",
            "state": "IA"
          },
          {
            "city": "Muscatine",
            "state": "IA"
          },
          {
            "city": "Sioux City",
            "state": "IA"
          }
        ]
      }
    },
    {
      "fullUrl": "https://epic.example.org/Organization/associated-physicians-madison",
      "resource": {
        "resourceType": "Organization",
        "id": "associated-physicians-madison",
        "partOf": {
          "reference": "Organization/unity-point"
        },
        "extension": [
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/brand-logo",
            "valueUrl": "https://static.wixstatic.com/media/9f38bc_b5e81faf3c3645b3869556e8a83433ee~mv2.png"
          }
        ],
        "name": "Associated Physicians Madison",
        "alias": [],
        "identifier": [
          {
            "system": "urn:ietf:rfc:3986",
            "value": "https://apmadison.com"
          }
        ],
        "telecom": [
          {
            "system": "url",
            "value": "https://www.apmadison.com"
          }
        ],
        "address": [
          {
            "city": "Madison",
            "state": "WI"
          }
        ]
      }
    },
    {
      "fullUrl": "https://epic.example.org/Organization/stewart-memorial",
      "resource": {
        "resourceType": "Organization",
        "id": "stewart-memorial",
        "partOf": {
          "reference": "Organization/unity-point"
        },
        "extension": [
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/brand-logo",
            "valueUrl": "data:image/svg+xml;base64,PHN2ZyB0aXRsZT0iU3Rld2FydCBNZW1vcmlhbCBIb3NwaXRhbCBMb2dvIiBjbGFzcz0ibG9nby1zdmciIHZlcnNpb249IjEuMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHZpZXdCb3g9IjAgMCAzMzAuNSA2NS43NCIgc3R5bGU9ImVuYWJsZS1iYWNrZ3JvdW5kOm5ldyAwIDAgMzMwLjUgNjUuNzQ7IiB4bWw6c3BhY2U9InByZXNlcnZlIj4gPHN0eWxlIHR5cGU9InRleHQvY3NzIj4gLnN2Zy1sb2dvLWljb257ZmlsbDojOEUxNTM3O30gLnN2Zy1sb2dvLXRleHR7ZmlsbDojMDAwMDAwO30gPC9zdHlsZT4gPGcgY2xhc3M9InN2Zy1sb2dvLXRleHQiPiA8cGF0aCBkPSJNODYuOTMsMTEuNGMtMC41NC0xLjkyLTEuMzItNC0zLjkzLTRjLTEuNzQtMC4xLTMuMjMsMS4yMi0zLjMzLDIuOTZjLTAuMDEsMC4xMS0wLjAxLDAuMjMsMCwwLjM0IGMwLDIuMTksMS40NCwzLjIxLDMuODEsNC40NHM1LjE5LDIuNjEsNS4xOSw2YzAsMy4xNS0yLjY3LDUuNjctNi42Niw1LjY3Yy0xLTAuMDEtMS45OS0wLjE2LTIuOTQtMC40NSBjLTAuNTEtMC4xNy0xLTAuMzgtMS40Ny0wLjYzYy0wLjM3LTEuNTMtMC42NC0zLjA4LTAuODEtNC42NWwwLjg3LTAuMjFjMC40OCwxLjgzLDEuODMsNC44Niw0LjkyLDQuODYgYzEuODQsMC4xNSwzLjQ1LTEuMjIsMy42LTMuMDZjMC4wMS0wLjE4LDAuMDEtMC4zNiwwLTAuNTRjMC0yLjIyLTEuNjUtMy4yNy0zLjktNC40N2MtMS45Mi0xLTUtMi41Mi01LTUuOTEgYzAtMi44OCwyLjMxLTUuMzQsNi4xOC01LjM0YzEuMjksMC4wMywyLjU2LDAuMjcsMy43OCwwLjY5YzAuMTIsMS4wOCwwLjI3LDIuMjUsMC41MSw0LjE0TDg2LjkzLDExLjR6Ij48L3BhdGg+IDxwYXRoIGQ9Ik05Ni4yMywyNi4zMWMtMC4zOCwwLjIyLTAuOCwwLjM1LTEuMjMsMC4zOWMtMS44OSwwLTIuOTQtMS4yLTIuOTQtMy41N1YxNC40SDkwbC0wLjEyLTAuM2wwLjgxLTAuODdIOTJWMTFsMi0ybDAuNDIsMC4wNiB2NC4xMWgzLjM5YzAuMjcsMC4zNywwLjE5LDAuODktMC4xOCwxLjE3SDk0LjR2Ny43MWMwLDIuNDMsMSwyLjg4LDEuNzQsMi44OGMwLjY1LTAuMDEsMS4yOC0wLjE2LDEuODYtMC40NWwwLjI3LDAuNzhMOTYuMjMsMjYuMzEgeiI+PC9wYXRoPiA8cGF0aCBkPSJNMTEwLjE1LDIzLjc5Yy0xLjg5LDIuMzctNCwyLjkxLTQuODksMi45MWMtMy42OSwwLTUuODUtMy01Ljg1LTYuMzljLTAuMDItMS45NCwwLjctMy44MSwyLTUuMjUgYzEuMS0xLjMyLDIuNy0yLjExLDQuNDEtMi4xOWMyLjQ3LDAuMDgsNC40NSwyLjA4LDQuNSw0LjU2YzAsMC42LTAuMTUsMC44NC0wLjY5LDFzLTQuMjYsMC4zOS03LjgzLDAuNTEgYzAsNC4wOCwyLjM3LDUuNzYsNC40Nyw1Ljc2YzEuMjktMC4wMywyLjUyLTAuNTcsMy40Mi0xLjVMMTEwLjE1LDIzLjc5eiBNMTAxLjkzLDE3LjY3YzEuNjgsMCwzLjMzLDAsNS4wNy0wLjA5IGMwLjU0LDAsMC43Mi0wLjE4LDAuNzItMC42YzAuMTQtMS41MS0wLjk3LTIuODUtMi40OS0yLjk5Yy0wLjA1LDAtMC4xLTAuMDEtMC4xNS0wLjAxQzEwMy43LDE0LDEwMi4zOCwxNS4yNCwxMDEuOTMsMTcuNjd6Ij48L3BhdGg+IDxwYXRoIGQ9Ik0xMzIuMTcsMTRjLTEuNSwwLjI0LTEuNzcsMC42LTIuNCwyLjI1Yy0wLjksMi4zNy0yLjIyLDYuMzYtMy42LDEwLjQ0aC0wLjg0Yy0xLjItMy4yNC0yLjQzLTYuMTgtMy42Ni05LjMzIGMtMS4xNCwzLTIuMzcsNi0zLjU0LDkuMzNoLTAuODdjLTEuMDgtMy41OS0yLjI2LTcuMTMtMy40NS0xMC42OWMtMC41NC0xLjU2LTAuODEtMS43Ny0yLjI1LTJ2LTAuNzVoNi4yMVYxNCBjLTEuOCwwLjMtMiwwLjQ4LTEuNSwxLjgzYzAuNjksMi4zMSwxLjQ0LDQuNjgsMi4xOSw3aDAuMDZjMS4xMS0yLjg4LDIuMjItNiwzLjQ4LTkuNDJoMC43OGMxLjExLDMuMTIsMi4zNCw2LjMsMy42LDkuNTFoMC4wNiBjMC42Ni0yLjA3LDEuNS00LjY4LDItNi45YzAuMzktMS41NiwwLjIxLTEuNzQtMS43NC0ydi0wLjc1aDUuNDNMMTMyLjE3LDE0eiI+PC9wYXRoPiA8cGF0aCBkPSJNMTQyLjI4LDI2LjdjLTAuNTItMC4wNC0xLjAxLTAuMjQtMS40MS0wLjU3Yy0wLjM1LTAuMzgtMC42LTAuODUtMC43Mi0xLjM1Yy0xLjIsMC44MS0yLjY0LDEuOTItMy41NCwxLjkyIGMtMi0wLjAxLTMuNjItMS42My0zLjYxLTMuNjNjMC0wLjAyLDAtMC4wNSwwLTAuMDdjMC0xLjQ3LDAuNzgtMi40LDIuNDMtM2MxLjYyLTAuNDcsMy4xOC0xLjEyLDQuNjUtMS45NXYtMC41NCBjMC0yLjE2LTEtMy4zOS0yLjUyLTMuMzljLTAuNTItMC4wMi0xLjAyLDAuMi0xLjM1LDAuNmMtMC40NywwLjU4LTAuNzgsMS4yNy0wLjksMmMtMC4wNywwLjQyLTAuNDUsMC43MS0wLjg3LDAuNjkgYy0wLjY5LTAuMDctMS4yNC0wLjYtMS4zMi0xLjI5YzAtMC40NSwwLjM5LTAuNzgsMS0xLjJjMS4zNi0wLjk3LDIuODgtMS42OSw0LjUtMi4xYzAuODktMC4wMiwxLjc2LDAuMjcsMi40NiwwLjgxIGMxLDAuOTQsMS41LDIuMywxLjM1LDMuNjZ2NS41OGMwLDEuMzUsMC41NCwxLjgsMSwxLjhjMC4zOC0wLjAyLDAuNzUtMC4xMywxLjA4LTAuMzNsMC4zLDAuNzhMMTQyLjI4LDI2Ljd6IE0xNDAuMDksMTkuMTQgYy0wLjYzLDAuMzMtMi4wNywxLTIuNywxLjI2Yy0xLjE3LDAuNTQtMS44MywxLjExLTEuODMsMi4xOWMtMC4wNiwxLjIxLDAuODcsMi4yNSwyLjA5LDIuMzFjMC4wMSwwLDAuMDMsMCwwLjA0LDAgYzAuODktMC4xLDEuNzMtMC40OCwyLjQtMS4wOFYxOS4xNHoiPjwvcGF0aD4gPHBhdGggZD0iTTE1MC4yMywxNi4wNWMwLjktMS41LDIuMTktMy4xOCwzLjYzLTMuMThjMC44OS0wLjA0LDEuNjUsMC42MiwxLjc0LDEuNWMtMC4wMywwLjY0LTAuNDIsMS4yMS0xLDEuNDcgYy0wLjI2LDAuMTUtMC41OCwwLjEzLTAuODEtMC4wNmMtMC4zLTAuMzktMC43Ny0wLjYyLTEuMjYtMC42M2MtMC43OCwwLTEuNzQsMC45LTIuNCwyLjU4djUuNDljMCwyLDAuMTUsMi4xNiwyLjQ2LDIuMzR2MC43OGgtNi45IHYtMC43OGMxLjg2LTAuMTgsMi4wNy0wLjM2LDIuMDctMi4zNFYxN2MwLTItMC4xNS0yLjEtMS44Ni0yLjM0VjE0YzEuNDYtMC4yMiwyLjg4LTAuNjQsNC4yMy0xLjIzdjMuMjdMMTUwLjIzLDE2LjA1eiI+PC9wYXRoPiA8cGF0aCBkPSJNMTYzLjA3LDI2LjMxYy0wLjM5LDAuMjItMC44MiwwLjM2LTEuMjYsMC4zOWMtMS44OSwwLTIuOTQtMS4yLTIuOTQtMy41N1YxNC40aC0yLjA3bC0wLjEyLTAuM2wwLjgxLTAuODdoMS4zOFYxMWwxLjk1LTIgbDAuNDIsMC4wNnY0LjExaDMuMzljMC4yNywwLjM3LDAuMTksMC44OS0wLjE4LDEuMTdoLTMuMjF2Ny43MWMwLDIuNDMsMSwyLjg4LDEuNzQsMi44OGMwLjY1LTAuMDMsMS4yOS0wLjIsMS44Ni0wLjUxbDAuMjcsMC43OCBMMTYzLjA3LDI2LjMxeiI+PC9wYXRoPiA8cGF0aCBkPSJNMTkwLjA3LDI2LjM0VjI1LjVjMi40My0wLjI0LDIuNTUtMC4zOSwyLjUyLTMuNTdMMTkyLjUsOS42OWgtMC4xMmwtNy4zMiwxNi40NGgtMC42bC02LjcyLTE2aC0wLjA2bC0wLjQ1LDguNTUgYy0wLjEyLDIuNDYtMC4xMiwzLjc4LTAuMDksNWMwLjA2LDEuNDQsMC43OCwxLjY1LDIuNzYsMS44NnYwLjg0aC03VjI1LjVjMS43NC0wLjIxLDIuMzQtMC41NCwyLjU1LTEuOCBjMC4xNS0xLjA1LDAuMzMtMi4zNywwLjU3LTUuNDlsMC40Mi02LjI0YzAuMjctMy45LDAuMTItNC0yLjYxLTQuMjlWNi44NGg0LjkybDYuODQsMTVsNi45My0xNWg1LjF2MC44NCBjLTIuNjQsMC4yNC0yLjg1LDAuMy0yLjc2LDMuMzlsMC4zLDEwLjg2YzAuMDksMy4xOCwwLjE4LDMuMzMsMi43OSwzLjU3djAuODRIMTkwLjA3eiI+PC9wYXRoPiA8cGF0aCBkPSJNMjA5LjkzLDIzLjc5QzIwOCwyNi4xNiwyMDYsMjYuNywyMDUsMjYuN2MtMy42OSwwLTUuODUtMy01Ljg1LTYuMzljLTAuMDItMS45NCwwLjctMy44MSwyLTUuMjUgYzEuMS0xLjMyLDIuNy0yLjExLDQuNDEtMi4xOWMyLjQ3LDAuMDgsNC40NSwyLjA4LDQuNSw0LjU2YzAsMC42LTAuMTUsMC44NC0wLjY5LDFzLTQuMjYsMC4zOS03LjgzLDAuNTEgYzAsNC4wOCwyLjM3LDUuNzYsNC40Nyw1Ljc2YzEuMjktMC4wMywyLjUyLTAuNTcsMy40Mi0xLjVMMjA5LjkzLDIzLjc5eiBNMjAxLjcxLDE3LjY3YzEuNjgsMCwzLjMzLDAsNS4wNy0wLjA5IGMwLjU0LDAsMC43Mi0wLjE4LDAuNzItMC42YzAuMTQtMS41MS0wLjk3LTIuODUtMi40OS0yLjk5Yy0wLjA1LDAtMC4xLTAuMDEtMC4xNS0wLjAxQzIwMy40OCwxNCwyMDIuMTYsMTUuMjQsMjAxLjcxLDE3LjY3IEwyMDEuNzEsMTcuNjd6Ij48L3BhdGg+IDxwYXRoIGQ9Ik0yMjguMzIsMjYuMzR2LTAuNzhjMS43Ny0wLjE4LDIuMS0wLjMsMi4xLTIuNDN2LTVjMC0yLjEzLTAuNzUtMy40OC0yLjY0LTMuNDhjLTEuMjcsMC4xMi0yLjQ1LDAuNjctMy4zNiwxLjU2IGMwLjA3LDAuNDIsMC4xLDAuODQsMC4wOSwxLjI2djUuODVjMCwxLjg5LDAuMjcsMi4wNywxLjkyLDIuMjV2MC43OEgyMjB2LTAuNzhjMS44Ni0wLjE4LDIuMTMtMC4zMywyLjEzLTIuMzF2LTUuMTcgYzAtMi4yMi0wLjc4LTMuNDUtMi42MS0zLjQ1Yy0xLjIzLDAuMTQtMi4zOCwwLjY5LTMuMjcsMS41NnY3LjA1YzAsMS45NSwwLjI0LDIuMTMsMS43MSwyLjMxdjAuNzhoLTYuMzN2LTAuNzggYzItMC4xOCwyLjI1LTAuMzYsMi4yNS0yLjMxVjE3YzAtMS45Mi0wLjA5LTIuMDctMS44My0yLjM0VjE0YzEuNDMtMC4yNCwyLjgzLTAuNjYsNC4xNy0xLjIzdjIuNDNjMC42My0wLjQyLDEuMjktMSwyLjE5LTEuNTMgYzAuNzItMC41MSwxLjU4LTAuNzksMi40Ni0wLjgxYzEuNTIsMC4wMywyLjg1LDEuMDIsMy4zMywyLjQ2YzAuOC0wLjYsMS42My0xLjE2LDIuNDktMS42OGMwLjY2LTAuNDcsMS40NC0wLjc1LDIuMjUtMC43OCBjMi4zNCwwLDMuODEsMS42NSwzLjgxLDQuNTl2NS43OWMwLDIsMC4yNCwyLjEzLDIsMi4zMXYwLjc4TDIyOC4zMiwyNi4zNHoiPjwvcGF0aD4gPHBhdGggZD0iTTI0OS40NywxOS41NmMwLDQuODMtMy41NCw3LjE0LTYuNTEsNy4xNGMtMy41OSwwLjA0LTYuNTMtMi44NC02LjU3LTYuNDNjMC0wLjA3LDAtMC4xMywwLTAuMiBjLTAuMi0zLjc3LDIuNjktNi45OSw2LjQ3LTcuMmMwLjAzLDAsMC4wNywwLDAuMSwwYzMuNiwwLDYuNTEsMi45MSw2LjUxLDYuNTFDMjQ5LjQ3LDE5LjQ0LDI0OS40NywxOS41LDI0OS40NywxOS41NnogTTIzOS4xOCwxOS4xMWMwLDMuNzgsMS42NSw2LjYsNC4xMSw2LjZjMS44NiwwLDMuMzktMS4zOCwzLjM5LTUuNDljMC0zLjUxLTEuNDEtNi4zNi00LTYuMzYgQzI0MC44LDEzLjg2LDIzOS4xOCwxNS43MiwyMzkuMTgsMTkuMTFMMjM5LjE4LDE5LjExeiI+PC9wYXRoPiA8cGF0aCBkPSJNMjU1LjcxLDE2LjA1YzAuOS0xLjUsMi4xOS0zLjE4LDMuNjMtMy4xOGMwLjg5LTAuMDQsMS42NSwwLjYyLDEuNzQsMS41Yy0wLjAzLDAuNjQtMC40MiwxLjIxLTEsMS40NyBjLTAuMjYsMC4xNS0wLjU4LDAuMTMtMC44MS0wLjA2Yy0wLjMtMC4zOS0wLjc3LTAuNjItMS4yNi0wLjYzYy0wLjc4LDAtMS43NCwwLjktMi40LDIuNTh2NS40OWMwLDIsMC4xNSwyLjE2LDIuNDYsMi4zNHYwLjc4aC02Ljkgdi0wLjc4YzEuODYtMC4xOCwyLjA3LTAuMzYsMi4wNy0yLjM0VjE3YzAtMi0wLjE1LTIuMS0xLjg2LTIuMzRWMTRjMS40Ni0wLjIyLDIuODgtMC42NCw0LjIzLTEuMjN2My4yN0wyNTUuNzEsMTYuMDV6Ij48L3BhdGg+IDxwYXRoIGQ9Ik0yNjIuNDksMjYuMzR2LTAuNzhjMS44OS0wLjE4LDIuMS0wLjM2LDIuMS0yLjRWMTdjMC0xLjg2LTAuMDktMi0xLjg5LTIuMjhWMTRjMS40OC0wLjIzLDIuOTItMC42Myw0LjMtMS4xOXYxMC4zNSBjMCwyLDAuMjEsMi4yMiwyLjEzLDIuNHYwLjc4SDI2Mi40OXogTTI2NC4wOCw4LjczYy0wLjAxLTAuODUsMC42Ny0xLjU1LDEuNTItMS41NmMwLDAsMC4wMSwwLDAuMDEsMGMwLjgzLDAsMS41LDAuNjcsMS41LDEuNSBjMCwwLjAyLDAsMC4wNCwwLDAuMDZjLTAuMDEsMC44NC0wLjY5LDEuNTItMS41MywxLjUzQzI2NC43NiwxMC4yMiwyNjQuMSw5LjU1LDI2NC4wOCw4LjczeiI+PC9wYXRoPiA8cGF0aCBkPSJNMjgwLjEsMjYuN2MtMC41Mi0wLjA0LTEuMDEtMC4yNC0xLjQxLTAuNTdjLTAuMzUtMC4zOC0wLjYtMC44NS0wLjcyLTEuMzVjLTEuMiwwLjgxLTIuNjQsMS45Mi0zLjU0LDEuOTIgYy0yLTAuMDEtMy42MS0xLjY0LTMuNi0zLjY0YzAtMC4wMSwwLTAuMDEsMC0wLjAyYzAtMS40NywwLjc4LTIuNCwyLjQzLTNjMS42Mi0wLjQ3LDMuMTgtMS4xMiw0LjY1LTEuOTV2LTAuNTQgYzAtMi4xNi0xLTMuMzktMi41Mi0zLjM5Yy0wLjUyLTAuMDItMS4wMiwwLjItMS4zNSwwLjZjLTAuNDcsMC41OC0wLjc4LDEuMjctMC45LDJjLTAuMDcsMC40Mi0wLjQ1LDAuNzEtMC44NywwLjY5IGMtMC42Ny0wLjA5LTEuMTktMC42MS0xLjI3LTEuMjhjMC0wLjQ1LDAuMzktMC43OCwxLTEuMmMxLjM2LTAuOTcsMi44OC0xLjY5LDQuNS0yLjFjMC44OS0wLjAyLDEuNzYsMC4yNywyLjQ2LDAuODEgYzEsMC45NCwxLjUsMi4zLDEuMzUsMy42NnY1LjU4YzAsMS4zNSwwLjU0LDEuOCwxLDEuOGMwLjM4LTAuMDIsMC43NS0wLjEzLDEuMDgtMC4zM2wwLjMsMC43OEwyODAuMSwyNi43eiBNMjc3LjkxLDE5LjE0IGMtMC42MywwLjMzLTIuMDcsMS0yLjcsMS4yNmMtMS4xNywwLjU0LTEuODMsMS4xMS0xLjgzLDIuMTljLTAuMDYsMS4yMSwwLjg3LDIuMjUsMi4wOSwyLjMxYzAuMDEsMCwwLjAzLDAsMC4wNCwwIGMwLjg5LTAuMSwxLjczLTAuNDgsMi40LTEuMDhWMTkuMTR6Ij48L3BhdGg+IDxwYXRoIGQ9Ik0yODMuNDMsMjYuMzR2LTAuNzhjMS44OS0wLjE4LDIuMTYtMC4zNiwyLjE2LTIuMzRWOWMwLTItMC4xOC0yLjEzLTIuMDctMi4yOFY2YzEuNTItMC4xOCwzLjAyLTAuNTIsNC40OC0xdjE4LjIyIGMwLDIsMC4yNCwyLjE2LDIuMTYsMi4zNHYwLjc4SDI4My40M3oiPjwvcGF0aD4gPHBhdGggZD0iTTk0LjgyLDUxLjM5Yy0wLjQ1LDEuNTgtMS4wMiwzLjEyLTEuNzEsNC42MWMtMS44LDAuNDctMy42NiwwLjc0LTUuNTIsMC44MWMtNy40NywwLTEwLjc0LTUuMTYtMTAuNzQtOS45MyBjMC02LjMsNC44Ni0xMC40NywxMS41NS0xMC40N2MxLjc5LDAuMDcsMy41OCwwLjM0LDUuMzEsMC44MWMwLjI0LDEuNzEsMC40MiwyLjkxLDAuNiw0LjUzbC0wLjksMC4yMSBjLTAuNzgtMy4xOC0yLjU4LTQuNDctNS44Mi00LjQ3Yy01LDAtNy42OCw0LjIzLTcuNjgsOC43OWMwLDUuNjEsMy4zLDkuNDQsNy44Niw5LjQ0YzMuMDYsMCw0LjY4LTEuNjQsNi4xOC00LjY0TDk0LjgyLDUxLjM5eiI+PC9wYXRoPiA8cGF0aCBkPSJNMTEwLjEyLDQ5LjU2YzAsNC44My0zLjU0LDcuMTQtNi41MSw3LjE0Yy0zLjU5LDAuMDYtNi41NS0yLjgtNi42MS02LjM5YzAtMC4wOCwwLTAuMTYsMC0wLjI0IGMtMC4yLTMuNzcsMi42OS02Ljk5LDYuNDctNy4yYzAuMDMsMCwwLjA3LDAsMC4xLDBjMy42LTAuMDIsNi41MywyLjg3LDYuNTUsNi40N0MxMTAuMTIsNDkuNDEsMTEwLjEyLDQ5LjQ5LDExMC4xMiw0OS41NnogTTk5LjgzLDQ5LjExYzAs
My43OCwxLjY1LDYuNTksNC4xMSw2LjU5YzEuODYsMCwzLjM5LTEuMzcsMy4zOS01LjQ4YzAtMy41MS0xLjQxLTYuMzYtNC02LjM2IEMxMDEuNDUsNDMuODYsOTkuODMsNDUuNzIsOTkuODMsNDkuMTF6Ij48L3BhdGg+IDxwYXRoIGQ9Ik0xMjguMzYsNTYuMzR2LTAuNzhjMS43Ny0wLjE5LDIuMS0wLjMsMi4xLTIuNDR2LTVjMC0yLjEzLTAuNzUtMy40OC0yLjY0LTMuNDhjLTEuMjcsMC4xMi0yLjQ1LDAuNjctMy4zNiwxLjU2IGMwLjA3LDAuNDIsMC4xLDAuODQsMC4wOSwxLjI2djUuODVjMCwxLjg5LDAuMjcsMi4wNiwxLjkyLDIuMjV2MC43OGgtNi40MnYtMC43OGMxLjg2LTAuMTksMi4xMy0wLjMzLDIuMTMtMi4zMXYtNS4xNiBjMC0yLjIyLTAuNzgtMy40NS0yLjYxLTMuNDVjLTEuMjMsMC4xNC0yLjM4LDAuNjktMy4yNywxLjU2djdjMCwyLDAuMjQsMi4xMiwxLjcxLDIuMzF2MC43OGgtNi4zM3YtMC43OCBjMi0wLjE5LDIuMjUtMC4zNiwyLjI1LTIuMzFWNDdjMC0xLjkyLTAuMDktMi4wNy0xLjgzLTIuMzRWNDRjMS40My0wLjI0LDIuODMtMC42Niw0LjE3LTEuMjN2Mi40M2MwLjYzLTAuNDIsMS4yOS0xLDIuMTktMS41MyBjMC43Mi0wLjUxLDEuNTgtMC43OSwyLjQ2LTAuODFjMS41MiwwLjAzLDIuODUsMS4wMiwzLjMzLDIuNDZjMC44LTAuNiwxLjYzLTEuMTYsMi40OS0xLjY4YzAuNjYtMC40NywxLjQ0LTAuNzUsMi4yNS0wLjc4IGMyLjM0LDAsMy44MSwxLjY1LDMuODEsNC41OXY1Ljc5YzAsMiwwLjI0LDIuMTIsMS45NSwyLjMxdjAuNzhMMTI4LjM2LDU2LjM0eiI+PC9wYXRoPiA8cGF0aCBkPSJNMTUyLjkzLDU2LjM0di0wLjc4YzEuNzctMC4xOSwyLjEtMC4zLDIuMS0yLjQ0di01YzAtMi4xMy0wLjc1LTMuNDgtMi42NC0zLjQ4Yy0xLjI4LDAuMTEtMi40NywwLjY2LTMuMzksMS41NiBjMC4wNywwLjQyLDAuMSwwLjg0LDAuMDksMS4yNnY1Ljg1YzAsMS44OSwwLjI3LDIuMDYsMS45MiwyLjI1djAuNzhoLTYuNDJ2LTAuNzhjMS44Ni0wLjE5LDIuMTMtMC4zMywyLjEzLTIuMzF2LTUuMTYgYzAtMi4yMi0wLjc4LTMuNDUtMi42MS0zLjQ1Yy0xLjIzLDAuMTQtMi4zOCwwLjY5LTMuMjcsMS41NnY3YzAsMiwwLjI0LDIuMTIsMS43MSwyLjMxdjAuNzhoLTYuMzN2LTAuNzggYzItMC4xOSwyLjI1LTAuMzYsMi4yNS0yLjMxVjQ3YzAtMS45Mi0wLjA5LTIuMDctMS44My0yLjM0VjQ0YzEuNDMtMC4yNCwyLjgzLTAuNjYsNC4xNy0xLjIzdjIuNDNjMC42My0wLjQyLDEuMjktMSwyLjE5LTEuNTMgYzAuNzItMC41MSwxLjU4LTAuNzksMi40Ni0wLjgxYzEuNTIsMC4wMywyLjg1LDEuMDIsMy4zMywyLjQ2YzAuOC0wLjYsMS42My0xLjE2LDIuNDktMS42OGMwLjY2LTAuNDcsMS40NC0wLjc1LDIuMjUtMC43OCBjMi4zNCwwLDMuODEsMS42NSwzLjgxLDQuNTl2NS43OWMwLDIsMC4yNCwyLjEyLDEuOTUsMi4zMXYwLjc4TDE1Mi45Myw1Ni4zNHoiPjwvcGF0aD4gPHBhdGggZD0iTTE3NSw1NS42MmMtMS40OSwwLjI2LTIuOTcsMC42Mi00LjQxLDEuMDhsLTAuMTgtMC4xOHYtMi4xM2MtMC42OSwwLjUxLTEuMzgsMS0yLjIyLDEuNTZjLTAuNjgsMC40Ni0xLjQ4LDAuNzItMi4zMSwwLjc1IGMtMiwwLTMuNzItMS4yNC0zLjcyLTQuNDd2LTUuODhjMC0xLjY1LTAuMTItMS43Ny0xLjgzLTIuMXYtMC42OWMxLjQzLTAuMSwyLjg2LTAuMjksNC4yNy0wLjU2Yy0wLjA5LDAuOTMtMC4wOSwyLjM0LTAuMDksNC4zOHY0IGMwLDIuNjcsMS4yOSwzLjM5LDIuNjQsMy4zOWMxLjIzLTAuMDMsMi4zOS0wLjU1LDMuMjQtMS40NHYtN2MwLTEuNzEtMC4xOC0xLjgzLTIuMzQtMi4xM3YtMC42OWMxLjU4LTAuMDYsMy4xNi0wLjI0LDQuNzEtMC41NFY1MyBjMCwxLjUsMC4yNCwxLjcxLDEuMzgsMS43N2wwLjg0LDAuMDZMMTc1LDU1LjYyeiI+PC9wYXRoPiA8cGF0aCBkPSJNMTg0LjgyLDU2LjM0di0wLjc4YzEuNzctMC4xOSwyLTAuNDIsMi0yLjQ5di01YzAtMi4wNy0wLjcyLTMuNDItMi43My0zLjQyYy0xLjIzLDAuMTItMi4zOSwwLjY2LTMuMjcsMS41M3Y3IGMwLDIsMC4xOCwyLjE1LDEuOTUsMi4zNHYwLjc4aC02LjUxdi0wLjc4YzItMC4yMSwyLjE5LTAuMzYsMi4xOS0yLjM0VjQ3YzAtMS45Mi0wLjE4LTItMS44LTIuMzFWNDQgYzEuNDMtMC4yNCwyLjgzLTAuNjUsNC4xNy0xLjIzdjIuNGMwLjYtMC40NSwxLjI2LTAuOSwyLTEuNDFjMC43Mi0wLjU0LDEuNTktMC44NSwyLjQ5LTAuOWMyLjM3LDAsMy44NywxLjY1LDMuODcsNC41NnY1Ljc5IGMwLDIsMC4xNSwyLjE1LDEuODksMi4zNHYwLjc4TDE4NC44Miw1Ni4zNHoiPjwvcGF0aD4gPHBhdGggZD0iTTE5Mi43NCw1Ni4zNHYtMC43OGMxLjg5LTAuMTksMi4xLTAuMzYsMi4xLTIuNFY0N2MwLTEuODYtMC4wOS0yLTEuODktMi4yOFY0NGMxLjQ2LTAuMjIsMi44OS0wLjYxLDQuMjYtMS4xN3YxMC4zMyBjMCwyLDAuMjEsMi4yMSwyLjEzLDIuNHYwLjc4SDE5Mi43NHogTTE5NC4zMywzOC43M2MtMC4wMS0wLjg1LDAuNjctMS41NSwxLjUyLTEuNTZjMCwwLDAuMDEsMCwwLjAxLDBjMC44MywwLDEuNSwwLjY3LDEuNSwxLjUgYzAsMC4wMiwwLDAuMDQsMCwwLjA2Yy0wLjAxLDAuODQtMC42OSwxLjUyLTEuNTMsMS41M0MxOTUuMDEsNDAuMjIsMTk0LjM1LDM5LjU1LDE5NC4zMywzOC43M3oiPjwvcGF0aD4gPHBhdGggZD0iTTIwNi4zNiw1Ni4zMWMtMC4zOSwwLjIyLTAuODIsMC4zNi0xLjI2LDAuMzljLTEuODksMC0yLjk0LTEuMi0yLjk0LTMuNThWNDQuNGgtMi4wN2wtMC4xMi0wLjNsMC44MS0wLjg3aDEuMzhWNDFsMi0yIGwwLjQyLDAuMDZ2NC4xMWgzLjM5YzAuMjcsMC4zNywwLjE5LDAuODktMC4xOCwxLjE3aC0zLjIxdjcuNzFjMCwyLjQzLDEsMi44OCwxLjc0LDIuODhjMC42NS0wLjAzLDEuMjktMC4yLDEuODYtMC41MWwwLjI3LDAuNzggTDIwNi4zNiw1Ni4zMXoiPjwvcGF0aD4gPHBhdGggZD0iTTIyMyw0NGMtMS41OSwwLjI0LTEuODYsMC40OC0yLjY3LDIuMTlzLTEuNjgsNC4wOC0zLjc1LDljLTEuMjEsMi42NC0yLjI1LDUuMzUtMy4wOSw4LjEzYy0wLjA5LDAuNDctMC41MywwLjc4LTEsMC43MSBjLTAuODQsMC4wMS0xLjU3LTAuNi0xLjcxLTEuNDNjMC0wLjQ5LDAuMjctMC43NSwwLjc4LTEuMDhjMC45Ny0wLjY3LDEuNzQtMS41OSwyLjIyLTIuNjdjMC4zOC0wLjY2LDAuNjktMS4zNSwwLjkzLTIuMDcgYzAuMTYtMC40MywwLjE2LTAuOTIsMC0xLjM1Yy0xLjItMy40Mi0yLjU1LTctMy40NS05LjE4Yy0wLjYzLTEuNjUtMC45My0yLTIuNTgtMi4yOHYtMC43NWg2LjA5VjQ0IGMtMS4zOCwwLjI0LTEuNTMsMC41NC0xLjE0LDEuNjVsMi43Myw3LjUzYzAuODQtMiwyLjEzLTUuNTgsMi43Ni03LjQ3YzAuMzYtMS4xNCwwLjE1LTEuNDctMS41Ni0xLjcxdi0wLjc1SDIyM1Y0NHoiPjwvcGF0aD4gPHBhdGggZD0iTTI1MS4xNSwzNy42OGMtMi40NiwwLjIxLTIuNywwLjM2LTIuNywyLjg1djEyLjEyYzAsMi41MiwwLjI0LDIuNjcsMi42NywyLjg1djAuODRoLThWNTUuNWMyLjU1LTAuMTgsMi44Mi0wLjMzLDIuODItMi44NSB2LTZoLTEwLjI3djZjMCwyLjQ5LDAuMjQsMi42NywyLjcsMi44NXYwLjg0aC03Ljg5VjU1LjVjMi40LTAuMTgsMi42NC0wLjMzLDIuNjQtMi44NVY0MC41M2MwLTIuNTItMC4yNC0yLjY0LTIuNy0yLjg1di0wLjg0aDcuNzcgdjAuODRjLTIuMjgsMC4yMS0yLjUyLDAuMzYtMi41MiwyLjg1djQuODZoMTAuMjN2LTQuODZjMC0yLjQ5LTAuMjQtMi42NC0yLjU4LTIuODV2LTAuODRoNy44M1YzNy42OHoiPjwvcGF0aD4gPHBhdGggZD0iTTI2NS43LDQ5LjU2YzAsNC44My0zLjU0LDcuMTQtNi41MSw3LjE0Yy0zLjU5LDAuMDQtNi41My0yLjg0LTYuNTctNi40M2MwLTAuMDcsMC0wLjEzLDAtMC4yIGMtMC4yLTMuNzcsMi42OS02Ljk5LDYuNDctNy4yYzAuMDMsMCwwLjA3LDAsMC4xLDBjMy42LDAsNi41MSwyLjkxLDYuNTEsNi41MUMyNjUuNyw0OS40NCwyNjUuNyw0OS41LDI2NS43LDQ5LjU2eiBNMjU1LjQxLDQ5LjExIGMwLDMuNzgsMS42NSw2LjU5LDQuMTEsNi41OWMxLjg2LDAsMy4zOS0xLjM3LDMuMzktNS40OGMwLTMuNTEtMS40MS02LjM2LTQtNi4zNkMyNTcsNDMuODYsMjU1LjQxLDQ1LjcyLDI1NS40MSw0OS4xMSBMMjU1LjQxLDQ5LjExeiI+PC9wYXRoPiA8cGF0aCBkPSJNMjc1LjYzLDQ2Ljc3Yy0wLjU3LTEuNzctMS42Mi0zLTMuMDktM2MtMS4xLDAtMiwwLjg5LTIsMmMwLDAuMDIsMCwwLjA1LDAsMC4wN2MwLDEuMzUsMS4yLDIsMi41NSwyLjYxIGMyLjI1LDAuOTMsMy43OCwyLDMuNzgsNC4wOGMwLDIuNzMtMi41NSw0LjE0LTQuOTUsNC4xNGMtMS4yMiwwLjAyLTIuNDMtMC4zMy0zLjQ1LTFjLTAuMzEtMS4xNS0wLjQ3LTIuMzQtMC40OC0zLjU0bDAuNzgtMC4xNSBjMC41NCwyLDEuODksMy43MSwzLjY5LDMuNzFjMS4xNSwwLjAzLDIuMS0wLjg4LDIuMTMtMi4wM2MwLTAuMDIsMC0wLjA0LDAtMC4wNmMwLTEuMzItMC44Ny0yLTIuMzctMi43MyBjLTEuOC0wLjg0LTMuNzUtMS44My0zLjc1LTQuMTRjMC0yLjEsMS44LTMuODcsNC41Ni0zLjg3YzAuOTEtMC4wMSwxLjgyLDAuMTcsMi42NywwLjUxYzAuMywxLjA1LDAuNTIsMi4xMywwLjY2LDMuMjEgTDI3NS42Myw0Ni43N3oiPjwvcGF0aD4gPHBhdGggZD0iTTI4NS41LDQzLjMyYzAuNDUtMC4yNiwwLjk1LTAuNDIsMS40Ny0wLjQ1YzMuMzMsMCw1LjMxLDIuNyw1LjMxLDUuNjdjMCw0LjUzLTMuNTcsNy40NC03LjQ3LDguMTYgYy0wLjcyLTAuMDMtMS40My0wLjIyLTIuMDctMC41NHYzLjkyYzAsMi4yOSwwLjIxLDIuNDQsMi41NSwyLjY1djAuODFoLTcuMTF2LTAuODFjMS45Mi0wLjE5LDIuMTktMC4zNiwyLjE5LTIuMzRWNDYuODMgYzAtMS45NS0wLjEyLTItMi0yLjI1di0wLjcyYzEuNDktMC4yOCwyLjk1LTAuNzIsNC4zNS0xLjI5djIuMzdMMjg1LjUsNDMuMzJ6IE0yODIuNzQsNTQuMDZjMC43NiwwLjczLDEuNzcsMS4xNSwyLjgyLDEuMTcgYzIuNTIsMCw0LjItMi4xNiw0LjItNS41NWMwLTMuMjEtMS44My01LTQtNWMtMS4xLDAuMTMtMi4xNCwwLjU3LTMsMS4yNkwyODIuNzQsNTQuMDZ6Ij48L3BhdGg+IDxwYXRoIGQ9Ik0yOTQsNTYuMzR2LTAuNzhjMS44OS0wLjE5LDIuMS0wLjM2LDIuMS0yLjRWNDdjMC0xLjg2LTAuMDktMi0xLjg5LTIuMjhWNDRjMS40Ni0wLjIyLDIuODktMC42MSw0LjI2LTEuMTd2MTAuMzMgYzAsMiwwLjIxLDIuMjEsMi4xMywyLjR2MC43OEgyOTR6IE0yOTUuNTksMzguNzNjLTAuMDEtMC44NSwwLjY3LTEuNTUsMS41Mi0xLjU2YzAsMCwwLjAxLDAsMC4wMSwwYzAuODMsMCwxLjUsMC42NywxLjUsMS41IGMwLDAuMDIsMCwwLjA0LDAsMC4wNmMtMC4wMSwwLjg0LTAuNjksMS41Mi0xLjUzLDEuNTNjLTAuODMtMC4wMy0xLjQ5LTAuNy0xLjUxLTEuNTNIMjk1LjU5eiI+PC9wYXRoPiA8cGF0aCBkPSJNMzA3LjYxLDU2LjMxYy0wLjM5LDAuMjItMC44MiwwLjM2LTEuMjYsMC4zOWMtMS44OSwwLTIuOTQtMS4yLTIuOTQtMy41OFY0NC40aC0yLjA3bC0wLjEyLTAuM2wwLjgxLTAuODdoMS4zOFY0MWwxLjk1LTIgbDAuNDIsMC4wNnY0LjExaDMuMzljMC4zLDAuMzYsMC4yNCwwLjktMC4xMiwxLjJjLTAuMDEsMC4wMS0wLjAzLDAuMDItMC4wNSwwLjAzaC0zLjIxdjcuNzFjMCwyLjQzLDEsMi44OCwxLjc0LDIuODggYzAuNjUtMC4wMywxLjI5LTAuMiwxLjg2LTAuNTFsMC4yNywwLjc4TDMwNy42MSw1Ni4zMXoiPjwvcGF0aD4gPHBhdGggZD0iTTMyMC40OCw1Ni43Yy0wLjUyLTAuMDMtMS4wMi0wLjI0LTEuNDEtMC41OGMtMC4zNS0wLjM4LTAuNi0wLjg0LTAuNzItMS4zNGMtMS4yLDAuODEtMi42NCwxLjkyLTMuNTQsMS45MiBjLTItMC4wMS0zLjYxLTEuNjQtMy42LTMuNjRjMC0wLjAxLDAtMC4wMSwwLTAuMDJjMC0xLjQ3LDAuNzgtMi40LDIuNDMtM2MxLjYyLTAuNDgsMy4xOC0xLjE1LDQuNjUtMlY0Ny41IGMwLTIuMTYtMS0zLjM5LTIuNTItMy4zOWMtMC41Mi0wLjAyLTEuMDIsMC4yLTEuMzUsMC42Yy0wLjQ3LDAuNTgtMC43OCwxLjI3LTAuOSwyYy0wLjA3LDAuNDItMC40NSwwLjcxLTAuODcsMC42OSBjLTAuNjktMC4wNy0xLjI0LTAuNi0xLjMyLTEuMjljMC0wLjQ1LDAuMzktMC43OCwxLTEuMmMxLjM2LTAuOTcsMi44OC0xLjY5LDQuNS0yLjFjMC44OS0wLjAyLDEuNzYsMC4yNywyLjQ2LDAuODEgYzEsMC45NCwxLjUsMi4zLDEuMzUsMy42NnY1LjU4YzAsMS4zNSwwLjU0LDEuNzksMSwxLjc5YzAuMzgtMC4wMSwwLjc1LTAuMTIsMS4wOC0wLjMybDAuMywwLjc4TDMyMC40OCw1Ni43eiBNMzE4LjI5LDQ5LjE0IGMtMC42MywwLjMzLTIuMDcsMS0yLjcsMS4yNmMtMS4xNywwLjU0LTEuODMsMS4xMS0xLjgzLDIuMTljLTAuMDYsMS4yMSwwLjg3LDIuMjUsMi4wOSwyLjMxYzAuMDEsMCwwLjAzLDAsMC4wNCwwIGMwLjg5LTAuMSwxLjczLTAuNDgsMi40LTEuMDhWNDkuMTR6Ij48L3BhdGg+IDxwYXRoIGQ9Ik0zMjMuODEsNTYuMzR2LTAuNzhjMS44OS0wLjE5LDIuMTYtMC4zNiwyLjE2LTIuMzRWMzljMC0yLTAuMTgtMi4xMy0yLjA3LTIuMjhWMzZjMS41MS0wLjE5LDMtMC41Miw0LjQ0LTF2MTguMjIgYzAsMiwwLjI0LDIuMTUsMi4xNiwyLjM0djAuNzhIMzIzLjgxeiI+PC9wYXRoPiA8L2c+IDxnIGNsYXNzPSJzdmctbG9nby1pY29uIj4gPHBhdGggZD0iTTQwLjM2LDE2LjNoLTkuN3YxMmgtMTMuMlYzN2gxMi43OHYxMi4zN2g5LjQ0di0xMmgxMy4wNnYtOUg0MC4zNlYxNi4zeiBNNTEuNzQsMjkuMzl2N0gzOC42OHYxMmgtNy40NFYzNiBIMTguNDZ2LTYuNzRoMTMuMnYtMTJoNy43djEyLjEzSDUxLjc0eiI+PC9wYXRoPiA8cGF0aCBkPSJNNjEuNDMsMzAuNTdjMC0xLjE2LDAtMi4zMywwLjA3LTMuNDl2LTMuMTZjMSwxLjE3LDIuNDYsMS44Myw0LDEuODFjMi42OSwwLjA3LDQuOTUtMi4wNCw1LjA2LTQuNzMgYy0wLjA5LTIuNzItMi4zNy00Ljg2LTUuMS00Ljc3Yy0xLjU0LTAuMDItMywwLjY1LTQsMS44MXYtNC44Mkw2MCwxMi40MmwtMy43Ny0xLjk0Yy0xLjU4LTAuOC0zLjE2LTEuNi00LjczLTIuNDJsLTQuMzYtMi4yNCBjLTAuNTYtMC4yOS0yLjU4LTEuMTktMy4xMS0xLjQzYy0xLjc4LTAuODEtMy4zMSwwLjYyLTMuODcsMi4xM2MtMC4xOCwwLjUtMC40NSwxLjYxLDAsMi4wOGwwLjA2LDAuMDYgQzM5LjgyLDguNjEsMzkuNDEsOC41OSwzOSw4LjZjLTIsMC00LjEzLDAtNi4xNi0wLjA2bC0zLjczLTAuMDdsMCwwaC0zLjM5YzEuMTktMC44NiwxLjktMi4yMywxLjkyLTMuNyBDMjcuNTUsMi4wNSwyNS4yOC0wLjA5LDIyLjU2LDBjMCwwLDAsMC0wLjAxLDBjLTIuNzMtMC4wOS01LjAxLDIuMDUtNS4xLDQuNzdjMC4wMiwxLjQ3LDAuNzMsMi44NCwxLjkzLDMuN2gtNS4xMmwtMC44NCwxLjQ1IGMtMC43LDEuMTctMS40LDIuMzUtMi4wOCwzLjUzYy0wLjg1LDEuNDgtMS43MSwyLjk2LTIuNTksNC40M2MtMC44LDEuMzQtMS41OSwyLjY5LTIuNCw0Yy0wLjMxLDAuNTItMS4yNywyLjQxLTEuNTIsMi45MSBjLTAuODYsMS42NiwwLjY2LDMuMSwyLjI3LDMuNjJjMC42NywwLjI1LDEuNDEsMC4yOCwyLjEsMC4xYzAsMC4yLDAsMC40MSwwLDAuNjRjMCwxLjg5LDAsMy44Ny0wLjA2LDUuNzYgYzAsMS4xNi0wLjA2LDI
uMzMtMC4wNywzLjQ5bDAsMHYzLjE1Yy0xLTEuMTYtMi40Ny0xLjgyLTQtMS44Yy0yLjYzLTAuMjEtNC45MywxLjc1LTUuMTQsNC4zOXMxLjc1LDQuOTMsNC4zOSw1LjE0IGMwLjI1LDAuMDIsMC41LDAuMDIsMC43NiwwYzEuNTMsMC4wMiwzLTAuNjQsNC0xLjh2NC44MmwxLjU0LDAuNzlMMTQuMzcsNTVjMS41OSwwLjgsMy4xNywxLjYsNC43MywyLjQyczIuOSwxLjUyLDQuMzEsMi4yOCBDMjQsNjAsMjYsNjAuODksMjYuNTIsNjEuMTJjMS43OSwwLjgxLDMuMzItMC42MiwzLjg3LTIuMTJjMC4yNS0wLjU5LDAuMzEtMS4yNSwwLjE3LTEuODhjMC4zLDAsMC42MSwwLDEsMGMyLDAsNC4xMywwLDYuMTYsMC4wNSBsMy43MywwLjA3aDMuMzVjLTEuMjEsMC44Ny0xLjkzLDIuMjctMS45MywzLjc2YzAuMTgsMi44MSwyLjYsNC45NSw1LjQxLDQuNzdjMi41Ny0wLjE2LDQuNjEtMi4yMSw0Ljc3LTQuNzcgYy0wLjAyLTEuNDctMC43My0yLjg0LTEuOTMtMy43aDUuMTNsMC44NC0xLjQ1YzAuNy0xLjE3LDEuNC0yLjM1LDIuMDgtMy41M2MwLjg1LTEuNDgsMS43MS0zLDIuNTktNC40MmwyLjM5LTQgYzAuMzEtMC41MiwxLjI4LTIuNDIsMS41My0yLjkxYzAuODctMS42Ni0wLjY2LTMuMS0yLjI3LTMuNjJjLTAuNjYtMC4yMy0xLjM3LTAuMjgtMi4wNi0wLjEzYzAtMC4yNiwwLTAuNTIsMC0wLjg0IEM2MS40MSwzNC40NCw2MS4zOSwzMi40Niw2MS40MywzMC41N3ogTTU3Ljc5LDQxLjg2TDU0LjcsNDYuNXYtNy4zM0g0MS40M3YxMS42aC0wLjg1bC00LjczLDAuMTJjLTAuODUsMC0xLjY4LDAuMDUtMi41MywwLjA2IGMtMC40LDAtMC44MSwwLTEuMjIsMGMtMC41My0wLjAzLTEuMDcsMC0xLjU5LDAuMDljLTEuOSwwLjU3LTEuNzcsMS45Mi0xLjg5LDMuNmMtMC4wMSwwLjM0LDAuMDMsMC42NywwLjEyLDFsLTMuMjItMmwtNS0yLjg5IGg3Ljg4VjM4LjQzSDE2YzAtMC4yMiwwLTAuNzUsMC0wLjc4YzAtMS40OC0wLjA3LTMtMC4xMi00LjQ0YzAtMC43OS0wLjA2LTEuNTctMC4wNy0yLjM2YzAtMC4zOCwwLTAuNzYsMC0xLjE0IGMwLjA0LTAuNSwwLjAxLTEtMC4wOC0xLjQ5Yy0wLjYyLTEuNzgtMi4wNi0xLjY2LTMuODYtMS43N2MtMC4zNC0wLjAxLTAuNjcsMC4wMi0xLDAuMDlsMS44Ni0yLjY2bDMuMDktNC42NHY3LjMzaDEzLjI2VjE1aDAuODQgbDQuNzQtMC4xMWMwLjg0LDAsMS42OC0wLjA2LDIuNTMtMC4wNmgxLjIyYzAuNTMsMCwxLjA3LTAuMDUsMS41OS0wLjE2YzEuOS0wLjU4LDEuNzctMS45MywxLjg5LTMuNjEgYzAuMDEtMC4zNi0wLjAzLTAuNzItMC4xMy0xLjA2Yy0wLjAzLTAuMTEtMC4wNi0wLjIxLTAuMTEtMC4zMUw0NSwxMS43OGw1LDIuODhoLTcuODV2MTIuNDJoMTIuNGMwLDAuMjMsMCwwLjc2LDAsMC43OSBjMCwxLjQ3LDAuMDcsMi45NSwwLjEyLDQuNDNjMCwwLjc5LDAsMS41NywwLjA2LDIuMzZjMCwwLjM4LDAsMC43NywwLDEuMTVjLTAuMDMsMC41LDAsMSwwLjA5LDEuNDljMC42MiwxLjc3LDIsMS42NiwzLjg2LDEuNzYgYzAuMzgsMC4wNCwwLjc2LDAuMDIsMS4xNC0wLjA2TDU3Ljc5LDQxLjg2eiI+PC9wYXRoPiA8L2c+IDwvc3ZnPgo="
          }
        ],
        "name": "Stewart Memorial Community Hospital",
        "identifier": [
          {
            "system": "urn:ietf:rfc:3986",
            "value": "https://stewartmemorial.org"
          }
        ],
        "telecom": [
          {
            "system": "url",
            "value": "https://www.stewartmemorial.org"
          }
        ],
        "address": [
          {
            "city": "Lake City",
            "state": "IA"
          }
        ]
      }
    }
  ]
}
```

### Dana Farber: Epic and Cerner EHRs for different sub-populations, displayed in a unified card

*(Note: this is not an uncommon pattern. For example see https://info.chesapeakeregional.com/patient-portal, https://www.tuftsmedicalcenter.org/myTuftsMedicalCenter, https://www.nuvancehealth.org/patients-and-visitors/patient-portals, https://www.ouhealth.com/ou-health-patients-families/patient-portals, or run a search like https://www.google.com/search?q=%22patient+portals%22+%22if+you%22.)*

The patient portal is split by audience
* Uses MGB Epic system for adults
* Uses Boston Children's Cerner system for pediatrics
From <https://www.dana-farber.org/for-patients-and-families/my-dana-farber/>


{% include img-med.html img="https://i.imgur.com/WAr06qo.png" %}

Based on the definitions below, there would be top-level Brand cards for MGB and Boston Children's Hospital:

<div class="bg-info" markdown="1">
![](https://i.imgur.com/IVuJArL.png) **Mass General Brigham** ([massgeneralbrigham.org](https://www.massgeneralbrigham.org/))

|Source|API|Portal|
|--|--|--|
|**Patient Gateway**|{{SQUARE}} Connect |{{SQUARE}} View|
{:.grid style="background-color: white"}

Nearest location: 3 miles (Boston)
</div><!-- info -->

<div class="bg-info" markdown="1">
![](https://i.imgur.com/K0A3NjL.png) **Boston Children's Hospital** ([childrenshospital.org](https://www.childrenshospital.org/))


|Source|API|Portal|
|--|--|--|
|**MyChildren's Patient Portal**|{{SQUARE}} Connect |{{SQUARE}} View|
{:.grid style="background-color: white"}

Nearest location: 3 miles (Boston)
</div><!-- info -->


Without a consistent identifier  on both Organizations, Dana Farber would have two cards. This is accurate and works, but may not reflect the organization's desired formatting:

<div class="bg-info" markdown="1">
![](https://i.imgur.com/OjSDF1Z.png) **Dana-Farber Cancer Institute** ([dana-farber.org](https://www.dana-farber.org/))

|Source|API|Portal|
|--|--|--|
|**Patient Gateway.** *Patient Gateway is an online tool to help adult patients connect with healthcare providers, manage appointments, and refill prescriptions.*|{{SQUARE}}Connect|{{SQUARE}} View|
{:.grid style="background-color: white"}

Nearest location: 3 miles (Boston)
</div><!-- info -->

<div class="bg-info" markdown="1">
![](https://i.imgur.com/OjSDF1Z.png) **Dana-Farber Cancer Institute** ([dana-farber.org](https://www.dana-farber.org/))

|Source|API|Portal|
|--|--|--|
|**MyChildren's Patient Portal.** *MyChildren's Patient Portal is a Web-based, easy-to-use, and secure way to access your child's information at your convenience.*|{{SQUARE}} Connect |{{SQUARE}} View|
{:.grid style="background-color: white"}

Nearest location: 3 miles (Boston)
</div><!-- info -->


Since the definitions below include a consistent identifier (system `urn:ietf:rfc:3986`, value `https://dana-farber.org`), the system can combine the two Dana Farber connection choices into a single card at display time. This results in a card more like this:

<div class="bg-info" markdown="1">
![](https://i.imgur.com/OjSDF1Z.png) **Dana-Farber Cancer Institute** ([dana-farber.org](https://www.dana-farber.org/))

|Source|API|Portal|
|--|--|--|
|**Patient Gateway.** *Patient Gateway is an online tool to help adult patients connect with healthcare providers, manage appointments, and refill prescriptions.*| {{SQUARE}}  Connect|{{SQUARE}} View |
|**MyChildren's Patient Portal.** *MyChildren's Patient Portal is a Web-based, easy-to-use, and secure way to access your child's information at your convenience.*|{{SQUARE}} Connect |{{SQUARE}} View|
{:.grid style="background-color: white"}

Nearest location: 3 miles (Boston)
</div><!-- info -->


#### Epic content for Mass General Brigham (with Dana Farber as `partOf`)
```javascript
{
  "resourceType": "Bundle",
  "type": "collection",
  "meta": {
    "lastUpdated": "2022-03-14T15:09:26.535Z"
  },
  "entry": [
    {
      "fullUrl": "https://epic.example.org/Endpoint/mgb-endpoint-r2",
      "resource": {
        "resourceType": "Endpoint",
        "id": "unity-point",
        "address": "https://ws-interconnect-fhir.partners.org/Interconnect-FHIR-MU-PRD/api/FHIR/DSTU2",
        "name": "FHIR DSTU2 Endpoint for Mass General Brigham Patient Gateway",
        "managingOrganization": {
          "reference": "Organization/mgb"
        },
        "extension": [
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/endpoint-fhir-version",
            "valueCode": "1.0.2"
          },
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/patient-access-developer-url",
            "valueUrl":  "https://open.epic.com"
          }
        ],
        "connectionType": {
          "system": "http://terminology.hl7.org/CodeSystem/endpoint-connection-type",
          "code": "hl7-fhir-rest"
        }
      }
    },
    {
      "fullUrl": "https://epic.example.org/Organization/mgb",
      "resource": {
        "resourceType": "Organization",
        "id": "mgb",
        "extension": [
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/brand-logo",
            "valueUrl": "https://www.massgeneralbrigham.org/themes/custom/partners_mgb/logo.svg"
          },
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/patient-access-url", 
            "valueUrl": "https://patientgateway.massgeneralbrigham.org/"
          },
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/patient-access-name",
            "valueString": "Mass General Brigham Patient Gateway"
          }
        ],
        "name": "Mass General Brigham",
        "alias": [
          "Partners Healthcare",
          "Brigham and Women's",
          "Newton-Wellesley Hospital"
        ],
        "identifier": [
          {
            "system": "urn:ietf:rfc:3986",
            "value": "https://massgeneralbrigham.org"
          }
        ],
        "telecom": [
          {
            "system": "url",
            "value": "https://www.massgeneralbrigham.org/"
          }
        ],
        "address": [
          {
            "city": "Boston",
            "state": "MA"
          },
          {
            "city": "Newton",
            "state": "MA"
          },
          {
            "city": "Walpole",
            "state": "MA"
          },
          {
            "city": "Waltham",
            "state": "MA"
          },
          {
            "city": "Newton",
            "state": "MA"
          }
        ]
      }
    },
    {
      "fullUrl": "https://epic.example.org/Organization/dana-farber",
      "resource": {
        "resourceType": "Organization",
        "id": "data-farber",
        "partOf": {
          "reference": "Organization/mbg"
        },
        "extension": [
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/brand-logo",
            "valueUrl": "https://www.dana-farber.org/ui/images/img-logo-2x-new.webp"
          },
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/patient-access-description",
            "valueMarkdown": "Patient Gateway is an online tool to help adult patients connect with health care providers, manage appointments, and refill prescriptions."
          }
        ],
        "name": "Dana-Farber Cancer Institute",
        "alias": [],
        "identifier": [
          {
            "system": "urn:ietf:rfc:3986",
            "value": "https://dana-farber.org"
          }
        ],
        "telecom": [
          {
            "system": "url",
            "value": "https://www.dana-farber.org/"
          }
        ],
        "address": [
          {
            "city": "Boston",
            "state": "MA"
          }
        ]
      }
    }
  ]
}
```

#### Cerner Content for Boston Children's Hospital (with Dana Farber as `partOf`)


```javascript
{
  "resourceType": "Bundle",
  "type": "collection",
  "meta": {
    "lastUpdated": "2022-03-14T15:09:26.535Z"
  },
  "entry": [
    {
      "fullUrl": "https://cerner.example.org/Endpoint/bch-r4",
      "resource": {
        "resourceType": "Endpoint",
        "id": "bch-r4",
        "address": "https://bch.cerner.examlpe.org/r4",
        "name": "FHIR R4 Endpoint for Boston Children's Hospital",
        "managingOrganization": {
          "reference": "Organization/bch"
        },
        "extension": [
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/endpoint-fhir-version",
            "valueCode": "4.0.1"
          },
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/patient-access-developer-url",
            "valueUrl": "https://code.cerner.com"
          }
        ],
        "connectionType": {
          "system": "http://terminology.hl7.org/CodeSystem/endpoint-connection-type",
          "code": "hl7-fhir-rest"
        }
      }
    },
    {
      "fullUrl": "https://cerner.example.org/Organization/bch",
      "resource": {
        "resourceType": "Organization",
        "id": "bch",
        "extension": [
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/brand-logo",
            "valueUrl": "https://www.childrenshospital.org/-/media/BCH-Global/Landing-Pages/National-Brand/BCHlogo.ashx?h=85&w=600&la=en&hash=AF50B39C3F246D61E4C012ED25A2D8CF4C3A1607"
          },
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/patient-access-url",
            "valueUrl": "https://apps.childrenshospital.org/mychildrens/index.html"
          },
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/patient-access-name",
            "valueString": "MyChildrens Patient Portal"
          }
        ],
        "name": "Boston Children's Hospital",
        "alias": [],
        "identifier": [
          {
            "system": "urn:ietf:rfc:3986",
            "value": "https://childrenshospital.org"
          }
        ],
        "telecom": [
          {
            "system": "url",
            "value": "https://www.childrenshospital.org/"
          }
        ],
        "address": [
          {
            "city": "Boston",
            "state": "MA"
          }
        ]
      }
    },
    {
      "fullUrl": "https://cerner.example.org/Organization/dana-farber",
      "resource": {
        "resourceType": "Organization",
        "id": "data-farber",
        "partOf": {
          "reference": "Organization/bch"
        },
        "extension": [
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/brand-logo", 
            "valueUrl": "https://www.dana-farber.org/ui/images/img-logo-2x-new.webp"
          },
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/patient-access-description",  \\<<<Where is this extension defined >>>
            "valueMarkdown": "MyChildren's Patient Portal is a Web-based, easy-to-use, and secure way to access your child's information at your convenience."
          }
        ],
        "name": "Dana-Farber Cancer Institute",
        "alias": [],
        "identifier": [
          {
            "system": "urn:ietf:rfc:3986",
            "value": "https://dana-farber.org"
          }
        ],
        "telecom": [
          {
            "system": "url",
            "value": "https://www.dana-farber.org/"
          }
        ],
        "address": [
          {
            "city": "Boston",
            "state": "MA"
          }
        ]
      }
    }
  ]
}
```


### Two co-equal brands ("Cigna" + "Evernorth")

##### Option 1: Combine both Brands as Affiliated with a Hidden Brand

* One endpoint with a parent brand
* Parent brand marked as "hidden"
* Child brands for Cigna + Evernorth, pointing up to "primary brand"

##### Option 2: Duplicate the Endpoint

* two endpoints with the same address
* Each endpoint points to its primary brand
* No brand hierarchy


##### Option 3: Replace Endpoint.managingOrganization with a Multi-cardinality Extension

* One endpoint with links to two primary brands
* No brand hierarchy

```javascript
{
  "resourceType": "Bundle",
  "type": "collection",
  "meta": {
    "lastUpdated": "2022-03-14T15:09:26.535Z"
  },
  "entry": [
    {
      "fullUrl": "https://epic.example.org/Endpoint/evernorth",
      "resource": {
        "resourceType": "Endpoint",
        "id": "evernorth",
        "address": "https://cigna.org/ProdFHIR/api/FHIR/R4",
        "name": "FHIR R4 Endpoint for Cigna/Evernorth",
        "managingOrganization": {
          "reference": "Organization/evernorth"
        },
        "extension": [
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/endpoint-fhir-version",
            "valueCode": "4.0.1"
          },
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/patient-access-developer-url",
            "valueUrl":  "https://open.epic.com"
          }
 
        ],
        "connectionType": {
          "system": "http://terminology.hl7.org/CodeSystem/endpoint-connection-type",
          "code": "hl7-fhir-rest"
        }
      }
    }, {
      "fullUrl": "https://epic.example.org/Endpoint/cigna",
      "resource": {
        "resourceType": "Endpoint",
        "id": "cigna",
        "address": "https://cigna.org/ProdFHIR/api/FHIR/R4",
        "name": "FHIR R4 Endpoint for Cigna/Evernorth",
        "managingOrganization": {
          "reference": "Organization/cigna"
        },
        "extension": [
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/endpoint-fhir-version",
            "valueCode": "4.0.1"
          },
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/patient-access-developer-url",
            "valueUrl":  "https://open.epic.com"
          }
 
        ],
        "connectionType": {
          "system": "http://terminology.hl7.org/CodeSystem/endpoint-connection-type",
          "code": "hl7-fhir-rest"
        }
      }
    },{
      "fullUrl": "https://epic.example.org/Organization/cigna",
      "resource": {
        "resourceType": "Organization",
        "id": "cigna",
        "extension": [
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/brand-logo",
            "valueUrl": "https://unitypoint.org/logo/main.1024x102.png"
          },
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/patient-access-url",
            "valueUrl": "https://chart.cigna.org"
          }
        ],
        "name": "Cigna",
        "alias": [],
        "identifier": [],
        "telecom": [],
        "address": []
      }
    }, {
      "fullUrl": "https://epic.example.org/Organization/evernorth",
      "resource": {
        "resourceType": "Organization",
        "id": "evernorth",
        "extension": [
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/brand-logo",
            "valueUrl": "https://unitypoint.org/logo/main.1024x102.png"
          },
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/patient-access-url",
            "valueUrl": "https://chart.cigna.org"
          }
        ],
        "name": "Evernorth",
        "alias": [],
        "identifier": [],
        "telecom": [],
        "address": []
      }
    }
  ]
}

```