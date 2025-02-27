data1 = readmatrix("M2.25_N2_Pres_5222_Pchm_170_Leeds_DBS_30000_AUSM\axial_temperature")
data2 = readmatrix("M2.25_N2_Pres_5222_Pchm_170_Leeds_DBS_30000_Roe\axial_temperature")
data3 = readmatrix("M2.25_N2_Pres_5222_Pchm_170_Leeds_PBS_1000_Coupled_Steady\axial_temperature")

data1_x = data1(:,1) - 0.04167
data1_t = data1(:,2)

data2_x = data2(:,1) - 0.04167
data2_t = data2(:,2)

data3_x = data3(:,1) -0.04167
data3_t = data3(:,2)

figure
plot(data1_x,data1_t, 'k-', 'LineWidth',1.5), hold on
plot(data2_x,data2_t, 'k--', 'LineWidth',1.5), hold on
plot(data3_x,data3_t, 'k-.', 'LineWidth',1.5)
grid on
xlim([0 0.25]), ylim([60 160])
xlabel("Distance From Nozzle Exit (m)")
ylabel("Static Temperature (K)")
legend("DBS AUSM 30k", "DBS ROE 30k", "Coupled PBS 1k")



