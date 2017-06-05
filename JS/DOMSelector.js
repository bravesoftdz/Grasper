var script = document.createElement('script');
script.src = 'jquery-3.1.1.js';
document.getElementsByTagName('head')[0].appendChild(script);

function getXPathJSON(element) {

    var xpath = [];

    for (; element && element.nodeType == 1; element = element.parentNode) {

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

$(document).find('body').click(function (e) {

    e.preventDefault();

    var xpath = getXPathJSON(e.target);
    app.selectdataback(xpath);

    return false;
});