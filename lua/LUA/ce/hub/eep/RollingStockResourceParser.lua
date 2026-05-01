if CeDebugLoad then print("[#Start] Loading ce.hub.eep.RollingStockResourceParser ...") end

local RollingStockResourceParser = {}

local FLOAT_ONE_BYTES = string.char(0, 0, 128, 63)
local MATRIX_SIZE_MARKER = string.char(4, 0, 0, 0, 4, 0, 0, 0)
local RELATION_NAME_MARKER = string.char(189, 55, 134, 53)

-- Rolling stock axis metadata comes from two resource files:
--
-- * The .ini file contains entries like MovAxis8_GER = "Heckfluegel".
--   The number in MovAxis<N> is not the runtime number used by
--   EEPRollingstockSetAxisByNumber. In EEP 18 tests, the INI value is the
--   visible axis name and the name accepted by EEPRollingstockGetAxis /
--   EEPRollingstockSetAxis. The original MovAxis<N> number is kept below as
--   sourceNumber/rawAxisNames for diagnostics only.
--
-- * The .3dm file contains structural axis records. Their record order is
--   useful as a structural index, but it is not the runtime ByNumber slot.
--   Records whose name starts with "_" are internal. Public records are used
--   as visible axis names only when the .ini file has no MovAxis entries.
--
-- * EEP exposes visible axes as a compact list numbered from 1..N. Current
--   evidence shows this list is sorted by displayed name, with digits before
--   letters. Therefore axisNames/axisNamesByLanguage produced by infoForXmlModel
--   are compact visible-axis maps, while rawAxisNames/rawAxisNamesByLanguage
--   retain the original INI numbers.

