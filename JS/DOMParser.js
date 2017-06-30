
var group = %s;
group.rules.sort(function (a, b) {
    if (a.cut === true)
        return -1;
    else
        return 1;
});

function getElementResults(rule, elem, firstGroupResult) {

    if (elem == null)
        return [getResultNoElementFind('NoMatchInRuleNodes', rule.id, rule.critical)];

    // paint selected elements
    $(elem).addClass('PIAColor');
    $(elem).css('background-color', rule.color);
    $('.PIAColor').children().css('background-color', 'inherit');

    ////////////////////////////////////////////////////////////////////////////
    var matches = [];

    if (rule.level != null) {
        
        if (rule.level == 3){
            var eng = elem.innerText.match(/^English$/g);
            if (eng != null) matches.push(elem.href); 
        }
        else
            matches.push(elem.href);
        var islink = true;
    }
    if (rule.key != null) {
        var content = elem.innerText;

        /////Temp RegExp////////////////////////////////////////////////////////
        content = content.replace(/\[.*\]/g, "");
        content = content.replace(/\nПримечания(.|\s)*/g, "");
        content = content.replace(/\nСсылки(.|\s)*/g, "");
        
        content = content.replace(/\nSee else(.|\s)*/g, "");
        content = content.replace(/\nReferences(.|\s)*/g, "");
        content = content.replace(/\nExternal links(.|\s)*/g, "");
        ////////////////////////////////////////////////////////////////////////

        matches.push(content);
        var isrecord = true;
    }
    //////////////////////////////////////////////////////////////////////////// 


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
     
     if (matches == null || checkOnly) {
     matches = [];
     if (islink)
     matches.push(elem.href);
     if (isrecord)
     matches.push(content);
     }*/

    //var matches = [];
    //matches.push(content);

    var elementResults = [];
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

    return elementResults;
}

function getElementsByNodes(baseElement, nodes, strict) {
    var elements = [baseElement];
    // list each node inside base element
    nodes.map(function (node) {
        var matchElements = [];

        elements.map(function (element) {
            var collection = getCollectionByTag(element, node.tag);

            if (strict) {
                element = getElementByRuleNode(node, collection, true);
                if (element != null)
                    matchElements.push(element);
            } else {
                // list each child nodes - search for matching
                collection.map(function (child, i) {
                    // search element
                    node.index = i + 1;
                    element = getElementByRuleNode(node, collection, false);
                    if (element === undefined)
                        matchElements.push(null);
                    else
                        matchElements.push(element);
                });
            }          
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

    // step down to DOM tree - get container collection
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

    // step down to DOM tree - get rule collection  
    if (element != null) {

        var rcount = 0;
        group.rules.map(function (rule) {

            if (rule.cut) {
                var elements = getElementsByNodes(element, rule.nodes, rule.strict);

                if (elements != null) { 
                    $(elements).addClass('PIAHide');
                    $('.PIAHide').css('display', 'none');
                }
            } else {
                elements = getElementsByNodes(element, rule.nodes, false);

                rcount++;
                if (rcount === 1)
                    elements.map(function (elem) {
                        resultsFromElements.push(getElementResults(rule, elem));
                    });
                else
                    resultsFromElements.map(function (elementResults, j) {
                        elementResults.concat(getElementResults(rule, elements[j], elementResults[0]));
                    });
            }
        });
    }

    returnObj.result = resultsFromElements;
    if (group.islast === 1)
        returnObj.islast = 1;
    return JSON.stringify(returnObj);

}

// clear previous selection
var paintedElements = $('.PIAColor');
paintedElements.css('background-color', '');
paintedElements.removeClass('PIAColor');

// clear previous hidding 
var hiddenElements = $('.PIAHide');
hiddenElements.css('display', '');
hiddenElements.removeClass('PIAHide');

app.parsedataback(parseDOMbyGroup(group));
console.log('done');