import numpy as np

# 生成随机测试数据
np.random.seed(42)
A = np.random.randint(-128, 127, size=(32, 128), dtype=np.int8)
B = np.random.randint(-128, 127, size=(128, 128), dtype=np.int8)

with open('row_data.txt', 'w') as f:
    for col in range(128):
        column = A[:, col]
        f.write(' '.join(f"{x}" for x in column) + '\n')  # 直接保存 int8 十进制

with open('col_data.txt', 'w') as f:
    for row in range(128):
        row_data = B[row, :]
        f.write(' '.join(f"{x}" for x in row_data) + '\n')  # 直接保存 int8 十进制

# 计算参考结果
C_ref = np.dot(A.astype(np.int32), B.astype(np.int32))
np.savetxt('ref_result.txt', C_ref, fmt='%d')

# 量化参数
C_quantized = C_ref.astype(np.int8)
np.savetxt('quantized_result.txt', C_quantized, fmt='%d')

# 转置存储
C_quantized_T = C_quantized.T  # 转置以便后续处理
np.savetxt('quantized_transposed_result.txt', C_quantized_T, fmt='%d')

# 将 8 个 8 位整数打包成 64 位数据并保存为十六进制
hex_output = []
for i in range(0, C_quantized_T.size, 8):  # 每次取 8 个元素
    chunk = C_quantized_T.flatten()[i:i+8]  # 取出 8 个元素
    if len(chunk) < 8:
        break  # 如果不足 8 个元素则跳过（这里假设数据大小是 8 的倍数）
    # 转换为字节并拼接成 64 位整数
    bytes_data = chunk.astype(np.uint8).tobytes()  # 转换为无符号字节
    value = int.from_bytes(bytes_data, byteorder='big')  # 大端序转换为整数
    hex_str = f"{value:016X}"  # 格式化为 16 位宽的十六进制字符串
    hex_output.append(hex_str)

# 将结果按 128 行 4 列排列并保存到文件
with open('quantized_packed_result.txt', 'w') as f:
    for i in range(0, len(hex_output), 4):
        row = hex_output[i:i+4]
        f.write(' '.join(row) + '\n')


