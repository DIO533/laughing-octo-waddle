# 快速入门指南

## 🚀 5分钟快速开始

### 1. 环境准备

确保您已安装：
- MATLAB R2020b 或更高版本（推荐 R2025b）
- 无需额外工具箱

### 2. 打开MATLAB

在MATLAB中导航到项目目录：
```matlab
cd regenerative_braking_simulation
```

### 3. 验证安装

```matlab
% 运行安装验证
verify_installation
```

### 4. 运行第一个仿真

```matlab
% 对比基准策略和优化策略
results = main('comparison', 'NEDC');
```

### 5. 查看结果

仿真完成后会自动显示：
- 6个子图的综合分析图表
- 控制台输出的效率统计信息
- 保存在`results/`目录的数据文件

---

## 📋 常用命令速查

### 基本仿真
```matlab
% 运行基准策略NEDC工况
results = main('baseline', 'NEDC');

% 运行优化策略UDDS工况
results = main('optimized', 'UDDS');

% 对比两种策略
results = main('comparison', 'NEDC');
```

### 自定义参数
```matlab
% 指定车辆质量、温度、坡度和初始SOC
results = main('optimized', 'UDDS', ...
    'mass', 1800, ...           % 车辆质量 (kg)
    'temperature', -10, ...     % 环境温度 (℃)
    'slope', 5, ...             % 道路坡度 (%)
    'initial_SOC', 50);         % 初始SOC (%)
```

### 因素分析
```matlab
% 加载配置
params = vehicle_params();
config = simulation_config();

% 分析车辆质量影响
results = factor_analysis('mass', 'NEDC', 'optimized', params, config);

% 分析环境温度影响
results = factor_analysis('env_temperature', 'NEDC', 'optimized', params, config);
```

### 查看完整示例
```matlab
% 运行所有示例（8个不同场景）
example_usage
```

---

## 📊 预期结果

### NEDC工况
- **基准策略**：约 40-45% 能量回收效率
- **优化策略**：约 60-70% 能量回收效率
- **效率提升**：约 15-25 个百分点

### UDDS工况
- **基准策略**：约 45-50% 能量回收效率
- **优化策略**：约 70-75% 能量回收效率
- **效率提升**：约 20-30 个百分点

### 运行时间（优化后）
- NEDC工况：约 10 秒
- UDDS工况：约 17 秒
- 策略对比：约 27 秒

---

## ⚙️ 配置修改

### 关闭可视化（加快速度）
```matlab
config = simulation_config();
config.plot_results = false;
config.verbose = false;
```

### 修改车辆参数
```matlab
params = vehicle_params();
params.vehicle.mass_default = 1800;  % 修改质量
params.battery.capacity = 70;        % 修改电池容量
```

---

## 🔧 常见问题

### Q: 提示找不到函数？
A: 确保已添加路径：
```matlab
addpath(genpath('config'));
addpath(genpath('models'));
addpath(genpath('controllers'));
addpath(genpath('utils'));
addpath(genpath('visualization'));
```

### Q: 图表中文显示乱码？
A: 设置中文字体：
```matlab
setup_chinese_font();
```

### Q: 仿真运行时间过长？
A: 可以关闭可视化加快速度：
```matlab
config = simulation_config();
config.plot_results = false;
config.verbose = false;
```

### Q: 如何查看详细的仿真数据？
A: 仿真结果保存在 `results/` 目录下的.mat文件中：
```matlab
load('results/results_comparison_NEDC_20260106_XXXXXX.mat');
```

---

## 🧪 测试和验证

```matlab
% 安装验证（推荐首次运行）
verify_installation

% 兼容性测试
test_compatibility

% 性能测试
performance_test
```

---

## 📈 性能监控

```matlab
% 测试运行时间
tic;
results = main('comparison', 'NEDC');
fprintf('运行时间: %.2f 秒\n', toc);

% 性能分析
profile on
results = main('comparison', 'NEDC');
profile viewer
```

---

## 📚 下一步

### 查看完整文档
- **README.md** - 完整项目说明和功能介绍
- **OPTIMIZATION_SUMMARY.md** - 代码优化总结
- **CHANGELOG.md** - 版本更新日志

### 学习路径

**第1天**：
1. 运行 `verify_installation`
2. 运行 `main('comparison', 'NEDC')`
3. 查看图表和结果

**第2-3天**：
1. 运行 `example_usage`
2. 修改参数重新运行
3. 尝试因素分析

**第4-7天**：
1. 阅读代码实现
2. 理解算法原理
3. 尝试修改策略

---

## 💡 提示和技巧

### 批量运行
```matlab
cycles = {'NEDC', 'UDDS'};
for i = 1:length(cycles)
    results{i} = main('comparison', cycles{i});
end
```

### 保存自定义配置
```matlab
my_config = simulation_config();
my_config.sampling_time = 0.5;
save('my_config.mat', 'my_config');
```

### 导出结果
```matlab
% 导出图表
saveas(gcf, 'figure.png');

% 导出为Excel
T = struct2table(results);
writetable(T, 'results.xlsx');
```

---

## 🆘 获取帮助

```matlab
% 查看函数帮助
help main
help vehicle_model
help baseline_strategy

% 查看示例
edit example_usage.m
```

---

## ✨ 主要特性

- ✅ 无需工具箱 - 只使用MATLAB基础功能
- ✅ 性能优化 - 比初始版本快30-35%
- ✅ 智能字体 - 自动适配不同操作系统
- ✅ 完整文档 - 每个函数都有详细说明
- ✅ 易于扩展 - 模块化设计

---

**版本**: v1.1.0  
**更新日期**: 2026年1月7日  
**兼容性**: MATLAB R2025b ✅

祝您使用愉快！🎉
