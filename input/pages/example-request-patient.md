### Example: Request Patient Clinical Data

```sh
curl -i 'http://launch.smarthealthit.org/v/r2/sim/eyJoIjoiMSIsImoiOiIxIn0/fhir/Patient/f3ecf690-e035-498d-9e8c-1ef1e4db34b7' -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJuZWVkX3BhdGllbnRfYmFubmVyIjp0cnVlLCJzbWFydF9zdHlsZV91cmwiOiJodHRwczovL2xhdW5jaC5zbWFydGhlYWx0aGl0Lm9yZy9zbWFydC1zdHlsZS5qc29uIiwicGF0aWVudCI6ImYzZWNmNjkwLWUwMzUtNDk4ZC05ZThjLTFlZjFlNGRiMzRiNyIsImVuY291bnRlciI6IjQ2MzJlNjFiLTliMzQtNGFkNy1hNDMxLWYwMDhmMzViNGRkMyIsInJlZnJlc2hfdG9rZW4iOiJleUowZVhBaU9pSktWMVFpTENKaGJHY2lPaUpJVXpJMU5pSjkuZXlKamIyNTBaWGgwSWpwN0ltNWxaV1JmY0dGMGFXVnVkRjlpWVc1dVpYSWlPblJ5ZFdVc0luTnRZWEowWDNOMGVXeGxYM1Z5YkNJNkltaDBkSEJ6T2k4dmJHRjFibU5vTG5OdFlYSjBhR1ZoYkhSb2FYUXViM0puTDNOdFlYSjBMWE4wZVd4bExtcHpiMjRpTENKd1lYUnBaVzUwSWpvaVpqTmxZMlkyT1RBdFpUQXpOUzAwT1Roa0xUbGxPR010TVdWbU1XVTBaR0l6TkdJM0lpd2laVzVqYjNWdWRHVnlJam9pTkRZek1tVTJNV0l0T1dJek5DMDBZV1EzTFdFME16RXRaakF3T0dZek5XSTBaR1F6SW4wc0ltTnNhV1Z1ZEY5cFpDSTZJbTE1WDNkbFlsOWhjSEFpTENKelkyOXdaU0k2SW05d1pXNXBaQ0J3Y205bWFXeGxJRzltWm14cGJtVmZZV05qWlhOeklIVnpaWEl2S2k0cUlIQmhkR2xsYm5RdktpNHFJR3hoZFc1amFDOWxibU52ZFc1MFpYSWdiR0YxYm1Ob0wzQmhkR2xsYm5RaUxDSjFjMlZ5SWpvaVVISmhZM1JwZEdsdmJtVnlMMU5OUVZKVUxURXlNelFpTENKcFlYUWlPakUxTWprMk56TTVNRElzSW1WNGNDSTZNVFV5T1RZM05ESXdNbjAudDZZbjlOd0RZWU5IeWlOdXQ2N2xpOFRENzZZX0MtanEwVlExTVBFTGpXSSIsInRva2VuX3R5cGUiOiJiZWFyZXIiLCJzY29wZSI6Im9wZW5pZCBwcm9maWxlIG9mZmxpbmVfYWNjZXNzIHVzZXIvKi4qIHBhdGllbnQvKi4qIGxhdW5jaC9lbmNvdW50ZXIgbGF1bmNoL3BhdGllbnQiLCJjbGllbnRfaWQiOiJteV93ZWJfYXBwIiwiZXhwaXJlc19pbiI6MzYwMCwiaWRfdG9rZW4iOiJleUowZVhBaU9pSktWMVFpTENKaGJHY2lPaUpTVXpJMU5pSjkuZXlKd2NtOW1hV3hsSWpvaVVISmhZM1JwZEdsdmJtVnlMMU5OUVZKVUxURXlNelFpTENKaGRXUWlPaUp0ZVY5M1pXSmZZWEJ3SWl3aWMzVmlJam9pTnpaa05UTm1aalpqWTJRMk9XVmhNamRtTXpJek9UTTRNR0l6TURNNVlqUmhPRGN5T1RreVpqZ3hOVEZsWWpNeE9HTmxNVGcyWldRNVpqSm1NekV6WXlJc0ltbHpjeUk2SW1oMGRIQTZMeTlzWVhWdVkyZ3VjMjFoY25Sb1pXRnNkR2hwZEM1dmNtY2lMQ0pwWVhRaU9qRTFNamsyTnpNNU1EY3NJbVY0Y0NJNk1UVXlPVFkzTnpVd04zMC5LanJScTJYZ2lPYk0wQXpOcTVIcmUzd2tRRlFGNHhjc0Y3YzlnVnpWOHF6N0x2eXc0bnd1blBxbTlUdmJFaEYzM2k5anZPb1RUS0pjVTJJMGt1eHR3bEYzLUJ6WjdoZjRBWUZVY1poME9BZkFVRjNIaFRmRUQ5R1MxVmlDWjJBUmNkRWdyc0dqTk83OGFlODd2M2hlNFQtaG9KWkZ2T2FXaWZPaEdqcFA1WW14eEdpaGozbDluckpVZmtId0V6VFdCaUo4TEpQOVVCRXFZaTBHclc0TzJCRnJJSk14YWNyQmVrbkJ3cHJJbnJKNlg5TkpJbGpkVEI1Yk1iT1BPNVJGbDBldFdXMDVTNU1NRmdZT3duemJHM0xOa3YyWnlINWRSeDRoQWhaRVhFLW1aZndFSUVVRkc4WHdZeHc5WVNzSTlPOFVhQUh6OGtNQkVVSEg4U01ad2ciLCJpYXQiOjE1Mjk2NzM5MDcsImV4cCI6MTUyOTY3NzUwN30.RdYLx5aMfXdLdRTuzkvKB0jo_ZRqXSxcamrl7mwcEi0' -H 'Content-Type: application/json' -H 'Accept: application/json'
HTTP/1.1 200 OK
Server: Cowboy
Connection: keep-alive
X-Powered-By: Express
Vary: Origin
Access-Control-Allow-Credentials: true
Content-Type: application/json+fhir;charset=utf-8
Date: Fri, 22 Jun 2018 13:31:39 GMT
Transfer-Encoding: chunked
Via: 1.1 vegur

{
  "resourceType": "Patient",
  "id": "f3ecf690-e035-498d-9e8c-1ef1e4db34b7",
  "meta": {
    "versionId": "1",
    "lastUpdated": "2018-05-07T13:09:20.942-04:00",
    "tag": [
      {
        "system": "https://smarthealthit.org/tags",
        "code": "synthea-8-2017"
      }
    ]
  },
  "text": {
    "status": "generated",
    "div": "<div xmlns=\"http://www.w3.org/1999/xhtml\">Generated by <a href=\"https://github.com/synthetichealth/synthea\">Synthea</a>. Version identifier: 1a8d765a5375bf72f3b7a92001940d05a6f21189</div>"
  },
  "extension": [
    {
      "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-race",
      "valueCodeableConcept": {
        "coding": [
          {
            "system": "http://hl7.org/fhir/v3/Race",
            "code": "2106-3",
            "display": "White"
          }
        ],
        "text": "race"
      }
    },
    {
      "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity",
      "valueCodeableConcept": {
        "coding": [
          {
            "system": "http://hl7.org/fhir/v3/Ethnicity",
            "code": "2186-5",
            "display": "Nonhispanic"
          }
        ],
        "text": "ethnicity"
      }
    },
    {
      "url": "http://hl7.org/fhir/StructureDefinition/birthPlace",
      "valueAddress": {
        "city": "Great Barrington",
        "state": "MA",
        "country": "US"
      }
    },
    {
      "url": "http://hl7.org/fhir/StructureDefinition/patient-mothersMaidenName",
      "valueString": "Angelique Wiza"
    },
    {
      "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-birthsex",
      "valueCode": "F"
    },
    {
      "url": "http://hl7.org/fhir/StructureDefinition/patient-interpreterRequired",
      "valueBoolean": false
    }
  ],
  "identifier": [
    {
      "system": "https://github.com/synthetichealth/synthea",
      "value": "9a4673a6-c188-4a2a-8ac5-20fc1570562d"
    },
    {
      "type": {
        "coding": [
          {
            "system": "http://hl7.org/fhir/identifier-type",
            "code": "SB"
          }
        ]
      },
      "system": "http://hl7.org/fhir/sid/us-ssn",
      "value": "999579282"
    },
    {
      "type": {
        "coding": [
          {
            "system": "http://hl7.org/fhir/v2/0203",
            "code": "DL"
          }
        ]
      },
      "system": "urn:oid:2.16.840.1.113883.4.3.25",
      "value": "S99935956"
    },
    {
      "type": {
        "coding": [
          {
            "system": "http://hl7.org/fhir/v2/0203",
            "code": "MR"
          }
        ]
      },
      "system": "http://hospital.smarthealthit.org",
      "value": "9a4673a6-c188-4a2a-8ac5-20fc1570562d"
    }
  ],
  "name": [
    {
      "use": "official",
      "family": [
        "Abernathy"
      ],
      "given": [
        "Yu"
      ],
      "prefix": [
        "Mrs."
      ]
    },
    {
      "use": "maiden",
      "family": [
        "Conroy"
      ],
      "given": [
        "Yu"
      ]
    }
  ],
  "telecom": [
    {
      "system": "phone",
      "value": "1-388-106-3453 x11564",
      "use": "home"
    }
  ],
  "gender": "female",
  "birthDate": "1933-10-28",
  "deceasedDateTime": "1981-08-02T03:17:54-04:00",
  "address": [
    {
      "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/geolocation",
          "extension": [
            {
              "url": "latitude",
              "valueDecimal": 42.20330140988886
            },
            {
              "url": "longitude",
              "valueDecimal": -70.95949950304376
            }
          ]
        }
      ],
      "line": [
        "1613 Haley Glen",
        "Suite 387"
      ],
      "city": "Weymouth Town",
      "state": "MA",
      "postalCode": "02188",
      "country": "US"
    }
  ],
  "maritalStatus": {
    "coding": [
      {
        "system": "http://hl7.org/fhir/v3/MaritalStatus",
        "code": "M"
      }
    ],
    "text": "M"
  },
  "multipleBirthBoolean": false,
  "communication": [
    {
      "language": {
        "coding": [
          {
            "system": "http://hl7.org/fhir/ValueSet/languages",
            "code": "en-US",
            "display": "English (United States)"
          }
        ]
      }
    }
  ]
}
```
{: .smart-code}
