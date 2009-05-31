// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function toggle_arrow(label) {
  var e = document.getElementById(label);
  if (e.style.display != "none") {
    document.getElementById("arrow_" + label).outerHTML = "<img src='images/right_arrow.gif' width='9' height='11' id='arrow_" + label + "' border='0' />";
    e.hide();
  } else {
    document.getElementById("arrow_" + label).outerHTML = "<img src='images/down_arrow.gif' width='9' height='11' id='arrow_" + label + "' border='0' />";
    e.show();
  }
}

function hide_box(){
  Modalbox.hide({transitions:true});
  return false;
}