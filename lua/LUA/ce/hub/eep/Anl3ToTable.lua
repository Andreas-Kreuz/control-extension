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
    return str:gsub("[\xC2\xC3][\x80-\xBF]", function (seq)
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

local function readAnlageContent(filename)
    local file, err = io.open(filename, "r")
    if not file then
        return nil, "Anl3ToTable: cannot open file: " .. tostring(err)
    end

    local content = utf8ToLatin1(file:read("*a"))
    file:close()
    return content
end

local function appendTextToCurrentNode(stack, textContent)
    local trimmedText = textContent:match("^%s*(.-)%s*$")
    if trimmedText == "" then return end

    local currentNode = stack[#stack]
    currentNode.text = (currentNode.text or "") .. trimmedText
end

local function parseTag(tagContent)
    local firstCharacter = tagContent:sub(1, 1)
    if firstCharacter == "?" or firstCharacter == "!" then return nil end

    return {
        isClosing = firstCharacter == "/",
        isSelfClosing = tagContent:sub(-1) == "/",
        name = tagContent:match("^([%w_]+)"),
        attrs = parseAttrs(tagContent)
    }
end

local function applyTagToStack(stack, parsedTag)
    if parsedTag.isClosing then
        if #stack > 1 then table.remove(stack) end
        return
    end

    if not parsedTag.name then return end

    local node = { tag = parsedTag.name, attrs = parsedTag.attrs, children = {} }
    local currentNode = stack[#stack]
    currentNode.children[#currentNode.children + 1] = node
    if not parsedTag.isSelfClosing then
        stack[#stack + 1] = node
    end
end

local function parseXmlContent(content)
    local contentLength = #content

    local root = { tag = "root", attrs = {}, children = {} }
    local stack = { root }
    local position = 1

    while position <= contentLength do
        local ltPos = content:find("<", position, true)
        if not ltPos then break end

        if ltPos > position then
            appendTextToCurrentNode(stack, content:sub(position, ltPos - 1))
        end

        local gtPos = content:find(">", ltPos + 1, true)
        if not gtPos then break end

        local tagContent = content:sub(ltPos + 1, gtPos - 1)
        position = gtPos + 1

        local parsedTag = parseTag(tagContent)
        if parsedTag then applyTagToStack(stack, parsedTag) end
    end

    if #root.children == 1 then return root.children[1] end
    return root
end

function Anl3ToTable.loadAnlage(filename)
    local content, err = readAnlageContent(filename)
    if not content then return nil, err end

    return parseXmlContent(content)
end

return Anl3ToTable
