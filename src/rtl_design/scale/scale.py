def scale(input_bar):
    """
    模拟 Verilog 的 scale 模块功能，对输入的 64 位数据进行缩放点积操作。
    
    参数:
    input_bar -- 64 位输入数据（整数列表，包含 8 个 8 位数）
    
    返回:
    output_bar -- 64 位输出数据（整数列表，包含 8 个 8 位数）
    output_valid -- 输出有效标志（布尔值）
    """
    output_bar = [0] * 8  # 初始化输出列表
    output_valid = False
    
    # 检查输入是否有效（假设 bar_valid 为 True）
    bar_valid = True
    
    if bar_valid:
        output_valid = True
        for i in range(8):
            # 提取第 i 个 8 位数据
            byte = input_bar[i]
            
            # 进行位移操作并相加，相当于乘以 45/255
            scaled_byte = (byte >> 1) + (byte >> 3) + (byte >> 4) + (byte >> 6)
            
            # 限制结果在 0 到 255 之间
            scaled_byte = max(0, min(255, scaled_byte))
            
            # 将结果存入输出列表
            output_bar[i] = scaled_byte
    else:
        output_valid = False
    
    return output_bar, output_valid

# 示例用法
if __name__ == "__main__":
    # 示例输入：64 位数据（8 个 8 位数）
    input_data = [1, 2, 3, 4, 5, 6, 7, 8]
    
    # 调用 scale 函数
    output_data, valid = scale(input_data)
    
    # 打印输出结果
    print("输入数据：", input_data)
    print("输出数据：", output_data)
    print("输出有效：", valid)