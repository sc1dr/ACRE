exp = readmatrix("N2_Nozzle1_M4_Pitot4_Coarse1D_Comparison.txt")
exp_x = exp(:,1) % this is in cm
exp_t = exp(:,6) % K
exp_m = exp(:,5)

cfd1 = readmatrix("M4_N2_295K_Pin_5584_Pout_37_Bham_DBS_Implicit_25_Axial_Temperature")
cfd2 = readmatrix("M4_N2_295K_Pin_5584_Pout_37_Bham_PBS_25_Axial_Temperature")

cfd1_x = (cfd1(:,1) -0.081)*100 % in m
cfd1_t = cfd1(:,2)
cfd2_x = (cfd2(:,1) -0.081)*100 % in m
cfd2_t = cfd2(:,2)


figure
scatter(exp_x,exp_t,10,'k'), hold on
plot(cfd1_x,cfd1_t, 'k'), hold on
plot(cfd2_x,cfd2_t, 'k--'), hold on
xlim([0 45])
ylim([0 160])
grid on
ylabel("Static Temperaure (K)")
xlabel("Distance From Nozzle Exit (cm)")
legend("Experimental", "RANS CFD - Density Based", "RANS CFD - Pressure Based")
title("M4 N2, 295K, Pchm = 5584Pa, Pres = 37Pa, Solver Comparison")


exp_mean = mean(exp_t(1:40))
cfd1_mean = mean(cfd1_t(782:1999))
cfd2_mean = mean(cfd2_t(782:1999))

exp_std = std(exp_t(:))
cfd1_std = std(cfd1_t(782:1999))
cfd2_std = std(cfd2_t(782:1999))

text(1,155,0,"Average Temperature")
text(1,148,0,"Experimental = " + exp_mean + 'K')
text(1,141,0,"Density Based = " + cfd1_mean + 'K')
text(1,134,0,"Pressure Based = " + cfd2_mean + 'K')

text(1,35,0,"STD Temperature")
text(1,28,0,"Experimental = " + exp_std + 'K')
text(1,21,0,"Density Based = " + cfd1_std + 'K')
text(1,14,0,"Pressure Based = " + cfd2_std + 'K')
