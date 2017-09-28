// выбираем элемент
var target = document.body;
 
// создаем экземпл€р наблюдател€
var observer = new MutationObserver(function(mutations) {
    mutations.forEach(function(mutation) {
        console.log(mutation.type);
    });    
});
 
// настраиваем наблюдатель
var config = { attributes: true, childList: true, characterData: true, subtree: true };
 
// передаем элемент и настройки в наблюдатель
console.log('DOMObserver begin');
observer.observe(target, config);
 
// позже можно остановить наблюдение
//observer.disconnect();


