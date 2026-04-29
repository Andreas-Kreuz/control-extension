if CeDebugLoad then print("[#Start] Loading ce.hub.eep.RollingStockResourceParser ...") end

local RollingStockResourceParser = {}

local function emptyInfo()
    return {
        axisNames = {},
        textureNames = {}
    }
end

local function unquote(value)
    return value:gsub('^%s*"', ""):gsub('"%s*$', "")
end

local function normalizePath(path)
    return (path or ""):gsub("/", "\\")
end

local function iniPathForXmlModel(xmlModel)
    if type(xmlModel) ~= "string" or xmlModel == "" then return nil end

    local normalized = normalizePath(xmlModel)
    local lower = string.lower(normalized)
    if string.sub(lower, -4) == ".3dm" then
        normalized = string.sub(normalized, 1, -5) .. ".ini"
    else
        normalized = normalized .. ".ini"
    end

    return "Resourcen\\Rollmaterial\\" .. normalized,
        "Resourcen.unp\\Rollmaterial\\" .. normalized
end

local function parseLine(line, info)
    local axisNumber, axisName = line:match("^%s*MovAxis(%d+)_GER%s*=%s*(.-)%s*$")
    if axisNumber and axisName then
        info.axisNames[tonumber(axisNumber)] = unquote(axisName)
        return
    end

    local textureNumber, textureName = line:match("^%s*TexText(%d+)_GER%s*=%s*(.-)%s*$")
    if textureNumber and textureName then
        info.textureNames[tonumber(textureNumber)] = unquote(textureName)
    end
end

function RollingStockResourceParser.parseContent(content)
    local info = emptyInfo()
    if type(content) ~= "string" then return info end

    for line in (content .. "\n"):gmatch("([^\r\n]*)\r?\n") do
        parseLine(line, info)
    end

    return info
end

function RollingStockResourceParser.parseFile(path)
    if type(path) ~= "string" or path == "" then return emptyInfo() end

    local file = io.open(path, "r")
    if not file then
        print("Rolling stock resource ini file not found: " .. path)
        return emptyInfo()
    end

    local content = file:read("*all")
    file:close()
    return RollingStockResourceParser.parseContent(content)
end

function RollingStockResourceParser.parseFirstExistingFile(paths)
    for _, path in ipairs(paths or {}) do
        local file = io.open(path, "r")
        if file then
            local content = file:read("*all")
            file:close()
            return RollingStockResourceParser.parseContent(content)
        end
    end

    print("Rolling stock resource ini file not found: " .. table.concat(paths or {}, " or "))
    return emptyInfo()
end

function RollingStockResourceParser.infoForXmlModel(xmlModel)
    local primaryPath, fallbackPath = iniPathForXmlModel(xmlModel)
    if not primaryPath then return emptyInfo() end

    return RollingStockResourceParser.parseFirstExistingFile({ primaryPath, fallbackPath })
end

function RollingStockResourceParser.iniPathForXmlModel(xmlModel)
    return iniPathForXmlModel(xmlModel)
end

return RollingStockResourceParser
