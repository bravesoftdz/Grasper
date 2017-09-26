
function getChildren(children) {

    var result = [];

    for (var i = 0; i < children.length; i++) {

        var node = children[i];
        result.push(processNode(node, i));

    }

    return result;
}

function processNode(node, i) {

    var result = {};

    result.tagName = node.tagName;
    result.index = i + 1;
    result.tagID = node.id;
    result.className = node.className;
    result.children = getChildren(node.children);

    return result;

}

$(function () {

    console.log('DOMFullTree begin');

    var node = document.children[0];

    var result = processNode(node, 0);
    app.fullnodestreeback(JSON.stringify(result));

    console.log('DOMFullTree done');

});

