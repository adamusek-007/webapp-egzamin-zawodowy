$(document).ready(function () {
  $("#form").on("submit", function (event) {
    event.preventDefault();

    var allFieldsFilled = validateIncomingData();

    if (allFieldsFilled) {
      var formData = new FormData(this);
      makeAjaxRequest(formData);
    } else {
      alert("Please fill out all required fields before submitting.");
    }
  })
});

function makeAjaxRequest(formData) {
  $.ajax({
    type: "POST",
    url: "s-insert-questions.php",
    data: formData,
    processData: false,
    contentType: false,
    success: function (response) {
      if (response == 0)  {
        $("#form")[0].reset();
      } else {
        alert(response);
        console.log(response);
      }
    },
    error: function (error) {
      console.log("AJAX request error:");
      console.log(error);
    }
  });
}

function validateIncomingData() {
  var allFieldsFilled = true;
  
  $(document).find("textarea").each(function () {
    if ($(this).val() == "") {
      allFieldsFilled = false;
      return false;
    }
  });

  return allFieldsFilled;
}