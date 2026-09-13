(function () {
  function buildSupportEmail() {
    var user = [68, 101, 118].map(function (c) {
      return String.fromCharCode(c);
    }).join("");
    var host = [
      112, 97, 108, 108, 97, 100, 105, 117, 109, 99, 111, 109, 112, 97, 115, 115, 46, 99, 111, 109,
    ].map(function (c) {
      return String.fromCharCode(c);
    }).join("");
    return user + "@" + host;
  }

  function setupYear() {
    var year = document.getElementById("year");
    if (year) {
      year.textContent = new Date().getFullYear();
    }
  }

  function setupEmailReveal() {
    var button = document.getElementById("reveal-email");
    var display = document.getElementById("email-display");
    if (!button || !display) {
      return;
    }

    button.addEventListener("click", function () {
      var email = buildSupportEmail();
      display.innerHTML = "";
      var link = document.createElement("a");
      link.href = "mailto:" + email;
      link.textContent = email;
      display.appendChild(link);
      display.hidden = false;
      button.hidden = true;
    });
  }

  setupYear();
  setupEmailReveal();
})();
