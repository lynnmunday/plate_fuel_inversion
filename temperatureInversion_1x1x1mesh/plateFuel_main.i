[Optimization]
[]

measurementDir = '/Users/mundlb/projects/isopod_inputs/plate_fuel_inversion/syntheticData'
[OptimizationReporter]
  type = ParameterMeshOptimization
  parameter_names = 'source_elem'
  parameter_meshes = '${measurementDir}/mesh_1x1x1.e'
  parameter_families = 'MONOMIAL'
  parameter_orders = 'CONSTANT'
  measurement_file = '${measurementDir}/results_1x1x1_disp_all_0001.csv'
  constant_group_initial_condition = 50000
  file_xcoord = 'x'
  file_ycoord = 'y'
  file_zcoord = 'z'
  file_value = 'temperature'
  # file_variable_weights = 'weight_disp_x'
[]
[Executioner]
  type = Optimize
  verbose = true
  ##--gradient bounded quasiNewtonKrylov Trust Region
  # tao_solver = taobqnktr
  # petsc_options_iname = '-tao_gatol -tao_grtol'# -tao_fd_gradient -tao_fd_delta'
  # petsc_options_value = '1e-8 1e-16'# true 1e-3'
  ##--gradient lmvm
  # tao_solver = taolmvm
  # petsc_options_iname = '-tao_gttol -tao_grtol -tao_ls_type'
  # petsc_options_value = ' 1e-5 1e-16 unit'
  ##--gradient cg
  # tao_solver = taobncg
  # petsc_options_iname = '-tao_gatol -tao_ls_type'
  # petsc_options_value = '1e-7 unit'
  ##--finite difference testing
  tao_solver = taobncg
  petsc_options_iname = '-tao_max_it -tao_grtol -tao_ls_type -tao_fd_test -tao_test_gradient -tao_fd_gradient -tao_fd_delta'
  petsc_options_value = '1 1e-16 unit true true false 1e3'
  petsc_options = '-tao_test_gradient_view'
[]

[MultiApps]
  [forward]
    type = FullSolveMultiApp
    input_files = plateFuel_forward.i
    execute_on = "FORWARD"
  []
  [adjoint]
    type = FullSolveMultiApp
    input_files = plateFuel_adjoint.i
    execute_on = "ADJOINT"
  []
[]

[Transfers]
  [toForward]
    type = MultiAppReporterTransfer
    to_multi_app = forward
    from_reporters = 'OptimizationReporter/measurement_xcoord
                      OptimizationReporter/measurement_ycoord
                      OptimizationReporter/measurement_zcoord
                      OptimizationReporter/measurement_time
                      OptimizationReporter/measurement_values
                      OptimizationReporter/source_elem'
    to_reporters = 'measure_data/measurement_xcoord
                    measure_data/measurement_ycoord
                    measure_data/measurement_zcoord
                    measure_data/measurement_time
                    measure_data/measurement_values
                    params_fuel/source'
  []
  [fromForward]
    type = MultiAppReporterTransfer
    from_multi_app = forward
    from_reporters = 'measure_data/simulation_values'
    to_reporters = 'OptimizationReporter/simulation_values'
  []
  [toAdjoint]
    type = MultiAppReporterTransfer
    to_multi_app = adjoint
    from_reporters = 'OptimizationReporter/measurement_xcoord
                      OptimizationReporter/measurement_ycoord
                      OptimizationReporter/measurement_zcoord
                      OptimizationReporter/measurement_time
                      OptimizationReporter/misfit_values
                      OptimizationReporter/source_elem'
    to_reporters = 'misfit/measurement_xcoord
                    misfit/measurement_ycoord
                    misfit/measurement_zcoord
                    misfit/measurement_time
                    misfit/misfit_values
                    params_fuel/source'
  []
  [fromadjoint]
    type = MultiAppReporterTransfer
    from_multi_app = adjoint
    from_reporters = 'grad_src_fuel/inner_product'
    to_reporters = 'OptimizationReporter/grad_source_elem'
  []
[]

[Reporters]
  [optInfo]
    type = OptimizationInfo
    items = 'current_iterate function_value gnorm'
  []
[]

[Outputs]
  csv = true
  console = true
[]
