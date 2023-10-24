parameter_mesh_size = 20x3x1

[Optimization]
[]

[OptimizationReporter]
  type = ParameterMeshOptimization
  parameter_names = 'source_elem'
  parameter_meshes = '../../syntheticData/mesh_${parameter_mesh_size}.e'
  parameter_families = 'MONOMIAL'
  parameter_orders = 'CONSTANT'
  measurement_file = '../../syntheticData/results_func_disp_all_0001.csv'
  # constant_group_initial_condition = 5e10
  file_xcoord = 'x'
  file_ycoord = 'y'
  file_zcoord = 'z'
  file_value = 'weighted_disp_z' #'temperature'
  file_variable_weights = 'weight'
  # tikhonov_coeff = 0.1
[]
[Executioner]
  type = Optimize
  verbose = true
  ##--Hessian
  # tao_solver = taonls
  # petsc_options_iname = '-tao_gatol -tao_grtol -tao_nls_pc_type -tao_nls_ksp_type'
  # petsc_options_value = '1e-8 1e-16 none cg'

  #  tao_solver = taontr #taonls
  #  petsc_options_iname = '-tao_max_it -tao_gatol -tao_grtol -tao_ntr_pc_type -tao_ntr_ksp_type'
  #  petsc_options_value = '3 1e-8 1e-16 none stcg'
  ##--gradient bounded quasiNewtonKrylov Trust Region
  # tao_solver = taobqnktr
  # petsc_options_iname = '-tao_max_it -tao_gatol -tao_grtol -tao_trust0'
  # petsc_options_value = '7 1e-8 1e-16 1e6'
  ##--gradient lmvm
  tao_solver = taolmvm
  petsc_options_iname = '-tao_max_it -tao_gttol -tao_grtol -tao_ls_type' # -tao_fd_gradient -tao_fd_delta'
  petsc_options_value = '100         1e-4       1e-16      unit ' #armijo#       true             1e3'
  ##--gradient cg
  # tao_solver = taobncg
  # petsc_options_iname = '-tao_max_it -tao_gatol -tao_grtol -tao_ls_type'
  # petsc_options_value = '50 1e-8 1e-16 unit'
  ##--finite difference testing
  # tao_solver = taobncg
  # petsc_options_iname = '-tao_max_it -tao_grtol -tao_ls_type -tao_fd_test -tao_test_gradient -tao_fd_gradient -tao_fd_delta'
  # petsc_options_value = '1 1e-16 unit true true false 1e3'
  # petsc_options = '-tao_test_gradient_view'
[]

[MultiApps]
  [forward_adjoint]
    type = FullSolveMultiApp
    input_files = plateFuel_forward_adjoint.i
    execute_on = "FORWARD"
    cli_args = parameter_mesh_size=${parameter_mesh_size}
  []
[]

[Transfers]
  [fromForward]
    type = MultiAppReporterTransfer
    from_multi_app = forward_adjoint
    from_reporters = 'measure_data/simulation_values
                      grad_src_fuel/inner_product'
    to_reporters = 'OptimizationReporter/simulation_values
                    OptimizationReporter/grad_source_elem'
  []

  [toForward]
    type = MultiAppReporterTransfer
    to_multi_app = forward_adjoint
    from_reporters = 'OptimizationReporter/measurement_xcoord
                      OptimizationReporter/measurement_ycoord
                      OptimizationReporter/measurement_zcoord
                      OptimizationReporter/measurement_time
                      OptimizationReporter/measurement_values
                      OptimizationReporter/weight
                      OptimizationReporter/source_elem'
    to_reporters = 'measure_data/measurement_xcoord
                    measure_data/measurement_ycoord
                    measure_data/measurement_zcoord
                    measure_data/measurement_time
                    measure_data/measurement_values
                    measure_data/weight
                    params_fuel/source'
  []
[]

[Reporters]
  [optInfo]
    type = OptimizationInfo
    items = 'current_iterate function_value gnorm'
  []
[]

##--------- output parameter for transfer---------#
[Mesh]
  [restart_mesh]
    type = FileMeshGenerator
    file = '../../syntheticData/mesh_${parameter_mesh_size}.e'
  []
[]

[AuxVariables]
  [source_exact]
    order = CONSTANT
    family = MONOMIAL
  []
  [source]
    order = CONSTANT
    family = MONOMIAL
  []
  [disp_x]
  []
  [disp_y]
  []
  [disp_z]
  []
[]

[AuxKernels]
  [source_exact]
    type = FunctionAux
    variable = source_exact
    function = src_fuel_function
  []
[]

[Functions]
  [src_fuel_function]
    type = ParameterMeshFunction
    family = MONOMIAL
    order = CONSTANT
    exodus_mesh = '../../syntheticData/mesh_${parameter_mesh_size}.e'
    parameter_name = OptimizationReporter/source_elem
  []
[]

[Transfers]
  [fromForward_source_parameter]
    type = MultiAppGeneralFieldShapeEvaluationTransfer
    from_multi_app = forward_adjoint
    source_variable = source
    variable = source
  []
  [fromForward_disp_x_parameter]
    type = MultiAppGeneralFieldShapeEvaluationTransfer
    from_multi_app = forward_adjoint
    source_variable = disp_x
    variable = disp_x
  []
  [fromForward_disp_y_parameter]
    type = MultiAppGeneralFieldShapeEvaluationTransfer
    from_multi_app = forward_adjoint
    source_variable = disp_y
    variable = disp_y
  []
  [fromForward_disp_z_parameter]
    type = MultiAppGeneralFieldShapeEvaluationTransfer
    from_multi_app = forward_adjoint
    source_variable = disp_z
    variable = disp_z
  []
[]

[Outputs]
  exodus = true
  csv = true
  console = true
[]
