local Group = require("leetcode-ui.group")
local Button = require("leetcode-ui.lines.button")
local Line = require("leetcode-ui.line")
local Contest = require("leetcode.api.contest")
local Spinner = require("leetcode.logger.spinner")
local cmd = require("leetcode.command")
local config = require("leetcode.config")
local t = require("leetcode.translator")

---@class lc.ui.ContestList : lc.ui.Group
local ContestList = Group:extend("LeetContestList")

function ContestList:init()
    ContestList.super.init(self, {}, {
        spacing = 1,
    })

    self:append(Line():append(t("Loading contests..."), "leetcode_medium"))
    self:fetch()
end

function ContestList:fetch()
    Contest.all(function(res, err)
        if err then
            self:clear()
            self:append(Line():append(err.msg, "Error"))
            _Lc_state.menu:draw()
            return
        end
        self:handle_res(res)
    end)
end

function ContestList:handle_res(res)
    self:clear()

    if #res.upcoming > 0 then
        self:append(Line():append(t("Upcoming Contests"), "leetcode_alt"))
        for _, c in ipairs(res.upcoming) do
            self:add_contest_button(c)
        end
        self:append(Line()) -- Spacer
    end

    if #res.past > 0 then
        self:append(Line():append(t("Past Contests"), "leetcode_alt"))
        -- Show only recent 10 past contests to avoid clutter
        for i = 1, 10 do
            if res.past[i] then
                self:add_contest_button(res.past[i])
            end
        end
    end

    _Lc_state.menu:draw()
end

function ContestList:add_contest_button(c)
    local button = Button({}, {
        on_press = function()
            cmd.contest_problems(c)
        end,
    })

    local icon = c.startTime > os.time() and "󱑒" or ""
    
    -- Format date
    local date = os.date("%Y-%m-%d %H:%M", c.startTime)

    button:append(icon .. " ", "leetcode_medium")
    button:append(c.title .. " ", "leetcode_normal")
    button:append("(" .. date .. ")", "leetcode_medium")

    self:insert(button)
end

return ContestList
