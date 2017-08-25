console.log('domparser');

var level = %s;

function parseDOMbyLevel(level) {

    level.rules.forEach(function (rule) {
        alert(rule.id);
    });

}

app.parsedataback(parseDOMbyLevel(level));

console.log('done');