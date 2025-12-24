local Page = require("leetcode-ui.group.page")
local Title = require("leetcode-ui.lines.title")
local ContestProblemList = require("leetcode-ui.group.contest-problem-list")
local BackButton = require("leetcode-ui.lines.button.menu.back")
local Buttons = require("leetcode-ui.group.buttons.menu")
local footer = require("leetcode-ui.lines.footer")
local header = require("leetcode-ui.lines.menu-header")

local page = Page()

page:insert(header)

local contest = _Lc_state.contest
local title_text = "Contest Problems"
if contest then
    title_text = contest.title
end

page:insert(Title({ "Menu", "Contests" }, title_text))

page:insert(ContestProblemList(contest))

local buttons = Buttons({})
local back = BackButton("contests")
buttons:insert(back)

page:insert(buttons)
page:insert(footer)

return page
