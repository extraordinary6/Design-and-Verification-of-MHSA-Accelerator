import numpy as np

# ---------------------生成随机测试数据--------------------
np.random.seed(42)
input_x = np.random.randint(-128, 127, size=(32, 128), dtype=np.int8)
Wq = np.random.randint(-128, 127, size=(128, 128), dtype=np.int8)
Wk = np.random.randint(-128, 127, size=(128, 128), dtype=np.int8)
Wv = np.random.randint(-128, 127, size=(128, 128), dtype=np.int8)

with open('input_x.txt', 'w') as f:
    for col in range(128):
        column = input_x[:, col]                
        f.write(' '.join(f"{x}" for x in column) + '\n')  # 转置后保存

with open('Wq.txt', 'w') as f:
    for row in range(128):
        row_data = Wq[row, :]
        f.write(' '.join(f"{x}" for x in row_data) + '\n')  # 不需要转置

with open('Wk.txt', 'w') as f:
    for row in range(128):
        row_data = Wk[row, :]
        f.write(' '.join(f"{x}" for x in row_data) + '\n')

with open('Wv.txt', 'w') as f:
    for row in range(128):
        row_data = Wv[row, :]
        f.write(' '.join(f"{x}" for x in row_data) + '\n')


# ---------------------计算linear参考结果---------------------
linear_q_ref = np.dot(input_x.astype(np.int32), Wq.astype(np.int32))
linear_k_ref = np.dot(input_x.astype(np.int32), Wk.astype(np.int32))
linear_v_ref = np.dot(input_x.astype(np.int32), Wv.astype(np.int32))

# 量化 + 转置
linear_q_quantized = linear_q_ref.astype(np.int8)
linear_k_quantized = linear_k_ref.astype(np.int8)
linear_v_quantized = linear_v_ref.astype(np.int8)

linear_q_quantized_t = linear_q_quantized.T 
linear_k_quantized_t = linear_k_quantized.T
linear_v_quantized_t = linear_v_quantized.T

# -------------------计算 4-HEAD-QK------------------
# Q 和 K 矩阵均为 32x128，分 4 头 32x32 的矩阵进行分别计算，得到 4 头 32x32 的矩阵

# 将 Q 和 K 分成 4 个头，每个头处理 32 个特征维度
num_heads = 4
head_dim = 32

Q_heads = np.split(linear_q_quantized, num_heads, axis=1)
K_heads = np.split(linear_k_quantized, num_heads, axis=1)

QK_heads = []
for i in range(num_heads):
    QK = np.dot(Q_heads[i].astype(np.int32), K_heads[i].astype(np.int32).T)
    QK_heads.append(QK)

# 量化 + 转置
QK_heads_quantized = [QK.astype(np.int8) for QK in QK_heads]
QK_heads_quantized_t = [QK.T for QK in QK_heads_quantized]

# -------------------softmax & scale------------------
def scale_data(input_data):
    scaled_data = np.zeros_like(input_data, dtype=np.uint8)  # 使用无符号整数
    for i in range(input_data.shape[0]):
        for j in range(input_data.shape[1]):
            byte = np.uint8(input_data[i, j])  # 确保 byte 是无符号的
            scaled_byte = (byte >> 1) + (byte >> 3) + (byte >> 4) + (byte >> 6)
            scaled_data[i, j] = scaled_byte
    return scaled_data

# 对 QK_heads_quantized 的每个头进行缩放操作
scaled_QK_heads = [scale_data(QK) for QK in QK_heads_quantized]
scaled_QK_heads_t = [scaled_QK.T for scaled_QK in scaled_QK_heads]

# -------------------attention compute------------------
# 将 scaled_QK_heads 和 V 分成 4 个头，每个头处理 32 个特征维度
V_heads = np.split(linear_v_quantized, num_heads, axis=1)
# 计算注意力输出
attention_outputs = []
for i in range(num_heads):
    attention_output = np.dot(scaled_QK_heads[i].astype(np.int32), V_heads[i].astype(np.int32).T)
    attention_outputs.append(attention_output)

# 量化 + 转置
attention_quantized = [output.astype(np.int8) for output in attention_outputs]
attention_quantized_t = [output.T for output in attention_quantized]

#--------------------------linear层验证----------------------------
linear_q_output = []

for i in range(0, linear_q_quantized_t.size, 8):  # 每次取 8 个元素
    chunk = linear_q_quantized_t.flatten()[i:i+8]
    if len(chunk) < 8:
        break 
    bytes_data = chunk.astype(np.uint8).tobytes()  # 转换为无符号字节
    value = int.from_bytes(bytes_data, byteorder='big')
    hex_str = f"{value:016X}"  # 格式化为 16 位宽的十六进制字符串
    linear_q_output.append(hex_str)

with open('linear_q_output.txt', 'w') as f:
    for i in range(0, len(linear_q_output), 4):
        row = linear_q_output[i:i+4]
        f.write(' '.join(row) + '\n')
    
#--------------------------linear层验证----------------------------

#--------------------------QK层验证----------------------------
QK_output = []
for head in range(4):
    for i in range(0, QK_heads_quantized_t[head].size, 8):  # 每次取 8 个元素
        chunk = QK_heads_quantized_t[head].flatten()[i:i + 8]
        if len(chunk) < 8:
            break
        bytes_data = chunk.astype(np.uint8).tobytes()  # 转换为无符号字节
        value = int.from_bytes(bytes_data, byteorder='big')
        hex_str = f"{value:016X}"  # 格式化为 16 位宽的十六进制字符串
        QK_output.append(hex_str)

with open('qkmm_output.txt', 'w') as f:
    for i in range(0, len(QK_output), 4):
        row = QK_output[i:i+4]
        f.write(' '.join(row) + '\n')
#--------------------------QK层验证----------------------------

#--------------------------softmax层验证----------------------------
softmax_output = []
for head in range(4):
    for i in range(0, scaled_QK_heads_t[head].size, 8):  # 每次取 8 个元素
        chunk = scaled_QK_heads_t[head].flatten()[i:i+8]
        if len(chunk) < 8:
            break
        bytes_data = chunk.astype(np.uint8).tobytes()  # 转换为无符号字节
        value = int.from_bytes(bytes_data, byteorder='big')
        hex_str = f"{value:016X}"  # 格式化为 16 位宽的十六进制字符串
        softmax_output.append(hex_str)

with open('softmax_output.txt', 'w') as f:
    for i in range(0, len(softmax_output), 4):
        row = softmax_output[i:i+4]
        f.write(' '.join(row) + '\n')
#--------------------------softmax层验证----------------------------

#--------------------------attention层验证----------------------------
attention_output = []
for head in range(4):
    for i in range(0, attention_quantized_t[head].size, 8):  # 每次取 8 个元素
        chunk = attention_quantized_t[head].flatten()[i:i+8]
        if len(chunk) < 8:
            break
        bytes_data = chunk.astype(np.uint8).tobytes()  # 转换为无符号字节
        value = int.from_bytes(bytes_data, byteorder='big')
        hex_str = f"{value:016X}"  # 格式化为 16 位宽的十六进制字符串
        attention_output.append(hex_str)

with open('attmm_output.txt', 'w') as f:
    for i in range(0, len(attention_output), 4):
        row = attention_output[i:i+4]
        f.write(' '.join(row) + '\n')
#--------------------------attention层验证----------------------------




