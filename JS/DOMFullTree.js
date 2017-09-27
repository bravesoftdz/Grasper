
function getTagIndx(node, tagIndexes) {

    var result = 0;
    tagIndexes.forEach(function (tagIndex) {
        
        if (tagIndex.tag == node.tagName) {
            tagIndex.seq++;
            result = tagIndex.seq;
            return false;
        }

    });
    if (result > 0) return result;  
    
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

    result.tagName = node.tagName;
    result.index = i;
    result.tagID = node.id;
    result.className = node.className;
    result.children = getChildren(node.children);

    var ruleNodeID = $(node).data('pia-nodeid'); 
    if (ruleNodeID != null) 
        result.ruleNodeID = ruleNodeID; 

    return result;

}

$(function () {

    console.log('DOMFullTree begin');

    var node = document.children[0];

    var result = processNode(node, 0);
    app.fullnodestreeback(JSON.stringify(result));

    console.log('DOMFullTree done');

});

