$(document).ready(function() {
  $("#interpret_container .protection_input").click(function() {
    $(this).parent().toggleClass("protected");
  });
  /* Activating Best In Place */
  $("#interpret_container .best_in_place").best_in_place()
});
