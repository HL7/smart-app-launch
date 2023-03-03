CodeSystem: PatientAccessBrandCategory
Title: "Category for PatientAccessBrands"
Description: "Categorizes a PatientAccessBrand into high-level taxonomy"
* ^url = "http://hl7.org/fhir/smart-app-launch/CodeSystem/patient-access-brand-category"
* #health-system "A health system (e.g., regional or national)"
* #hospital "Hospital, residential, or inpatient facility"
* #outpatient "Outpatient office or clinic"
* #insurer "Health insuraance provider"
* #lab "Laboratory"
* #pharmacy "Pharmacy"
* #network "Network access provider such as a TEFCA QHIN"
* #aggregator "Aggregator of healthcare data offering individual access"

ValueSet: PatientAccessBrandCategoryValueSet
Title: "Category for PatientAccessBrands"
Description: "Categorizes a PatientAccessBrand into high-level taxonomy"
* ^url = "http://hl7.org/fhir/smart-app-launch/ValueSet/patient-access-brand-category-vs"
* include codes from system PatientAccessBrandCategory

Extension: PatientAccessBrandPortalUrl
Title: "Patient Access Brand: Portal URL"
Description: "URL were patients can access data from this provider and manage connected apps" 
* ^url = "http://hl7.org/fhir/smart-app-launch/StructureDefinition/patient-portal-url"
* value[x] only url

Extension: PatientAccessBrandPortalAudience
Title: "Patient Access Brand: Logo"
Description: "describes, if necessary, the sub-population of the Brand’s customers for whom this portal manages data. This capability supports(for example) a cancer center that uses one EHR for pediatric patients and another for adult patients. Each EHR would publish a PatientAccessBrand, and apps display the value from this extension to disambiguate the user’s selection (e.g., one Brand might say \"for pediatric patients\" and the other might say \"for adult patients\")"
* ^url = "http://hl7.org/fhir/smart-app-launch/StructureDefinition/patient-portal-audience"
* value[x] only string


Extension: PatientAccessBrandLogo
Title: "Patient Access Brand: Audience"
Description: "Logo for this brand."
* ^url = "http://hl7.org/fhir/smart-app-launch/StructureDefinition/brand-logo"
* value[x] only url

Extension: PatientAccessBrandLogoUseAgreement
Title: "Patient Access Brand: Logo Use Agreement"
Description: "URL pointing to terms of use for logo use by patient access apps"
* ^url = "http://hl7.org/fhir/smart-app-launch/StructureDefinition/brand-logo-use-agreement"
* value[x] only url


Extension: PatientAccessBrandHidden
Title: "Patient Access Brand: Hide from display"
Description: "allows for Organizations to be communicated as part of a hierarchy without necessarily being shown to patients in a card or tile. The intended use case is to help app developers understand and debug the organizational relationships that underpin published Brands."
* ^url = "http://hl7.org/fhir/smart-app-launch/StructureDefinition/brand-hidden"
* value[x] only boolean


Profile: PatientAccessBrand
Parent: Organization
Title: "Patient Access Brand (Organization)"
Description: "Profile on Organization to communicate the branding associated with a Patient Access API endpoint."
* ^url = "http://hl7.org/fhir/smart-app-launch/StructureDefinition/patient-access-brand"
* name 1..1 MS 
* name ^short = "Primary brand name for display in a card title"
* alias 0..* MS
* alias ^short = "Aliases (e.g., former names like \"Partners Healthcare\") for filtering/search"
* identifier 1..* MS
* identifier ^short = "Prvide a stable identifier that apps can use to recognize this Brand even if it appears in association with different endpoints or different vendors. SHOULD include an NPI (system http://hl7.org/fhir/sid/us-npi) or other externally recognized identifier; MAY include vendor-specific identifiers"
* partOf 0..1 MS
* partOf ^short = "Affiliated \"parent brand\", if this Brand is part of a larger health system"
* address 0..* MS
* address ^short = "ons (zip codes and/or street addresses) associated with the brand. SHALL include at least a zip code and SHOULD include a full street address."
* contact 0..* MS
* contact ^short = "Technical contact; SHALL provide use a telecom with url or email."
* type from PatientAccessBrandCategoryValueSet (extensible)
* type ^short = "Categories for this organization (health-system, hospital, outpatient, insurer, lab, pharmacy)"
* extension contains 
    PatientAccessBrandPortalUrl named portalUrl 1..1 MS and
    PatientAccessBrandPortalAudience named audience 0..1 and
    PatientAccessBrandLogo named logo 0..1 MS and
    PatientAccessBrandLogoUseAgreement named logoUse 0..1 MS and
    PatientAccessBrandHidden named hidden 0..1
* extension[portalUrl] ^short = """
      URL were patients can access data from this provider and manage connected apps
  """
* extension[logo] ^short = """
    Logo associated with this brand. The set of logos SHOULD include a 1024x1024 pixel
    PNG with transparent background and MAY include additional sizes.
 """
* extension[logoUse] ^short = """
    Link to terms of use of the logo by patient access apps.
  """
* extension[hidden] ^short = """
    Marks an Organization as "hidden" from user-facing displays. The allows Organizations
    to be communicated as part of a hierarchy without necessarily being shown to patients
    in a card or tile. The intended use case is to help app developers understand and
    debug the organizational relationships that underpin published Brands.
  """
* extension[audience] ^short = """
    describes, if necessary, the sub-population of the Brand’s customers for whom this
    portal manages data. This capability supports(for example) a cancer center that uses
    one EHR for pediatric patients and another for adult patients. Each EHR would publish
    a PatientAccessBrand, and apps display the value from this extension to disambiguate
    the user’s selection (e.g., one Brand might say "for pediatric patients" and the other
    might say "for adult patients")
  """