local function emptyInfo()
    return {
        axisNames = {},
        axisNamesByLanguage = {},
        rawAxisNames = {},
        rawAxisNamesByLanguage = {},
        parsed3dmAxes = {},
        visibleAxisInfos = {},
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

local function modelPathForXmlModel(xmlModel)
    if type(xmlModel) ~= "string" or xmlModel == "" then return nil end

    local normalized = normalizePath(xmlModel)
    return "Resourcen\\Rollmaterial\\" .. normalized,
        "Resourcen.unp\\Rollmaterial\\" .. normalized
end

local function readFile(path, mode)
    local file = io.open(path, mode or "rb")
    if not file then return nil end

    local content = file:read("*all")
    file:close()
    return content
end

local function sortedNumberKeys(values)
    local keys = {}
    for key in pairs(values or {}) do
        local numberKey = tonumber(key)
        if numberKey then keys[#keys + 1] = numberKey end
    end
    table.sort(keys)
    return keys
end

local function tableSize(values)
    local count = 0
    for _ in pairs(values or {}) do count = count + 1 end
    return count
end

local function stringAt(data, position, length)
    local raw = string.sub(data, position, position + length - 1)
    if #raw ~= length then return nil end

    for index = 1, #raw do
        local byte = string.byte(raw, index)
        if byte < 32 or byte > 126 then return nil end
    end

    return raw
end

local function readUint32Le(data, position)
    local b1, b2, b3, b4 = string.byte(data, position, position + 3)
    if not b4 then return nil end
    return b1 + b2 * 256 + b3 * 65536 + b4 * 16777216
end

local function countPlain(value, pattern)
    local count = 0
    local position = 1
    while true do
        local found = string.find(value, pattern, position, true)
        if not found then return count end
        count = count + 1
        position = found + 1
    end
end

local function hasWordBytes(value)
    return string.find(value, "%a%a%a%a") ~= nil
end

local function isAxisRecordName(name)
    if type(name) ~= "string" or name == "" then return false end
    if string.find(name, "[^A-Za-z0-9_ %.,%+%(%)%/%<%>%:%-]") then return false end

    local letters = 0
    for _ in string.gmatch(name, "%a") do letters = letters + 1 end
    return letters >= 2 and letters / #name >= 0.45
end

local function markerPositions(data)
    local positions = {}
    local position = string.find(data, MATRIX_SIZE_MARKER, 1, true)
    while position do
        positions[#positions + 1] = position
        position = string.find(data, MATRIX_SIZE_MARKER, position + 1, true)
    end
    return positions
end

local function isEmbeddedReferenceName(data, previousAxis, offset)
    if not previousAxis then return false end

    local distance = offset - previousAxis.offset
    if distance >= 180 then return false end

    local previousNameEnd = previousAxis.offset + 4 + #previousAxis.name
    local between = string.sub(data, previousNameEnd, offset - 1)
    return distance < 180 or string.find(between, RELATION_NAME_MARKER, 1, true) ~= nil
end

local function read3dmAxisCandidateAt(data, position)
    local nameLength = readUint32Le(data, position)
    if not nameLength or nameLength < 1 or nameLength > 80 then return nil end

    local name = stringAt(data, position + 4, nameLength)
    if not name or not isAxisRecordName(name) then return nil end

    local previousRecordBytes = string.sub(data, math.max(1, position - 128), position - 1)
    local previousLocalBytes = string.sub(data, math.max(1, position - 48), position - 1)
    local hasMatrix = countPlain(previousRecordBytes, FLOAT_ONE_BYTES) >= 3
    if not hasMatrix or hasWordBytes(previousLocalBytes) then return nil end

    return {
        offset = position,
        name = name
    }
end

local function collect3dmAxisCandidates(data)
    local candidates = {}
    local candidatePositions = {}

    for _, markerPosition in ipairs(markerPositions(data)) do
        local searchStart = markerPosition + #MATRIX_SIZE_MARKER
        local searchEnd = math.min(#data - 4, markerPosition + 128)
        for position = searchStart, searchEnd do
            if not candidatePositions[position] then
                local candidate = read3dmAxisCandidateAt(data, position)
                if candidate then
                    candidatePositions[position] = true
                    candidates[#candidates + 1] = candidate
                end
            end
        end
    end

    return candidates
end

local function build3dmAxisList(data, candidates)
    local axes = {}
    for _, candidate in ipairs(candidates) do
        if not isEmbeddedReferenceName(data, axes[#axes], candidate.offset) then
            axes[#axes + 1] = {
                index = #axes + 1,
                name = candidate.name,
                isPublic = string.sub(candidate.name, 1, 1) ~= "_",
                offset = candidate.offset
            }
        end
    end
    return axes
end

local function currentLanguageAxisNames(info, language)
    local axisNamesByLanguage = info.rawAxisNamesByLanguage or info.axisNamesByLanguage or {}
    return axisNamesByLanguage[language or "GER"] or axisNamesByLanguage.GER
        or info.rawAxisNames or info.axisNames or {}
end

local function addUniqueName(axisInfos, seenNames, axisName, sourceNumber, source)
    if type(axisName) ~= "string" or axisName == "" or seenNames[axisName] then return end

    seenNames[axisName] = true
    axisInfos[#axisInfos + 1] = {
        name = axisName,
        sourceNumber = sourceNumber,
        source = source
    }
end

local function buildVisibleAxisInfos(info, language)
    local axisInfos = {}
    local seenNames = {}
    local languageAxisNames = currentLanguageAxisNames(info, language)

    if tableSize(languageAxisNames) > 0 then
        for _, axisNumber in ipairs(sortedNumberKeys(languageAxisNames)) do
            addUniqueName(axisInfos, seenNames, languageAxisNames[axisNumber], axisNumber, "ini")
        end
    else
        for _, axis in ipairs(info.parsed3dmAxes or {}) do
            if axis.isPublic then addUniqueName(axisInfos, seenNames, axis.name, axis.index, "3dm") end
        end
    end

    table.sort(axisInfos, function (left, right)
        return left.name < right.name
    end)

    for index, axis in ipairs(axisInfos) do axis.axisNumber = index end
    return axisInfos
end

local function applyVisibleAxisNames(info)
    info.visibleAxisInfos = buildVisibleAxisInfos(info, "GER")
    info.axisNames = {}
    info.axisNamesByLanguage = {}

    for _, axis in ipairs(info.visibleAxisInfos) do info.axisNames[axis.axisNumber] = axis.name end

    for language in pairs(info.rawAxisNamesByLanguage or {}) do
        info.axisNamesByLanguage[language] = {}
        for _, axis in ipairs(buildVisibleAxisInfos(info, language)) do
            info.axisNamesByLanguage[language][axis.axisNumber] = axis.name
        end
    end

    if not info.axisNamesByLanguage.GER then info.axisNamesByLanguage.GER = info.axisNames end
    return info
end

local function parseLine(line, info)
    local axisNumber, language, axisName = line:match("^%s*MovAxis(%d+)_(%a+)%s*=%s*(.-)%s*$")
    if axisNumber and axisName and
        (language == "ENG" or language == "GER" or language == "POL" or language == "FRA") then
        local number = tonumber(axisNumber)
        if not number then return end
        info.rawAxisNamesByLanguage[language] = info.rawAxisNamesByLanguage[language] or {}
        info.rawAxisNamesByLanguage[language][number] = unquote(axisName)
        info.axisNamesByLanguage[language] = info.axisNamesByLanguage[language] or {}
        info.axisNamesByLanguage[language][number] = info.rawAxisNamesByLanguage[language][number]
        if language == "GER" then
            info.rawAxisNames[number] = info.rawAxisNamesByLanguage[language][number]
            info.axisNames[number] = info.rawAxisNamesByLanguage[language][number]
        end
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
        print(string.format("Rolling stock resource ini file not found: %s", path))
        return emptyInfo()
    end

    local content = file:read("*all")
    file:close()
    return RollingStockResourceParser.parseContent(content)
end

function RollingStockResourceParser.parse3dmContent(data)
    local content = data or ""
    return build3dmAxisList(content, collect3dmAxisCandidates(content))
end

function RollingStockResourceParser.parseFirstExisting3dm(paths)
    for _, path in ipairs(paths or {}) do
        local data = readFile(path, "rb")
        if data then return RollingStockResourceParser.parse3dmContent(data), path end
    end
    return {}, nil
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

    print(string.format("Rolling stock resource ini file not found: %s", table.concat(paths or {}, " or ")))
    return emptyInfo()
end

function RollingStockResourceParser.infoForXmlModel(xmlModel)
    local primaryPath, fallbackPath = iniPathForXmlModel(xmlModel)
    if not primaryPath then return emptyInfo() end

    local info = RollingStockResourceParser.parseFirstExistingFile({ primaryPath, fallbackPath })
    info.xmlModel = xmlModel

    local primaryModelPath, fallbackModelPath = modelPathForXmlModel(xmlModel)
    local ok, axesOrError, path = pcall(
        RollingStockResourceParser.parseFirstExisting3dm,
        { primaryModelPath, fallbackModelPath })
    if ok then
        info.parsed3dmAxes = axesOrError
        info.parsed3dmAxisPath = path
    else
        info.parsed3dmAxes = {}
        info.parserError = tostring(axesOrError)
    end

    return applyVisibleAxisNames(info)
end

function RollingStockResourceParser.iniPathForXmlModel(xmlModel)
    return iniPathForXmlModel(xmlModel)
end

function RollingStockResourceParser.modelPathForXmlModel(xmlModel)
    return modelPathForXmlModel(xmlModel)
end

function RollingStockResourceParser.applyVisibleAxisNames(info)
    return applyVisibleAxisNames(info)
end

return RollingStockResourceParser
