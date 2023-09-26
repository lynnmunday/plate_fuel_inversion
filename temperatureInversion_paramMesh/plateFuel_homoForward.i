parameter_mesh_size = 1x1x1
[Mesh]
  [read_plate_mesh]
    type = FileMeshGenerator
    file = plate_steady_mm_in.e
  []
[]

[Variables]
  [temperature]
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
[]

[Materials]
  # fuel properties
  [fuel_thermal]
    type = ADGenericConstantMaterial
    prop_names = thermal_conductivity
    prop_values = 17.6e3
    block = 'fuel liner'
  []
  # cladding properties
  [clad_thermal]
    type = ADGenericConstantMaterial
    prop_names = thermal_conductivity
    prop_values = 175e3
    block = 'cladding'
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

  line_search = 'none'

  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-7
  nl_max_its = 50

  l_tol = 1e-4
  l_max_its = 50
[]

##---------Optimization stuff------------------#
[Reporters]
  [measure_data]
    type = OptimizationData
    variable = 'temperature'
    # variable_weight_names = 'weighted_temperature'
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

