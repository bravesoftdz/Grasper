console.log('domparser');

var income = %s;
var groupCounter = 1;
var skipActions = false;
var designMode = income.design_mode;

if (window.Prototype) {
    delete Object.prototype.toJSON;
    delete Array.prototype.toJSON;
    delete Hash.prototype.toJSON;
    delete String.prototype.toJSON;
}

function getNormalizeString(str) {
    str = str.replace(/\n/g, "");
    str = str.replace(/ {1,}/g, " ");
    return str.trim();
}

function getClassMatch(ruleNode, node) {

    if (ruleNode.className == null)
        ruleNode.className = '';

    if (ruleNode.className == '' && node.className == '')
        return -1;

    var clName = getNormalizeString(ruleNode.className);
    var clArr = clName.split(' ');
    clName = getNormalizeString(node.className);

    var matchCount = 0;
    var i = 0;
    clArr.forEach(function (item) {
        i++;
        var reg = new RegExp(item, 'g');
        if (clName.match(reg) != null)
            matchCount++;
    });

    if (i == matchCount)
        matchCount = 1000;

    return matchCount;
}

function checkNodeMatches(matches, ruleNode, node) {

    if (node === undefined)
        return false;
    
    matches.IDMatch = false;
    matches.ClassMatch = 0;
    matches.NameMatch = false;

    // ID match
    if (ruleNode.tagID === undefined)
        ruleNode.tagID = '';
    if (ruleNode.tagID === node.id)
        matches.IDMatch = true;

    // class match (matches count, -1 class name is empty, 1000 full match)
    matches.ClassMatch = getClassMatch(ruleNode, node);

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

    if (ruleNode.className !== '') {

        var maxCount = 0;
        var indx = 0;
        for (var i = 0; i < tagCollection.length; i++) {
            var node = tagCollection[i];

            var matchesCount = getClassMatch(ruleNode, node);
            if (matchesCount > maxCount) {
                maxCount = matchesCount;
                indx = i;
            }
        }

        if (maxCount > 0)
            var resultNode = tagCollection[indx];
    }

    checkNodeMatches(matches, ruleNode, resultNode);

    return resultNode;
}

