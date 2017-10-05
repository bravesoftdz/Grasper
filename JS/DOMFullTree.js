var config = %s;
var GIAnodeEnumenator = 0;

function emptyIfnull(value) {
    if (value == null) return '';
    return value;	
}

function getTagIndx(node, tagIndexes) {

    var result = 0;
    tagIndexes.forEach(function (tagIndex) {

        if (tagIndex.tag == node.tagName) {
            tagIndex.seq++;
            result = tagIndex.seq;
            return false;
        }

    });
    if (result > 0)
        return result;

    var tagIndex = {};
    tagIndex.tag = node.tagName;
    tagIndex.seq = 0;
    tagIndexes.push(tagIndex);

    return getTagIndx(node, tagIndexes);
}

function getChildren(children) {

    var result = [];
    var tagIndexes = [];

    for (var i = 0; i < children.length; i++) {

        var node = children[i];
        var tagIndx = getTagIndx(node, tagIndexes);
        result.push(processNode(node, tagIndx));

    }

    return result;
}

function processNode(node, i) {

    var result = {};

    if (config.needDataBack) {

        GIAnodeEnumenator++;
        $(node).attr('data-pia-keyid', GIAnodeEnumenator);
        result.keyID = GIAnodeEnumenator;
    }

    var piaKeyid = $(node).attr('data-pia-keyid');

    if (piaKeyid == config.nodeKeyID) {

        setColorMark(node);
        
        return {};
    }

    result.tag = node.tagName;
    result.index = i;
    result.tagID = emptyIfnull(node.id);
    result.className = emptyIfnull(node.className);
    result.name = emptyIfnull($(node).attr('name'));
    result.children = getChildren(node.children);

    return result;

}

function setColorMark(node) {
    
    $(node).attr('data-pia-nodecolor', 1);
    $(node).css('background-color', 'SlateGray');
    $(node).find('*').css('background-color', 'SlateGray');   
    
}

function clearColorMark() {
    
    var node = $('[data-pia-nodecolor]'); 
    $(node).css('background-color', '');
    $(node).find('*').css('background-color', '');
    
}

$(function () {

    console.log('DOMFullTree begin');

    clearColorMark();

    var node = document.children[0];

    var result = processNode(node, 0);

    if (config.needDataBack)
        app.fullnodestreeback(JSON.stringify(result));

    console.log('DOMFullTree done');

});

