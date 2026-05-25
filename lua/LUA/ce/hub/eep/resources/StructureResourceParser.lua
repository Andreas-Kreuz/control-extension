if CeDebugLoad then print("[#Start] Loading ce.hub.eep.resources.StructureResourceParser ...") end

local StructureResourceParser = {}

local VALID_LANGUAGES = {
    ENG = true,
    GER = true,
    POL = true,
    FRA = true
}

local function emptyInfo()
    return {
        modelNamesByLanguage = {}
    }
end

local function unquote(value)
    return value:gsub('^%s*"', ""):gsub('"%s*$', "")
end

local function normalizePath(path)
    return (path or ""):gsub("/", "\\")
end

local function trimLeadingBackslashes(path)
    return (path or ""):gsub("^\\+", "")
end

local function iniPathForGsbname(gsbname)
    if type(gsbname) ~= "string" or gsbname == "" then return nil end

    local normalized = trimLeadingBackslashes(normalizePath(gsbname))
    local lower = string.lower(normalized)
    if string.sub(lower, -4) == ".3dm" then
        normalized = string.sub(normalized, 1, -5) .. ".ini"
    else
        normalized = normalized .. ".ini"
    end

    return "Resourcen\\" .. normalized,
        "Resourcen.unp\\" .. normalized
end

local function parseLine(line, info)
    local language, modelName = line:match("^%s*Name_(%a+)%s*=%s*(.-)%s*$")
    if language and modelName and VALID_LANGUAGES[language] then
        info.modelNamesByLanguage[language] = unquote(modelName)
    end
end

local function parseContent(content)
    local info = emptyInfo()
    if type(content) ~= "string" then return info end

    for line in (content .. "\n"):gmatch("([^\r\n]*)\r?\n") do
        parseLine(line, info)
    end

    return info
end

local function parseFirstExistingFile(paths)
    for _, path in ipairs(paths or {}) do
        local file = io.open(path, "r")
        if file then
            local content = file:read("*all")
            file:close()
            return parseContent(content)
        end
    end

    return emptyInfo()
end

local function modelNameForLanguage(info, language)
    local names = info and info.modelNamesByLanguage or {}
    return names[language or "GER"] or names.GER
end

function StructureResourceParser.parseContent(content)
    return parseContent(content)
end

function StructureResourceParser.parseFirstExistingFile(paths)
    return parseFirstExistingFile(paths)
end

function StructureResourceParser.infoForGsbname(gsbname)
    local primaryPath, fallbackPath = iniPathForGsbname(gsbname)
    if not primaryPath then return emptyInfo() end
    return parseFirstExistingFile({ primaryPath, fallbackPath })
end

function StructureResourceParser.iniPathForGsbname(gsbname)
    return iniPathForGsbname(gsbname)
end

function StructureResourceParser.modelNameForLanguage(info, language)
    return modelNameForLanguage(info, language)
end

return StructureResourceParser
