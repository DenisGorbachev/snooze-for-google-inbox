#$body.on "click", (event) ->
#  $target = $(event.target)
#  if $target.closest("[jsaction*='toggle_snooze_menu']").length
#    cl "clicked toggle snooze"
isDebug = false

$body = $(document.body)

$body.arrive "[data-jsaction*='show_date_time_picker']", ->
  $element = $(@)
  $ul = $element.closest("section").prev("section").find("ul")
  $firstExistingLi = $ul.find("li").first()
  firstExistingLiHtml = $firstExistingLi[0].outerHTML
  $newLi = $(firstExistingLiHtml)
  $newLi.find().andSelf().each (index, el) ->
    $(el).removeAttr("id jsl jsan jsaction jsinstance data-jsaction data-action-data")
  textContainers = []
  $newLi.find("span").each (index, el) ->
    $el = $(el)
    if $el.text().trim()
      textContainers.push($el)
  textContainers[0].text("Tomorrow noon")
  textContainers[1].text("4:00 PM")
  $newLi.addClass("snooze-li")
  $newLi.on "click", (event) ->

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
      $targetTd = $currentTd.next()
      if not $targetTd.length
        $targetTd = $currentTd.closest("tr").next().find("td").first()
      $targetTd.simulate("click")
      $body.unbindArrive "[jsaction*='show_date_picker'] + div"

    $body.arrive "[jsaction*='show_time_picker'] input[value]", {fireOnAttributesModification: true}, ->
      $input = $(@)
      $divAfterShowTimePicker = $input.closest("[jsaction*='show_time_picker']").next()
      $divAfterShowTimePicker.arrive "[role='menuitem']", ->
        if $(@).text().trim() is "Custom"
          $(@).simulate("mousedown").simulate("mouseup").simulate("click")
          $input.val("4:00 PM")
          $input.blur()
          _.defer -> # TODO may be better to wait until both inputs are set
            $("[jsaction*='date_time_pattern_set']").simulate("mousedown").simulate("mouseup").simulate("click")
          $divAfterShowTimePicker.unbindArrive "[role='menuitem']"
      $input.simulate("mousedown").simulate("mouseup").simulate("click")
      $body.unbindArrive "[jsaction*='show_time_picker'] input[value]"

    $("[data-jsaction*='show_date_time_picker']").simulate("mousedown").simulate("mouseup").simulate("click")

  $ul.append($newLi)
  if isDebug
    $newLi.simulate("click")

if isDebug
  $body.arrive ".top-level-item [jsaction*='list.toggle_snooze_menu']", ->
    $(@).simulate("mousedown").simulate("mouseup").simulate("click")
    $body.unbindArrive ".top-level-item [jsaction*='list.toggle_snooze_menu']"

  $body.arrive ".top-level-item [jsaction*='list.toggle_item']", ->
    $(".top-level-item [jsaction*='list.toggle_item']").first().simulate("mouseover")
    $body.unbindArrive ".top-level-item [jsaction*='list.toggle_item']"
