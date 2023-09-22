#all blocks common to forward and adjoint problems.

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
[]

[BCs]
  [conv_BC_front]
    type = ConvectiveHeatFluxBC
    variable = temperature
    boundary = front
    T_infinity = 0
    heat_transfer_coefficient = 90000
    extra_vector_tags = 'flux_tag'
  []
  [conv_BC_back]
    type = ConvectiveHeatFluxBC
    variable = temperature
    boundary = back
    T_infinity = 0
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

[DiracKernels]
  [adjointLoad_T]
    type = ReporterPointSource
    variable = temperature
    x_coord_name = misfit/measurement_xcoord
    y_coord_name = misfit/measurement_ycoord
    z_coord_name = misfit/measurement_zcoord
    value_name = misfit/misfit_values
  []
[]

[Reporters]
  [misfit]
    type = OptimizationData
    # variable_weight_names = 'weight_disp_x'
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
    exodus_mesh = '${measurementDir}/mesh_1x1x1.e'
    parameter_name = params_fuel/source
  []
[]

[VectorPostprocessors]
  [grad_src_fuel]
    type = ElementOptimizationSourceFunctionInnerProduct
    variable = temperature
    function = src_fuel_function
    block = 'fuel liner'
  []
[]

[Outputs]
  csv = true
  exodus = true
[]
