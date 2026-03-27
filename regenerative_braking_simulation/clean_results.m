function clean_results(confirm)
% CLEAN_RESULTS 清理仿真结果文件
%
% 清理results目录中的所有.mat文件，为新的演示做准备
%
% 输入参数:
%   confirm - 确认清理 (可选): true/false 或 'yes'/'no'
%
% 示例:
%   clean_results()           % 交互式确认
%   clean_results(true)       % 直接清理
%   clean_results('yes')      % 直接清理

    if nargin < 1
        confirm = [];
    end
    
    % 检查results目录
    results_dir = 'results';
    if ~exist(results_dir, 'dir')
        fprintf('results目录不存在，无需清理。\n');
        return;
    end
    
    % 查找.mat文件
    mat_files = dir(fullfile(results_dir, '*.mat'));
    
    if isempty(mat_files)
        fprintf('results目录中没有.mat文件，无需清理。\n');
        return;
    end
    
    fprintf('发现 %d 个结果文件:\n', length(mat_files));
    for i = 1:min(5, length(mat_files))  % 只显示前5个
        fprintf('  %s\n', mat_files(i).name);
    end
    if length(mat_files) > 5
        fprintf('  ... 还有 %d 个文件\n', length(mat_files) - 5);
    end
    
    % 确认清理
    if isempty(confirm)
        response = input('\n是否清理所有结果文件? (y/n): ', 's');
        confirm = strcmpi(response, 'y') || strcmpi(response, 'yes');
    elseif ischar(confirm)
        confirm = strcmpi(confirm, 'yes') || strcmpi(confirm, 'y');
    end
    
    if confirm
        try
            % 删除所有.mat文件
            for i = 1:length(mat_files)
                delete(fullfile(results_dir, mat_files(i).name));
            end
            fprintf('\n✓ 成功清理 %d 个结果文件\n', length(mat_files));
            fprintf('系统已准备好进行新的演示。\n');
        catch ME
            fprintf('\n✗ 清理失败: %s\n', ME.message);
        end
    else
        fprintf('\n取消清理操作。\n');
    end
    
end