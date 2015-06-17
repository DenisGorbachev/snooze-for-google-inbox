# coffee -wc .
# TODO: rewrite using "jsactions"?
# I've discovered that jsaction attribute is actually being used at runtime
# if you copy HTML while leaving jsaction, it will behave like the copy source element

isDebug = false

$body = $(document.body)

handleNewLiClick = (time, event) ->
  TimeMoment = time.getMoment()
  CurrentMoment = moment().hour(0).minute(0).second(0)

  $body.arrive "[jsaction*='show_date_picker'] + div", ->
    dateIncrement = TimeMoment.diff(CurrentMoment, 'days')
    if dateIncrement < 0
      throw "dateIncrement #{dateIncrement} < 0"
    tdsByBackgroundColor = {}
    $("[jsaction*='show_date_picker'] + div tbody td").each ->
      $td = $(@)
      backgroundColor = $td.css("background-color").toString()
      if not tdsByBackgroundColor[backgroundColor]
        tdsByBackgroundColor[backgroundColor] = []
      tdsByBackgroundColor[backgroundColor].push($td)
    $currentTd = null
    for cls, $tds of tdsByBackgroundColor
      if $tds.length is 1
        $currentTd = $tds[0]
        break
    if not $currentTd
      throw "Couldn't find current td"
    $targetTd = $currentTd
    while dateIncrement
      $targetTd = $targetTd.next()
      if not $targetTd.length
        $targetTd = $currentTd.closest("tr").next().find("td").first()
      dateIncrement--
    $targetTd.simulate("click")
    $body.unbindArrive "[jsaction*='show_date_picker'] + div"

  $body.arrive "[jsaction*='show_time_picker'] input[value]", {fireOnAttributesModification: true}, ->
    $input = $(@)
    $button = $input.closest(".top-level-item").find("[jsaction*='date_time_pattern_set']")
    $divAfterShowTimePicker = $input.closest("[jsaction*='show_time_picker']").next()
    $divAfterShowTimePicker.arrive "[role='menuitem']", ->
	
      var selectTime;
	  var timeFormatted = TimeMoment.format("h:mm A");
	  if (timeFormatted == '4:00 PM') selectTime = 'Afternoon';
	  else if (timeFormatted == '10:00 PM') selectTime = 'Evening';
	  else selectTime = 'Morning';
	  console.log(timeFormatted + ':' + selectTime);
	
      $menuitem = $(@)
      if $menuitem.find('span').eq(0).text().trim() is selectTime //"Custom"
        $menuitem.simulate("mousedown").simulate("mouseup").simulate("click")
        #$input.val(TimeMoment.format("hh:mm A"))
        #$input.blur()
        _.defer -> # TODO may be better to wait until both inputs are set
          $button.simulate("mousedown").simulate("mouseup").simulate("click")
        $divAfterShowTimePicker.unbindArrive "[role='menuitem']"
    _.defer ->
      $input.simulate("mousedown").simulate("mouseup").simulate("click")
    $body.unbindArrive "[jsaction*='show_time_picker'] input[value]"

  $(@).closest(".top-level-item").find("[data-jsaction*='show_date_time_picker']").simulate("mousedown").simulate("mouseup").simulate("click")

times = [
  {
    name: "[T0] Tennis today"
    getMoment: ->
      moment().hour(16).minute(0).second(0)
  }
  {
    name: "[E0] Evening today"
    getMoment: ->
      moment().hour(22).minute(0).second(0)
  }
  {
    name: "[T1] Tennis tomorrow"
    getMoment: ->
      moment().hour(16).minute(0).second(0).add(1, "days")
  }
  {
    name: "[MW] Morning this Sunday"
    getMoment: ->
      Moment = moment().hour(7).minute(0).second(0).day("Sunday")
      if Moment.toDate().getTime() < Date.now()
        Moment.add(7, "days")
      Moment
  }
  {
    name: "[TT] Tennis this Tuesday"
    getMoment: ->
      Moment = moment().hour(16).minute(0).second(0).day("Tuesday")
      if Moment.toDate().getTime() < Date.now()
        Moment.add(7, "days")
      Moment
  }
]

