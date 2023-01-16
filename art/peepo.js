function SVGAnimFrames(elm, tobefound, repeat, frametime, delay) {
  var counter = 0;
  //   var detectFrame = parseInt(
  //     document.querySelectorAll(elm + " " + tobefound).length
  //   );
  var totalFrames = parseInt(
    document.querySelectorAll(elm + " " + tobefound).length
  );
  function killAnim() {
    counter = 0;
    detectFrame = 0;
    clearInterval(window._1);
  }
  function restartSVGAnim() {
    killAnim();
    _1 = setInterval(animateSVGFrames, frametime);
  }
  function animateSVGFrames() {
    var detectFrame = counter++;
    for (var i = 0; i < totalFrames; i += 1) {
      if (counter > totalFrames) {
        return false;
      }
      document.querySelectorAll(elm + " " + tobefound)[i].style.display =
        "none";
      document.querySelectorAll(elm + " " + tobefound)[
        detectFrame
      ].style.display = "block";
    }
    if (repeat === "no-repeat") {
      if (counter === totalFrames) {
        for (var i = 0; i < totalFrames; i += 1) {
          if (counter > totalFrames) {
            clearInterval(window._1);
            counter = 0;
            var detectFrame = totalFrames;
            return false;
          }
          document.querySelectorAll(elm + " " + tobefound)[i].style.display =
            "none";
          document.querySelectorAll(elm + " " + tobefound)[
            detectFrame
          ].style.display = "block";
        }
      }
    } else {
      if (counter === totalFrames) {
        setTimeout(function () {
          restartSVGAnim();
        }, delay);
      } else if (detectFrame >= totalFrames) {
        setTimeout(function () {
          restartSVGAnim();
        }, delay);
      }
    }
  }
  window._1 = setInterval(animateSVGFrames, frametime);
  return false;
}
SVGAnimFrames("", ".f", "repeat", 150 * Math.random(), 0);
