require "Math/Math"

function string_split(s, d)
    local t = {}
    local i = 0
    local f
    local match = "(.-)" .. d .. "()"

    if string.find(s, d) == nil then
        return {s}
    end

    for sub, j in string.gmatch(s, match) do
        i = i + 1
        t[i] = sub
        f = j
    end

    if i ~= 0 then
        t[i + 1] = string.sub(s, f)
    end

    return t
end

test = "f 47/242 103/543 119/631"
local l = string_split(test, "%s+")
print(l[1], l[2], l[3], l[4])
