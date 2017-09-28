// �������� �������
var target = document.body;
 
// ������� ��������� �����������
var observer = new MutationObserver(function(mutations) {
    mutations.forEach(function(mutation) {
        console.log(mutation.type);
    });    
});
 
// ����������� �����������
var config = { attributes: true, childList: true, characterData: true, subtree: true };
 
// �������� ������� � ��������� � �����������
console.log('DOMObserver begin');
observer.observe(target, config);
 
// ����� ����� ���������� ����������
//observer.disconnect();


