if CeDebugLoad then print("[#Start] Loading ce.hub.data.DtoFieldAccess ...") end

local DtoFieldAccess = {}

function DtoFieldAccess.cached(source, readCachedValue, fieldName)
    if not source then return nil end
    if readCachedValue then
        local ok, value = pcall(readCachedValue, source)
        if ok then return value end
    end
    return source[fieldName]
end

function DtoFieldAccess.peek(readCachedValue, fieldName)
    return function (source) return DtoFieldAccess.cached(source, readCachedValue, fieldName) end
end

return DtoFieldAccess
