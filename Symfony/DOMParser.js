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
    // совпадение ID
    if (node.tagID === undefined)
        node.tagID = '';
    if (element.id === node.tagID)
        matches.isIDMatch = true;
    // совпадение class
    if (node.className === undefined)
        node.className = '';
    if (getNormalizeString(element.className) === node.className)
        matches.isClassMatch = true;
    // совпадение name
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

function processRegExps(element, regexps, firstGroupResult) {

    var matches = [];
    var Text = element.innerText;
    var HTML = element.innerHTML;

    regexps.forEach(function (regexp) {

        if (regexp.type === 1) {
            matches = HTML.match(regexp.regexp);
            if (matches == null || firstGroupResult.noresult != null)
                matches = null;
        }
        if (regexp.type === 4) {
            matches = Text.match(regexp.regexp);
        }
        if (regexp.type === 5) {
            var re = new RegExp(regexp.regexp, "g");
            matches[0] = Text.replace(re, "");
        }
    });

    return matches;
}

function getElementByRuleNode(node, collection, keepSearch) {
    var matches = {
        isIDMatch: false,
        isClassMatch: false,
        isNameMatch: false
    };
    // элемент по индексу (по умолчанию)
    var element = getElementOfCollectionByIndex(node, collection, matches);
    if (keepSearch) {
        // приоритет атрибута "ID"
        if (element === undefined || !(matches.isIDMatch)) {
            var matchElement = getElementOfCollectionByID(node, collection, matches);
            if (matchElement !== undefined)
                element = matchElement;
        }

        // приоритет атрибута "class"
        if (element === undefined || (!(matches.isClassMatch) && (node.tagID === ""))) {
            matchElement = getElementOfCollectionByClass(node, collection, matches);
            if (matchElement !== undefined)
                element = matchElement;
        }

        // приоритет атрибута "name"
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

function getElementsByNodes(baseElement, nodes) {
    // перебираем узлы внутри контейнера
    var elements = [baseElement];
    nodes.map(function (node) {

        // перебираем совпавшие элементы
        var matchElements = [];
        elements.map(function (element) {

            var collection = getCollectionByTag(element, node.tag);
            // перебираем все дочерние узлы по тегу - ищем новое совпадение
            collection.map(function (child, i) {

                // ищем элемент
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

function getElementResults(rule, elem, firstGroupResult) {

    if (elem == null)
        return [getResultNoElementFind('NoMatchInRuleNodes', rule.id, rule.critical)];

    // обработка RegExps
    if (rule.regexps.length > 0) {
        var matches = processRegExps(elem, rule.regexps, firstGroupResult);
        if (matches == null)
            return [getResultNoElementFind('NoMatchInRegExps', rule.id, rule.critical)];
    }

    // пользовательская обработка
    if (rule.custom_func !== undefined)
        elem = customFuncs[rule.custom_func](elem);

    if 
    
    
    var elementResults = [];
    if (matches == null) {
        matches[0] = elem.href;
        matches[0] = elem.innerText;
        matches[0] = elem.innerHTML;
    }

    matches.forEach(function (value) {
        var elemRes = {};
        elemRes.id = rule.id;

        // ссылки
        if (rule.level != null) {
            elemRes.level = rule.level;
            elemRes.href = value;
        }

        // записи
        if (rule.key != null) {
            elemRes.key = rule.key;
            elemRes.value = value;
        }

        elementResults.push(elemRes);
    });

    // записи
    if (rule.key != null) {
        if (resText != '')
            var value = resText;
        else
            value = elem.innerText;
        if (rule.typeid === 1)
            return {
                id: rule.id,
                key: rule.key,
                value: value
            };

        if (rule.typeid === 2)
            return {
                id: rule.id,
                key: rule.key,
                value: elem.innerHTML
            };
    }
}

function getResultNoElementFind(message, ruleid, critical) {
    return {
        id: ruleid,
        noresult: message,
        critical: critical
    };
}

function getDataFromDOMbyGroup(group) {
    var element = document;
    var resultsFromElements = [];
    var returnObj = {};
    // получаем коллекцию - контейнер спускаясь по дереву DOM
    group.nodes.forEach(function (node) {

        if (element != null) {
            // коллекция узлов по тегу
            var collection = getCollectionByTag(element, node.tag);
            // выбор узла 
            element = getElementByRuleNode(node, collection, true);
            // не найден узел
            if (element == null) {
                var mainRule = group.rules[0];
                result.push([getResultNoElementFind('NoMatchInGroupNodes', mainRule.id, mainRule.critical)]);
            }
        }

    });
    if (element != null) {
        // перебираем правила группы
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

    returnObj.result = result;
    if (group.islast === 1)
        returnObj.islast = 1;
    return JSON.stringify(returnObj);
}

app.databack(getDataFromDOMbyGroup(group));