# Решение СЛАУ методом Якоби с помощью CUDA 8.0

### Сборка:
make

### Запуск:
./jacobi -f <input_file> -i <n_iterations> -b <block_size>

### Генерация тестов:
python gen_diag_dominant_matrix <size> <output_file>

### Формат входного файла:
N
a[1, 1], ..., a[1, N] b[1]
..................... ....
a[N, 1], ..., a[N, N] b[N]

