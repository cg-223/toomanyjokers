---Essentially collects string.gmatch into a table
function string.split(str, split_by)
    str = str .. split_by
    local strs = {}
    for strng in string.gmatch(str, "(.-)" .. split_by) do
        strs[#strs + 1] = strng
    end

    return strs
end

---Takes the values of a table and turns them into keys with value true 
function table_into_hashset(tbl)
    local new = {}
    for i, v in pairs(tbl) do
        new[v] = true
    end
    setmetatable(new, {
        __newindex = function (t, k, v)
            assert(type(v) == "boolean", "misuse of hashset")
            rawset(t, k, v or nil)
        end,
        __index = function (t, k)
            if k == "set" then
                return function(self, key)
                    rawset(self, key, true)
                end
            else
                return rawget(t, k)
            end
        end
    })
    return new
end

function todo(msg, ...)
    msg = msg or ""
    error("Not yet implemented: " .. string.format(msg, ...))
end

function utils_unit_tests()
    local tbl = { "1", 2, "8" }
    local tbl2 = table_into_hashset(tbl)
    tbl2:set("three")
    assert(tbl2["1"] and tbl2[2] and tbl2["8"] and tbl2.three)
    assert(not (tbl2[1] or tbl2["hello"]))
    local str = "Hello, Whats up,,a"
    local split = string.split(str, ",")
    assert(split[1] == "Hello")
    assert(split[2] == " Whats up")
    assert(split[3] == "")
    assert(split[4] == "a")
    assert(split[5] == nil)
    assert(spaceless("your mom  whore") == "yourmomwhore")
    assert(lower_spaceless("YOUR MOM    whore") == "yourmomwhore")
    assert(math.clamp(1, 2, 3) == 2)
    assert(math.clamp(4, 1, 2) == 2)
end

function spaceless(str)
    return string.gsub(str, "%s", "")
end

function lower_spaceless(str)
    return string.lower(spaceless(str))
end

---Calls func with every element of tbl (via pairs). If func returns one value, tbl[i] = ret1. If func returns two values, tbl[ret1] = ret2. If func returns no value, do nothing.
function table.map(tbl, func)
    for i, v in pairs(tbl) do
        local kret, vret = func(i, v)
        if vret then
            tbl[kret or i] = vret
        elseif kret then
            tbl[i] = kret
        end
    end
end

---sometimes i wonder why these functions dont exist.
function math.clamp(num, min, max)
    max = max or math.huge
    min = min or -math.huge
    assert(min <= max)
    return math.min(math.max(num, min), max)
end

function collect(iter)
    local ret = {}
    for v in iter do
        ret[#ret+1] = v
    end
    return ret
end