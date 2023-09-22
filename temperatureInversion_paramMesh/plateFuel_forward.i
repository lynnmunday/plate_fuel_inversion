parameter_mesh_size=1x1x1

[Mesh]
  [read_plate_mesh]
    type = FileMeshGenerator
    file = plate_steady_in.e
  []
[]

[Problem]
  extra_tag_vectors = 'flux_tag heatSource_tag'
[]

[AuxVariables]
  [flux_tag]
    order = FIRST
    family = LAGRANGE
  []
  [heatSource_tag]
    order = FIRST
    family = LAGRANGE
  []
[]

[AuxKernels]
  [heatSource]
    type = TagVectorAux
    variable = heatSource_tag
    v = temperature
    vector_tag = heatSource_tag
    execute_on = timestep_end
  []
  [flux]
    type = TagVectorAux
    variable = flux_tag
    v = temperature
    vector_tag = flux_tag
    execute_on = timestep_end
  []
[]

[Variables]
  [temperature]
  []
[]

[Kernels]
  [heat]
    type = HeatConduction
    variable = temperature
  []
  [heat_source]
    type = HeatSource
    block = 'fuel liner'
    function = src_fuel_function
    variable = temperature
    extra_vector_tags = 'heatSource_tag'
  []
[]

[BCs]
  [conv_BC_front]
    type = ConvectiveHeatFluxBC
    variable = temperature
    boundary = front
    T_infinity = 355
    heat_transfer_coefficient = 90000
    extra_vector_tags = 'flux_tag'
  []
  [conv_BC_back]
    type = ConvectiveHeatFluxBC
    variable = temperature
    boundary = back
    T_infinity = 325
    heat_transfer_coefficient = 40000
    extra_vector_tags = 'flux_tag'
  []
[]

[Materials]
  # fuel properties
  [fuel_thermal]
    type = HeatConductionMaterial
    block = 'fuel liner'
    thermal_conductivity = 17.6
  []
  # cladding properties
  [clad_thermal]
    type = HeatConductionMaterial
    block = cladding
    thermal_conductivity = 175
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

[Postprocessors]
  [average_fuel_T]
    type = ElementAverageValue
    block = fuel
    variable = temperature
    execute_on = 'initial timestep_end'
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
    start_point = '0.0 0.0127 0.0007'
    end_point = '0.101 0.0127 0.0007'
    num_points = 20
    sort_by = id
    variable = 'temperature'
  []
[]

[Outputs]
  csv = true
  exodus = true
[]
