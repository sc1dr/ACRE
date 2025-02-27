set fluentversion v221
set username scldr
set argv0 [info script]
set script_dir [file dirname $argv0]
set geom_file_path [file join $script_dir/NozzleProfileFormatted.txt]

ic_unload_tetin
ic_hex_unload_blocking
ic_unload_mesh
ic_empty_tetin

ic_set_global geo_cad 0 toptol_userset
ic_set_global geo_cad 0.0 toler
ic_set_meshing_params global 0
ic_set_global geo_cad 1 toptol_userset
ic_set_global geo_cad 0 toptol_userset
ic_set_global geo_cad 0.0 toler
ic_set_meshing_params global 0 gttol 0.001 gtrel 1
ic_geo_set_units mm
ic_geo_cre_geom_input $geom_file_path 0.001 input PNTS pnt CRVS crv SURFS {}
ic_boco_solver
ic_boco_clear_icons
ic_set_global geo_cad 0 toptol_userset
ic_set_global geo_cad 0.02 toler

# Code Changes the reactor size using these points (MATLAB)
ic_point {} PNTS pnt.00 -10,5,0
ic_point {} PNTS pnt.01 -10,0,0
ic_point {} PNTS pnt.02 764,0,0
ic_point {} PNTS pnt.03 764,120,0
ic_point {} PNTS pnt.04 88.1,120,0


ic_set_global geo_cad 0.4 toler
ic_delete_geometry curve names crv.00 0
ic_curve point CRVS crv.00 {pnt0 pnt.00}
ic_delete_geometry curve names crv.01 0
ic_curve point CRVS crv.01 {pnt.00 pnt.01}
ic_delete_geometry curve names crv.02 0
ic_curve point CRVS crv.02 {pnt.01 pnt.02}
ic_delete_geometry curve names crv.03 0
ic_curve point CRVS crv.03 {pnt.02 pnt.03}
ic_delete_geometry curve names crv.04 0
ic_curve point CRVS crv.04 {pnt.03 pnt.04}
ic_delete_geometry curve names crv.05 0

# Accounts for the fact number of points may change (MATLAB)
ic_curve point CRVS crv.05 {pnt.04 pnt209}

ic_delete_geometry curve names crv.06 0
ic_curve point CRVS crv.06 {}
ic_set_global geo_cad 0.4 toler
ic_set_global geo_cad 0.4 toler

# Code changes these depending on outlet/reservoir diameter
ic_point crv_par PNTS pnt.08 {crv.04 0.20361}
ic_point crv_par PNTS pnt.09 {crv.04 0.16893}
ic_point crv_par PNTS pnt.06 {crv.00 0.3535}
ic_point crv_par PNTS pnt.07 {crv.00 0.6465}

# This splits the edges to make inlet/outlet edges
ic_set_global geo_cad 0.4 toler
ic_curve split CRVS crv.06 {crv.00 pnt.07}
ic_curve split CRVS crv.07 {crv.00 pnt.06}
ic_curve split CRVS crv.08 {crv.04 pnt.08}
ic_curve split CRVS crv.09 {crv.04 pnt.09}


