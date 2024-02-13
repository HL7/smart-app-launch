{% capture SQUARE %}<span style="font-size:1em">&#9634;</span>{% endcapture %}

*The brands below are fabricated for the purpose of these examples.*

### Example 1: Lab with Locations Nationwide

Let's begin by considering a national lab with many locations nationwide.

The configuration below establishes a single top-level Organization (applying the `UserAccessBrand` profile) with a potentially long list of ExampleLabs addresses. In this configuration there's a single Organization associated with a single portal and endpoint. The organization lists several aliases and addresses.

(An alternative choice for ExampleLabs would be to create an Organization for each state as a "sub-brand" with its own name, logo, and addresses. This is a decision that ExampleLabs can make based on how they wish to appear in patient-facing apps.)

Based on this configuration, a patient app might display the following cards to a user:
<div class="bg-info" markdown="1">

<img src="Logo1.png" alt="ExampleLabs" width="40"/> **ExampleLabs** ([examplelabs.com](#))

|Source|API|Portal|
|--|--|--|
|**ExampleLabs Patient™ portal**|{{SQUARE}} Connect|{{SQUARE}} View |
{:.grid style="background-color: white"}

Nearest location: 1 mile (Madison)

</div><!-- info -->

The FHIR server's `.well-known/smart-configuration` file would include a link like

    "userAccessBrands": "https://labs.example.com/branding.json"
    
And the hosted User Access Brands Bundle file would look like:

[Raw JSON](Bundle-example1.json)


### Example 2: Regional Health System With Independently Branded Affiliates

Next, let's look at a Regional health system ("ExampleHealth") that has:

* Has locations in/around 12 cities
* Provides EHR for independent affiliates (distinctly branded sites like "ExampleHealth Physicians of Madison" or "ExampleHealth Community Hospital")

The configuration below establishes a single Organization for ExampleHealth, with a single portal associated with two FHIR endpoints (one R2, one R4). There are also Organizations for the affiliated providers, each indicating a `partOf`  relationship with ExampleHealth.

Based on this configuration, a patient app might display the following cards to a user:

<div class="bg-info" markdown="1">
<img src="Logo2.png" alt="ExampleHealth" width="40"/>  **ExampleHealth** ([examplehealth.org](#))

|Source|API|Portal|
|--|--|--|
|**MyExampleHospital**| {{SQUARE}}  Connect|{{SQUARE}} View |
{:.grid style="background-color: white"}

Nearest location: 13 miles (Madison)
</div><!-- info -->

<div class="bg-info" markdown="1">
<img src="Logo8.png" alt="ExampleHealth Physicians of Madison" width="40"/> **ExampleHealth Physicians of Madison** ([ehpmadison.com](#))

|Source|API|Portal|
|--|--|--|
|**MyExampleHospital**| {{SQUARE}}  Connect|{{SQUARE}} View |
{:.grid style="background-color: white"}

Nearest location: 1 mile (Madison)
</div><!-- info -->

<div class="bg-info" markdown="1">
<img src="Logo5.svg" alt="ExampleHealth Community Hospital" width="40"/>  **ExampleHealth Community Hospital** ([ehchospital.org](#))

|Source|API|Portal|
|--|--|--|
|**MyExampleHospital**| {{SQUARE}}  Connect|{{SQUARE}} View |
{:.grid style="background-color: white"}

Nearest location: 120 miles (Lake City)
</div><!-- info -->

[Raw JSON](Bundle-example2.json)

### Example 3: Different EHRs for different sub-populations displayed in a unified card

Now let's look at a more complex (but still surprisingly common) scenario where a care facility ("ExampleHospital") has two patient portals offered by different EHR vendors and split by audience:

* EHR1: "Patient Gateway" for adult patients to help them connect with providers, manage appointments and refill prescriptions.
* EHR2: "Pediatrics", a patient portal where parents can access their child's information.

The configuration below establishes a single Organization for ExampleHospital, with a portal for pediatrics and a portal for adult care, each associated with a distinct endpoint.

Based on this configuration, a patient app might display the following cards to a user:

<div class="bg-info" markdown="1">
<img src="Logo9.svg" alt="Brand1" width="40"/> **ExampleHospital** ([examplehospital.org](#))

|Source|API|Portal|
|--|--|--|
|**Patient Gateway**|{{SQUARE}}Connect|{{SQUARE}} View|
|**Pediatrics**|{{SQUARE}}Connect|{{SQUARE}} View|
{:.grid style="background-color: white"}

Nearest location: 1 miles (Napa)
</div><!-- info -->


*(Note: In practice, if ExampleHospital uses two different EHR vendors to host these different portals, it's possible that each vendor might publish only "their" portion of the content in an endpoint list. This is why it's important to populate `Organization.identifier` with consistent values, allowing apps to merge details from different publication sources into a single card for a streamlined selection UX. This guide [recommends the use of normalized website URLs](brands.html#consistent-identifiers-for-organizations) as common identifiers.)*


[Raw JSON](Bundle-example3.json)


### Example 4: Two co-equal brands ("Brand1" + "Brand2")

Finally, let's consider the scenario where a single patient portal is associated with two brands, neither one considered "primary".

One possibility is simply to duplicate the Endpoints and Organizations and maintain entirely separate copies of their information, which apps can render into separate cards.

But if both organizations really do share an endpoint, the configuration below shows a more precise way to model the situation with one Endpoint and two Organizations that point to it.

Based on this configuration, a patient app might display the following cards to a user:

<div class="bg-info" markdown="1">
<img src="Logo10.svg" alt="Brand1" width="40"/> **Brand1** ([brand1.org](#))

|Source|API|Portal|
|--|--|--|
|**Brand1 Portal**|{{SQUARE}}Connect|{{SQUARE}} View|
{:.grid style="background-color: white"}

Nearest location: 1 miles (Napa)
</div><!-- info -->

<div class="bg-info" markdown="1">
<img src="Logo11.svg" alt="Brand2" width="40"/> **Brand2** ([brand2.org](#))

|Source|API|Portal|
|--|--|--|
|**Brand2 Portal**|{{SQUARE}}Connect|{{SQUARE}} View|
{:.grid style="background-color: white"}

Nearest location: 13 miles (Sonoma)
</div><!-- info -->


[Raw JSON](Bundle-example4.json)
