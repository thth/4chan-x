ThemeTools =
  init: (key) ->
    unless Conf["Style"]
      alert "Please enable Style Options and reload the page to use Theme Tools."
      return
    editMode = true
    unless newTheme
      Style.addStyle userThemes[key]
    if newTheme
      editTheme = {}
      editTheme["Theme"] = "Untitled"
      editTheme["Author"] = "Author"
      editTheme["Author Tripcode"] = "Unknown"
    else
      editTheme = userThemes[key]
      editTheme["Theme"] = key
    layout = ["Background Image", "Background Attachment", "Background Position", "Background Repeat", "Background Color", "Thread Wrapper Background", "Thread Wrapper Border", "Dialog Background", "Dialog Border", "Reply Background", "Reply Border", "Highlighted Reply Background", "Highlighted Reply Border", "Backlinked Reply Outline", "Input Background", "Input Border", "Checkbox Background", "Checkbox Border", "Checkbox Checked Background", "Buttons Background", "Buttons Border", "Focused Input Background", "Focused Input Border", "Hovered Input Background", "Hovered Input Border", "Navigation Background", "Navigation Border", "Quotelinks", "Backlinks", "Links", "Hovered Links", "Navigation Links", "Hovered Navigation Links", "Names", "Tripcodes", "Emails", "Subjects", "Text", "Inputs", "Post Numbers", "Greentext", "Sage", "Board Title", "Timestamps", "Warnings", "Shadow Color", "Dark Theme", "Custom CSS"]

    dialog = $.el "div",
      id: "themeConf"
      className: "reply dialog"
      innerHTML: "
<div id=themebar>
</div>
<hr>
<div id=themecontent>
</div>
<div id=save>
  <a href='javascript:;'>Save Theme</a>
</div>
<div id=cancel>
  <a href='javascript:;'>Cancel</a>
</div>
"

    header = $.el "div",
      innerHTML: "