ic_geo_new_family FLUID
ic_boco_set_part_color FLUID
ic_hex_unload_blocking
ic_hex_initialize_mesh 2d new_numbering new_blocking FLUID
ic_hex_unblank_blocks
ic_hex_multi_grid_level 0
ic_hex_projection_limit 0
ic_hex_default_bunching_law default 2.0
ic_hex_floating_grid off
ic_hex_transfinite_degree 1
ic_hex_unstruct_face_type one_tri
ic_hex_set_unstruct_face_method uniform_quad
ic_hex_set_n_tetra_smoothing_steps 20
ic_hex_error_messages off_minor
ic_hex_set_piercing 0
ic_geo_set_part curve {crv.06 crv.00 crv.01} RESERVOIR_WALL 0
ic_delete_empty_parts
ic_geo_set_part curve crv.07 INLET 0
ic_delete_empty_parts
ic_geo_set_part curve crv0 NOZZLE_WALL 0
ic_delete_empty_parts
ic_geo_set_part curve crv.05 LEFT_REACTOR_WALL 0
ic_delete_empty_parts
ic_geo_set_part curve {crv.08 crv.04} TOP_REACTOR_WALL 0
ic_delete_empty_parts
ic_geo_set_part curve crv.09 OUTLET 0
ic_delete_empty_parts
ic_geo_set_part curve crv.03 RIGHT_REACTOR_WALL 0
ic_delete_empty_parts
ic_geo_set_part curve crv.02 AXIS 0
ic_geo_delete_family CRVS
ic_delete_empty_parts
ic_hex_unstruct_face_type
ic_hex_set_unstruct_face_method
ic_hex_split_grid 11 19 pnt.07 m PNTS FLUID RESERVOIR_WALL INLET NOZZLE_WALL LEFT_REACTOR_WALL TOP_REACTOR_WALL OUTLET RIGHT_REACTOR_WALL AXIS VORFN
ic_hex_split_grid 33 19 pnt.06 m PNTS FLUID RESERVOIR_WALL INLET NOZZLE_WALL LEFT_REACTOR_WALL TOP_REACTOR_WALL OUTLET RIGHT_REACTOR_WALL AXIS VORFN
ic_hex_split_grid 37 19 pnt0 m PNTS FLUID RESERVOIR_WALL INLET NOZZLE_WALL LEFT_REACTOR_WALL TOP_REACTOR_WALL OUTLET RIGHT_REACTOR_WALL AXIS VORFN
ic_hex_split_grid 41 19 pnt209 m PNTS FLUID RESERVOIR_WALL INLET NOZZLE_WALL LEFT_REACTOR_WALL TOP_REACTOR_WALL OUTLET RIGHT_REACTOR_WALL AXIS VORFN
ic_hex_split_grid 45 19 pnt.08 m PNTS FLUID RESERVOIR_WALL INLET NOZZLE_WALL LEFT_REACTOR_WALL TOP_REACTOR_WALL OUTLET RIGHT_REACTOR_WALL AXIS VORFN
ic_hex_split_grid 49 19 pnt.09 m PNTS FLUID RESERVOIR_WALL INLET NOZZLE_WALL LEFT_REACTOR_WALL TOP_REACTOR_WALL OUTLET RIGHT_REACTOR_WALL AXIS VORFN
ic_hex_split_grid 11 13 pnt209 m PNTS FLUID RESERVOIR_WALL INLET NOZZLE_WALL LEFT_REACTOR_WALL TOP_REACTOR_WALL OUTLET RIGHT_REACTOR_WALL AXIS VORFN
ic_hex_delete_blocks numbers 28 29 30 31
ic_hex_move_node 57 pnt.00
ic_hex_move_node 58 pnt.07
ic_hex_move_node 59 pnt.06
ic_hex_move_node 60 pnt0
ic_hex_move_node 11 pnt.01
ic_hex_move_node 61 pnt209
ic_hex_move_node 46 pnt.04
ic_hex_move_node 50 pnt.08
ic_hex_move_node 54 pnt.09
ic_hex_move_node 21 pnt.03
ic_hex_move_node 19 pnt.02
ic_hex_find_comp_curve crv.06
ic_hex_set_edge_projection 57 58 0 1 crv.06
ic_hex_find_comp_curve crv.07
ic_hex_set_edge_projection 58 59 0 1 crv.07
ic_hex_find_comp_curve crv.00
ic_hex_set_edge_projection 59 60 0 1 crv.00
ic_hex_find_comp_curve crv.01
ic_hex_set_edge_projection 11 57 0 1 crv.01
ic_hex_find_comp_curve crv0
ic_hex_set_edge_projection 60 61 0 1 crv0
ic_hex_find_comp_curve crv.05
ic_hex_set_edge_projection 61 46 0 1 crv.05
ic_hex_find_comp_curve crv.08
ic_hex_set_edge_projection 46 50 0 1 crv.08
ic_hex_find_comp_curve crv.09
ic_hex_set_edge_projection 50 54 0 1 crv.09
ic_hex_find_comp_curve crv.04
ic_hex_set_edge_projection 54 21 0 1 crv.04
ic_hex_find_comp_curve crv.03
ic_hex_set_edge_projection 64 21 0 1 crv.03
ic_hex_set_edge_projection 19 64 0 1 crv.03
ic_hex_find_comp_curve crv.02
ic_hex_set_edge_projection 53 19 0 1 crv.02
ic_hex_set_edge_projection 49 53 0 1 crv.02
ic_hex_set_edge_projection 45 49 0 1 crv.02
ic_hex_set_edge_projection 41 45 0 1 crv.02
ic_hex_set_edge_projection 37 41 0 1 crv.02
ic_hex_set_edge_projection 33 37 0 1 crv.02
ic_hex_set_edge_projection 11 33 0 1 crv.02



