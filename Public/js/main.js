jQuery(document).ready(function($) {

    // configure active navigation item
    $('ul.nav > li > a[href="' + document.location.pathname + '"]').parent().addClass('active');
    
    // make table rows clickable           
    $(".clickable-row").click(function() {
        window.document.location = $(this).data("href");
    });
                       
});
