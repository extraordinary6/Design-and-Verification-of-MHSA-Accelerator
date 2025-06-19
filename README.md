# MHSA-Accelerator

## Project Directory Structure

- **doc/**  
  Documentation and reports related to the accelerator.

- **img/**  
  Architecture images of the accelerator.
  
- **pnr/**  
  Files related to the physical design of the accelerator.

- **software/**  
  Software driver for the accelerator.

- **src/**  
  RTL design code of the accelerator.

- **synthesis/**  
  Files related to the synthesis of the accelerator.

- **testbench/**  
  Self-testing platform for the accelerator.

- **uvm_mhsa/**  
  UVM verification environment for the accelerator.

- **uvm_sim/**  
  Output results related to UVM verification.


## Division of Labor Table

| 姓  名 | 具体分工内容 | 工作量占比 |
|--------|--------------|-------------|
| 黄超凡 | 验证方案制定，UVM 验证平台的搭建、调试与仿真，随机化与断言设计，验证报告撰写；加速器的挂载，软件驱动设计与仿真，系统集成功能验证报告撰写。 | 1/3 |
| 张博文 | 加速器中 Softmax、Scale 模块的 RTL 实现，Model 组件功能模型实现，设计报告撰写；加速器的逻辑综合与物理设计，加速器后端设计报告撰写。 | 1/3 |
| 汪子尧 | 设计 SPEC 制定，加速器中 Linear 等其余模块的 RTL 实现及顶层设计，设计报告撰写；加速器 ICB 接口设计，软件驱动功能验证，系统集成功能验证报告撰写。 | 1/3 |
