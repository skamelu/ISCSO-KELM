%%  清空环境变量
warning off             % 关闭报警信息
close all               % 关闭开启的图窗
clear                   % 清空变量
clc                     % 清空命令行

%%  添加路径
addpath('path_kelm\')

%%  读取数据
res = xlsread('test.xlsx');

%%  分析数据
num_class = length(unique(res(:, end)));  % 类别数（Excel最后一列放类别）
num_res = size(res, 1);                   % 样本数（每一行，是一个样本）
num_size = 0.82;                           % 训练集占数据集的比例
%res = res(randperm(num_res), :);          % 打乱数据集（不打乱数据时，注释该行）
flag_conusion = 1;                        % 标志位为1，打开混淆矩阵（要求2018版本及以上）

%%  设置变量存储数据
P_train = []; P_test = [];
T_train = []; T_test = [];

%%  划分数据集
for i = 1 : num_class
    mid_res = res((res(:, end) == i), :);           % 循环取出不同类别的样本
    mid_size = size(mid_res, 1);                    % 得到不同类别样本个数
    mid_tiran = round(num_size * mid_size);         % 得到该类别的训练样本个数

    P_train = [P_train; mid_res(1: mid_tiran, 1: end - 1)];       % 训练集输入
    T_train = [T_train; mid_res(1: mid_tiran, end)];              % 训练集输出

    P_test  = [P_test; mid_res(mid_tiran + 1: end, 1: end - 1)];  % 测试集输入
    T_test  = [T_test; mid_res(mid_tiran + 1: end, end)];         % 测试集输出
end

%%  数据转置
P_train = P_train'; P_test = P_test';
T_train = T_train'; T_test = T_test';

%%  得到训练集和测试样本个数
M = size(P_train, 2);
N = size(P_test , 2);

%%  数据归一化
[p_train, ps_input] = mapminmax(P_train, 0, 1);
p_test = mapminmax('apply', P_test, ps_input );
t_train = ind2vec(T_train);
t_test  = ind2vec(T_test );

%%  参数设置
pop = 20;                     %  种群数量
Max_time = 30;                %  设定最大迭代次数
Kernel_type = 'rbf';          %  核函数
dim = 2;                      %  维度为2，即优化两个参数，正则化系数 C 和核函数参数 S
lb = [1, 1];                  %  下边界
ub = [100, 100];              %  上边界
fobj = @(x) fun(x, p_train, T_train);
[Best_score, Best_pos, Curve] = ISCSO(pop, Max_time, lb, ub, dim, fobj); %开始优化

%%  获取最优正则化系数 C 和核函数参数 S
Regularization_coefficient = Best_pos(1);
Kernel_para = Best_pos(2);

%%  训练模型
[TrainOutT, OutputWeight] = kelmTrain(p_train,t_train,Regularization_coefficient,Kernel_type,Kernel_para);

%%  模型预测
InputWeight = OutputWeight;
t_sim1 = kelmPredict(p_train,InputWeight,Kernel_type,Kernel_para,p_train);
t_sim2 = kelmPredict(p_train,InputWeight,Kernel_type,Kernel_para,p_test);

%%  反归一化
T_sim1 = vec2ind(t_sim1);
T_sim2 = vec2ind(t_sim2);

%%  性能评价
error1 = sum((T_sim1 == T_train)) / M * 100 ;
error2 = sum((T_sim2 == T_test )) / N * 100 ;

%%  迭代曲线图 
figure
plot(Curve,'linewidth',1.5)
xlabel('迭代次数')
ylabel('适应度值')
grid on
title('收敛曲线')
set(gcf,'color','w')

%%  绘图
figure
plot(1: M, T_train, 'r-*', 1: M, T_sim1, 'b-o', 'LineWidth', 1)
legend('真实值', 'ISCSO-KELM预测值')
xlabel('预测样本')
ylabel('预测结果')
string = {'训练集预测结果对比'; ['准确率=' num2str(error1) '%']};
title(string)
grid
set(gcf,'color','w')

figure
plot(1: N, T_test, 'r-*', 1: N, T_sim2, 'b-o', 'LineWidth', 1)
legend('真实值', 'ISCSO-KELM预测值')
xlabel('预测样本')
ylabel('预测结果')
string = {'测试集预测结果对比'; ['准确率=' num2str(error2) '%']};
title(string)
grid
set(gcf,'color','w')

%%  混淆矩阵
if flag_conusion == 1

    figure
    cm = confusionchart(T_train, T_sim1);
    cm.Title = 'Confusion Matrix for Train Data';
    cm.ColumnSummary = 'column-normalized';
    cm.RowSummary = 'row-normalized';
    set(gcf,'color','w')

    figure
    cm = confusionchart(T_test, T_sim2);
    cm.Title = 'Confusion Matrix for Test Data';
    cm.ColumnSummary = 'column-normalized';
    cm.RowSummary = 'row-normalized';
    set(gcf,'color','w')

end