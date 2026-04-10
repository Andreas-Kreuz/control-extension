if CeDebugLoad then print("[#Start] Loading ce.hub.eep.Anl3ToTable ...") end

-- Generic pure Lua XML parser for EEP .anl3 files.
-- Does not call external tools or libraries.
--
-- Returns the full XML tree as nested Lua tables:
--   node = {
--     tag      = "TagName",          -- element name
--     attrs    = { key = "value" },  -- all attributes
--     children = { node, ... },      -- child elements (array)
--     text     = "content",          -- text content, only set when non-empty
--   }

local Anl3ToTable = {}

-- Convert UTF-8 encoded string to Latin-1 (Windows-1252).
-- EEP uses Latin-1 internally, but .anl3 files are UTF-8.
-- Only 2-byte UTF-8 sequences (U+0080..U+00FF) map to Latin-1;
-- anything outside that range is left unchanged.
local function utf8ToLatin1(str)
    return str:gsub("[\xC2\xC3][\x80-\xBF]", function(seq)
        local b1, b2 = seq:byte(1), seq:byte(2)
        local cp = (b1 - 0xC0) * 64 + (b2 - 0x80)
        return string.char(cp)
    end)
end

local function parseAttrs(s)
    local attrs = {}
    for k, v in s:gmatch("([%w_]+)%s*=%s*\"([^\"]*)\"") do
        attrs[k] = v
    end
    return attrs
end

function Anl3ToTable.loadAnlage(filename)
    local file, err = io.open(filename, "r")
    if not file then
        return nil, "Anl3ToTable: cannot open file: " .. tostring(err)
    end
    local content = utf8ToLatin1(file:read("*a"))
    file:close()

    local root = { tag = "root", attrs = {}, children = {} }
    local stack = { root }
    local pos = 1
    local len = #content

    while pos <= len do
        local ltPos = content:find("<", pos, true)
        if not ltPos then break end

        if ltPos > pos then
            local trimmed = content:sub(pos, ltPos - 1):match("^%s*(.-)%s*$")
            if trimmed ~= "" then
                local current = stack[#stack]
                current.text = (current.text or "") .. trimmed
            end
        end

        local gtPos = content:find(">", ltPos + 1, true)
        if not gtPos then break end

        local tagContent = content:sub(ltPos + 1, gtPos - 1)
        pos = gtPos + 1

        local first = tagContent:sub(1, 1)

        if first == "/" then
            if #stack > 1 then table.remove(stack) end
        elseif first ~= "?" and first ~= "!" then
            local isSelf = tagContent:sub(-1) == "/"
            local tagName = tagContent:match("^([%w_]+)")
            if tagName then
                local node = { tag = tagName, attrs = parseAttrs(tagContent), children = {} }
                local current = stack[#stack]
                current.children[#current.children + 1] = node
                if not isSelf then
                    stack[#stack + 1] = node
                end
            end
        end
    end

    if #root.children == 1 then return root.children[1] end
    return root
end

return Anl3ToTable
