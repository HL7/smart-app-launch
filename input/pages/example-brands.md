{% capture SQUARE %}<span style="font-size:1em">&#9634;</span>{% endcapture %}

*The brands below are fabricated for the purpose of these examples.*

### Example 1: Lab with Thousands of Locations Nationwide

* One national brand
* Locations in thousands of cities

The configuration below establishes a single top-level Brand with a long list of ExampleHealth addresses. (The organization can also group  their locations into sub-brands such as "ExampleLabs Alaska")


<div class="bg-info" markdown="1">

<img src="Logo1.png" alt="ExampleLabs" width="40"/> **ExampleLabs** ([examplelabs.com](#))

|Source|API|Portal|
|--|--|--|
|**ExampleLabs Patient™ portal**|{{SQUARE}} Connect|{{SQUARE}} View |
{:.grid style="background-color: white"}

Nearest location: 1 mile (Madison)

</div><!-- info -->

The FHIR server's `.well-known/smart-configuration` file would include a link like

    "patientAccessBrands": "https://examplelabs.example.com/branding.json"
    
And the hosted` Patient Access Brands Bundle file would look like:

[Raw JSON](Bundle-example1.json)

~~~
{% include_relative Bundle-example1.json %}
~~~


### Example 2: Regional Health System With Independently Branded Affiliates

* Regional health system ("ExampleHealth")
* Multiple locations in/around 12 cities
* Provides EHR for many affiliates (distinctly branded sites like "ExampleHealth Physicians of Madison" or "ExampleHealth Community Hospital")

The system displays the following cards to a user:

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

(And two more cards for other affiliated brands sharing the MyExampleHospital portal.)

[Raw JSON](Bundle-example2.json)

~~~
{% include_relative Bundle-example2.json %}
~~~

### Example 3: Different EHRs for different sub-populations displayed in a unified card

*(Note: this is not an uncommon pattern. For example see, <https://www.tuftsmedicalcenter.org/myTuftsMedicalCenter>, <https://www.nuvancehealth.org/patients-and-visitors/patient-portals>, <https://www.ouhealth.com/ou-health-patients-families/patient-portals>, or run a search like <https://www.google.com/search?q=%22patient+portals%22+%22if+you%22>.)*

The ExampleHospital's patient portals below are split by audience:
* EHR1: "Patient Gateway" for adult patients to help them connect with providers, manage appointments and refill prescriptions.
* EHR2: "Pediatrics", a patient portal where parents can access their child's information.

Based on the definitions below, there would be top-level Brand cards for the two Hospital's, ExampleHospital1 and ExampleHospital2

<div class="bg-info" markdown="1">
<img src="Logo12.svg" alt="ExampleHospital1" width="40"/> **ExampleHospital1** ([examplehospital1.org](#))

|Source|API|Portal|
|--|--|--|
|**Patient Gateway**|{{SQUARE}} Connect |{{SQUARE}} View|
{:.grid style="background-color: white"}

Nearest location: 3 miles (Boston)
</div><!-- info -->

<div class="bg-info" markdown="1">
<img src="Logo7.svg" alt="ExampleHospital2" width="40"/> **ExampleHospital2** ([examplehospital2.org](#))


|Source|API|Portal|
|--|--|--|
|**Pediatrics**|{{SQUARE}} Connect |{{SQUARE}} View|
{:.grid style="background-color: white"}

Nearest location: 3 miles (Boston)
</div><!-- info -->

ExampleHospital3's patient portal is split by "Patient Gateway" and "Pediatrics".

Without a consistent identifier on both Organizations, ExampleHospital3 would have two cards:

<div class="bg-info" markdown="1">
<img src="Logo9.svg" alt="ExampleHospital3" width="40"/> **ExampleHospital3** ([examplehospital3.org](#))

|Source|API|Portal|
|--|--|--|
|**Patient Gateway**|{{SQUARE}}Connect|{{SQUARE}} View|
{:.grid style="background-color: white"}

Nearest location: 3 miles (Boston)
</div><!-- info -->

<div class="bg-info" markdown="1">
<img src="Logo9.svg" alt="ExampleHospital3" width="40"/> **ExampleHospital3** ([examplehospital3.org](#))

|Source|API|Portal|
|--|--|--|
|**Pediatrics**|{{SQUARE}} Connect |{{SQUARE}} View|
{:.grid style="background-color: white"}

Nearest location: 3 miles (Boston)
</div><!-- info -->


Although displaying 2 cards is correct, it may not reflect the organization's desired formatting.  Since the definitions below include a consistent identifier (system `urn:ietf:rfc:3986`, value `https://examplehospital3.org`), the system can combine the two ExampleHospital3 connection choices into a single card at display time. This results in a card more like this:

<div class="bg-info" markdown="1">
<img src="Logo9.svg" alt="ExampleHospital3" width="40"/> **ExampleHospital3** ([examplehospital3.org](#))

|Source|API|Portal|
|--|--|--|
|**Patient Gateway**| {{SQUARE}}  Connect|{{SQUARE}} View |
|**Pediatrics**|{{SQUARE}} Connect |{{SQUARE}} View|
{:.grid style="background-color: white"}

Nearest location: 3 miles (Boston)
</div><!-- info -->


#### EHR1 content for ExampleHospital1 (with ExampleHospital3 as `partOf`)


[Raw JSON](Bundle-example3.json)

~~~
{% include_relative Bundle-example3.json %}
~~~


#### EHR2 Content for ExampleHospital2 (with ExampleHospital3 as `partOf`)



[Raw JSON](Bundle-example4.json)

~~~
{% include_relative Bundle-example4.json %}
~~~



### Example 4: Two co-equal brands ("Brand1" + "Brand2")

All three option described below would have two cards:

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

#### Option 1: Duplicate the Endpoint

* two endpoints with the same address
* Each endpoint points to its primary brand
* No brand hierarchy

#### Option 2: Combine both Brands as Affiliated with a Hidden Brand

* One endpoint with a parent brand
* Parent brand marked as "hidden"
* Child brands for Brand1 + Brand2, pointing up to "primary brand"

##### Brand Bundle for Option 1: Duplicate the Endpoint


[Raw JSON](Bundle-example5.json)

~~~
{% include_relative Bundle-example5.json %}
~~~

### Example 5: EHR and EHR Customer Hosted Brands Bundles

ExampleHealth uses EHR1, and its endpoint is listed in EHR1's Brands Bundle.  As shown above, [ExampleHealth](#example-2-regional-health-system-with-independently-branded-affiliates) *also* hosts its own branding bundle (with mores details about every clinic location, specialty, etc.). <span class="bg-success" markdown="1">In EHR1 Brands Bundle, ExampleHealth points to the Patient Access Endpoint within the Bundle and to an external Brand Bundle.</span><!-- new-content -->

For EHR1 Brands Bundle, the system displays the following card to a user:

<div class="bg-info" markdown="1">
<img src="Logo13.png" alt="ExampleHealth" width="40"/>  **ExampleHealth** ([examplehealth.org](#))

|Source|API|Portal|
|--|--|--|
|**MyExampleHospital**| {{SQUARE}}  Connect|{{SQUARE}} View |
{:.grid style="background-color: white"}

</div><!-- info -->


#### EHR1 Content for ExampleHealth


[Raw JSON](Bundle-example6.json)

~~~
{% include_relative Bundle-example6.json %}
~~~