# This section sets node number to a float, which depends on length of edges

set edgelength1 [ic_hex_get_edge_param 57 58 len]
set nodevalue1 [expr ($edgelength1 * 8.49)]

set edgelength2 [ic_hex_get_edge_param 58 59 len]
set nodevalue2 [expr ($edgelength2 * 8.16)]

set edgelength3 [ic_hex_get_edge_param 60 61 len]
set nodevalue3 [expr ($edgelength3 * 7.179)]

set edgelength4 [ic_hex_get_edge_param 45 49 len]
set nodevalue4 [expr ($edgelength4 * 2.236)]

set edgelength5 [ic_hex_get_edge_param 50 54 len]
set nodevalue5 [expr ($edgelength5 * 1.1254)]

set edgelength6 [ic_hex_get_edge_param 54 21 len]
set nodevalue6 [expr ($edgelength6 * 0.880)]

set edgelength7 [ic_hex_get_edge_param 45 61 len]
set nodevalue7 [expr ($edgelength7 * 10)]

set edgelength8 [ic_hex_get_edge_param 61 46 len]
set nodevalue8 [expr ($edgelength8 * 2.6948)]

# Reservoir Before Outlet Horizontal (Node Value 1)
ic_hex_set_mesh 57 58 n $nodevalue1 h1rel 0.0 h2rel 0.0 r1 2 r2 2 lmax 0 default copy_to_parallel unlocked                              
ic_hex_set_mesh 57 58 n $nodevalue1 h1rel 0.0 h2rel 0.0 r1 2 r2 2 lmax 0 default copy_to_parallel unlocked 

# Inlet Horizontal (Node Value 2)                             
ic_hex_set_mesh 58 59 n $nodevalue2 h1rel 0.0 h2rel 0.0 r1 2 r2 2 lmax 0 default copy_to_parallel unlocked                              
ic_hex_set_mesh 58 59 n $nodevalue2 h1rel 0.0 h2rel 0.0 r1 2 r2 2 lmax 0 default copy_to_parallel unlocked   

# Reservoir After Outlet Horizontal (Node Value 1 inlet in center)                           
ic_hex_set_mesh 59 60 n $nodevalue1 h1rel 0.0 h2rel 0.0 r1 2 r2 2 lmax 0 default copy_to_parallel unlocked                              
ic_hex_set_mesh 59 60 n $nodevalue1 h1rel 0.0 h2rel 0.0 r1 2 r2 2 lmax 0 default copy_to_parallel unlocked  
                            
