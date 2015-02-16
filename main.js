// Generated by CoffeeScript 1.7.1
(function() {
  var $body, handleNewLiClick, isDebug, times;

  isDebug = false;

  $body = $(document.body);

  handleNewLiClick = function(dateIncrement, time, event) {
    $body.arrive("[jsaction*='show_date_picker'] + div", function() {
      var $currentTd, $targetTd, $tds, cls, tdsByClassNames;
      tdsByClassNames = {};
      $("[jsaction*='show_date_picker'] + div tbody td").each(function() {
        var $td, cls, clses, _i, _len, _results;
        $td = $(this);
        clses = $td.attr("class").toString().split(' ');
        _results = [];
        for (_i = 0, _len = clses.length; _i < _len; _i++) {
          cls = clses[_i];
          if (!tdsByClassNames[cls]) {
            tdsByClassNames[cls] = [];
          }
          _results.push(tdsByClassNames[cls].push($td));
        }
        return _results;
      });
      $currentTd = null;
      for (cls in tdsByClassNames) {
        $tds = tdsByClassNames[cls];
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
        $targetTd = $currentTd.next();
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
        if ($(this).text().trim() === "Custom") {
          $(this).simulate("mousedown").simulate("mouseup").simulate("click");
          $input.val(time);
          $input.blur();
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
      name: "[T0] Tennis today",
      hint: "4:00 PM",
      dateIncrement: 0,
      time: "4:00 PM"
    }, {
      name: "[T1] Tennis tomorrow",
      hint: "4:00 PM",
      dateIncrement: 1,
      time: "4:00 PM"
    }
  ];

  $body.arrive("[data-jsaction*='show_date_time_picker']", function() {
    var $element, $firstExistingLi, $lastLi, $newLi, $spans, $ul, firstExistingLiHtml, jsinstance, time, _i, _len;
    $element = $(this);
    $ul = $element.closest("section").prev("section").find("ul").first();
    $firstExistingLi = $ul.find("li").first();
    firstExistingLiHtml = $firstExistingLi[0].outerHTML;
    for (_i = 0, _len = times.length; _i < _len; _i++) {
      time = times[_i];
      $newLi = $(firstExistingLiHtml);
      $newLi.find().andSelf().each(function(index, el) {
        return $(el).removeAttr("id jsl jsan jsaction jsinstance data-jsaction data-action-data");
      });
      $spans = $newLi.find("span");
      $spans.eq(1).text(time.name);
      $spans.eq(2).text(time.hint);
      $newLi.addClass("snooze-element snooze-list-item");
      $newLi.on("click", _.partial(handleNewLiClick, time.dateIncrement, time.time));
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

  $body.arrive("[jsaction*='show_time_picker'] + div [role='menuitem']:first-child", function() {
    var $arrivedMenuitem, $beforeMenuitem, $newMenuitem, $newSpans;
    $arrivedMenuitem = $(this);
    if ($arrivedMenuitem.hasClass("snooze-element")) {
      return;
    }
    $newMenuitem = $($arrivedMenuitem[0].outerHTML);
    $newMenuitem.addClass("snooze-element snooze-list-item");
    $newMenuitem.find().andSelf().each(function(index, el) {
      return $(el).removeAttr("id jsl jsan jsaction jsinstance data-jsaction data-action-data");
    });
    $newSpans = $newMenuitem.find("span");
    $newSpans.eq(0).text("[T] Tennis");
    $newSpans.eq(1).text("4:00 PM");
    $beforeMenuitem = null;
    $arrivedMenuitem.nextAll("[role='menuitem']").andSelf().each(function() {
      var $spans;
      $beforeMenuitem = $(this);
      $spans = $beforeMenuitem.find("span");
      if ($spans.eq(1).text().trim() > $newSpans.eq(1).text().trim()) {
        return false;
      }
    });
    $beforeMenuitem.before($newMenuitem);
    return $newMenuitem.on("click", function() {
      var $input, $menu, $menuitem;
      $menuitem = $(this);
      $menu = $menuitem.closest("[role='menu']");
      $input = $menu.closest(".top-level-item").find("[jsaction*='show_time_picker'] input");
      return $menu.find("[role='menuitem']").each(function() {
        if ($(this).text().trim() === "Custom") {
          $(this).simulate("mousedown").simulate("mouseup").simulate("click");
          $input.val($menuitem.find("span").eq(1).text());
          $input.blur();
          return false;
        }
      });
    });
  });

  if (isDebug) {
    $body.arrive(".top-level-item [jsaction*='list.toggle_snooze_menu']", function() {
      $(this).simulate("mousedown").simulate("mouseup").simulate("click");
      return $body.unbindArrive(".top-level-item [jsaction*='list.toggle_snooze_menu']");
    });
    $body.arrive(".top-level-item [jsaction*='list.toggle_item']", function() {
      $(".top-level-item [jsaction*='list.toggle_item']").first().simulate("mouseover");
      return $body.unbindArrive(".top-level-item [jsaction*='list.toggle_item']");
    });
  }

  $body.on("keydown", function(event) {
    var $currentItem, $element;
    if ($(event.target).closest(":input").length) {
      return;
    }
    if (event.keyCode >= 49 && event.keyCode <= 57) {
      $element = $(".snooze-element:visible");
      if ($element.length) {
        return $element.eq(event.keyCode - 49).simulate("mousedown").simulate("mouseup").simulate("click");
      } else {
        $currentItem = $(".scroll-list-item-open");
        if (!$currentItem.length) {
          $currentItem = $(".scroll-list-item-highlighted");
        }
        if (!$currentItem.length) {
          return;
        }
        $currentItem.find("[jsaction*='list.toggle_snooze_menu']").simulate("mousedown").simulate("mouseup").simulate("click");
        return _.defer(function() {
          $element = $(".snooze-element:visible");
          if ($element.length) {
            return $element.eq(event.keyCode - 49).simulate("mousedown").simulate("mouseup").simulate("click");
          }
        });
      }
    }
  });

}).call(this);
