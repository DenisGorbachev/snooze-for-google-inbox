# coffee -wc .
# TODO: rewrite using "jsactions"?
# I've discovered that jsaction attribute is actually being used at runtime
# if you copy HTML while leaving jsaction, it will behave like the copy source element

isDebug = false

$body = $(document.body)

handleNewLiClick = (time, event) ->
  $body.arrive "[jsaction*='show_date_picker'] + div", ->
    dateIncrement = time.getDateIncrement()
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
      $menuitem = $(@)
      if $menuitem.find('span').eq(0).text().trim() is time.preset
        $menuitem.simulate("mousedown").simulate("mouseup").simulate("click")
        _.defer -> # TODO may be better to wait until both inputs are set
          $button.simulate("mousedown").simulate("mouseup").simulate("click")
        $divAfterShowTimePicker.unbindArrive "[role='menuitem']"
    _.defer ->
      $input.simulate("mousedown").simulate("mouseup").simulate("click")
    $body.unbindArrive "[jsaction*='show_time_picker'] input[value]"

  $(@).closest(".top-level-item").find("[data-jsaction*='show_date_time_picker']").simulate("mousedown").simulate("mouseup").simulate("click")

times = [
    name: "Today afternoon"
    preset: "Afternoon"
    getDateIncrement: -> 0
  ,
    name: "Today evening"
    preset: "Evening"
    getDateIncrement: -> 0
  ,
    name: "Tomorrow afternoon"
    preset: "Afternoon"
    getDateIncrement: -> 1
  ,
    name: "Sunday morning"
    preset: "Morning"
    getDateIncrement: ->
      Moment = moment().hour(0).minute(0).second(0).day("Sunday")
      if Moment.toDate().getTime() < Date.now()
        Moment.add(7 + 1, "days")
      Moment.diff(moment(), 'days')
  ,
    name: "Tuesday afternoon"
    preset: "Afternoon"
    getDateIncrement: ->
      Moment = moment().hour(0).minute(0).second(0).day("Tuesday")
      if Moment.toDate().getTime() < Date.now()
        Moment.add(7 + 1, "days")
      Moment.diff(moment(), 'days')
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
    $spans.eq(2).text("")
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

$body.arrive "[role='heading']", {fireOnAttributesModification: true}, ->
  $heading = $(@)
  return if $heading.text() isnt "Top results"
  $heading.parent(".section-header").parent().remove()
