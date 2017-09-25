console.log('domparser');

var level = %s;
var groupNum = 1;

function getNormalizeString(str) {
    str = str.replace(/\n/g, "");
    str = str.replace(/ {1,}/g, " ");
    return str.trim(str);
}

function checkClassMatch(ruleNode, node) {

    if (ruleNode.className == null)
        ruleNode.className = '';

    var clName = ruleNode.className.toString();
    var clArr = clName.split(' ');
    clName = getNormalizeString(node.className);

    var isMatch = false;
    clArr.forEach(function (item) {
        var reg = new RegExp(item, 'g');
        if (clName.match(reg) != null)
            isMatch = true;
    });

    return isMatch;
}

function checkNodeMatches(matches, ruleNode, node) {

    matches.IDMatch = false;
    matches.ClassMatch = false;
    matches.NameMatch = false;

    if (node === undefined)
        return false;

    // ID match
    if (ruleNode.tagID === undefined)
        ruleNode.tagID = '';
    if (ruleNode.tagID === node.id)
        matches.IDMatch = true;

    // class match (true even one class name matched)
    if (checkClassMatch(ruleNode, node))
        matches.ClassMatch = true;

    // name match
    if (ruleNode.name === undefined)
        ruleNode.name = null;
    if (ruleNode.name === node.getAttribute('name'))
        matches.NameMatch = true;
}

function getNodeByName(ruleNode, tagCollection, matches) {

    if (ruleNode.name !== "") {
        for (var i = 0; i < tagCollection.length; i++) {
            var node = tagCollection[i];
            if (node.getAttribute('name') === ruleNode.name)
                break;
        }
    }

    checkNodeMatches(matches, ruleNode, node);

    return node;
}

function getNodeByClass(ruleNode, tagCollection, matches) {

    if (ruleNode.className !== "") {
        for (var i = 0; i < tagCollection.length; i++) {
            var node = tagCollection[i];

            if (checkClassMatch(ruleNode, node))
                break;
        }
    }

    checkNodeMatches(matches, ruleNode, node);

    return node;
}

function getNodeByID(ruleNode, tagCollection, matches) {

    if (ruleNode.tagID !== "") {
        for (var i = 0; i < tagCollection.length; i++) {
            var node = tagCollection[i];
            if (node.id === ruleNode.tagID)
                break;
        }
    }

    checkNodeMatches(matches, ruleNode, node);

    return node;
}

function getNodeByIndex(ruleNode, tagCollection, matches) {

    var node = tagCollection[ruleNode.index - 1];

    checkNodeMatches(matches, ruleNode, node);

    return node;
}

function getNodeByRuleNode(ruleNode, tagCollection, keepSearch) {

    var matches = {};

    // find node by index (default)
    var node = getNodeByIndex(ruleNode, tagCollection, matches);

    if (keepSearch) {
        // find node by ID
        if (node == null || !(matches.IDMatch)) {
            var matchedNode = getNodeByID(ruleNode, tagCollection, matches);
            if (matchedNode != null)
                node = matchedNode;
        }

        // find element by class
        if (node == null || (!(matches.ClassMatch) && (ruleNode.tagID === ""))) {
            matchedNode = getNodeByClass(ruleNode, tagCollection, matches);
            if (matchedNode != null)
                node = matchedNode;
        }

        // find element by name
        if (node == null) {
            matchedNode = getNodeByName(ruleNode, tagCollection, matches);
            if (matchedNode != null)
                node = matchedNode;
        }
    }

    return node;
}

function getTagCollection(node, ruleNode) {

    var collection = [];

    for (var i = 0; i < node.children.length; i++) {
        
        if (node.children[i].tagName === ruleNode.tag)
            collection.push(node.children[i]);
    
    }
    
    return collection;
}

function getInsideContainerNodes(containerNode, ruleNodes) {

    var nodes = [containerNode];

    // list each rule node inside container
    ruleNodes.forEach(function (ruleNode) {

        var matchedNodes = [];

        nodes.forEach(function (node) {

            var tagCollection = getTagCollection(node, ruleNode);

            // list each child nodes - search for matching
            tagCollection.forEach(function (node, i) {
                // search element
                ruleNode.index = i + 1;
                node = getNodeByRuleNode(ruleNode, tagCollection, false);
                if (node != null)
                    matchedNodes.push(node);

            });

        });

        nodes = matchedNodes;
    });

    return nodes;
}

