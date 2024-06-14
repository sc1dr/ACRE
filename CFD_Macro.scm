(ti-menu-load-string (format #f "file/read-case /nobackup/scldr/ACRE_V4.0/M2.25_N2_Pres_5222_Pchm_170_IR_5.00mm/Mesh.msh ok"))
(ti-menu-load-string (format #f "/mesh/scale 0.001 0.001"))
(ti-menu-load-string (format #f "/define/models/axisymmetric yes"))
(ti-menu-load-string (format #f "/define/models/solver/pressure-based yes")); density-based explicit, pressure-based or density-based-implicit
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
(ti-menu-load-string (format #f "/define/materials/copy fluid nitrogen"))
(ti-menu-load-string (format #f "/define/boundary-conditions/fluid fluid yes nitrogen no no no no no no no"))
(ti-menu-load-string (format #f "/define/materials delete air"))
(ti-menu-load-string (format #f "/define/materials change-create nitrogen nitrogen yes ideal-gas yes piecewise-polynomial 2 0 340 7 1.1863e3 -4.4245 0.0545 -3.4749e-4 1.209e-6 -2.1777e-9 1.5894e-12 340 2000 8 1.0922e3 -0.2679 -2.9022e-5 1.8757e-6 -2.8784e-9 1.905e-12 -6.061e-16 7.595e-20 yes polynomial 8 -0.0014 1.1747e-4 -1.2094e-7 1.3642e-10 -1.0438e-13 5.0045e-17 -1.3416e-20 1.527e-24 yes sutherland three-coefficient-method 1.663e-05 273.11 106.67 no no no"))
(ti-menu-load-string (format #f "/define/models/viscous/turb-compressibility no")) ; Turning compressbility effects off
(ti-menu-load-string (format #f "/define/boundary-conditions/zone-type inlet pressure-inlet"))
(ti-menu-load-string (format #f "/define/boundary-conditions/zone-type outlet pressure-outlet"))
(ti-menu-load-string (format #f "/define/boundary-conditions/wall left_reactor_wall 0 no 0 no no no 0 no no no no 0 no 0 no 1"))
(ti-menu-load-string (format #f "/define/boundary-conditions/wall nozzle_wall 0 no 0 no no no 0 no no no no 0 no 0 no 1"))
(ti-menu-load-string (format #f "/define/boundary-conditions/wall reservoir_wall 0 no 0 no no no 0 no no no no 0 no 0 no 1"))
(ti-menu-load-string (format #f "/define/boundary-conditions/wall top_reactor_wall 0 no 0 no no no 0 no no no no 0 no 0 no 1"))
(ti-menu-load-string (format #f "/define/boundary-conditions/wall right_reactor_wall 0 no 0 no no no 0 no no no no 0 no 0 no 1"))
(ti-menu-load-string (format #f "/define/boundary-conditions/pressure-inlet inlet yes no 5222.73 no 0 no 300 no yes no no yes 1 1"))
(ti-menu-load-string (format #f "/define/boundary-conditions/pressure-outlet outlet yes no 170.65 no 300 no yes no no yes 1 1 yes no no"))
(ti-menu-load-string (format #f "/define/operating-conditions/operating-pressure 0")) ; |Value in Pa|
(ti-menu-load-string (format #f "/solve/monitors/residual/convergence-criteria 1e-5 1e-5 1e-5 1e-5 1e-5 1e-5"))
(ti-menu-load-string (format #f "/solve/set/discretization-scheme/mom 1"))		; [0 1 4 6] = [First Order, Second Order, QUICK, Third Order]
(ti-menu-load-string (format #f "/solve/set/discretization-scheme/pressure 12"))	; [12 10 14 11 13] = [Second, Standard, PRESTO!, Linear, Body Force Weighted]
(ti-menu-load-string (format #f "/solve/set/discretization-scheme/k 1"))		; [0 1 4 6] = [First Order, Second Order, QUICK, Third Order]
(ti-menu-load-string (format #f "/solve/set/discretization-scheme/density 1"))		; [0 1 4 6] = [First Order, Second Order, QUICK, Third Order]
(ti-menu-load-string (format #f "/solve/set/discretization-scheme/omega 1"))		; [0 1 4 6] = [First Order, Second Order, QUICK, Third Order]
(ti-menu-load-string (format #f "/solve/set/discretization-scheme/temperature 1"))	; [0 1 4 6] = [First Order, Second Order, QUICK, Third Order]
(ti-menu-load-string (format #f "/solve/set/flux-type no 0")) 				; [0 1], Rhie-Chow Distance, Rhie-Chow momentum
(ti-menu-load-string (format #f "/solve/set/p-v-coupling 24"))				; [20 21 22 24] = [SIMPLE, SIMPLEC, PISO, Coupled]
(ti-menu-load-string (format #f "/solve/set/warped-face-gradient-correction enable? yes no")) ;

;This is just to help convergence, i have left relaxation parameters as default and it seems to converge fine.
(ti-menu-load-string (format #f "/solve/set/high-order-term-relaxation enable? yes")); 
; This sets pseudo transient using automating conservative timestepping with a timestep factor of 0.5. This acts as under-relaxation.
(ti-menu-load-string (format #f "/solve/set/pseudo-transient yes yes 1 0.5 0"))

; setup report definitions
(ti-menu-load-string (format #f "/solve/report-definitions add max-mach surface-vertexmax field mach-number surface-names axis"));
(ti-menu-load-string (format #f "/solve/report-files/add max-mach report-defs max-mach"));

(ti-menu-load-string (format #f "/solve/report-definitions add min-temp surface-vertexmin field temperature surface-names axis"));
(ti-menu-load-string (format #f "/solve/report-files/add min-temp report-defs min-temp"));

(ti-menu-load-string (format #f "/solve/report-files/edit max-mach file-name M2.25_N2_Pres_5222_Pchm_170_IR_5.00mm/max-mach-convergence.txt"))
(ti-menu-load-string (format #f "/solve/report-files/edit min-temp file-name M2.25_N2_Pres_5222_Pchm_170_IR_5.00mm/min-temp-convergence.txt"))


; Initialisation settings and number of itterations
(ti-menu-load-string (format #f "/solve/init/hyb-initialization"))
;(ti-menu-load-string (format #f "solve init fmg y"))

(ti-menu-load-string (format #f "/mesh/adapt/cell-registers/add yplusrefine type yplus-ystar max-allowed 0.5 min-allowed 0.25 q () q () q ()"))
(ti-menu-load-string (format #f "/mesh/adapt/manage-criteria/add criteria1 type expression refinement-expression \"yplusrefine\" "))
(ti-menu-load-string (format #f "/mesh/adapt/manage-criteria/edit criteria1 frequency 250"))

(ti-menu-load-string (format #f "/solve/iterate 500"))

(ti-menu-load-string (format #f "/plot plot yes M2.25_N2_Pres_5222_Pchm_170_IR_5.00mm/axial_pressure yes no no total-pressure yes 1 0 axis ()"))
(ti-menu-load-string (format #f "/plot plot yes M2.25_N2_Pres_5222_Pchm_170_IR_5.00mm/axial_mach yes no no mach-number yes 1 0 axis ()"))
(ti-menu-load-string (format #f "/plot plot yes M2.25_N2_Pres_5222_Pchm_170_IR_5.00mm/axial_temperature yes no no temperature yes 1 0 axis ()"))
(ti-menu-load-string (format #f "/plot plot yes M2.25_N2_Pres_5222_Pchm_170_IR_5.00mm/axial_density yes no no density yes 1 0 axis ()"))
(ti-menu-load-string (format #f "/plot plot yes M2.25_N2_Pres_5222_Pchm_170_IR_5.00mm/axial_tke yes no no tke yes 1 0 axis ()"))
;(do((i 0 (+ i 1)))
    ;((>= i 151))
    ;(define a 5000)
    ;(define b i)
    ;(define ycoord (/ b a ))
    ;(ti-menu-load-string (format #f "/surface/line-surface line_~a 0.041621 ~a 0.774 ~a" ycoord ycoord ycoord))
    ;(ti-menu-load-string (format #f "/plot plot yes M2.25_N2_Pres_5222_Pchm_170_IR_5.00mm/Contour_Data/axial_pressure_y_~a yes no no total-pressure yes 1 0 line_~a ()" i ycoord))
    ;(ti-menu-load-string (format #f "/plot plot yes M2.25_N2_Pres_5222_Pchm_170_IR_5.00mm/Contour_Data/axial_mach_y_~a yes no no mach yes 1 0 line_~a ()" i ycoord))
    ;(ti-menu-load-string (format #f "/plot plot yes M2.25_N2_Pres_5222_Pchm_170_IR_5.00mm/Contour_Data/axial_temperature_y_~a yes no no temperature yes 1 0 line_~a ()" i ycoord))
    ;(ti-menu-load-string (format #f "/plot plot yes M2.25_N2_Pres_5222_Pchm_170_IR_5.00mm/Contour_Data/axial_density_y_~a yes no no density yes 1 0 line_~a ()" i ycoord))
;)

(ti-menu-load-string (format #f "/file/write-case M2.25_N2_Pres_5222_Pchm_170_IR_5.00mm/CFD_Data.cas y"))
(ti-menu-load-string (format #f "/file/write-data M2.25_N2_Pres_5222_Pchm_170_IR_5.00mm/CFD_Data.dat y"))

exit y
