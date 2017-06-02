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
    $('#xpath').text(JSON.stringify(xpath));
}

$(document).ready(function () {

    // загрузка iframe
    $('#btn').click(function () {
        var url = $('#panel-edit').val();
        $('#frame').attr('src', 'proxy.php?url=' + url);
    });
    
    // iframe загружен - доступ к контенту 
    $('#frame').on('load', function (){ 
        var frame = $('#frame').contents();
        var selectedObj;
        var privBackground;

        // клик по объекту
        $(frame).find('body').click(function(e){

            e.preventDefault();

            $(window.selectedObj).css('background', window.privBackground);

            window.privBackground = $(e.target).css('background');
            $(e.target).css('background', 'buttonshadow');

            $('#elText').text($(e.target).text());
            $('#elHTML').text($(e.target).html());

            window.selectedObj = e.target;
            
            var xpath = getXPathJSON(window.selectedObj);
            $('#xpath').text(xpath);
            
            return false;
        });
        
        $('#up').click(function(e){
            $(window.selectedObj.parentNode).click();
        });
        
        $('#down').click(function(e){
            $(window.selectedObj).children().each(function(index, elem){
                $(elem).click();
                return false;
            }); 
        });
        
        $('#apply').click(function(e){
            $('#jsonrule').text($('#xpath').text());
            $('#jsonrule').css('display', 'block');
        });
        
    });      

});
