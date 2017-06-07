
var group = %s;

function getElementResults(rule, elem, firstGroupResult) {
    
    if (elem == null)
        return [getResultNoElementFind('NoMatchInRuleNodes', rule.id, rule.critical)];

    $(elem).wrapAll('<b class="PIAColor"></b>');
    $('.PIAColor').css('background', rule.color);  
    
    // пользовательская обработка
    //if (rule.custom_func !== undefined)
    //    elem = customFuncs[rule.custom_func](elem);

    // тип контента
    //if (rule.typeid === 1)
    //    var content = elem.innerText;
    //if (rule.typeid === 2 || rule.typeid == null)
    //    content = elem.innerHTML;}

    // обработка RegExps
    //if (rule.regexps.length > 0) {
    //    var checkOnly = false;
    //    var matches = processRegExps(content, rule.regexps, firstGroupResult, checkOnly);
    //    if (matches == null)
    //        return [getResultNoElementFind('NoMatchInRegExps', rule.id, rule.critical)];
    //}

    /*
    // Links
    if (rule.level != null)
        var islink = true;
    // Records
    if (rule.key != null)
        var isrecord = true;

    var elementResults = [];
    if (matches == null || checkOnly) {
        matches = [];
        if (islink)
            matches.push(elem.href);
        if (isrecord)
            matches.push(content);
    }

    matches.forEach(function (value) {
        var elemRes = {};
        elemRes.id = rule.id;

        if (islink) {
            elemRes.level = rule.level;
            elemRes.href = value;
        }

        if (isrecord) {
            elemRes.key = rule.key;
            elemRes.value = value;
        }

        elementResults.push(elemRes);
    });

    return elementResults; */
}

function getElementsByNodes(baseElement, nodes) {
    var elements = [baseElement];
    // List Each Node inside Base Element
    nodes.map(function (node) {
        var matchElements = [];
        
        elements.map(function (element) {
            var collection = getCollectionByTag(element, node.tag);
            // List Each Child Nodes - Search For Matching
            collection.map(function (child, i) {
                // Search Element
                node.index = i + 1;
                element = getElementByRuleNode(node, collection, false);
                if (element === undefined)
                    matchElements.push(null);
                else
                    matchElements.push(element);
            });  
        });
        
        elements = matchElements;
    });
    return elements;
}

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
    
    // Step down to DOM Tree - Get Rule Collection  
    if (element != null) {
        group.rules.map(function (rule, i) {
            var elements = getElementsByNodes(element, rule.nodes);
            if (i === 0)
                elements.map(function (elem) {
                    resultsFromElements.push(getElementResults(rule, elem));
                });
            else
                resultsFromElements.map(function (elementResults, j) {
                   elementResults.concat(getElementResults(rule, elements[j], elementResults[0]));
                });
        });
    }

    returnObj.result = resultsFromElements;
    //if (group.islast === 1)
    //    returnObj.islast = 1;
    return JSON.stringify(returnObj);

}

var t = $('.PIAColor').children().first();
$(t).unwrap();
        
app.parsedataback(parseDOMbyGroup(group));
console.log('done');