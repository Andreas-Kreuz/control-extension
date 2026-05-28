---@meta

---@class SpecStubAssertion
---@field was_called fun(...):nil
---@field was_called_with fun(...):nil
---@field was_not_called fun():nil
---@field was_not_called_with fun(...):nil

---@class SpecAssertCallable
---@field errors fun(fn: fun(), message?: string):nil

---@class SpecAssertAre
---@field same fun(expected: any, actual: any, message?: string):nil
---@field equals fun(expected: any, actual: any, message?: string):nil
---@field equal fun(expected: any, actual: any, message?: string):nil
---@field is_same fun(expected: any, actual: any, message?: string):nil

---@class SpecAssert
---@field are SpecAssertAre
---@field same fun(expected: any, actual: any, message?: string):nil
---@field matches fun(pattern: string, value: any, ...):nil
---@field not_match fun(pattern: string, value: any, ...):nil
---@field equals fun(expected: any, actual: any, message?: string):nil
---@field equal fun(expected: any, actual: any, message?: string):nil
---@field is_same fun(expected: any, actual: any, message?: string):nil
---@field is_not_equal fun(expected: any, actual: any, message?: string):nil
---@field is_true fun(value: any, message?: string):nil
---@field is_false fun(value: any, message?: string):nil
---@field is_nil fun(value: any, message?: string):nil
---@field is_not_nil fun(value: any, message?: string):nil
---@field is_truthy fun(value: any, message?: string):nil
---@field is_falsy fun(value: any, message?: string):nil
---@field has_no SpecAssertCallable
---@field has_error SpecAssertCallable
---@field stub fun(stub: SpecStub):SpecStubAssertion
---@overload fun(value: any, message?: string): any
assert = {}

---@class SpecStub
---@field revert fun(self: SpecStub):nil

---@type fun(target: table, key: string, replacement?: any): SpecStub
stub = function (...) end

---@type fun(callback: fun())
finally = function (...) end
