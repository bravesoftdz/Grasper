$(document).ready(function () {

    var groups = [];

    // выбор уровня
    $('#levels a').click(function (e) {

        e.preventDefault()
        var url = '/groups/' + $(e.target).data("levelid");
        jQuery.getJSON(url, function (resJSON) {

            $("#groups").text("");
            groups = resJSON.groups;

            groups.forEach(function (group) {
                $("#groups").append('<tr><td><a href="#" data-groupid="' + group.id + '">' + group.notes + '</a></td></tr>');
            });
            $("#groups a").on('click', onGroupClick);
        });
    });

    // поиск группы по id
    function seekGroupByID(groups, ID) {
        for (var i = 0; i < groups.length; i++) {
            if (groups[i].id == ID)
                return groups[i];
        }
    }

    // выбор группы
    function onGroupClick(e) {

        e.preventDefault();
        $("#rules").text("");
        var group = seekGroupByID(groups, $(this).data("groupid"));

        group.rules.forEach(function (rule) {
            var rulesHTML = '<tr>';
            rulesHTML += '<tr><td>' + rule.description + '</td>';
            rulesHTML += '<td>' + rule.containerOffset + '</td>';
            rulesHTML += '<td>' + rule.criticalType + '</td>';
            rulesHTML += '<td>' + rule.record.key + '</td>';
            rulesHTML += '</tr>';

            $("#rules").append(rulesHTML);
        });
    }
});