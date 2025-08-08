---Essentially collects string.gmatch into a table
function string.split(str, split_by, allow_magic)
    local magicchars = table_into_hashset {
        '.',
        '(',
        ')',
        '%',
        '+',
        '-',
        '*',
        '?',
        '[',
        '^',
        '$' }
    if not allow_magic then
        for _, char in string.gmatch(split_by, '.') do
            if magicchars[char] then
                error(
                    "Attempt to call string.split with a magic character in the splitter. If this is intentional, supply a third argument to string.split.")
            end
        end
    end
    local strs = {}
    for strng in string.gmatch(str, ".-" .. split_by) do
        strs[#strs + 1] = string.sub(strng, 1, #strng - 1)
    end
    local rev = string.reverse(str)
    local last = string.sub(string.reverse(string.match(rev, ".-" .. split_by)), 2)
    if last ~= "" then
        strs[#strs + 1] = last
    end
    return strs
end

---Takes the values of a table and turns them into keys with value true (or if arg2 is true, the keys of the original table)
function table_into_hashset(tbl, oldkeys)
    local new = {}
    for i, v in pairs(tbl) do
        new[v] = (oldkeys and i) or true
    end
    return new
end

function todo(msg, ...)
    msg = msg or ""
    error("Not yet implemented: " .. string.format(msg, ...))
end

function utils_unit_tests()
    local tbl = { "1", 2, "8" }
    local tbl2 = table_into_hashset(tbl)
    assert(tbl2["1"] and tbl2[2] and tbl2["8"])
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