$body.arrive "[data-jsaction*='show_date_time_picker']", ->
  $element = $(@)
  $section = $element.closest("section")
  $sectionContainer = $section.closest("div")
  $sectionContainer.css("max-height", "1000px")
  $sectionContainer.prev("header").remove()
  $ul = $section.prev("section").find("ul").first()
  $firstExistingLi = $ul.find("li").first()
  $sectionContainer.prepend($section)
  firstExistingLiHtml = $firstExistingLi[0].outerHTML
  for time in times
    $newLi = $(firstExistingLiHtml)
    $newLi.find().andSelf().each (index, el) ->
      $(el).removeAttr("id jsl jsan jsaction jsinstance data-jsaction data-action-data")
    $spans = $newLi.find("span")
    $spans.eq(1).text(time.name)
    $spans.eq(2).text(time.getMoment().format("h:mm A"))
    $newLi.addClass("snooze-element snooze-list-item")
    $newLi.on "click", _.partial(handleNewLiClick, time)
    $ul.append($newLi)
  jsinstance = 0
  $ul.find("li").each ->
    $(@).attr("jsinstance", jsinstance)
    jsinstance++
  $lastLi = $ul.find("li").last()
  $lastLi.attr("jsinstance", "*" + $lastLi.attr("jsinstance"))
  if isDebug
    $newLi.simulate("click")

$body.arrive "[jsaction*='show_time_picker'] + div [role='menuitem']:first-child", ->
  $arrivedMenuitem = $(@)
  if $arrivedMenuitem.hasClass("snooze-element")
    return
  $newMenuitem = $($arrivedMenuitem[0].outerHTML)
  $newMenuitem.addClass("snooze-element snooze-list-item")
  $newMenuitem.find().andSelf().each (index, el) ->
    $(el).removeAttr("id jsl jsan jsaction jsinstance data-jsaction data-action-data")
  $newSpans = $newMenuitem.find("span")
  $newSpans.eq(0).text("[T] Tennis")
  $newSpans.eq(1).text("4:00 PM")
  $beforeMenuitem = null
  $arrivedMenuitem.nextAll("[role='menuitem']").andSelf().each ->
    $beforeMenuitem = $(@)
    $spans = $beforeMenuitem.find("span")
    if $spans.eq(1).text().trim() > $newSpans.eq(1).text().trim()
      return false
  $beforeMenuitem.before($newMenuitem)
  $newMenuitem.on "click", ->
    $menuitem = $(@)
    $menu = $menuitem.closest("[role='menu']")
    $input = $menu.closest(".top-level-item").find("[jsaction*='show_time_picker'] input")
    $menu.find("[role='menuitem']").each ->
      if $(@).text().trim() is "Custom"
        $(@).simulate("mousedown").simulate("mouseup").simulate("click")
        $input.val($menuitem.find("span").eq(1).text())
        $input.blur()
        return false
#  $menu = $menuitem.closest("[role='menu']")
#  $menu.append($newMenuitem)

if isDebug
  $body.arrive ".top-level-item [jsaction*='toggle_snooze_menu']", ->
    $(@).simulate("mousedown").simulate("mouseup").simulate("click")
    $body.unbindArrive ".top-level-item [jsaction*='toggle_snooze_menu']"

  $body.arrive ".top-level-item [jsaction*='toggle_item']", ->
    $(".top-level-item [jsaction*='toggle_item']").first().simulate("mouseover")
    $body.unbindArrive ".top-level-item [jsaction*='toggle_item']"

$body.on "keypress", (event) ->
  $target = $(event.target)
  if $target.closest(":input").length or $target.closest("[contenteditable]").length
    return
  if event.altKey or event.ctrlKey
    return
  if event.keyCode is 192
    window.openSnoozeMenu()
    return
  if event.keyCode >= 49 and event.keyCode <= 57
    $element = $(".snooze-element:visible")
    if $element.length
      $element.eq(event.keyCode - 49).simulate("mousedown").simulate("mouseup").simulate("click")
    else
      window.openSnoozeMenu ->
        _.defer ->
          $element = $(".snooze-element:visible")
          if $element.length
            $element.eq(event.keyCode - 49).simulate("mousedown").simulate("mouseup").simulate("click")

window.openSnoozeMenu = (callback = null) ->
  $currentItem = $(".scroll-list-item-open")
  if not $currentItem.length
    $currentItem = $(".scroll-list-item-highlighted")
  if not $currentItem.length
    return
  $currentItem.find("[jsaction*='toggle_snooze_menu']").simulate("mousedown").simulate("mouseup").simulate("click")
  callback?()