# Nozzle Region Horizontal
ic_hex_set_mesh 60 61 n $nodevalue3 h1rel 0.0 h2rel 0.0 r1 2 r2 2 lmax 0 default copy_to_parallel unlocked                                      
ic_hex_set_mesh 60 61 n $nodevalue3 h1rel 0.0 h2rel 0.0 r1 2 r2 2 lmax 0 default copy_to_parallel unlocked 

# Wake Region Horizontal                           
ic_hex_set_mesh 45 49 n $nodevalue4 h1rel 0.0 h2rel 0.0 r1 2 r2 2 lmax 0 default copy_to_parallel unlocked                                     
ic_hex_set_mesh 45 49 n $nodevalue4 h1rel linked 41 45 h2rel 0.0 r1 2 r2 2 lmax 0 geo1 copy_to_parallel locked
                        
# Outlet Horizontal
ic_hex_set_mesh 50 54 n $nodevalue5 h1rel 0.0 h2rel 0.0 r1 2 r2 2 lmax 0 default copy_to_parallel unlocked                                       
ic_hex_set_mesh 50 54 n $nodevalue5 h1rel 0.0 h2rel 0.0 r1 2 r2 2 lmax 0 default copy_to_parallel unlocked   

# After Outlet Horizontal
ic_hex_set_mesh 54 21 n $nodevalue6 h1rel 0.0 h2rel 0.0 r1 2 r2 2 lmax 0 default copy_to_parallel unlocked                                      
ic_hex_set_mesh 54 21 n $nodevalue6 h1rel 0.0144592249855 h2rel 0.0 r1 2 r2 2 lmax 0 default copy_to_parallel unlocked

# Wake Region Vertical                    
ic_hex_set_mesh 45 61 n $nodevalue7 h1rel 0.0 h2rel 0.0 r1 2 r2 2 lmax 0 default copy_to_parallel unlocked                                       
ic_hex_set_mesh 45 61 n $nodevalue7 h1rel 0.0 h2rel 0.000230494410511 r1 2 r2 2 lmax 0 geo2 copy_to_parallel unlocked        

# Above Wake Vertical
ic_hex_set_mesh 61 46 n $nodevalue8 h1rel 0.0 h2rel 0.0 r1 2 r2 2 lmax 0 default copy_to_parallel unlocked                                      
ic_hex_set_mesh 61 46 n $nodevalue8 h1rel linked 61 45 h2rel 0.0 r1 2 r2 2 lmax 0 geo1 copy_to_parallel locked                           



