local Matrix = require("Math/Math")

matrix1 =
    Matrix {
    {1, 0, 0, 0},
    {0, 1, 0, 0},
    {0, 0, 1, 0},
    {0, 0, -1, 0}
}

test = {1}
table.insert(test, 2)
print(test[1], test[2])
