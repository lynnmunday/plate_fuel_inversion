parameter_mesh_size = 1x1x1

[Problem]
  nl_sys_names = 'nl0 adjoint'
  kernel_coverage_check = false
[]

[Mesh]
  [read_plate_mesh]
    type = FileMeshGenerator
    file = ../../syntheticData/plate_steady_mm_in.e
  []
[]

[Variables]
  [T]
  []
  [lam_T]
    nl_sys = adjoint
  []

  [disp_x]
  []
  [lam_x]
    nl_sys = adjoint
  []

  [disp_y]
  []
  [lam_y]
    nl_sys = adjoint
  []

  [disp_z]
  []
  [lam_z]
    nl_sys = adjoint
  []
[]

[Kernels]
  [heat_conduction]
    type = ADMatDiffusion
    variable = T
    diffusivity = thermal_conductivity
  []
  [heat_source]
    type = ADBodyForce
    function = src_fuel_function
    variable = T
    block = 'fuel liner'
  []
[]

[Modules/TensorMechanics/Master]
  displacements = 'disp_x disp_y disp_z'
  [all]
    strain = SMALL
    temperature = T
    eigenstrain_names = 'eigenstrain'
    use_automatic_differentiation = true
    displacements = 'disp_x disp_y disp_z'
  []
[]

[BCs]
  [conv_BC_front]
    type = ADConvectiveHeatFluxBC
    variable = T
    boundary = front
    T_infinity = 355
    heat_transfer_coefficient = 90000
  []
  [conv_BC_back]
    type = ADConvectiveHeatFluxBC
    variable = T
    boundary = back
    T_infinity = 325
    heat_transfer_coefficient = 40000
  []
  [disp_x]
    type = ADDirichletBC
    variable = disp_x
    boundary = 'left_bottom_back'
    value = 0.0
  []
  [disp_y]
    type = ADDirichletBC
    variable = disp_y
    boundary = 'left_bottom_back right_bottom_back'
    value = 0.0
  []
  [disp_z]
    type = ADDirichletBC
    variable = disp_z
    boundary = 'left_bottom_back right_bottom_back right_top_back'
    value = 0.0
  []
[]

[Materials]
  # fuel properties
  [fuel_thermal]
    type = ADGenericConstantMaterial
    prop_names = thermal_conductivity
    prop_values = 17.6e3
    block = 'fuel liner'
  []
  [fuel_elasticity]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = 90e3
    poissons_ratio = 0.35
    block = 'fuel liner'
  []
  [fuel_thermal_expansion]
    type = ADComputeThermalExpansionEigenstrain
    temperature = T
    thermal_expansion_coeff = 15e-6 #U10MoThermalExpansionEigenstrain - Burkes  T=300
    stress_free_temperature = 294
    eigenstrain_name = eigenstrain
    block = 'fuel liner'
  []
  [fuel_stress]
    type = ADComputeLinearElasticStress
    block = 'fuel liner'
  []
  # cladding properties
  [clad_thermal]
    type = ADGenericConstantMaterial
    prop_names = thermal_conductivity
    prop_values = 175e3
    block = 'cladding'
  []
  [clad_elasticity]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = 69e3
    poissons_ratio = 0.33
    block = cladding
  []
  [clad_thermal_expansion]
    type = ADComputeThermalExpansionEigenstrain
    temperature = T
    thermal_expansion_coeff = 25.1e-6 #Al6061ThermalExpansionEigenstrain T=300
    stress_free_temperature = 295
    eigenstrain_name = eigenstrain
    block = cladding
  []
  [clad_stress]
    type = ADComputeLinearElasticStress
    block = cladding
  []
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = SteadyAndAdjoint
  forward_system = nl0
  adjoint_system = adjoint

  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu mumps'

  # automatic_scaling = true
  # scaling_group_variables = 'disp_x disp_y disp_z'
  # off_diagonals_in_auto_scaling = true
  # compute_scaling_once = false

  line_search = 'none'

  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-30
  nl_max_its = 10

  l_tol = 1e-8
  l_max_its = 10
[]

[Postprocessors]
  [average_fuel_T]
    type = ElementAverageValue
    block = fuel
    variable = T
    execute_on = 'timestep_end'
    outputs = none
  []
[]

##---------Forward Optimization stuff------------------#
[Reporters]
  [measure_data]
    type = OptimizationData
    variable = 'disp_z'
    variable_weight_names = weight
    outputs = none
  []
  [params_fuel]
    type = ConstantReporter
    real_vector_names = 'source'
    real_vector_values = '0' # Dummy
  []
[]

[Functions]
  [src_fuel_function]
    type = ParameterMeshFunction
    family = MONOMIAL
    order = CONSTANT
    exodus_mesh = '../../syntheticData/mesh_${parameter_mesh_size}.e'
    parameter_name = params_fuel/source
  []
[]
##---------Adjoint Optimization stuff------------------#
[DiracKernels]
  [adjointLoad_uz]
    type = ReporterPointSource
    variable = lam_z
    x_coord_name = measure_data/measurement_xcoord
    y_coord_name = measure_data/measurement_ycoord
    z_coord_name = measure_data/measurement_zcoord
    value_name = measure_data/misfit_values
    weight_name = measure_data/weight
  []
[]

[VectorPostprocessors]
  [grad_src_fuel]
    type = ElementOptimizationSourceFunctionInnerProduct
    variable = lam_T
    function = src_fuel_function
    block = 'fuel liner'
    execute_on = ADJOINT_TIMESTEP_END
    outputs = none
  []
[]

##--------- output parameter for transfer---------#
[AuxKernels]
  [source]
    type = FunctionAux
    variable = source
    function = src_fuel_function
    block = 'fuel liner'
  []
[]
[AuxVariables]
  [source]
    order = CONSTANT
    family = MONOMIAL
  []
[]

##--------- Outputs ------------------#
[VectorPostprocessors]
  [disp_center_top]
    type = LineValueSampler
    start_point = '0.0 12.7 1.244'
    end_point = '101 12.7 1.244'
    num_points = 50
    sort_by = id
    variable = 'disp_z'
  []
  [disp_diag_top]
    type = LineValueSampler
    start_point = '0.0 0.0 1.244'
    end_point = '101 12.7 1.244'
    num_points = 50
    sort_by = id
    variable = 'disp_z'
  []
  [T_center_mid]
    type = LineValueSampler
    start_point = '0.0 0.0 0.622'
    end_point = '101 12.7 0.622'
    num_points = 50
    sort_by = id
    variable = 'T'
  []
  [T_diag_mid]
    type = LineValueSampler
    start_point = '0.0 0.0 0.622'
    end_point = '101 12.7 0.622'
    num_points = 50
    sort_by = id
    variable = 'T'
  []
[]

[Outputs]
  exodus = true
  execute_on = timestep_end
  csv = true
[]

[Debug]
  show_var_residual_norms = true
[]
