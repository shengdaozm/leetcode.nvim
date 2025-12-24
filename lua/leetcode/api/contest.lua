local utils = require("leetcode.api.utils")
local queries = require("leetcode.api.queries")
local Spinner = require("leetcode.logger.spinner")

---@class lc.ContestApi
local Contest = {}

---@param cb fun(res: table, err: lc.err)
function Contest.all(cb)
    local query = queries.contest_list

    local spinner = Spinner:start("fetching contests...", "points")

    utils.query(query, {}, {
        callback = function(res, err)
            if err then
                spinner:error(err.msg)
                return cb(nil, err)
            end

            local all_contests = res.data.allContests
            local upcoming = {}
            local past = {}
            local now = os.time()

            for _, c in ipairs(all_contests) do
                if c.startTime > now then
                    table.insert(upcoming, c)
                else
                    table.insert(past, c)
                end
            end

            -- Sort upcoming by start time (soonest first)
            table.sort(upcoming, function(a, b)
                return a.startTime < b.startTime
            end)

            -- Sort past by start time (newest first)
            table.sort(past, function(a, b)
                return a.startTime > b.startTime
            end)

            spinner:success("contests fetched")
            cb({ upcoming = upcoming, past = past })
        end,
    })
end

---@param title_slug string
---@param cb fun(res: table, err: lc.err)
function Contest.problems(title_slug, cb)
    local query = queries.contest_problems
    local variables = { titleSlug = title_slug }

    local spinner = Spinner:start("fetching contest problems...", "points")

    utils.query(query, variables, {
        callback = function(res, err)
            if err then
                spinner:error(err.msg)
                return cb(nil, err)
            end
            
            local contest = res.data.contest
            spinner:success("problems fetched")
            cb(contest)
        end,
    })
end

return Contest
