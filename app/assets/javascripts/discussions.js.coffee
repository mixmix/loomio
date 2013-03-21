window.Discussion ||= {}

# Set placeholders
$ ->
  if $("body.discussions.new").length > 0
    $('input, textarea').placeholder()

# Edit title
$ ->
  if $("body.discussions.show").length > 0
    $("#edit-title").click((event) ->
      $("#discussion-title").addClass('hidden')
      $("#edit-discussion-title").removeClass('hidden')
      event.preventDefault()
    )
    $("#cancel-edit-title").click((event) ->
      $("#edit-discussion-title").addClass('hidden')
      $("#discussion-title").removeClass('hidden')
      event.preventDefault()
    )

$ ->
  if $("body.discussions.show").length > 0
    $("textarea").atWho "@", 
      cache: false
      tpl: "<li id='${id}' data-value='${username}'> ${name} <small> @${username}</small></li>"
      callback: (query, callback) ->
        group = $("#comment-input").data("group")
        $.get "/groups/#{group}/members", pre: query, ((result) ->
            #TODO tidy this up
            names = _.toArray(result)
            names = _.map names, (name) ->
              _.toArray(name)
            callback _.toArray(names)
        ), "json"

$ ->
  if $("body.discussions.show").length > 0
    $("#enable-markdown").click((event) ->
      updateMarkdownSetting(this, true)
    )
$ ->
  if $("body.discussions.show").length > 0
    $("#disable-markdown").click((event) ->
      updateMarkdownSetting(this, false)
    )

updateMarkdownSetting = (selected, usesMarkdown) ->
  $("#uses_markdown").val(usesMarkdown)
  $('#markdown-setting-dropdown').find('.icon-ok').removeClass('icon-ok')
  $(selected).children().first().children().addClass('icon-ok')
  $("#markdown-settings-form").submit()
  event.preventDefault()

# Edit description
Discussion.enableInlineEdition = ()->
  if $("body.discussions.show").length > 0
    $(".edit-description").click((event) ->
      container = $(this).parents(".description-container")
      description_height = container.find(".model-description").height()
      container.find(".description-body").toggle()
      container.find("#description-edit-form").toggle()
      if description_height > 90
        container.find('#description-input').height(description_height)
      event.preventDefault()
    )
    $(".edit-discussion-description").click (event)->
      $(".discussion-description-helper-text").toggle()
      $(".discussion-additional-info").toggle()
      event.preventDefault()
    $("#cancel-add-description").click((event) ->
      $("#description-edit-form").toggle()
      $(".description-body").toggle()
      $(".discussion-description-helper-text").toggle()
      $(".discussion-additional-info").toggle()
      event.preventDefault()
    )

Discussion.seeMoreDescription = () ->
  #expand/shrink description text
  if $("body.discussions.show").length > 0
    $(".see-more").click((event) ->
      $(this).parent().children(".short-description").toggle()
      $(this).parent().children(".long-description").toggle()
      if $(this).html() == "Show More"
        $(this).html("Show Less")
      else
        $(this).html("Show More")
      event.preventDefault()
    )

$ ->
  Discussion.enableInlineEdition()
  Discussion.seeMoreDescription()