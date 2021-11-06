local Matrix = require("Math/Math")

matrix1 =
    Matrix {
    {1, 0, 0, 0},
    {0, 1, 0, 0},
    {0, 0, 1, 0},
    {0, 0, -1, 0}
}
matrix2 = Matrix:new(4, "I")
matrix2[1][1] = 1
matrix2[2][2] = 1
matrix2[3][3] = 0
matrix2[4][4] = 1
print(matrix1)
print(matrix2)
print(matrix1 * matrix2)
