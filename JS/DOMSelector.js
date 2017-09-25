console.log('domselector');

function getXPathJSON(element) {

    var xpath = [];

    for (; element && element.nodeType == 1; element = element.parentNode) {

        $(element).removeClass('PIAColor');
        $(element).removeClass('PIAIgnore');
        
        var index = $(element.parentNode).children(element.tagName).index(element) + 1;

        xpath.unshift({
            tag: element.tagName,
            index: index,
            tagID: $(element).attr('id'),
            className: $(element).attr('class'),
            name: $(element).attr('name')
        });
    }

    return JSON.stringify(xpath);
}

$(document).find('body').one('click', function (e) {

    e.preventDefault();
       
    var xpath = getXPathJSON(e.target);
    app.selectdataback(xpath);
});