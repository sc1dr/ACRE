(ti-menu-load-string (format #f "file/read-case C:/Users/scldr/OneDrive - University of Leeds/PhD/CFD/USCR/ACRE/ACRE_Toolbox_V3.0/M2.25_N2_Pres_10494_Pchm_355_Leeds/Mesh.msh ok"))
(ti-menu-load-string (format #f "/mesh/scale 0.001 0.001"))
(ti-menu-load-string (format #f "/define/models/axisymmetric yes"))
(ti-menu-load-string (format #f "/define/models/solver/density-based-implicit yes")); density-based explicit, pressure-based or density-based-implicit
(ti-menu-load-string (format #f "/define/models/energy yes yes yes"))  ; enable energy model?, compute viscout energy dissipation?, Including diffusion at inlets?
(ti-menu-load-string (format #f "/define/models/viscous/kw-sst yes"))
(ti-menu-load-string (format #f "(rpsetvar' sst-a1 0.31)"))  ; 0.31
(ti-menu-load-string (format #f "(rpsetvar' sst-kappa 0.41)")); 0.41
(ti-menu-load-string (format #f "(rpsetvar' sst-beta-i2 0.0828)")) ; 0.0828
(ti-menu-load-string (format #f "(rpsetvar' sst-beta-i1 0.075)")) ; 0.075
(ti-menu-load-string (format #f "(rpsetvar' sst-sig-w2 1.168)")) ; 1.168
(ti-menu-load-string (format #f "(rpsetvar' sst-sig-w1 2)")) ; 2
(ti-menu-load-string (format #f "(rpsetvar' sst-sig-k2 1)")) ; 1
(ti-menu-load-string (format #f "(rpsetvar' sst-sig-k1 1.176)")) ; 1.176
(ti-menu-load-string (format #f "/define/materials/copy fluid argon"))
(ti-menu-load-string (format #f "/define/boundary-conditions/fluid fluid yes argon no no no no no no no"))
(ti-menu-load-string (format #f "/define/materials delete air"))
(ti-menu-load-string (format #f "/define/materials change-create argon argon yes ideal-gas yes piecewise-linear 7 0 543.045 103.81 522.53 133.81 521.33 173.81 520.81 243.81 520.53 503.81 520.37 1993.8 520.33 yes polynomial 8 -8.3052e-4 7.8512e-5 -7.0875e-8 6.5431e-11 -4.2832e-14 1.8059e-17 -4.3440e-21 4.5046e-25 yes sutherland three-coefficient-method 2.125e-05 273.11 144.4 no no no"))
(ti-menu-load-string (format #f "/define/models/viscous/turb-compressibility no")) ; Turning compressbility effects off
(ti-menu-load-string (format #f "/define/boundary-conditions/zone-type inlet pressure-inlet"))
(ti-menu-load-string (format #f "/define/boundary-conditions/zone-type outlet pressure-outlet"))
(ti-menu-load-string (format #f "/define/boundary-conditions/wall left_reactor_wall 0 no 0 no no no 0 no no no no 0 no 0 no 1"))
(ti-menu-load-string (format #f "/define/boundary-conditions/wall nozzle_wall 0 no 0 no no no 0 no no no no 0 no 0 no 1"))
(ti-menu-load-string (format #f "/define/boundary-conditions/wall reservoir_wall 0 no 0 no no no 0 no no no no 0 no 0 no 1"))
(ti-menu-load-string (format #f "/define/boundary-conditions/wall top_reactor_wall 0 no 0 no no no 0 no no no no 0 no 0 no 1"))
(ti-menu-load-string (format #f "/define/boundary-conditions/wall right_reactor_wall 0 no 0 no no no 0 no no no no 0 no 0 no 1"))
(ti-menu-load-string (format #f "/define/boundary-conditions/pressure-inlet inlet yes no 10494.5 no 0 no 293 no yes no no yes 1 1"))
(ti-menu-load-string (format #f "/define/boundary-conditions/pressure-outlet outlet yes no 355.96 no 293 no yes no no yes 1 1 yes no no"))
(ti-menu-load-string (format #f "/define/operating-conditions/operating-pressure 0")) ; |Value in Pa|
(ti-menu-load-string (format #f "/solve/monitors/residual/convergence-criteria 1e-5 1e-5 1e-5 1e-5 1e-5 1e-5"))
(ti-menu-load-string (format #f "/solve/set/discretization-scheme/amg-c 1"))		; [0 1 4 6] = [First Order, Second Order, QUICK, Third Order]
(ti-menu-load-string (format #f "/solve/set/high-speed-numerics enable? yes"))		; [0 1 4 6] = [First Order, Second Order, QUICK, Third Order]
(ti-menu-load-string (format #f "/solve/set/discretization-scheme/k 1"))		; [0 1 4 6] = [First Order, Second Order, QUICK, Third Order]

(ti-menu-load-string (format #f "/solve/set/discretization-scheme/omega 1"))		; [0 1 4 6] = [First Order, Second Order, QUICK, Third Order]
(ti-menu-load-string (format #f "/solve/set/courant-number 25")) ;
(ti-menu-load-string (format #f "/solve/set/flux-type no 0")) 				; [0 1], Rhie-Chow Distance, Rhie-Chow momentum

(ti-menu-load-string (format #f "/solve/set/warped-face-gradient-correction enable? yes no")) ;

;This is just to help convergence, i have left relaxation parameters as default and it seems to converge fine.
(ti-menu-load-string (format #f "/solve/set/high-order-term-relaxation enable? yes")); 
; This sets pseudo transient using automating conservative timestepping with a timestep factor of 0.5. This acts as under-relaxation.
(ti-menu-load-string (format #f "/solve/set/pseudo-transient yes yes 1 0.5 0")) ;

; setup report definitions
(ti-menu-load-string (format #f "/solve/report-definitions add max-mach surface-vertexmax field mach-number surface-names axis"));
(ti-menu-load-string (format #f "/solve/report-files/add max-mach report-defs max-mach"));

(ti-menu-load-string (format #f "/solve/report-definitions add min-temp surface-vertexmin field temperature surface-names axis"));
(ti-menu-load-string (format #f "/solve/report-files/add min-temp report-defs min-temp"));

(ti-menu-load-string (format #f "/solve/report-files/edit max-mach file-name M2.25_N2_Pres_10494_Pchm_355_Leeds/max-mach-convergence.txt"))
(ti-menu-load-string (format #f "/solve/report-files/edit min-temp file-name M2.25_N2_Pres_10494_Pchm_355_Leeds/min-temp-convergence.txt"))


; Initialisation settings and number of itterations
(ti-menu-load-string (format #f "/solve/init/hyb-initialization"))
(ti-menu-load-string (format #f "solve init fmg y"))

(ti-menu-load-string (format #f "/mesh/adapt/cell-registers/add yplusrefine type yplus-ystar max-allowed 0.5 min-allowed 0.25 q () q () q ()"))
(ti-menu-load-string (format #f "/mesh/adapt/manage-criteria/add criteria1 type expression refinement-expression \"yplusrefine\" "))
(ti-menu-load-string (format #f "/mesh/adapt/manage-criteria/edit criteria1 frequency 250"))

(ti-menu-load-string (format #f "/solve/iterate 1000"));

(ti-menu-load-string (format #f "/plot plot yes M2.25_N2_Pres_10494_Pchm_355_Leeds/axial_pressure yes no no total-pressure yes 1 0 axis ()"))
(ti-menu-load-string (format #f "/plot plot yes M2.25_N2_Pres_10494_Pchm_355_Leeds/axial_mach yes no no mach-number yes 1 0 axis ()"))
(ti-menu-load-string (format #f "/plot plot yes M2.25_N2_Pres_10494_Pchm_355_Leeds/axial_temperature yes no no temperature yes 1 0 axis ()"))
(ti-menu-load-string (format #f "/plot plot yes M2.25_N2_Pres_10494_Pchm_355_Leeds/axial_density yes no no density yes 1 0 axis ()"))

(do((i 0 (+ i 1)))
    ((>= i 151))
    (define a 5000)
    (define b i)
	(define ycoord (/ b a))
    (ti-menu-load-string (format #f "/surface/line-surface line_~a 0.041621 ~a 1 ~a" ycoord ycoord ycoord))
    (ti-menu-load-string (format #f "/plot plot yes M2.25_N2_Pres_10494_Pchm_355_Leeds/Contour_Data/axial_pressure_y_~a yes no no total-pressure yes 1 0 line_~a ()" i ycoord))
    (ti-menu-load-string (format #f "/plot plot yes M2.25_N2_Pres_10494_Pchm_355_Leeds/Contour_Data/axial_mach_y_~a yes no no mach yes 1 0 line_~a ()" i ycoord))
    (ti-menu-load-string (format #f "/plot plot yes M2.25_N2_Pres_10494_Pchm_355_Leeds/Contour_Data/axial_temperature_y_~a yes no no temperature yes 1 0 line_~a ()" i ycoord))
    (ti-menu-load-string (format #f "/plot plot yes M2.25_N2_Pres_10494_Pchm_355_Leeds/Contour_Data/axial_density_y_~a yes no no density yes 1 0 line_~a ()" i ycoord))
)

(ti-menu-load-string (format #f "/file/write-case M2.25_N2_Pres_10494_Pchm_355_Leeds/CFD_Data.cas y"))
(ti-menu-load-string (format #f "/file/write-data M2.25_N2_Pres_10494_Pchm_355_Leeds/CFD_Data.dat y"))

exit y