function getNodeByID(ruleNode, tagCollection, matches) {

    if (ruleNode.tagID !== "") {

        for (var i = 0; i < tagCollection.length; i++) {

            if (tagCollection[i].id === ruleNode.tagID) {
                var node = tagCollection[i];
                break;
            }

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

function getNodeByRuleNode(ruleNode, tagCollection, keepSearch, isStrict) {

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
        if (node == null
                || ((matches.ClassMatch != 1000)
                        && (matches.ClassMatch != -1)
                        && (ruleNode.tagID === ""))) {
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

        // check strict search
        if (isStrict) {

            if (!(matches.IDMatch && matches.ClassMatch == 1000 && matches.NameMatch))
                node = null;

        }
    }

    if (designMode)
        setPIAMarks(node, ruleNode.id);

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

function processIgnoreRegExps(source, node, regexps) {

    var isIgnore = false;

    regexps.forEach(function (regex) {

        // ignore if match
        if (regex.type == 3) {

            var reg = new RegExp(regex.regexp, 'g');
            var matches = source.match(reg);

            if (matches != null)
                isIgnore = true;

        }

        // ignore if not match
        if (regex.type == 4) {

            var reg = new RegExp(regex.regexp, 'g');
            var matches = source.match(reg);

            if (matches == null)
                isIgnore = true;

        }

    });

    if (isIgnore)
        setPIAIgnore(node);

}

function processRegExps(content, regexps) {

    var results = [];
    var hasRegExp = false;

    // type 1 - matches
    regexps.forEach(function (regex) {

        if (regex.type == 1) {

            hasRegExp = true;
            var reg = new RegExp(regex.regexp, 'g');
            var matches = content.match(reg);

            if (matches != null)
                matches.forEach(function (match) {
                    results.push(match);
                });
        }
    });
    if (!hasRegExp && content != null)
        results = [content];

    // type 2 - replaces
    regexps.forEach(function (regex) {

        if (regex.type == 2) {

            var replacedResults = results.map(function (result) {

                var reg = new RegExp(regex.regexp, 'g');
                return result.replace(reg, regex.replace);

            });

            results = replacedResults;
        }

    });

    return results;
}

function processResultNodesByRule(rule, resultNodes, groupNum, parentGroupNum) {

    var result = [];

    resultNodes.forEach(function (node) {

        if (rule.source_type == 1)
            var source = node.innerText;
        else
            source = node.innerHTML;

        // process ignore RegExps
        processIgnoreRegExps(source, node, rule.regexps);

        //check parent and self ignores     
        var ignoreNodes = $(node).closest('.PIAIgnore');
        if (ignoreNodes.length > 0) 
            return result;
        
        // take off child ignores
        $('.PIAIgnore', node).css('display', 'none');

        // case text grab
        if (rule.grab_type == 1)
            var content = node.innerText;

        // case HTML grab
        if (rule.grab_type == 2)
            content = node.innerHTML;

        // case href attr grab
        if (rule.grab_type == 4)
            content = $('a', node).attr('href');

        // case value attr grab
        if (rule.grab_type == 5)
            content = $(node).attr('value');

        // links
        if (rule.type == 'link')
            content = node.href;

        // take back child ignores
        $('.PIAIgnore', node).css('display', '');
        $('.PIAIgnore', node).removeClass('PIAIgnore');
        
        //process matches and replaces regexps
        var RegExpResults = processRegExps(content, rule.regexps);

        RegExpResults.forEach(function (matchText) {

            var objRes = {};
            objRes.rule_id = rule.id;
            objRes.group = groupNum;
            objRes.parent_group = parentGroupNum;

            if (rule.type == 'link') {
                objRes.type = 'link';
                objRes.href = matchText;
                objRes.level = rule.level;
            }

            if (rule.type == 'record') {
                objRes.type = 'record';
                objRes.key = rule.key;
                objRes.value = matchText;
            }

            result.push(objRes);
        });

    });

    return result;
}

function processActionsByRule(rule, resultNodes) {

    if (skipActions)
        return false;

    if (rule.type == 'action') {

        resultNodes.forEach(function (node) {

            if (rule.delay > 0)
                $(node).delay(rule.delay);

            if (rule.act_type == 1)
                $(node)[0].click();

            if (rule.act_type == 2)
                $(node).attr('value', rule.fill);

            if (rule.act_type == 3)
                $(node).mouseover();

        });

    }

}

function processRequestsByRule(rule, resultNodes) {

    if (rule.request == null)
        return false;

    resultNodes.forEach(function (node) {

        var observer = new MutationObserver(function (mutations) {

            app.observerevent(String(rule.id));

            mutations.forEach(function (mutation) {
                console.log(mutation.type);
            });

        });

        var config = {childList: true, characterData: true, subtree: true};
        console.log('Observer begin');
        observer.observe(node, config);

    });
}

function setPIAMarks(node, ruleNodeid) {

    $(node).attr('data-pia-rule-node-id', ruleNodeid);

}

function clearPIAMarksAndColor() {

    var nodes = $('[data-pia-rule-node-id!=0]');
    $(nodes).attr('data-pia-rule-node-id', 0);


    nodes = $('[data-pia-rule-colored=1]');
    $(nodes).css('background-color', '');
    $(nodes).attr('data-pia-rule-colored', 0);
}

function setPIAIgnore(node) {
    $(node).addClass('PIAIgnore');
}

function setPIAColor(rule, node) {

    $(node).attr('data-pia-rule-colored', 1);
    $(node).css('background-color', rule.color);

    var nodes = $(node).find('*');
    $(nodes).attr('data-pia-rule-colored', 1);
    $(nodes).css('background-color', rule.color);

}

function getRuleResult(rule, containerNode, groupNum, parentGroupNum) {

    // special rules
    if (rule.grab_type == 3) {
        return [{
                rule_id: rule.id,
                group: groupNum,
                parent_group: 0,
                type: 'record',
                key: rule.key,
                value: document.URL
            }];
    }

    var containerSize = rule.nodes.length - rule.container_offset;
    for (var i = 0; i < containerSize; i++) {

        var ruleNode = rule.nodes[i];
        var tagCollection = getTagCollection(containerNode, ruleNode);
        containerNode = getNodeByRuleNode(ruleNode, tagCollection, true, (rule.is_strict && i == containerSize - 1));

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

    processActionsByRule(rule, resultNodes);
    processRequestsByRule(rule, resultNodes);

    var result = [];
    
    resultNodes.forEach(function (node) {

        if (rule.type == 'cut')
            setPIAIgnore(node);

        // set PIA color to result nodes
        if (designMode)
            setPIAColor(rule, node);

        if (rule.rules != null) {

            groupCounter++;
            var newGroupNum = groupCounter; 
            rule.rules.forEach(function (rule) {
                result = result.concat(getRuleResult(rule, node, newGroupNum, groupNum));
            });

        }

    });

    var currResult = processResultNodesByRule(rule, resultNodes, groupNum, parentGroupNum);
    result = result.concat(currResult);
    
    return result;
}

function processDOM(income) {

    var objResult = {result: []};

    if (income.skip_actions != null)
        skipActions = income.skip_actions;

    if (income.request_id != null)
        objResult.request_id = income.request_id;

    if (income.link_id != null)
        objResult.link_id = income.link_id;

    groupCounter = 1; 

    income.rules.forEach(function (rule) {

        var objRuleResult = getRuleResult(rule, document, groupCounter, 0);
        objResult.result = objResult.result.concat(objRuleResult);

    });

    
 if (JSON.stringify === undefined) {
	if (JSON.encode != null) JSON.stringify = JSON.encode;
 }

   return JSON.stringify(objResult);
}

$(function () {

    // clear previous selection
    if (designMode)
        clearPIAMarksAndColor();

    app.parsedataback(processDOM(income));

    console.log('done');

});
