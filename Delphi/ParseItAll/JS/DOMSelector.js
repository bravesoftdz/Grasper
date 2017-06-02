	var script = document.createElement('script');
	script.src = 'jquery-3.1.1.js';
	document.getElementsByTagName('head')[0].appendChild(script);
	alert('script loaded');		


function getXPathJSON(element){
    var xpath = [];
    for ( ;element && element.nodeType == 1; element = element.parentNode) {
        //var id = $(element.parentNode).children(element.tagName).index(element) + 1;
        //id > 1 ? (id = '[' + id + ']') : (id = '');
        //xpath = '/' + element.tagName.toLowerCase() + id + xpath;
        
        var index = $(element.parentNode).children(element.tagName).index(element) + 1;
        xpath.unshift({
          tag: element.tagName,
          index: index,
          tagID: $(element).attr('id'), 
          className: $(element).attr('class'),
          name: $(element).attr('name')  
        });    
    }
    //$('#xpath').text(JSON.stringify(xpath));
    return JSON.stringify(xpath);	
} 

        var selectedObj;
        var privBackground; 


	// клик по объекту
        $(document).find('body').click(function(e){

            e.preventDefault();

            $(window.selectedObj).css('background', window.privBackground);

            window.privBackground = $(e.target).css('background');
            $(e.target).css('background', 'buttonshadow');

            window.selectedObj = e.target;
            
           var xpath = getXPathJSON(window.selectedObj);
            //$('#xpath').text(xpath);
	    
	   //alert(xpath);
	   app.databack(xpath);		
            
            return false;
        });