ic_boco_solver {Ansys Fluent}
ic_solver_mesh_info {Ansys Fluent}
ic_boco_set LEFT_REACTOR_WALL {{1 WALL 0}}
ic_boco_set TOP_REACTOR_WALL {{1 WALL 0}}
ic_geo_new_family VORFN 0
ic_boco_set VORFN {}
ic_boco_set RIGHT_REACTOR_WALL {{1 WALL 0}}
ic_boco_set INLET {{1 PRESI 0}}
ic_boco_set AXIS {{1 AXIS 0}}
ic_boco_set PNTS {}
ic_boco_set RESERVOIR_WALL {{1 WALL 0}}
ic_boco_set NOZZLE_WALL {{1 WALL 0}}
ic_boco_set FLUID { { 1  {color}  12109107  } }
ic_boco_set ORFN {}
ic_boco_set OUTLET {{1 PRESO 0}}
ic_hex_write_file $script_dir/Meshing/hex.uns PNTS FLUID RESERVOIR_WALL INLET NOZZLE_WALL LEFT_REACTOR_WALL TOP_REACTOR_WALL OUTLET RIGHT_REACTOR_WALL AXIS proj 2 dim_to_mesh 3 no_boco
ic_uns_load $script_dir/Meshing/hex.uns 3 0 {} 1
ic_uns_update_family_type visible {LEFT_REACTOR_WALL TOP_REACTOR_WALL VORFN RIGHT_REACTOR_WALL INLET AXIS PNTS RESERVOIR_WALL NOZZLE_WALL FLUID ORFN OUTLET} {!NODE !LINE_2 QUAD_4} update 0
ic_boco_solver 
ic_hex_create_mesh PNTS FLUID RESERVOIR_WALL INLET NOZZLE_WALL LEFT_REACTOR_WALL TOP_REACTOR_WALL OUTLET RIGHT_REACTOR_WALL AXIS VORFN VORFN proj 2 dim_to_mesh 3
ic_boco_clear_icons 
ic_boco_solver 
ic_boco_solver {Ansys Fluent}
ic_solution_set_solver {Ansys Fluent} 1
ic_boco_save $script_dir/Meshing/ansys.fbc
ic_boco_save_atr $script_dir/Meshing/ansys.atr
ic_delete_empty_parts 
ic_save_tetin $script_dir/Meshing/project1.tin 0 0 {} {} 0 0 1
ic_uns_check_duplicate_numbers 
ic_save_unstruct $script_dir/Meshing/project1.uns 1 {} {} {}
ic_uns_set_modified 1
ic_hex_save_blocking $script_dir/Meshing/project1.blk
ic_boco_solver 
ic_boco_solver {Ansys Fluent}
ic_solution_set_solver {Ansys Fluent} 1
ic_boco_save $script_dir/Meshing/project1.fbc
ic_boco_save_atr $script_dir/Meshing/project1.atr
ic_save_project_file $script_dir/Meshing/project1.prj {array\ set\ file_name\ \{ {    catia_dir .} {    parts_dir .} {    domain_loaded 0} {    cart_file_loaded 0} {    cart_file {}} {    domain_saved $script_dir/Meshing/project1.uns} {    archive {}} {    med_replay {}} {    topology_dir .} {    ugparts_dir .} {    icons {{$env(ICEM_ACN)/lib/ai_env/icons} {$env(ICEM_ACN)/lib/va/EZCAD/icons} {$env(ICEM_ACN)/lib/icons} {$env(ICEM_ACN)/lib/va/CABIN/icons}}} {    tetin $script_dir/Meshing/project1.tin} {    family_boco $script_dir/Meshing/project1.fbc} {    iges_dir .} {    solver_params_loaded 0} {    attributes_loaded 0} {    project_lock {}} {    attributes $script_dir/Meshing/project1.atr} {    domain project1.uns} {    domains_dir .} {    settings_loaded 0} {    settings $script_dir/Meshing/project1.prj} {    blocking $script_dir/Meshing/project1.blk} {    hexa_replay {}} {    transfer_dir .} {    mesh_dir .} {    family_topo {}} {    gemsparts_dir .} {    family_boco_loaded 0} {    tetin_loaded 0} {    project_dir .} {    topo_mulcad_out {}} {    solver_params {}} \} array\ set\ options\ \{ {    expert 1} {    remote_path {}} {    tree_disp_quad 2} {    tree_disp_pyra 0} {    evaluate_diagnostic 0} {    histo_show_default 1} {    select_toggle_corners 0} {    remove_all 0} {    keep_existing_file_names 0} {    record_journal 0} {    edit_wait 0} {    face_mode all} {    select_mode all} {    med_save_emergency_tetin 1} {    user_name scldr} {    diag_which all} {    uns_warn_if_display 500000} {    bubble_delay 1000} {    external_num 1} {    tree_disp_tri 2} {    apply_all 0} {    temporary_directory {}} {    flood_select_angle 0} {    home_after_load 1} {    project_active 0} {    histo_color_by_quality_default 1} {    undo_logging 1} {    tree_disp_hexa 0} {    histo_solid_default 1} {    host_name login2.arc4.leeds.ac.uk} {    xhidden_full 1} {    replay_internal_editor 1} {    editor vi} {    mouse_color orange} {    clear_undo 1} {    remote_acn {}} {    remote_sh csh} {    tree_disp_penta 0} {    n_processors 4} {    remote_host {}} {    save_to_new 0} {    quality_info Quality} {    tree_disp_node 0} {    med_save_emergency_mesh 1} {    redtext_color red} {    tree_disp_line 0} {    select_edge_mode 0} {    use_dlremote 0} {    max_mesh_map_size 1024} {    show_tris 1} {    remote_user {}} {    enable_idle 0} {    auto_save_views 1} {    max_cad_map_size 512} {    display_origin 0} {    uns_warn_user_if_display 1000000} {    detail_info 0} {    win_java_help 0} {    show_factor 1} {    boundary_mode all} {    clean_up_tmp_files 1} {    auto_fix_uncovered_faces 1} {    med_save_emergency_blocking 1} {    max_binary_tetin 0} {    tree_disp_tetra 0} \} array\ set\ disp_options\ \{ {    uns_dualmesh 0} {    uns_warn_if_display 500000} {    uns_normals_colored 0} {    uns_icons 0} {    uns_locked_elements 0} {    uns_shrink_npos 0} {    uns_node_type None} {    uns_icons_normals_vol 0} {    uns_bcfield 0} {    backup Wire} {    uns_nodes 0} {    uns_only_edges 0} {    uns_surf_bounds 0} {    uns_wide_lines 0} {    uns_vol_bounds 0} {    uns_displ_orient Triad} {    uns_orientation 0} {    uns_directions 0} {    uns_thickness 0} {    uns_shell_diagnostic 0} {    uns_normals 0} {    uns_couplings 0} {    uns_periodicity 0} {    uns_single_surfaces 0} {    uns_midside_nodes 1} {    uns_shrink 100} {    uns_multiple_surfaces 0} {    uns_no_inner 0} {    uns_enums 0} {    uns_disp Wire} {    uns_bcfield_name {}} {    uns_color_by_quality 0} {    uns_changes 0} {    uns_cut_delay_count 1000} \} {set icon_size1 24} {set icon_size2 35} {set thickness_defined 0} {set solver_type 1} {set solver_setup -1} array\ set\ prism_values\ \{ {    n_triangle_smoothing_steps 5} {    min_smoothing_steps 6} {    first_layer_smoothing_steps 1} {    new_volume {}} {    height {}} {    prism_height_limit {}} {    interpolate_heights 0} {    n_tetra_smoothing_steps 10} {    do_checks {}} {    delete_standalone 1} {    ortho_weight 0.50} {    max_aspect_ratio {}} {    ratio_max {}} {    incremental_write 0} {    total_height {}} {    use_prism_v10 0} {    intermediate_write 1} {    delete_base_triangles {}} {    ratio_multiplier {}} {    verbosity_level 1} {    refine_prism_boundary 1} {    max_size_ratio {}} {    triangle_quality {}} {    max_prism_angle 180} {    tetra_smooth_limit 0.3} {    max_jump_factor 5} {    use_existing_quad_layers 0} {    layers 3} {    fillet 0.10} {    into_orphan 0} {    init_dir_from_prev {}} {    blayer_2d 0} {    do_not_allow_sticking {}} {    top_family {}} {    law exponential} {    min_smoothing_val 0.1} {    auto_reduction 0} {    stop_columns 1} {    stair_step 1} {    smoothing_steps 12} {    side_family {}} {    min_prism_quality 0.01} {    ratio 1.2} \} {set aie_current_flavor {}} array\ set\ vid_options\ \{ {    wb_import_mat_points 0} {    wb_NS_to_subset 0} {    wb_import_surface_bodies 1} {    wb_import_cad_att_pre {SDFEA;DDM}} {    wb_import_mix_res_line 0} {    wb_import_tritol 0.001} {    auxiliary 0} {    wb_import_cad_att_trans 1} {    wb_import_mix_res -1} {    wb_import_mix_res_surface 0} {    show_name 0} {    wb_import_solid_bodies 1} {    wb_import_delete_solids 0} {    wb_import_mix_res_solid 0} {    wb_import_save_pmdb {}} {    inherit 1} {    default_part GEOM} {    new_srf_topo 1} {    wb_import_associativity_model_name {}} {    DelPerFlag 0} {    wb_import_line_bodies 0} {    wb_import_save_partfile 0} {    composite_tolerance 1.0} {    wb_NS_to_entity_parts 0} {    wb_import_en_sym_proc 1} {    wb_import_sel_proc 0} {    wb_import_work_points 0} {    wb_import_reference_key 0} {    wb_import_mix_res_point 0} {    wb_import_pluginname {}} {    wb_NS_only 0} {    wb_import_create_solids 0} {    wb_import_refresh_pmdb 0} {    wb_import_lcs 0} {    wb_import_sel_pre {}} {    wb_import_scale_geo Default} {    wb_import_load_pmdb {}} {    replace 0} {    wb_import_cad_associativity 0} {    same_pnt_tol 1e-4} {    tdv_axes 1} {    vid_mode 0} {    DelBlkPerFlag 0} \} {set savedTreeVisibility {geomNode 1 geom_subsetNode 2 geomPointNode 0 geomCurveNode 2 meshNode 1 mesh_subsetNode 2 meshPointNode 0 meshLineNode 2 meshShellNode 2 meshQuadNode 2 blockingNode 1 block_subsetNode 2 block_vertNode 0 block_edgeNode 2 block_faceNode 0 block_blockNode 0 block_meshNode 0 topoNode 2 topo-root 2 partNode 2 part-AXIS 2 part-FLUID 2 part-INLET 2 part-LEFT_REACTOR_WALL 2 part-NOZZLE_WALL 2 part-OUTLET 2 part-PNTS 2 part-RESERVOIR_WALL 2 part-RIGHT_REACTOR_WALL 2 part-TOP_REACTOR_WALL 2 part-VORFN 2}} {set last_view {rot {0.00089605722776 0.0 0.0 0.999999598541} scale {393.115752187 393.115752187 393.115752187} center {0 0 0} pos {0 0 0}}} array\ set\ cut_info\ \{ {    active 0} \} array\ set\ hex_option\ \{ {    default_bunching_ratio 2.0} {    floating_grid 0} {    project_to_topo 0} {    n_tetra_smoothing_steps 20} {    sketching_mode 0} {    trfDeg 1} {    wr_hexa7 0} {    hexa_projection_mode 0} {    smooth_ogrid 0} {    find_worst 1-3} {    hexa_verbose_mode 0} {    old_eparams 0} {    uns_face_mesh_method uniform_quad} {    multigrid_level 0} {    uns_face_mesh one_tri} {    check_blck 0} {    proj_limit 0} {    check_inv 0} {    project_bspline 0} {    hexa_update_mode 1} {    default_bunching_law BiGeometric} {    worse_criterion Quality} \} array\ set\ saved_views\ \{ {    views {}} \}} {ICEM CFD}
ic_exec /apps/applications/ansys/2023R1/1/default/v231/icemcfd/linux64_amd/icemcfd/output-interfaces/fluent6 -dom $script_dir/Meshing/project1.uns -b $script_dir/Meshing/project1.fbc -dim2d $script_dir/Run1/Mesh
ic_uns_num_couplings
ic_uns_create_diagnostic_edgelist 1
ic_uns_diagnostic subset all diag_type uncovered fix_fam FIX_UNCOVERED diag_verb {Uncovered faces} fams {} busy_off 1 quiet 1
ic_uns_create_diagnostic_edgelist 0
ic_uns_min_metric Quality {} {}
ic_reports_write_mesh_report All $script_dir/Run1/mesh_report.html -format HTML -mesher {ICEM CFD 2023 R1} -title {mesh_report mesh report} -user USER -write_quality All -write_quality_all __NONE__ -write_summary All -write_diagnostics All
exit
