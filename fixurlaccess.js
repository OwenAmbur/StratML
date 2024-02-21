function loadUrlXml(target){
	var idurl = "urlFrm";
	var idFrm = "formUrl";
	
	var surl  = document.getElementById(idurl).value;

	console.log('Handling the url here '+surl);
	
	var x = new XMLHttpRequest();
	x.open("GET", surl,true);
	x.onreadystatechange = function () {
  	if (x.readyState == 4 && x.status == 200)
  	{
   		 var doc = x.responseText;
		handlerXmlDoc(doc,target,true);
    }

	
	};
	x.send(null);
	
	return false;
}

function postDataUrl(surl){
	console.log('Getting '+surl);
	var x = new XMLHttpRequest();
	x.open("GET", surl,true);
	x.onreadystatechange = function () {
  		if (x.readyState == 4 && x.status == 200)
  		{
   		 	var doc = x.responseText;
			handlerXmlDoc(doc,'/forms2/walt5.pl',false);
			
        	}

	
	};
	x.send(null);
}



function handlerXmlDoc(xmldoc,trg,thiswindow){
	console.log('Receieved Xml now appending to form and submitting ');
	//nsole.log(xmldoc);
	var data = new FormData();
	data.append('xml',encodeXml( xmldoc));
	var xhr = new XMLHttpRequest();
	xhr.open('POST', trg, true);
	xhr.onload = function () {
   	 // do something to response
   		 console.log(this.responseText);
		if (this.responseText.indexOf("out.xml") > -1){
				if(thiswindow)
		   		window.location.href = '/forms2/out.xml';
				else
					window.open('/forms2/out.xml', '_blank');
		}	
		else if( this.responseText.indexOf("Import.xml") > -1 ) {
				if(thiswindow)
				window.location.href = '/forms2/Part1FormImport.xml';
				else
					window.open('/forms2/Part1FormImport.xml', '_blank');
    	}else{	
			alert('Something went wrong on server please check');
		}
	};
	xhr.send(data);


// add the xml to form and then submit 

}

var xml_special_to_escaped_one_map = {
    '&': '&amp;',
    '"': '&quot;',
    '<': '&lt;',
    '>': '&gt;'
};

var escaped_one_to_xml_special_map = {
    '&amp;': '&',
    '&quot;': '"',
    '&lt;': '<',
    '&gt;': '>'
};

function encodeXml(string) {
    return string.replace(/([\&"<>])/g, function(str, item) {
        return xml_special_to_escaped_one_map[item];
    });
};

function decodeXml(string) {
    return string.replace(/(&quot;|&lt;|&gt;|&amp;)/g,
        function(str, item) {
            return escaped_one_to_xml_special_map[item];
    });
}


