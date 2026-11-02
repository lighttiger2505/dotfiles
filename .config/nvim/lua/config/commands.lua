local Job = require("plenary.job")
local log = require("plenary.log")

local function get_commit_hash_current_line()
    local buf = vim.api.nvim_buf_get_name(0)
    local row = vim.api.nvim_win_get_cursor(0)[1]

    local result = Job:new({
        command = "git",
        args = {
            "blame",
            "-L" .. row .. "," .. row,
            "--porcelain",
            buf,
        },
    }):sync()

    if not result or #result == 0 then
        return nil
    end

    log.info("Found Blame" .. vim.inspect(result, { newline = "", indent = "" }))

    local sha = result[1]:match("^([0-9a-f]+)")
    return sha
end

local is_valid_result = function(result)
    return result
        and result.data
        and result.data.repository
        and result.data.repository.object
        and result.data.repository.object ~= vim.NIL
        and result.data.repository.object.associatedPullRequests
        and result.data.repository.object.associatedPullRequests.edges
        and result.data.repository.object.associatedPullRequests.edges[1]
        and result.data.repository.object.associatedPullRequests.edges[1].node
        and result.data.repository.object.associatedPullRequests.edges[1].node.number
end

local open_current_line_modified_pr = function()
    local gh_cmd = "gh"

    if vim.fn.executable(gh_cmd) == 0 then
        log.error(string.format("'%s' command is required to execute this process", gh_cmd))
        return
    end

    local commit_hash = get_commit_hash_current_line()
    if not commit_hash then
        log.error("failed to get commit hash")
        return
    end

    local find_pr_query = ([[query='
        query($repo:String!, $owner:String!, $hash:String) {
          repository(name: $repo, owner: $owner) {
            object(expression: $hash) {
              ... on Commit {
                associatedPullRequests(first: 10) {
                  edges {
                    node {
                      number,
                      title,
                      author { login },
                      createdAt,
                    }
                  }
                }
              }
            }
          }
        }'
  ]]):gsub("\n", "")
    local find_pr_cmd = string.format(
        '%s api graphql -F owner=":owner" -F repo=":repo" -F hash=%s -f %s',
        gh_cmd,
        commit_hash,
        find_pr_query
    )

    local job = Job:new({
        command = "bash",
        args = { "-c", find_pr_cmd },
    })
    local stdout, code = job:sync()
    if code ~= 0 then
        log.error("failed to get pull request")
        return
    end
    local result = vim.fn.json_decode(stdout)
    if not is_valid_result(result) then
        log.error("not found pull request number")
        return
    end

    local prs = result.data.repository.object.associatedPullRequests.edges
    for i, v in pairs(prs) do
        log.info("PR" .. i, vim.inspect(v.node, { newline = "", indent = "" }))
    end

    -- open pull request
    local pr_number = prs[1].node.number
    local open_pr_cmd = string.format("%s browse -- %s", gh_cmd, pr_number)
    job = Job:new({
        command = "bash",
        args = { "-c", open_pr_cmd },
    })
    stdout, code = job:sync()
    if code ~= 0 then
        log.error("failed to open pull request" .. stdout)
        return
    end
end

vim.keymap.set(
    "n",
    "<leader>gh",
    open_current_line_modified_pr,
    { noremap = true, silent = true, desc = "Git open pull request by current line modified" }
)

local function tag_pr_changes()
    local branch = vim.fn.systemlist({ "git", "rev-parse", "--abbrev-ref", "HEAD" })[1]
    if branch == "" then
        vim.notify("Failed to detect current branch", vim.log.levels.ERROR)
        return
    end

    local cmd = { "gh", "pr", "diff", branch, "--name-only" }
    local results = vim.fn.systemlist(cmd)
    if vim.v.shell_error ~= 0 then
        vim.notify("gh pr diff failed:\n" .. table.concat(results, "\n"), vim.log.levels.ERROR)
        return
    end

    local grapple = require("grapple")
    grapple.reset()
    for _, file in ipairs(results) do
        grapple.tag({ path = file })
    end
    vim.notify("Complete set grapple tags by pull request diff files", vim.log.levels.INFO)