function getContentByRegExps(grabData, rule) {

    var regexps = rule.regexps;
    var results = [];
    var hasRegEx = {
        match: false,
        replace: false,
        ignore: false
    };

    // case text grab
    if (rule.grab_type == 1)
        var sourceText = grabData.innerText;

    // case href grab
    if (rule.grab_type == 2)
        sourceText = grabData.innerText;

    // case html grab
    if (rule.grab_type == 3)
        sourceText = grabData.innerHTML;

    if (sourceText == null)
        sourceText = grabData.innerText;

    // type 3 - ignore
    var isIgnoreExit = false;
    regexps.forEach(function (regex) {

        if (regex.type == 3) {
            hasRegEx.ignore = true;
            var reg = new RegExp(regex.regexp, 'g');
            var matches = sourceText.match(reg);

            if (matches != null)
                isIgnoreExit = true;
        }

    });
    if (isIgnoreExit)
        return results;

    // type 1 - matches
    regexps.forEach(function (regex) {

        if (regex.type == 1) {
            hasRegEx.match = true;
            var reg = new RegExp(regex.regexp, 'g');
            var matches = sourceText.match(reg);

            if (matches != null)
                matches.forEach(function (match) {
                    results.push(match);
                });
        }
    });
    if (!hasRegEx.match)
        results = [sourceText];

    // type 2 - replaces
    regexps.forEach(function (regex) {

        if (regex.type == 2) {
            hasRegEx.replace = true;
            if (regex.replace == null)
                regex.replace = '';

            var replacedResults = results.map(function (result) {
                var reg = new RegExp(regex.regexp, 'g');
                return result.replace(reg, regex.replace);
            });
            results = replacedResults;
        }
    });

    // case href grab
    if (rule.grab_type == 2 && results.length > 0)
        results = [grabData.href];

    return results;
}

function processResultNodesByRule(rule, resultNodes) {
    
    if (rule.type == 'container') return [];
    
    var result = [];

    resultNodes.forEach(function (node) {

        var grabData = {};

        //switch on cuts     
        var ignoreNodes = $('.PIAIgnore', node);
        $(ignoreNodes).css('display', 'none');

        if (node.innerText != null)
            grabData.innerText = node.innerText;
        else
            grabData.innerText = '';

        var href = $('a', node).attr('href'); 
        if (href != null)
            grabData.href = href;
        else
            grabData.href = '';

        if (node.innerHTML != null)
            grabData.innerHTML = node.innerHTML;
        else
            grabData.innerHTML = '';

        //switch off cuts 
        $(ignoreNodes).css('display', '');

        //process grab type and regexps
        var regExResults = getContentByRegExps(grabData, rule);

        regExResults.forEach(function (matchText) {

            var objNodeRes = {};
            objNodeRes.ruleID = rule.id;
            objNodeRes.group = groupNum;

            if (rule.type == 'link') {
                objNodeRes.type = 'link';
                objNodeRes.href = node.href;
                objNodeRes.level = rule.level;
            }

            if (rule.type == 'record') {
                objNodeRes.type = 'record';
                objNodeRes.key = rule.key;
                objNodeRes.value = matchText;
            }

            result.push(objNodeRes);
        });

    });

    return result;
}

function setPIAClass(rule, node) {

    $(node).addClass('PIAColor');
    $(node).css('background-color', rule.color);
    //$('.PIAColor').children().css('background-color', 'inherit'); 

    if (rule.type == 'cut')
        $(node).addClass('PIAIgnore');
}

function getRuleResult(rule, containerNode) {

    var containerSize = rule.nodes.length - rule.container_offset;
    for (var i = 0; i < containerSize; i++) {
        var ruleNode = rule.nodes[i];
        var tagCollection = getTagCollection(containerNode, ruleNode);
        containerNode = getNodeByRuleNode(ruleNode, tagCollection, true);

        if (containerNode == null)
            break;
    }

    if (containerNode != null && containerNode != document) {
        if (rule.container_offset > 0) {

            var insideRuleNodes = [];
            for (i = containerSize; i < rule.nodes.length; i++) {
                insideRuleNodes.push(rule.nodes[i]);
            }

            var resultNodes = getInsideContainerNodes(containerNode, insideRuleNodes);

        } else {
            resultNodes = [containerNode];
        }
    } else
        resultNodes = [];
    
    var result = processResultNodesByRule(rule, resultNodes);
    
    resultNodes.forEach(function (node) {
        // set PIA class to selected elements
        setPIAClass(rule, node);

        if (rule.rules != null) {
            
            groupNum++;
            rule.rules.forEach(function (rule) {
                result = result.concat(getRuleResult(rule, node));
            });
            
        }
        
    });

    return result;
}

function parseDOMbyLevel(level) {

    var objResult = {result: []};

    level.rules.forEach(function (rule) {
        
        var objRuleResult = getRuleResult(rule, document);
        objResult.result = objResult.result.concat(objRuleResult);
        
    });

    return JSON.stringify(objResult);
}

$(function() {

    // clear previous selection
    var paintedElements = $('.PIAColor');
    paintedElements.css('background-color', '');
    paintedElements.removeClass('PIAColor');
    $('.PIAIgnore').removeClass('PIAIgnore');

    app.parsedataback(parseDOMbyLevel(level));

    console.log('done');

});
