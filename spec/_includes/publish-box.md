<p id="publish-box">
This is the  {% if {{site.data.fhir.ig.status}} == 'draft' %} Continuous Integration Build {% else %} Version {{site.data.fhir.ig.version}} Release {% endif %} of the {{site.data.fhir.igName}} Implementation Guide,  based on <a href="{{ site.data.fhir.path }}">FHIR Version {{ site.data.fhir.version }}</a>.  See the <a href="http://www.fhir.org/guides/{{page.historypath}}/history.html">Directory of published versions</a>
</p>
