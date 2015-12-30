$(document).on("page:change", function() {
  Dashboard = function() {
  };

  $('button#split-vertically').on('click', function(event) {
    alert("Split Vertically");
  });

  $('button#split-horizontally').on('click', function(event) {
    alert("Split Horizontally");
  });
});
