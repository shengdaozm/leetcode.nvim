local Page = require("leetcode-ui.group.page")
local Title = require("leetcode-ui.lines.title")
local ContestList = require("leetcode-ui.group.contest-list")
local BackButton = require("leetcode-ui.lines.button.menu.back")
local Buttons = require("leetcode-ui.group.buttons.menu")
local footer = require("leetcode-ui.lines.footer")
local header = require("leetcode-ui.lines.menu-header")

local page = Page()

page:insert(header)
page:insert(Title({ "Menu" }, "Contests"))

local contest_list = ContestList()
page:insert(contest_list)

local buttons = Buttons({})
local update = require("leetcode-ui.lines.button.menu")("Update", {
    icon = "",
    sc = "u",
    on_press = function()
        contest_list:fetch()
    end,
})
buttons:insert(update)

local back = BackButton("menu")
buttons:insert(back)

page:insert(buttons)
page:insert(footer)

return page