end

vim.keymap.set(
    "n",
    "<leader>gm",
    tag_pr_changes,
    { noremap = true, silent = true, desc = "Grapple reset tag for pull request modified files" }
)

-- Returns the subset of `files` whose .gitattributes `linguist-generated` value is `true`.
local function get_generated_files(files)
    if #files == 0 then
        return {}
    end

    local cmd = { "git", "check-attr", "linguist-generated", "--" }
    vim.list_extend(cmd, files)
    local results = vim.fn.systemlist(cmd)

    local generated = {}
    for _, line in ipairs(results) do
        local path, value = line:match("^(.-): linguist%-generated: (%S+)$")
        if value == "true" then
            table.insert(generated, path)
        end
    end
    return generated
end

local function open_diff_view_pr()
    local base = vim.fn
        .system({ "gh", "pr", "status", "--json", "baseRefName", "-q", ".currentBranch.baseRefName" })
        :gsub("%s+", "")
    if base == "" then
        vim.notify("No pull request found for this branch", vim.log.levels.WARN)
        return
    end

    local range = "origin/" .. base .. "...HEAD"
    local files = vim.fn.systemlist({ "git", "diff", "--name-only", range })
    if vim.v.shell_error ~= 0 then
        vim.notify("git diff failed:\n" .. table.concat(files, "\n"), vim.log.levels.ERROR)
        return
    end

    local args = { range, "--imply-local" }
    local generated = get_generated_files(files)
    if #generated > 0 then
        table.insert(args, "--")
        table.insert(args, ".")
        for _, f in ipairs(generated) do
            table.insert(args, ":!" .. f)
        end
    end

    vim.api.nvim_cmd({ cmd = "DiffviewOpen", args = args }, {})
end

vim.api.nvim_create_user_command("OpenDiffviewPR", open_diff_view_pr, {})
vim.keymap.set(
    "n",
    "<leader>dp",
    open_diff_view_pr,
    { noremap = true, silent = true, desc = "Diffview open diff view by pull request modifyed file" }
)

vim.api.nvim_create_user_command("GhPrView", function()
    local cmd = { "gh", "pr", "view", "--web" }
    if vim.system then
        vim.system(cmd, { detach = true })
    else
        vim.fn.jobstart(cmd, { detach = true })
    end
end, { desc = "Open current branch's PR in browser" })
vim.keymap.set("n", "<Leader>bp", "<Cmd>GhPrView<CR>", { silent = true, desc = "Open PR in browser" })

vim.api.nvim_create_user_command("LiaryEdit", function()
    vim.system({ "liary", "edit", "--path" }, { text = true }, function(obj)
        if obj.code ~= 0 then
            vim.schedule(function()
                vim.notify("liary command failed", vim.log.levels.ERROR)
            end)
            return
        end

        local path = vim.trim(obj.stdout)

        if path ~= "" then
            vim.schedule(function()
                vim.cmd.edit(path)
            end)
        end
    end)
end, {})
vim.keymap.set("n", "<Leader><Leader>d", "<cmd>LiaryEdit<CR>")

-- Yank the URL part of the markdown link `[text](url)` under the cursor.
local function yank_markdown_link_url()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2] + 1

    local init = 1
    while true do
        local s, e, url = line:find("%[[^%]]*%]%(([^)]*)%)", init)
        if not s then
            break
        end
        if col >= s and col <= e then
            vim.fn.setreg(vim.v.register, url)
            vim.notify("Yanked: " .. url, vim.log.levels.INFO)
            return
        end
        init = e + 1
    end
    vim.notify("No markdown link under cursor", vim.log.levels.WARN)
end

vim.keymap.set("n", "yx", yank_markdown_link_url, { silent = true, desc = "Yank markdown link URL" })
