local Group = require("leetcode-ui.group")
local Button = require("leetcode-ui.lines.button")
local Line = require("leetcode-ui.line")
local Contest = require("leetcode.api.contest")
local cmd = require("leetcode.command")
local config = require("leetcode.config")
local t = require("leetcode.translator")
local utils = require("leetcode.utils")
local ui_utils = require("leetcode-ui.utils")

---@class lc.ui.ContestProblemList : lc.ui.Group
local ContestProblemList = Group:extend("LeetContestProblemList")

function ContestProblemList:init(contest)
    ContestProblemList.super.init(self, {}, {
        spacing = 1,
    })

    self.contest = contest
    self:append(Line():append(t("Loading problems..."), "leetcode_medium"))
    self:fetch()
end

function ContestProblemList:fetch()
    if not self.contest then
        self:clear()
        self:append(Line():append("No contest selected", "Error"))
        _Lc_state.menu:draw()
        return
    end

    Contest.problems(self.contest.titleSlug, function(res, err)
        if err then
            self:clear()
            self:append(Line():append(err.msg, "Error"))
            _Lc_state.menu:draw()
            return
        end
        self:handle_res(res)
    end)
end

function ContestProblemList:handle_res(res)
    self:clear()

    if not res.questions or #res.questions == 0 then
        self:append(Line():append("No problems found", "leetcode_medium"))
    else
        for _, q in ipairs(res.questions) do
            self:add_problem_button(q)
        end
    end

    _Lc_state.menu:draw()
end

function ContestProblemList:add_problem_button(q)
    local button = Button({}, {
        on_press = function()
            -- We can use cmd.question(title_slug) if it exists, but cmd.problems calls picker.
            -- We want to open the question directly.
            -- cmd.random_question logic:
            -- local item = problems.get_by_title_slug(q.title_slug) or {}
            -- local Question = require("leetcode-ui.question")
            -- Question(item):mount()
            
            -- We need to ensure the problem is in cache or fetch it.
            -- The simplest way is to rely on Question(item) where item has title_slug.
            -- Let's try to get it from cache first.
            
            local problemlist = require("leetcode.cache.problemlist")
            local item = problemlist.get_by_title_slug(q.title_slug)
            
            if not item then
                -- If not in cache, we construct a minimal item
                item = {
                    title_slug = q.title_slug,
                    id = q.question_id,
                    frontend_id = q.question_frontend_id,
                    title = q.title,
                    difficulty = q.difficulty,
                    paid_only = false, -- Assume false or check if provided
                    status = "todo",
                }
            end
            
            local Question = require("leetcode-ui.question")
            Question(item):mount()
        end,
    })

    local status_icon = config.icons.status.todo
    local status_hl = "leetcode_medium"
    -- Check if we can determine status from `q.status` or cache
    -- q.status might be "AC", "TRIED", "NOT_STARTED"
    
    if q.status == "AC" then
        status_icon = config.icons.status.ac
        status_hl = "leetcode_easy"
    elseif q.status == "TRIED" then
        status_icon = config.icons.status.notac
        status_hl = "leetcode_medium"
    end

    button:append(status_icon .. " ", status_hl)
    button:append(q.question_frontend_id .. ". ", "leetcode_medium")
    button:append(q.title, "leetcode_normal")
    
    local diff = q.difficulty
    button:append(" " .. diff, ui_utils.diff_to_hl(diff))

    self:insert(button)
end

return ContestProblemList
