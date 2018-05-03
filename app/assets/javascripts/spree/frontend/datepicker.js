if (Spree.version < 3.3) {
  //= require jquery-ui/datepicker
} else {
  //= require jquery-ui/widgets/datepicker
}

$(function() {
  $('.datepicker').datepicker({
    dateFormat: "dd-mm-yy",
    minDate: new Date()
  });
});
