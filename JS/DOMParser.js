
var group = %s;

function getNormalizeString(str) {
    str = str.replace(/\n/g, "");
    str = str.replace(/ {1,}/g, " ");
    return str.trim(str);
}

function checkNodeMatches(matches, node, element) {
    matches.isIDMatch = false;
    matches.isClassMatch = false;
    matches.isNameMatch = false;
    if (element === undefined)
        return false;
    // ID match
    if (node.tagID === undefined)
        node.tagID = '';
    if (element.id === node.tagID)
        matches.isIDMatch = true;
    // class match
    if (node.className === undefined)
        node.className = '';
    var clName = node.className.toString();
    var clArr = clName.split(' ');
    clName = (getNormalizeString(element.className));
    clArr.forEach(function (item) {
        if (clName.match(item) != null)
            matches.isClassMatch = true;
    });
    // name match
    if (node.name === undefined)
        node.name = null;
    if (element.getAttribute('name') === node.name)
        matches.isNameMatch = true;
}

function getElementOfCollectionByIndex(node, collection, matches) {
    var element = collection[node.index - 1];
    checkNodeMatches(matches, node, element);
    return element;
}

function getElementOfCollectionByID(node, collection, matches) {
    if (node.tagID !== '') {
        for (var i = 0; i < collection.length; i++) {
            var element = collection[i];
            if (element.id === node.tagID)
                break;
        }
    }
    checkNodeMatches(matches, node, element);
    return element;
}

function getElementOfCollectionByClass(node, collection, matches) {
    if (node.className !== '') {
        for (var i = 0; i < collection.length; i++) {
            var element = collection[i];
            if (getNormalizeString(element.className) === node.className)
                break;
        }
    }
    checkNodeMatches(matches, node, element);
    return element;
}

function getElementOfCollectionByName(node, collection, matches) {
    if (node.name !== '') {
        for (var i = 0; i < collection.length; i++) {
            var element = collection[i];
            if (element.getAttribute('name') === node.name)
                break;
        }
    }
    checkNodeMatches(matches, node, element);
    return element;
}

function getElementByRuleNode(node, collection, keepSearch) {
    var matches = {
        isIDMatch: false,
        isClassMatch: false,
        isNameMatch: false
    };
    // find element by index (default)
    var element = getElementOfCollectionByIndex(node, collection, matches);

    if (keepSearch) {
        // find element by ID
        if (element === undefined || !(matches.isIDMatch)) {
            var matchElement = getElementOfCollectionByID(node, collection, matches);
            if (matchElement !== undefined)
                element = matchElement;
        }

        // find element by class
        if (element === undefined || (!(matches.isClassMatch) && (node.tagID === ""))) {
            matchElement = getElementOfCollectionByClass(node, collection, matches);
            if (matchElement !== undefined)
                element = matchElement;
        }

        // find element by name
        if (element === undefined) {
            matchElement = getElementOfCollectionByName(node, collection, matches);
            if (matchElement !== undefined)
                element = matchElement;
        }
    }
    return element;
}

function getCollectionByTag(element, tag) {
    var collection = [];
    for (var i = 0; i < element.children.length; i++) {
        if (element.children[i].tagName === tag)
            collection.push(element.children[i]);
    }
    return collection;
}

function parseDOMbyGroup(group) {

    var element = document;
    var resultsFromElements = [];
    var returnObj = {};

    // Step down to DOM Tree - Get Container Collection
    group.nodes.forEach(function (node) {
        if (element != null) {

            var collection = getCollectionByTag(element, node.tag);

            element = getElementByRuleNode(node, collection, true);
            // не найден узел
            //        if (element == null) {
            //            var mainRule = group.rules[0];
            //            resultsFromElements.push([getResultNoElementFind('NoMatchInGroupNodes', mainRule.id, mainRule.critical)]);
            //        }
        }
    });
    //if (element != null) {
    // перебираем правила группы
    //    group.rules.map(function (rule, i) {
    //        var elements = getElementsByNodes(element, rule.nodes);
    //        if (i === 0)
    //            elements.map(function (elem) {
    //                resultsFromElements.push(getElementResults(rule, elem));
    //            });
    //        else
    //            resultsFromElements.map(function (elementResults, j) {
    //               elementResults.concat(getElementResults(rule, elements[j], elementResults[0]));
    //            });
    //});


    //returnObj.result = resultsFromElements;
    //if (group.islast === 1)
    //    returnObj.islast = 1;
    //return JSON.stringify(returnObj);

}

console.log('done');
app.parsedataback(parseDOMbyGroup(group));