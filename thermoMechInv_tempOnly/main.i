parameter_mesh_size = 4x2x1
#parameter_mesh_size = 1x1x1

[Optimization]
[]

[OptimizationReporter]
#-mesh_approach
  type = ParameterMeshOptimization
  parameter_names = 'source'
  parameter_meshes = 'mesh_${parameter_mesh_size}.e'
  parameter_families = 'MONOMIAL'
  parameter_orders = 'CONSTANT'
#-function_approach
#  type = OptimizationReporter
#  parameter_names = 'source'
#  num_values = '1'

  measurement_file = 'synthetic_${parameter_mesh_size}_all_0001.csv'
  file_xcoord = 'x'
  file_ycoord = 'y'
  file_zcoord = 'z'
  file_value = 'temperature'
[]

[Executioner]
  type = Optimize
  verbose = true

#-Hessian
#  tao_solver = taonls
#  petsc_options_iname = '-tao_nls_pc_type -tao_nls_ksp_type'
#  petsc_options_value = 'none cg'

#-gradient lmvm
#  tao_solver = taolmvm
#  petsc_options_iname = '-tao_max_it -tao_gttol -tao_grtol -tao_ls_type'# -tao_fd_gradient -tao_fd_delta'
#  petsc_options_value = '50           1e-5       1e-16      armijo'#       true             1e3'

#-gradient check
  tao_solver = taobncg
  petsc_options_iname = '-tao_max_it -tao_grtol -tao_ls_type -tao_fd_test -tao_test_gradient -tao_fd_gradient -tao_fd_delta'
  petsc_options_value = '1 1e-16 unit true true false 1e3'
  petsc_options = '-tao_test_gradient_view'
[]

[MultiApps]
  [forward]
    type = FullSolveMultiApp
    input_files = forward.i
    execute_on = "FORWARD"
    cli_args = parameter_mesh_size=${parameter_mesh_size} #mesh_approach
  []
  [adjoint]
   type = FullSolveMultiApp
    input_files = grad.i
    execute_on = "ADJOINT"
    cli_args = parameter_mesh_size=${parameter_mesh_size} #mesh_approach
  []
#  [homogeneousForward]
#    type = FullSolveMultiApp
#    input_files = hforward.i
#    execute_on = "HOMOGENEOUS_FORWARD"
#    cli_args = parameter_mesh_size=${parameter_mesh_size} #mesh_approach
#  []
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
                      OptimizationReporter/source'
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
  # ADJOINT transfers
  [toAdjoint]
    type = MultiAppReporterTransfer
    to_multi_app = adjoint
    from_reporters = 'OptimizationReporter/measurement_xcoord
                      OptimizationReporter/measurement_ycoord
                      OptimizationReporter/measurement_zcoord
                      OptimizationReporter/measurement_time
                      OptimizationReporter/misfit_values
                      OptimizationReporter/source'
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
    to_reporters = 'OptimizationReporter/grad_source'
  []
  # HESSIAN transfers.  Same as forward.
#  [toHomoForward]
#    type = MultiAppReporterTransfer
#    to_multi_app = homogeneousForward
#    from_reporters = 'OptimizationReporter/measurement_xcoord
#                        OptimizationReporter/measurement_ycoord
#                        OptimizationReporter/measurement_zcoord
#                        OptimizationReporter/measurement_time
#                        OptimizationReporter/measurement_values
#                        OptimizationReporter/source'
#    to_reporters = 'measure_data/measurement_xcoord
#                      measure_data/measurement_ycoord
#                      measure_data/measurement_zcoord
#                      measure_data/measurement_time
#                      measure_data/measurement_values
#                      params_fuel/source'
#  []
#  [fromHomoForward]
#    type = MultiAppReporterTransfer
#    from_multi_app = homogeneousForward
#    from_reporters = 'measure_data/simulation_values'
#    to_reporters = 'OptimizationReporter/simulation_values'
#  []
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
