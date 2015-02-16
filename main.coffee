# TODO: rewrite using "jsactions"?
# I've discovered that jsaction attribute is actually being used at runtime
# if you copy HTML while leaving jsaction, it will behave like the copy source element

isDebug = false

$body = $(document.body)

handleNewLiClick = (dateIncrement, time, event) ->

  $body.arrive "[jsaction*='show_date_picker'] + div", ->
    tdsByClassNames = {}
    $("[jsaction*='show_date_picker'] + div tbody td").each ->
      $td = $(@)
      clses = $td.attr("class").toString().split(' ')
      for cls in clses
        if not tdsByClassNames[cls]
          tdsByClassNames[cls] = []
        tdsByClassNames[cls].push($td)
    $currentTd = null
    for cls, $tds of tdsByClassNames
      if $tds.length is 1
        $currentTd = $tds[0]
        break
    if not $currentTd
      throw "Couldn't find current td"
    $targetTd = $currentTd
    while dateIncrement
      $targetTd = $currentTd.next()
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
      if $(@).text().trim() is "Custom"
        $(@).simulate("mousedown").simulate("mouseup").simulate("click")
        $input.val(time)
        $input.blur()
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
    hint: "4:00 PM"
    dateIncrement: 0
    time: "4:00 PM"
  }
  {
    name: "[T1] Tennis tomorrow"
    hint: "4:00 PM"
    dateIncrement: 1
    time: "4:00 PM"
  }
]

$body.arrive "[data-jsaction*='show_date_time_picker']", ->
  $element = $(@)
  $ul = $element.closest("section").prev("section").find("ul").first()
  $firstExistingLi = $ul.find("li").first()
  firstExistingLiHtml = $firstExistingLi[0].outerHTML
  for time in times
    $newLi = $(firstExistingLiHtml)
    $newLi.find().andSelf().each (index, el) ->
      $(el).removeAttr("id jsl jsan jsaction jsinstance data-jsaction data-action-data")
    $spans = $newLi.find("span")
    $spans.eq(1).text(time.name)
    $spans.eq(2).text(time.hint)
    $newLi.addClass("snooze-element snooze-list-item")
    $newLi.on "click", _.partial(handleNewLiClick, time.dateIncrement, time.time)
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
  $body.arrive ".top-level-item [jsaction*='list.toggle_snooze_menu']", ->
    $(@).simulate("mousedown").simulate("mouseup").simulate("click")
    $body.unbindArrive ".top-level-item [jsaction*='list.toggle_snooze_menu']"

  $body.arrive ".top-level-item [jsaction*='list.toggle_item']", ->
    $(".top-level-item [jsaction*='list.toggle_item']").first().simulate("mouseover")
    $body.unbindArrive ".top-level-item [jsaction*='list.toggle_item']"

$body.on "keydown", (event) ->
  if event.keyCode >= 49 and event.keyCode <= 57
    $element = $(".snooze-element:visible").eq(event.keyCode - 49)
    if $element.length
      $element.simulate("mousedown").simulate("mouseup").simulate("click")
