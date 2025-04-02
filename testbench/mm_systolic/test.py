import numpy as np

# 生成随机测试数据
np.random.seed(42)
A = np.random.randint(-128, 127, size=(8, 128), dtype=np.int8)
B = np.random.randint(-128, 127, size=(128, 8), dtype=np.int8)

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