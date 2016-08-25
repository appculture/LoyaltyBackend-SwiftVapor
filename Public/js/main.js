jQuery(document).ready(function($) {

    // configure active navigation item
    $('ul.nav > li > a[href="' + document.location.pathname + '"]').parent().addClass('active');
    
    // make table rows clickable           
    $(".clickable-row").click(function() {
        window.document.location = $(this).data("href");
    });

    // make table rows selectable
    $('.selectable-row').click(function(event) {
    	if (event.target.type !== 'checkbox') {
      		$(':checkbox', this).trigger('click');
    	}
	});

    // client side validation to allow only numbers in textfield
    $(".numberField").keydown(function (e) {
        // Allow: backspace, delete, tab, escape, enter and .
        if ($.inArray(e.keyCode, [46, 8, 9, 27, 13, 110, 190]) !== -1 ||
            // Allow: Ctrl+A, Command+A
            (e.keyCode === 65 && (e.ctrlKey === true || e.metaKey === true)) || 
            // Allow: Ctrl+C, Command+C
            (e.keyCode === 67 && (e.ctrlKey === true || e.metaKey === true)) || 
            // Allow: Ctrl+X, Command+X
            (e.keyCode === 88 && (e.ctrlKey === true || e.metaKey === true)) || 
             // Allow: home, end, left, right, down, up
            (e.keyCode >= 35 && e.keyCode <= 40)) {
                // let it happen, don't do anything
                return;
        }
        // Ensure that it is a number and stop the keypress
        if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
            e.preventDefault();
        }
    });
                       
});

function makePurchase() {
	var amount = document.getElementById('purchaseAmount').value;

	if (amount > 0) {
		$("#purchaseErrorAlert").hide();
		$("#purchaseSuccessAlert").show("slow", function() {
    		document.getElementById('purchaseForm').submit();
  		});
	} else {
		$("#purchaseSuccessAlert").hide();
		$("#purchaseErrorAlert").show("fast");
	}
}
