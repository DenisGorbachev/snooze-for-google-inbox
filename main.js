// Generated by CoffeeScript 1.10.0
(function() {
  var $body, handleNewLiClick, isDebug, times;

  isDebug = false;

  $body = $(document.body);

  handleNewLiClick = function(time, event) {
    $body.arrive("[jsaction*='show_date_picker'] + div", function() {
      var $currentTd, $targetTd, $tds, cls, dateIncrement, tdsByBackgroundColor;
      dateIncrement = time.getDateIncrement();
      tdsByBackgroundColor = {};
      $("[jsaction*='show_date_picker'] + div tbody td").each(function() {
        var $td, backgroundColor;
        $td = $(this);
        backgroundColor = $td.css("background-color").toString();
        if (!tdsByBackgroundColor[backgroundColor]) {
          tdsByBackgroundColor[backgroundColor] = [];
        }
        return tdsByBackgroundColor[backgroundColor].push($td);
      });
      $currentTd = null;
      for (cls in tdsByBackgroundColor) {
        $tds = tdsByBackgroundColor[cls];
        if ($tds.length === 1) {
          $currentTd = $tds[0];
          break;
        }
      }
      if (!$currentTd) {
        throw "Couldn't find current td";
      }
      $targetTd = $currentTd;
      while (dateIncrement) {
        $targetTd = $targetTd.next();
        if (!$targetTd.length) {
          $targetTd = $currentTd.closest("tr").next().find("td").first();
        }
        dateIncrement--;
      }
      $targetTd.simulate("click");
      return $body.unbindArrive("[jsaction*='show_date_picker'] + div");
    });
    $body.arrive("[jsaction*='show_time_picker'] input[value]", {
      fireOnAttributesModification: true
    }, function() {
      var $button, $divAfterShowTimePicker, $input;
      $input = $(this);
      $button = $input.closest(".top-level-item").find("[jsaction*='date_time_pattern_set']");
      $divAfterShowTimePicker = $input.closest("[jsaction*='show_time_picker']").next();
      $divAfterShowTimePicker.arrive("[role='menuitem']", function() {
        var $menuitem;
        $menuitem = $(this);
        if ($menuitem.find('span').eq(0).text().trim() === time.preset) {
          $menuitem.simulate("mousedown").simulate("mouseup").simulate("click");
          _.defer(function() {
            return $button.simulate("mousedown").simulate("mouseup").simulate("click");
          });
          return $divAfterShowTimePicker.unbindArrive("[role='menuitem']");
        }
      });
      _.defer(function() {
        return $input.simulate("mousedown").simulate("mouseup").simulate("click");
      });
      return $body.unbindArrive("[jsaction*='show_time_picker'] input[value]");
    });
    return $(this).closest(".top-level-item").find("[data-jsaction*='show_date_time_picker']").simulate("mousedown").simulate("mouseup").simulate("click");
  };

  times = [
    {
      name: "Today afternoon",
      preset: "Afternoon",
      getDateIncrement: function() {
        return 0;
      }
    }, {
      name: "Today evening",
      preset: "Evening",
      getDateIncrement: function() {
        return 0;
      }
    }, {
      name: "Tomorrow afternoon",
      preset: "Afternoon",
      getDateIncrement: function() {
        return 1;
      }
    }, {
      name: "Sunday morning",
      preset: "Morning",
      getDateIncrement: function() {
        var Moment;
        Moment = moment().hour(0).minute(0).second(0).day("Sunday");
        if (Moment.toDate().getTime() < Date.now()) {
          Moment.add(7 + 1, "days");
        }
        return Moment.diff(moment(), 'days');
      }
    }, {
      name: "Tuesday afternoon",
      preset: "Afternoon",
      getDateIncrement: function() {
        var Moment;
        Moment = moment().hour(0).minute(0).second(0).day("Tuesday");
        if (Moment.toDate().getTime() < Date.now()) {
          Moment.add(7 + 1, "days");
        }
        return Moment.diff(moment(), 'days');
      }
    }
  ];

  $body.arrive("[data-jsaction*='show_date_time_picker']", function() {
    var $element, $firstExistingLi, $lastLi, $newLi, $section, $sectionContainer, $spans, $ul, firstExistingLiHtml, i, jsinstance, len, time;
    $element = $(this);
    $section = $element.closest("section");
    $sectionContainer = $section.closest("div");
    $sectionContainer.css("max-height", "1000px");
    $sectionContainer.prev("header").remove();
    $ul = $section.prev("section").find("ul").first();
    $firstExistingLi = $ul.find("li").first();
    $sectionContainer.prepend($section);
    firstExistingLiHtml = $firstExistingLi[0].outerHTML;
    for (i = 0, len = times.length; i < len; i++) {
      time = times[i];
      $newLi = $(firstExistingLiHtml);
      $newLi.find().andSelf().each(function(index, el) {
        return $(el).removeAttr("id jsl jsan jsaction jsinstance data-jsaction data-action-data");
      });
      $spans = $newLi.find("span");
      $spans.eq(1).text(time.name);
      $spans.eq(2).text("");
      $newLi.addClass("snooze-element snooze-list-item");
      $newLi.on("click", _.partial(handleNewLiClick, time));
      $ul.append($newLi);
    }
    jsinstance = 0;
    $ul.find("li").each(function() {
      $(this).attr("jsinstance", jsinstance);
      return jsinstance++;
    });
    $lastLi = $ul.find("li").last();
    $lastLi.attr("jsinstance", "*" + $lastLi.attr("jsinstance"));
    if (isDebug) {
      return $newLi.simulate("click");
    }
  });

  if (isDebug) {
    $body.arrive(".top-level-item [jsaction*='toggle_snooze_menu']", function() {
      $(this).simulate("mousedown").simulate("mouseup").simulate("click");
      return $body.unbindArrive(".top-level-item [jsaction*='toggle_snooze_menu']");
    });
    $body.arrive(".top-level-item [jsaction*='toggle_item']", function() {
      $(".top-level-item [jsaction*='toggle_item']").first().simulate("mouseover");
      return $body.unbindArrive(".top-level-item [jsaction*='toggle_item']");
    });
  }

  $body.on("keypress", function(event) {
    var $element, $target;
    $target = $(event.target);
    if ($target.closest(":input").length || $target.closest("[contenteditable]").length) {
      return;
    }
    if (event.altKey || event.ctrlKey) {
      return;
    }
    if (event.keyCode === 192) {
      window.openSnoozeMenu();
      return;
    }
    if (event.keyCode >= 49 && event.keyCode <= 57) {
      $element = $(".snooze-element:visible");
      if ($element.length) {
        return $element.eq(event.keyCode - 49).simulate("mousedown").simulate("mouseup").simulate("click");
      } else {
        return window.openSnoozeMenu(function() {
          return _.defer(function() {
            $element = $(".snooze-element:visible");
            if ($element.length) {
              return $element.eq(event.keyCode - 49).simulate("mousedown").simulate("mouseup").simulate("click");
            }
          });
        });
      }
    }
  });

  window.openSnoozeMenu = function(callback) {
    var $currentItem;
    if (callback == null) {
      callback = null;
    }
    $currentItem = $(".scroll-list-item-open");
    if (!$currentItem.length) {
      $currentItem = $(".scroll-list-item-highlighted");
    }
    if (!$currentItem.length) {
      return;
    }
    $currentItem.find("[jsaction*='toggle_snooze_menu']").simulate("mousedown").simulate("mouseup").simulate("click");
    return typeof callback === "function" ? callback() : void 0;
  };

  $body.arrive("[role='heading']", {
    fireOnAttributesModification: true
  }, function() {
    var $heading;
    $heading = $(this);
    if ($heading.text() !== "Top results") {
      return;
    }
    return $heading.parent(".section-header").parent().remove();
  });

}).call(this);
