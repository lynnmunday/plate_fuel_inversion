parameter_mesh_size = 1x1x1

[GlobalParams]
  order = FIRST
  family = LAGRANGE
  displacements = 'disp_x disp_y disp_z'
  volumetric_locking_correction = false
[]

[Problem]
  type = ReferenceResidualProblem
  reference_vector = ref
  extra_tag_vectors = 'ref'
  group_variables = 'disp_x disp_y disp_z'
[]

[Mesh]
  [read_plate_mesh]
    type = FileMeshGenerator
    file = plate_steady_mm_in.e
  []
[]

[Variables]
  [temperature]
  []
  [disp_x]
  []
  [disp_y]
  []
  [disp_z]
  []
[]

[Kernels]
  [heat_conduction]
    type = ADMatDiffusion
    variable = temperature
    diffusivity = thermal_conductivity
  []
  [heat_source]
    type = ADBodyForce
    function = src_fuel_function
    variable = temperature
    block = 'fuel liner'
  []
[]

[Modules/TensorMechanics/Master]
  [all]
    strain = SMALL
    temperature = temperature
    generate_output = 'stress_xx stress_yy stress_zz vonmises_stress'
    eigenstrain_names = 'eigenstrain'
    absolute_value_vector_tags = 'ref'
    use_automatic_differentiation = true
  []
[]

[BCs]
  [conv_BC_front]
    type = ADConvectiveHeatFluxBC
    variable = temperature
    boundary = front
    T_infinity = 0
    heat_transfer_coefficient = 90000
  []
  [conv_BC_back]
    type = ADConvectiveHeatFluxBC
    variable = temperature
    boundary = back
    T_infinity = 0
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
    temperature = temperature
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
    temperature = temperature
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
  type = Steady
  solve_type = 'Newton'

  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu superlu_dist'

  automatic_scaling = true
  scaling_group_variables = 'disp_x disp_y disp_z'
  # off_diagonals_in_auto_scaling = true
  compute_scaling_once = false

  line_search = 'none'

  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-30
  nl_max_its = 50

  l_tol = 1e-4
  l_max_its = 50
[]

[Postprocessors]
  [average_fuel_T]
    type = ElementAverageValue
    block = fuel
    variable = temperature
    execute_on = 'timestep_end'
  []
[]

##---------Optimization stuff------------------#
[Reporters]
  [measure_data]
    type = OptimizationData
    variable = 'temperature'
    # variable_weight_names = 'temperature'
  []
  [params_fuel]
    type = ConstantReporter
    real_vector_names = 'source'
    real_vector_values = '0' # Dummy
  []
[]
measurementDir = '/Users/mundlb/projects/isopod_inputs/plate_fuel_inversion/syntheticData'
[Functions]
  [src_fuel_function]
    type = ParameterMeshFunction
    family = MONOMIAL
    order = CONSTANT
    exodus_mesh = '${measurementDir}/mesh_${parameter_mesh_size}.e'
    parameter_name = params_fuel/source
  []
[]
##--------- Outputs ------------------#
[VectorPostprocessors]
  [disp_all]
    type = NodalValueSampler
    sort_by = id
    boundary = front
    variable = 'temperature'
  []
  [disp_top]
    type = LineValueSampler
    start_point = '0.0 12.7 0.7'
    end_point = '101 12.7 0.7'
    num_points = 20
    sort_by = id
    variable = 'temperature'
  []
[]

[Outputs]
  csv = true
  exodus = true
[]
