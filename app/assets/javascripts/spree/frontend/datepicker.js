//= require jquery-ui/widgets/datepicker

$(function() {
  $('.datepicker').datepicker({
    dateFormat: "dd-mm-yy",
    minDate: new Date()
  });
});
