# 可视化系统使用指南

## 概述

再生制动仿真系统的可视化模块已完成全面优化，提供专业级图表展示效果。系统支持三种主要的可视化模式，具备现代化设计风格和完整的中文字体支持。

## 主要特性

### ✨ 专业设计风格
- 现代化配色方案，视觉效果优雅
- 专业的图表布局和样式
- 增强的网格和坐标轴设计
- 渐变色彩和透明度效果

### 🎨 完整的中文支持
- 自动检测系统字体
- 跨平台中文字体兼容（Windows/macOS/Linux）
- 所有图表标题、标签和说明均支持中文显示

### 📊 三种可视化模式
1. **单策略分析** (`'single'`) - 详细展示单个策略的性能
2. **策略对比** (`'comparison'`) - 对比基准策略与优化策略
3. **因素分析** (`'factor_analysis'`) - 单因素影响分析结果

## 使用方法

### 基本调用
```matlab
% 添加路径
addpath(genpath('regenerative_braking_simulation'));

% 运行仿真并可视化
results = main('baseline', 'NEDC');
visualization(results, 'single');
```

### 1. 单策略可视化
```matlab
% 基准策略
results = main('baseline', 'NEDC');
visualization(results, 'single');

% 优化策略
results = main('optimized', 'NEDC');
visualization(results, 'single');
```

**显示内容：**
- 3×3 子图布局，包含9个专业图表
- 车速-时间曲线（含制动事件标注）
- 瞬时效率曲线（含平均效率线）
- 制动力分配比例（堆叠面积图）
- 电池SOC变化（含限制线标识）
- 功率曲线对比
- 效率统计饼图
- 专业信息面板

### 2. 策略对比可视化
```matlab
results = main('comparison', 'NEDC');
visualization(results, 'comparison');
```

**显示内容：**
- 2×4 子图布局，全面对比分析
- 效率对比柱状图（含提升箭头）
- 车速曲线展示
- 瞬时效率对比（双策略）
- 制动力分配对比
- 能量回收对比图表
- 性能指标统计
- 对比信息面板

### 3. 因素分析可视化
```matlab
params = vehicle_params();
config = simulation_config();

% 分析车辆质量影响
results = factor_analysis('mass', 'NEDC', 'optimized', params, config);
visualization(results, 'factor_analysis');

% 分析电池温度影响
results = factor_analysis('temperature', 'NEDC', 'optimized', params, config);
visualization(results, 'factor_analysis');
```

**支持的分析因素：**
- `'mass'` - 车辆质量
- `'motor_rpm'` - 电机转速
- `'temperature'` - 电池温度
- `'soc'` - 电池SOC
- `'pedal_travel'` - 制动踏板行程
- `'slope'` - 道路坡度
- `'env_temperature'` - 环境温度

## 快速演示

### 使用演示系统
```matlab
% 快速演示
demo('quick');

% 策略对比演示
demo('comparison');

% 完整演示
demo('all');
```

### 一键测试所有可视化
```matlab
% 测试所有可视化模式
addpath(genpath('regenerative_braking_simulation'));

% 单策略
results1 = main('baseline', 'NEDC');
visualization(results1, 'single');

% 策略对比
results2 = main('comparison', 'NEDC');
visualization(results2, 'comparison');

% 因素分析
params = vehicle_params();
config = simulation_config();
results3 = factor_analysis('mass', 'NEDC', 'optimized', params, config);
visualization(results3, 'factor_analysis');
```

## 技术特性

### 配色方案
- **主色调：** 现代蓝色系 `[0.2, 0.4, 0.8]`
- **次要色：** 深红色 `[0.8, 0.3, 0.3]`
- **强调色：** 橙色 `[1.0, 0.6, 0.0]`
- **功能色：** 绿色（成功）、黄色（警告）、红色（错误）

### 字体支持
- **Windows：** Microsoft YaHei UI → Microsoft YaHei → SimHei → SimSun
- **macOS：** PingFang SC → Hiragino Sans GB → STHeiti → Arial Unicode MS
- **Linux：** Noto Sans CJK SC → WenQuanYi Micro Hei → DejaVu Sans

### 图表增强
- 专业网格样式（透明度 0.3）
- 增强的坐标轴设计
- 现代化标注和图例
- 渐变色彩效果
- 智能布局优化

## 系统状态

✅ **完成项目：**
- 单策略可视化完全重构
- 策略对比可视化优化
- 因素分析可视化实现（专业化6子图布局）
- 专业样式系统
- 中文字体支持
- 配色方案设计
- 所有辅助函数实现

✅ **问题修复：**
- 修复饼图百分比计算错误
- 修复信息面板数据不一致问题
- 修复图表数据引用错误
- 解决MATLAB版本兼容性问题
- 统一数据显示格式

✅ **测试验证：**
- 所有可视化模式正常工作
- 中文字体正确显示
- 图表样式符合预期
- 演示系统运行正常
- 数据显示准确一致

## 更新日志

**2026-03-26 - 可视化系统优化完成**
- 完成所有可视化函数的专业化改造
- 实现现代化配色方案和样式
- 添加完整的中文字体支持
- 优化图表布局和信息展示
- 修复数据显示错误和兼容性问题
- 通过全面测试验证

**修复的主要问题：**
- 饼图百分比计算错误
- 信息面板数据不一致
- 图表数据引用错误
- MATLAB版本兼容性问题
- 数据显示格式统一

---

**使用建议：** 建议在运行可视化前确保 MATLAB 图形环境正常，首次运行时系统会自动配置最佳的中文字体。