nozzle_length = 0.081; % m

data1 = readmatrix("M4.00_N2_Pres_5584_Pchm_37.50_Bham_coarser\axial_temperature");
data2 = readmatrix("M4.00_N2_Pres_5584_Pchm_37.50_Bham_coarse\axial_temperature");
data3 = readmatrix("M4.00_N2_Pres_5584_Pchm_37.50_Bham_fine\axial_temperature");
data4 = readmatrix("M4.00_N2_Pres_5584_Pchm_37.50_Bham_finer\axial_temperature");

exp_data = readmatrix("N2_Nozzle1_M4_Pitot4_Coarse1D_Comparison.txt")
exp_data_x = (exp_data(:,1)/100)
exp_data_t = exp_data(:,6)

data1_x = data1(:,1) - nozzle_length, data1_t = data1(:,2)
data2_x = data2(:,1) - nozzle_length, data2_t = data2(:,2)
data3_x = data3(:,1) - nozzle_length, data3_t = data3(:,2)
data4_x = data4(:,1) - nozzle_length, data4_t = data4(:,2)

figure
plot(data1_x*100,data1_t, '.k','LineWidth',1.5), hold on
plot(data2_x*100,data2_t,'k--','LineWidth',1.5), hold on
plot(data3_x*100,data3_t,'k-.','LineWidth',1.5), hold on
plot(data4_x*100,data4_t, 'k-','LineWidth',1.5), hold on
ax= gca
ax.FontSize = 16
legend("83,167", "333,442", "1,340,618", "5,372,335", 'FontSize',16)
xlabel("Distance From Nozzle Exit (cm)", 'FontSize',16)
ylabel("Static Temperature (K)", 'FontSize',16)
xlim([ 0 50])
ylim([50 100])
grid on
