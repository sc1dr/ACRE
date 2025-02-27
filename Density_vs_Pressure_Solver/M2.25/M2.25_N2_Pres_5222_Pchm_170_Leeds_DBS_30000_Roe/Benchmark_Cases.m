exp = readmatrix("PR_30.6_exp.txt")
exp_x = exp(:,1)*100 % this is in cm
exp_t = exp(:,2) % K
% exp_m = exp(:,5)

cfd1 = readmatrix("axial_temperature")
cfd2 = readmatrix("axial_mach")

cfd_x = (cfd1(:,1) -0.04162)*100 % in m
cfd_t = cfd1(:,2)
cfd_m = cfd2(:,2)

figure
scatter(exp_x,exp_t,10,'k'), hold on
plot(cfd_x,cfd_t, 'k')
xlim([0 25])
ylim([60 160])
grid on
ylabel("Static Temperaure (K)")
xlabel("Distance From Nozzle Exit (cm)")
legend("Experimental", "RANS CFD")
title("M4 Ar, 295K, Pchm = 4830Pa, Pres = 23Pa, Density-Based")

% figure
% scatter(exp_x,exp_m,10,'k'), hold on
% plot(cfd_x,cfd_m, 'k')
% xlim([0 50])
% ylim([2 8])
% grid on
% ylabel("Mach Number")
% xlabel("Distance From Nozzle Exit (cm)")
% legend("Experimental", "RANS CFD")
% title("M4 Ar, 295K, Pchm = 4830Pa, Pres = 23Pa, Density-Based")

exp_mean = mean(exp_t(:))
cfd_mean = mean(cfd_t(782:1999))

exp_std = std(exp_t(:))
cfd_std = std(cfd_t(782:1999))

