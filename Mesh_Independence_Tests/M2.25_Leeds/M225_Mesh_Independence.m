data1 = readmatrix("M2.25_N2_Pres_5222_Pchm_170_coarser\axial_temperature")
data2 = readmatrix("M2.25_N2_Pres_5222_Pchm_170_coarse\axial_temperature")
data3 = readmatrix("M2.25_N2_Pres_5222_Pchm_170_fine\axial_temperature")
data4 = readmatrix("M2.25_N2_Pres_5222_Pchm_170_finest\axial_temperature")

data5 = readmatrix("M2.25_N2_Pres_5222_Pchm_170_coarser\axial_mach")
data6 = readmatrix("M2.25_N2_Pres_5222_Pchm_170_coarse\axial_mach")
data7 = readmatrix("M2.25_N2_Pres_5222_Pchm_170_fine\axial_mach")
data8 = readmatrix("M2.25_N2_Pres_5222_Pchm_170_finest\axial_mach")

nozzle_length = 0.04167 % m
data1_x = data1(:,1) - nozzle_length, data1_t = data1(:,2)
data2_x = data2(:,1) - nozzle_length, data2_t = data2(:,2)
data3_x = data3(:,1) - nozzle_length, data3_t = data3(:,2)
data4_x = data4(:,1) - nozzle_length, data4_t = data4(:,2)

data5_m = data5(:,2)
data6_m = data6(:,2)
data7_m = data7(:,2)
data8_m = data8(:,2)

figure
plot(data1_x,data1_t), hold on
plot(data2_x,data2_t), hold on
plot(data3_x,data3_t), hold on
plot(data4_x,data4_t), hold on
legend("33k", "134k", "539k", "2164k")
xlabel("Distance From Nozzle Exit (m)")
ylabel("Static Temperature (K)")
grid on
xlim([0 0.3])
ylim([60 160])

data1_t_mean = mean(data1_t(97:268))
data2_t_mean = mean(data2_t(192:532))
data3_t_mean = mean(data3_t(380:1058))
data4_t_mean = mean(data4_t(772:2115))

data1_t_std = std(data1_t(97:268))
data2_t_std = std(data2_t(192:532))
data3_t_std = std(data3_t(380:1058))
data4_t_std = std(data4_t(772:2115))

data5_m_mean = mean(data5_m(97:268))
data6_m_mean = mean(data6_m(192:532))
data7_m_mean = mean(data7_m(380:1058))
data8_m_mean = mean(data8_m(772:2115))

data5_m_std = std(data5_m(97:268))
data6_m_std = std(data6_m(192:532))
data7_m_std = std(data7_m(380:1058))
data8_m_std = std(data8_m(772:2115))
