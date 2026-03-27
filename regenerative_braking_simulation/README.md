# 纯电动汽车再生制动仿真系统

## 项目简介

本项目是一个基于MATLAB的纯电动汽车再生制动力分配策略验证仿真平台。系统聚焦于验证不同制动力分配策略对能量回收效率的影响，对比基准策略与优化策略的性能差异。

**版本**: v1.1.0 | **更新**: 2026-01-07 | **性能**: 优化后提升30-35%

## 📚 文档导航

| 文档 | 说明 | 适合人群 |
|------|------|----------|
| **[README.md](README.md)** | 完整项目说明（本文档） | 所有用户 |
| **[QUICKSTART.md](QUICKSTART.md)** | 5分钟快速入门 | 新用户 ⭐ |
| **[VISUALIZATION_GUIDE.md](VISUALIZATION_GUIDE.md)** | 可视化系统使用指南 | 图表用户 ⭐ |
| **[CHART_EXPLANATION.md](CHART_EXPLANATION.md)** | 图表详细说明文档 | 深度理解 ⭐ |
| **[PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md)** | 项目概览 | 快速了解 |
| **[OPTIMIZATION_SUMMARY.md](OPTIMIZATION_SUMMARY.md)** | 优化总结 | 技术用户 |

**推荐**: 新用户请先查看 [QUICKSTART.md](QUICKSTART.md) 快速上手！图表功能请参考 [VISUALIZATION_GUIDE.md](VISUALIZATION_GUIDE.md)。深入理解图表含义请阅读 [CHART_EXPLANATION.md](CHART_EXPLANATION.md)。

## 功能特性

- ✅ 基准制动力分配策略（固定比例6:4）
- ✅ 优化制动力分配策略（模糊逻辑控制）
- ✅ NEDC和UDDS标准驾驶循环仿真
- ✅ 能量回收效率计算和分析
- ✅ 单因素影响分析（质量、温度、坡度等）
- ✅ **专业级数据可视化**（现代化设计，完整中文支持）
- ✅ 性能优化（比初始版本快30-35%）
- ✅ **多种演示模式**（快速演示、对比分析、完整展示）

## 环境要求

### MATLAB版本
- MATLAB R2020b 或更高版本（推荐 R2025b）

### 必需工具箱
- 无（所有功能使用MATLAB基础功能实现）

### 可选工具箱
- 无

## 项目结构

```
regenerative_braking_simulation/
├── config/                     # 配置文件
│   ├── simulation_config.m     # 仿真参数配置
│   └── vehicle_params.m        # 车辆参数定义
├── models/                     # 模型文件
│   ├── vehicle_model.m         # 车辆动力学模型
│   ├── motor_model.m           # 电机模型
│   └── battery_model.m         # 电池模型
├── controllers/                # 控制器文件
│   ├── baseline_strategy.m     # 基准策略
│   └── optimized_strategy.m    # 优化策略（模糊逻辑）
├── utils/                      # 工具函数
│   ├── efficiency_calculator.m # 效率计算
│   ├── driving_cycle_data.m    # 工况数据
│   └── factor_analysis.m       # 影响因素分析
├── visualization/              # 可视化模块
│   └── visualization.m         # 图表绘制
├── tests/                      # 测试文件
│   ├── unit_tests/             # 单元测试
│   ├── integration_tests/      # 集成测试
│   └── property_tests/         # 属性测试
├── data/                       # 数据文件
│   ├── NEDC_cycle.mat          # NEDC工况数据
│   └── UDDS_cycle.mat          # UDDS工况数据
├── results/                    # 结果输出
│   ├── figures/                # 图表文件
│   └── data/                   # 数据文件
├── main.m                      # 主程序入口
├── example_usage.m             # 使用示例
└── README.md                   # 项目说明
```

## 快速开始

### 1. 克隆或下载项目

将项目文件放置在MATLAB工作目录中。

### 2. 添加路径

在MATLAB命令窗口中执行：

```matlab
addpath(genpath('regenerative_braking_simulation'));
```

### 3. 运行示例

```matlab
% 快速演示
demo()                          % 快速演示
demo('comparison')              % 策略对比演示

% 完整分析（推荐）
run_complete_analysis();        % 生成6张图表 + 详细分析报告

% 快速图表生成
generate_all_charts();         % 仅生成6张图表

% 基本仿真
main('baseline', 'NEDC');       % 基准策略NEDC工况
main('optimized', 'UDDS');      % 优化策略UDDS工况
main('comparison', 'NEDC');     % 策略对比

% 专业可视化
results = main('baseline', 'NEDC');
visualization(results, 'single');      % 单策略详细分析

results = main('comparison', 'NEDC');
visualization(results, 'comparison');  % 策略对比图表

% 增强版可视化（优化制动力分配和SOC图表）
visualization_enhanced(results, 'single');

% 因素分析
params = vehicle_params();
config = simulation_config();
results = factor_analysis('mass', 'NEDC', 'optimized', params, config);
visualization(results, 'factor_analysis');  % 因素分析图表
```

