var collapsibles = document.getElementsByClassName("collapsible-header");
var i;

// add event listener to collapsible headers to make the content show or disappear
for (i = 0; i < collapsibles.length; i++) {
  collapsibles[i].addEventListener("click", function() {
    this.classList.toggle("collapsible-active");
    var content = this.nextElementSibling;
    if (content.style.display === "block") {
      content.style.display = "none";
    } else {
      content.style.display = "block";
    }
  });
};

// flip content to initially being hidden (if users do not have JavaScript enabled, the content is shown)
for (i = 0; i < collapsibles.length; i++) {
  collapsibles[i].nextElementSibling.style.display = "none";
};

