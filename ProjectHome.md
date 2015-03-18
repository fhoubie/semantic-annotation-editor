# Summary #
Liferay portlet used to add tagging some ISO & OGC metadata with vocabulary URI.

# Installation #
To install this portlet, get the code and  build it using:
```
maven clean package
```

By default, it will use some existing Ontology Servers. If you want to specify your own Ontology Servers, simply edit the void.rdf file in /git/master/src/main/webapp/data directory before building it.

This file is an RDF file following the void structure (http://www.w3.org/TR/void/).

Once you have built the archive, you simply drop it in the liferay-portal-x.x.x/deploy directory.

# Description #
This portlet take care of annotating metadata with term selected in thesaurus. Currently, the following metadata formats are supported :

- ISO 19115
- ISO 19119
- SensorML
- OWS 1.1 XML Capabilities
- WMS 1.3 XML Capabilities

# Future work #
Currently, only metadata at the level of the service can be added. It is not possible to add keywords at the level of the layer.