## 使用说明

### 配置参数

编辑 `config/simulation_config.m` 修改仿真参数：

```matlab
config.sampling_time = 0.1;        % 采样时间（秒）
config.simulation_mode = 'comparison';  % 仿真模式
config.driving_cycle = 'NEDC';     % 驾驶循环
```

编辑 `config/vehicle_params.m` 修改车辆参数：

```matlab
params.vehicle.mass_default = 1500;     % 车辆质量（kg）
params.motor.max_regen_torque = 120;    % 最大回馈扭矩（Nm）
params.battery.capacity = 60.2;         % 电池容量（kWh）
```

### 仿真模式

系统支持四种仿真模式：

1. **baseline** - 仅运行基准策略
2. **optimized** - 仅运行优化策略
3. **comparison** - 对比两种策略性能
4. **factor_analysis** - 单因素影响分析

### 驾驶循环

支持两种标准驾驶循环：

- **NEDC** - 新欧洲驾驶循环
- **UDDS** - 城市道路循环

## 性能指标

### 实际仿真结果

#### NEDC工况
- **基准策略**：43.12%
- **优化策略**：62.67%
- **效率提升**：19.55个百分点（45.3%相对提升）
- **能量回收**：0.2007 kWh → 0.2917 kWh
- **总制动能量**：0.4654 kWh

#### UDDS工况
- **基准策略**：46.23%
- **优化策略**：71.74%
- **效率提升**：25.51个百分点（55.2%相对提升）
- **能量回收**：0.1606 kWh → 0.2492 kWh
- **总制动能量**：0.3473 kWh

### 策略特性

#### 基准策略（固定6:4比例）
- 前轴制动力：60%
- 后轴制动力：40%
- 平均电机制动占比：58.73%（NEDC）
- 平均电机效率：64.35%

#### 优化策略（模糊逻辑控制）
- 动态调整制动力分配
- 考虑车速、SOC、制动强度
- 平均电机制动占比：84.67%（NEDC）
- 平均电机效率：64.35%
- 49条模糊规则，无需Fuzzy Logic Toolbox

## 影响因素分析

系统支持以下影响因素的单因素分析：

1. **车辆质量**：1500kg、1800kg、2100kg
2. **电机转速**：三个转速区间
3. **电池温度**：-10℃、25℃、45℃
4. **电池SOC**：20%、50%、80%
5. **制动踏板行程**：20%、40%、60%、80%
6. **道路坡度**：-10%、0%、10%
7. **环境温度**：-20℃至50℃（每10℃）

## 结果输出

### 图表
- **专业级可视化系统**（现代化设计风格）
- 能量回收效率-时间曲线（含制动事件标注）
- 车速-时间曲线
- 制动力分配比例图（堆叠面积图）
- 策略对比柱状图（含提升指示）
- 影响因素关系曲线
- 电池SOC变化曲线
- 功率对比图表
- 效率统计饼图
- **完整中文字体支持**（跨平台兼容）

### 数据文件
- 仿真结果保存为.mat文件
- 图表导出为PNG和EPS格式

## 开发指南

### 添加新模型

在 `models/` 目录下创建新的.m文件，遵循以下模板：

```matlab
function [output1, output2] = new_model(input1, input2)
% NEW_MODEL 模型简要说明
%
% 输入参数:
%   input1 - 参数1说明
%   input2 - 参数2说明
%
% 输出参数:
%   output1 - 输出1说明
%   output2 - 输出2说明

    % 实现代码
    
end
```

### 运行测试

```matlab
% 运行所有测试
runtests('tests');

% 运行特定测试
runtests('tests/unit_tests/test_vehicle_model.m');
```

## 常见问题

### Q: 如何运行完整的对比仿真？
A: 在MATLAB命令窗口执行：
```matlab
cd regenerative_braking_simulation
results = main('comparison', 'NEDC');
```

### Q: 图表中文显示乱码？
A: 确保MATLAB支持中文字体，可以在代码中设置：
```matlab
set(0, 'DefaultAxesFontName', 'SimHei');
```

### Q: 仿真运行时间过长？
A: NEDC工况约需10-20秒，UDDS工况约需15-30秒。如需加快，可增加采样时间间隔。

### Q: 如何查看详细的仿真数据？
A: 仿真结果保存在 `results/` 目录下的.mat文件中，可以使用以下命令加载：
```matlab
load('results/results_comparison_NEDC_20260106_XXXXXX.mat');
```

## 参考文献

本项目基于纯电动汽车再生制动能量回收效率优化研究的相关论文实现。

## 许可证

本项目仅用于学术研究和教学目的。

## 联系方式

如有问题或建议，请联系项目维护者。

---

**版本**: 1.0.0  
**最后更新**: 2025年1月
