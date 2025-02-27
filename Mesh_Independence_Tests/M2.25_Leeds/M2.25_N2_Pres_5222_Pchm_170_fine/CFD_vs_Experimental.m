nozzle_length = 0.04167 % shift by nozzle length so nozzle exit is at x =0
data1 = readmatrix("axial_temperature")
data1_x = data1(:,1) - nozzle_length
data1_t = data1(:,2)

data2 = readmatrix("axial_mach")
data2_x = data2(:,1) - nozzle_length
data2_m = data2(:,2)

exp = readmatrix("experimental.txt")
exp_x = exp(:,1)
exp_t = exp(:,3)
exp_m = exp(:,2)

figure
plot(data1_x*100,data1_t, 'k-', 'LineWidth',1.5)
hold on
scatter(exp_x*100,exp_t,20, 'k')
xlim([0 20])
ylim([60 160])
ylabel("Static Temperature (K)")
xlabel("Distance from Nozzle Exit (cm)")
legend("RANS CFD", "Experimental")
grid on
box on

exp_t_mean = mean(exp_t(1:159))
exp_t_std = std(exp_t(1:159))
exp_m_mean = mean(exp_m(1:159))
exp_m_std = std(exp_m(1:159))


data1_t_mean = mean(data1_t(383:1058))
data1_t_std = std(data1_t(383:1058))
data2_m_mean = mean(data2_m(383:1058))
data2_m_std = std(data2_m(383:1058))