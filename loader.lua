local path = ... .. "."
local loader = {}

loader.version = "0.0.2"

function loader.load(file)
    assert(file_exists(file), "File not found: " .. file)

    local get_lines

    if love then
        get_lines = love.filesystem.lines
    else
        get_lines = io.lines
    end

    local lines = {}

    for line in get_lines(file) do
        table.insert(lines, line)
    end

    return loader.parse(lines)
end

function loader.parse(object)
    local obj = {
        v = {}, -- List of vertices - x, y, z, [w]=1.0
        vt = {}, -- Texture coordinates - u, v, [w]=0
        vn = {}, -- Normals - x, y, z
        vp = {}, -- Parameter space vertices - u, [v], [w]
        f = {} -- Faces
    }

    for _, line in ipairs(object) do
        local l = string_split(line, "%s+")

        if l[1] == "v" then
            local v = Vector4(tonumber(l[2]), tonumber(l[3]), tonumber(l[4]), tonumber(l[5]) or 1.0)
            table.insert(obj.v, v)
        elseif l[1] == "vt" then
            local vt = Vector4(tonumber(l[2]), tonumber(l[3]), tonumber(l[4]) or 0)
            table.insert(obj.vt, vt)
        elseif l[1] == "vn" then
            local vn = Vector4(tonumber(l[2]), tonumber(l[3]), tonumber(l[4]))
            table.insert(obj.vn, vn)
        elseif l[1] == "vp" then
            local vp = {
                u = tonumber(l[2]),
                v = tonumber(l[3]),
                w = tonumber(l[4])
            }
            table.insert(obj.vp, vp)
        elseif l[1] == "f" then
            if #l >= 5 and l[5] ~= "" then
                temp = l[5]
                l[5] = l[4]
                l[6] = temp
                l[7] = l[2]
            end
            for i = 2, #l, 3 do
                local f = {}

                for j = i, i + 2 do
                    local split = string_split(l[j], "/")
                    local v = {}

                    v.v = tonumber(split[1])
                    if #split >= 2 then
                        v.vt = tonumber(split[2])
                    end
                    if #split >= 3 then
                        v.vn = tonumber(split[3])
                    end

                    f[#f + 1] = v
                end
                table.insert(obj.f, f)
            end
        end
    end

    return obj
end

function file_exists(file)
    if love then
        return love.filesystem.getInfo(file) ~= nil
    end

    local f = io.open(file, "r")
    if f then
        f:close()
    end
    return f ~= nil
end

-- http://wiki.interfaceware.com/534.html
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

return loader