<input class='field subject' name='Theme' placeholder='Theme' value='#{key}'> by
<input class='field name' name='Author' placeholder='Author' value='#{editTheme['Author']}'>
<input class='field postertrip' name='Author Tripcode' placeholder='Author Tripcode' value='#{editTheme['Author Tripcode']}'>"
    for input in $$("input", header)
      $.on input, 'blur', ->
        editTheme[@name] = @value
    $.add $("#themebar", dialog), header
    if newTheme
      for item in layout
        editTheme[item] = ""
        div = $.el "div",
          className: "themevar"
          innerHTML: "<div class=optionname><b>#{item}</b></div><div class=option><input class=field name='#{item}' placeholder='#{item}'>"
        $.on $('input', div), 'blur', ->
          editTheme[@name] = @value
          Style.addStyle(editTheme)
        $.add $("#themecontent", dialog), div
    else
      for item in layout
        div = $.el "div",
          className: "themevar"
          innerHTML: "<div class=optionname><b>#{item}</b></div><div class=option><input type=text class=field name='#{item}' placeholder='#{item}' value='#{editTheme[item]}'>"
        $.on $('input', div), 'blur', ->
          depth = 0
          for i in [0..@value.length - 1]
            switch @value[i]
              when '(' then depth++
              when ')' then depth--
              when '"' then toggle1 = not toggle1
              when "'" then toggle2 = not toggle2
          if depth != 0 or toggle1 or toggle2
            return alert "Syntax error on #{@name}."
          editTheme[@name] = @value
          Style.addStyle(editTheme)
        $.add $("#themecontent", dialog), div
    $.on $('#save > a', dialog), 'click', ->
      ThemeTools.save editTheme
    $.on  $('#cancel > a', dialog), 'click', ThemeTools.close
    if newTheme then Style.addStyle(editTheme)
    $.add d.body, dialog

  color: (hex) ->
    @calc_rgb = (hex) ->
      rgb = []
      hex = parseInt hex, 16
      rgb[0] = (hex >> 16) & 0xFF
      rgb[1] = (hex >> 8) & 0xFF
      rgb[2] = hex & 0xFF
      return rgb;
    @hex = "#" + hex
    @private_rgb = @calc_rgb(hex)
    @rgb = @private_rgb.join ","
    @isLight = (rgb) ->
      rgb[0] + rgb[1] + rgb[2] >= 400
    @shiftRGB = (shift, smart) ->
      rgb = @private_rgb.slice 0
      shift = if smart
        if @isLight
          if shift < 0
            shift
          else
            -shift
        else
          Math.abs shift
      else
        shift;
      rgb[0] = Math.min Math.max(rgb[0] + shift, 0), 255
      rgb[1] = Math.min Math.max(rgb[1] + shift, 0), 255
      rgb[2] = Math.min Math.max(rgb[2] + shift, 0), 255
      return rgb.join ","
    @hover = @shiftRGB 16, true

  importtheme: (origin, evt) ->
    file = evt.target.files[0]
    reader = new FileReader()
    reader.onload = (e) ->
      try
        imported = JSON.parse e.target.result
      catch err
        alert err
        return
      unless (origin != 'appchan' and imported.mainColor) or (origin == 'appchan' and imported["Author Tripcode"])
        alert "Theme file is invalid."
        return
      name = imported.name or imported["Theme"]
      delete imported.name
      if userThemes[name] and not userThemes[name]["Deleted"]
        if confirm "A theme with this name already exists. Would you like to over-write?"
          delete userThemes[name]
        else
          return
      if origin == "oneechan" or origin == "SS"
        bgColor     = new ThemeTools.color(imported.bgColor);
        mainColor   = new ThemeTools.color(imported.mainColor);
        brderColor  = new ThemeTools.color(imported.brderColor);
        inputColor  = new ThemeTools.color(imported.inputColor);
        inputbColor = new ThemeTools.color(imported.inputbColor);
        blinkColor  = new ThemeTools.color(imported.blinkColor);
        jlinkColor  = new ThemeTools.color(imported.jlinkColor);
        linkColor   = new ThemeTools.color(imported.linkColor);
        linkHColor  = new ThemeTools.color(imported.linkHColor);
        nameColor   = new ThemeTools.color(imported.nameColor);
        quoteColor  = new ThemeTools.color(imported.quoteColor);
        sageColor   = new ThemeTools.color(imported.sageColor);
        textColor   = new ThemeTools.color(imported.textColor);
        titleColor  = new ThemeTools.color(imported.titleColor);
        tripColor   = new ThemeTools.color(imported.tripColor);
        timeColor   = new ThemeTools.color(imported.timeColor || imported.textColor);
        if origin == "oneechan"
          userThemes[name] = {
            'Author'                      : "Author"
            'Author Tripcode'             : "'!TRip.C0d3'"
            'Background Image'            : imported.bgImg
            'Background Attachment'       : imported.bgA
            'Background Position'         : imported.bgPY + " " + imported.bgPX
            'Background Repeat'           : imported.bgR
            'Background Color'            : bgColor.hex
            'Dialog Background'           : 'rgba(' + mainColor.rgb + ',.98)'
            'Dialog Border'               : brderColor.hex
            'Thread Wrapper Background'   : 'rgba(0,0,0,0)'
            'Thread Wrapper Border'       : 'rgba(0,0,0,0)'
            'Reply Background'            : 'rgba(' + mainColor.rgb + ',' + imported.replyOp + ')'
            'Reply Border'                : brderColor.hex
            'Highlighted Reply Background': 'rgba(' + mainColor.shiftRGB(4, true) + ',' + imported.replyOp + ')'
            'Highlighted Reply Border'    : linkColor.hex
            'Backlinked Reply Outline'    : linkColor.hex
            'Checkbox Background'         : 'rgba(' + inputColor.rgb + ',' + imported.replyOp + ')'
            'Checkbox Border'             : inputbColor.hex
            'Checkbox Checked Background' : inputColor.hex
            'Input Background'            : 'rgba(' + inputColor.rgb + ',' + imported.replyOp + ')'
            'Input Border'                : inputbColor.hex
            'Hovered Input Background'    : 'rgba(' + inputColor.hover + ',' + imported.replyOp + ')'
            'Hovered Input Border'        : inputbColor.hex
            'Focused Input Background'    : 'rgba(' + inputColor.hover + ',' + imported.replyOp + ')'
            'Focused Input Border'        : inputbColor.hex
            'Buttons Background'          : 'rgba(' + inputColor.rgb + ',' + imported.replyOp + ')'
            'Buttons Border'              : inputbColor.hex
            'Navigation Background'       : 'rgba(' + bgColor.rgb + ',0.8)'
            'Navigation Border'           : mainColor.hex
            'Links'                       : linkColor.hex
            'Hovered Links'               : linkHColor.hex
            'Navigation Links'            : textColor.hex
            'Hovered Navigation Links'    : linkHColor.hex
            'Subjects'                    : titleColor.hex
            'Names'                       : nameColor.hex
            'Sage'                        : sageColor.hex
            'Tripcodes'                   : tripColor.hex
            'Emails'                      : linkColor.hex
            'Post Numbers'                : linkColor.hex
            'Text'                        : textColor.hex
            'Backlinks'                   : linkColor.hex
            'Greentext'                   : quoteColor.hex
            'Board Title'                 : textColor.hex
            'Timestamps'                  : timeColor.hex
            'Inputs'                      : textColor.hex
            'Warnings'                    : sageColor.hex
            'Shadow Color'                : 'rgba(' + mainColor.shiftRGB(16) + ',.9)'
            'Dark Theme'                  : if mainColor.isLight then '1' else '0'
            'Custom CSS'                  : """
input[type=password]:hover,
input[type=text]:not([disabled]):hover,
input#fs_search:hover,
input.field:hover,
.webkit select:hover,
textarea:hover,
#options input:not[type=checkbox]:hover {
  box-shadow:inset rgba(0,0,0,.2) 0 1px 2px;
}
input[type=password]:focus,
input[type=text]:focus,
input#fs_search:focus,
input.field:focus,
.webkit select:focus,
textarea:focus,
#options input:focus {
  box-shadow:inset rgba(0,0,0,.2) 0 1px 2px;
}
button,
input:not(.jsColor),
textarea,
.rice {
  transition:background .2s,box-shadow .2s;
}""" + imported.customCSS }
        else if origin == "SS"
          userThemes[name] = {
            'Author'                      : "Author"
            'Author Tripcode'             : "'!TRip.C0d3'"
            'Background Image'            : imported.bgImg
            'Background Attachment'       : imported.bgA
            'Background Position'         : imported.bgPY + " " + imported.bgPX
            'Background Repeat'           : imported.bgR
            'Background Color'            : bgColor.hex
            'Dialog Background'           : 'rgba(' + mainColor.rgb + ',.98)'
            'Dialog Border'               : brderColor.hex
            'Thread Wrapper Background'   : 'rgba(' + mainColor.rgb + ',.5)'
            'Thread Wrapper Border'       : 'rgba(' + brderColor.rgb + ',.9)'
            'Reply Background'            : 'rgba(' + mainColor.rgb + ',' + imported.replyOp + ')'
            'Reply Border'                : brderColor.hex
            'Highlighted Reply Background': 'rgba(' + mainColor.shiftRGB(4, true) + ',' + imported.replyOp + ')'
            'Highlighted Reply Border'    : linkColor.hex
            'Backlinked Reply Outline'    : linkColor.hex
            'Checkbox Background'         : 'rgba(' + inputColor.rgb + ',' + imported.replyOp + ')'
            'Checkbox Border'             : inputbColor.hex
            'Checkbox Checked Background' : inputColor.hex
            'Input Background'            : 'rgba(' + inputColor.rgb + ',' + imported.replyOp + ')'
            'Input Border'                : inputbColor.hex
            'Hovered Input Background'    : 'rgba(' + inputColor.hover + ',' + imported.replyOp + ')'
            'Hovered Input Border'        : inputbColor.hex
            'Focused Input Background'    : 'rgba(' + inputColor.hover + ',' + imported.replyOp + ')'
            'Focused Input Border'        : inputbColor.hex
            'Buttons Background'          : 'rgba(' + inputColor.rgb + ',' + imported.replyOp + ')'
            'Buttons Border'              : inputbColor.hex
            'Navigation Background'       : 'rgba(' + bgColor.rgb + ',0.8)'
            'Navigation Border'           : mainColor.hex
            'Links'                       : linkColor.hex
            'Hovered Links'               : linkHColor.hex
            'Navigation Links'            : textColor.hex
            'Hovered Navigation Links'    : linkHColor.hex
            'Subjects'                    : titleColor.hex
            'Names'                       : nameColor.hex
            'Sage'                        : sageColor.hex
            'Tripcodes'                   : tripColor.hex
            'Emails'                      : linkColor.hex
            'Post Numbers'                : linkColor.hex
            'Text'                        : textColor.hex
            'Backlinks'                   : linkColor.hex
            'Greentext'                   : quoteColor.hex
            'Board Title'                 : textColor.hex
            'Timestamps'                  : timeColor.hex
            'Inputs'                      : textColor.hex
            'Warnings'                    : sageColor.hex
            'Shadow Color'                : 'rgba(' + mainColor.shiftRGB(16) + ',.9)'
            'Dark Theme'                  : if mainColor.isLight then '1' else '0'
            'Custom CSS'                  : """
#delform {
  padding: 1px 2px;
}
input[type=password]:hover,
input[type=text]:not([disabled]):hover,
input#fs_search:hover,
input.field:hover,
.webkit select:hover,
textarea:hover,
#options input:not[type=checkbox]:hover {
  box-shadow:inset rgba(0,0,0,.2) 0 1px 2px;
}
input[type=password]:focus,
input[type=text]:focus,
input#fs_search:focus,
input.field:focus,
.webkit select:focus,
textarea:focus,
#options input:focus {
  box-shadow:inset rgba(0,0,0,.2) 0 1px 2px;
}
button,
input:not(.jsColor),
textarea,
.rice {
  transition:background .2s,box-shadow .2s;
}""" + imported.customCSS }
      else if origin == 'appchan'
        userThemes[name] = imported
      $.set 'userThemes', userThemes
      alert "Theme \"#{name}\" imported!"
      $.rm $("#themes", d.body)
      Options.themeTab()
    reader.readAsText(file)

  save: (theme) ->
    name = theme["Theme"]
    delete theme["Theme"]
    if userThemes[name] and not userThemes[na  me]["Deleted"]
      if confirm "A theme with this name alre  ady exists. Would you like to over-write?"
        delete userThemes[name]
      else
        return
    userThemes[name] = theme
    $.set 'userThemes', userThemes
    $.set "Style", name
    Conf["Style"] = name
    ThemeTools.close()
    alert "Theme \"#{name}\" saved."

  close: ->
    newTheme = false
    editMode = false
    $.rm $("#themeConf", d.body)
    Style.addStyle Conf["Style"]
    Options.dialog("theme")