require "Math/Math"

vec = Vector4.new(1, 2, 3, 4)

last = os.clock()
for i = 1, 100000 do
    vec = vec / 1.1
end

print("vec div:", os.clock - last)
last = os.clock()

x, y, z, w = 1, 2, 3, 4
for i = 1, 100000 do
    x = x / 1.1
    y = y / 1.1
    z = z / 1.1
    w = w / 1.1
end

print("xyzw div:", os.clock - last)
last = os.clock()
