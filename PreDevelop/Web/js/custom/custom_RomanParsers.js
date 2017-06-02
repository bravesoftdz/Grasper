var customFuncs = {
    
    procWikiContent: function(element) {
    
        var child = element.firstElementChild;
        while (child.tagName != 'P') {
            var delChild = child;
            child = child.nextElementSibling;
            delChild.remove(); 
        }
        
        var collection = element.querySelectorAll('#toc');
        for (var i=0; i<collection.length; i++) {
            collection[i].remove();
        } 
        collection = element.querySelectorAll('table');
        for (var i=0; i<collection.length; i++) {
            if (collection[i].style.float == 'right') 
                  collection[i].remove();
        } 
        collection = element.querySelectorAll('.thumbinner');
        for (var i=0; i<collection.length; i++) {
            collection[i].remove();
        } 
        collection = element.querySelectorAll('div.dablink');
        for (var i=0; i<collection.length; i++) {
            collection[i].remove();
        } 
        collection = element.querySelectorAll('table.ambox');
        for (var i=0; i<collection.length; i++) {
            collection[i].remove();
        } 
        
        var killEl = false;
        child = element.firstElementChild;
        while (child != null) {
            
            if (   child.innerText === 'Примечания'
                || child.innerText === 'Ссылки'
                || child.innerText === 'Источники'
            ) killEl = true; 
            
            delChild = child;
            child = child.nextElementSibling;
            if (killEl)
                delChild.remove(); 
        }
       
        return element; 
    }  
};