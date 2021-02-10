function animationEnded(e)
{
    if (e.animationName == 'float-menu-in')
        $('#float-menu').css('transform', 'translateX(0%)');
    else
    {
        $('#float-menu').css('transform', 'translateX(110%)');
        $('#float-menu').css('display', 'none');
    }
}

function showFloatMenu()
{
    var floatMenu = $('#float-menu');
    floatMenu.css('display', '');
    floatMenu.css('transform', 'translateX(110%)');
    floatMenu.css('animation', 'float-menu-in 1s');
}

function hideFloatMenu()
{
    var floatMenu = $('#float-menu');
    if (floatMenu.css('display') != 'none')
        floatMenu.css('animation', 'float-menu-out 1s');
}

$(document).ready(function () {
    var floatMenu = document.getElementById('float-menu');
    floatMenu.addEventListener('webkitAnimationEnd', animationEnded);
    floatMenu.addEventListener('animationend', animationEnded);

    $('#btnShowMenu').click(function (e) {
        e.stopPropagation();
        e.preventDefault();
        showFloatMenu();
    });

    $('#btnHideMenu').click(function (e) {
        e.stopPropagation();
        e.preventDefault();
        hideFloatMenu();
    });

    $(document).click(function (e) {
        // e.stopPropagation();
        // e.preventDefault();
        hideFloatMenu();
    })
})
