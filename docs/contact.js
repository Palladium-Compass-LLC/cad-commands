(function () {
  // Sign up free at https://formspree.io, create a form, then paste your form ID here.
  const FORMSPREE_FORM_ID = "";

  function buildSupportEmail() {
    const user = [68, 101, 118].map(function (c) {
      return String.fromCharCode(c);
    }).join("");
    const host = [
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

  function setupContactForm() {
    var form = document.getElementById("contact-form");
    var status = document.getElementById("form-status");
    if (!form || !status) {
      return;
    }

    form.addEventListener("submit", async function (event) {
      event.preventDefault();

      if (!FORMSPREE_FORM_ID) {
        status.textContent = "Use the button below to reveal our email address, or try again later.";
        return;
      }

      var submitButton = form.querySelector('button[type="submit"]');
      submitButton.disabled = true;
      status.textContent = "Sending…";

      try {
        var response = await fetch("https://formspree.io/f/" + FORMSPREE_FORM_ID, {
          method: "POST",
          body: new FormData(form),
          headers: {
            Accept: "application/json",
          },
        });

        if (response.ok) {
          form.reset();
          status.textContent = "Message sent. We usually respond within a few business days.";
        } else {
          status.textContent = "Could not send your message. Please use the email option below.";
        }
      } catch (error) {
        status.textContent = "Could not send your message. Please use the email option below.";
      } finally {
        submitButton.disabled = false;
      }
    });
  }

  setupYear();
  setupEmailReveal();
  setupContactForm();
})();
