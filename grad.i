# Plate fuel example problem.
parameter_mesh_size='4x2x1'
#parameter_mesh_size='1x1x1'

#[GlobalParams]
#  order = FIRST
#  family = LAGRANGE
#  displacements = 'disp_x disp_y disp_z'
#  volumetric_locking_correction = false
#[]

[Mesh]
  coord_type = XYZ
  [read_plate_mesh]
    type = FileMeshGenerator
    file = plate_mm.e
  []
[]

[Variables]
  [temperature]
  []
#  [disp_x]
#  []
#  [disp_y]
#  []
#  [disp_z]
#  []
[]

[Kernels]
  [heat]
    type = HeatConduction
    variable = temperature
  []
[]

#[Modules/TensorMechanics/Master]
#  [all]
#    strain = SMALL
#    temperature = temperature
#    generate_output = 'stress_xx stress_yy stress_zz vonmises_stress'
#    eigenstrain_names = 'eigenstrain'
#  []
#[]

[BCs]
  [conv_BC_front]
    type = ConvectiveHeatFluxBC
    variable = temperature
    boundary = front
    T_infinity = 0
    heat_transfer_coefficient = 90000
  []
  [conv_BC_back]
    type = ConvectiveHeatFluxBC
    variable = temperature
    boundary = back
    T_infinity = 0
    heat_transfer_coefficient = 40000
  []
#  [disp_x]
#    type = DirichletBC
#    variable = disp_x
#    boundary = 'left_bottom_back'
#    value = 0.0
#  []
#  [disp_y]
#    type = DirichletBC
#    variable = disp_y
#    boundary = 'left_bottom_back right_bottom_back'
#    value = 0.0
#  []
#  [disp_z]
#    type = DirichletBC
#    variable = disp_z
#    boundary = 'left_bottom_back right_bottom_back right_top_back'
#    value = 0.0
#  []
[]

[Materials]
  [fuel_thermal]
    type = HeatConductionMaterial
    block = 'fuel liner'
    thermal_conductivity = 17.6e3
  []
#  [fuel_elasticity]
#    type = ComputeIsotropicElasticityTensor
#    youngs_modulus = 90e3
#    poissons_ratio = 0.35
#    block = 'fuel liner'
#  []
#  [fuel_thermal_expansion]
#    type = ComputeThermalExpansionEigenstrain
#    temperature = temperature
#    thermal_expansion_coeff = 15e-6
#    stress_free_temperature = 294
#    eigenstrain_name = eigenstrain
#    block = 'fuel liner'
#  []
#  [fuel_stress]
#    type = ComputeLinearElasticStress
#    block = 'fuel liner'
#  []
  [clad_thermal]
    type = HeatConductionMaterial
    block = cladding
    thermal_conductivity = 175e3
  []
#  [clad_elasticity]
#    type = ComputeIsotropicElasticityTensor
#    youngs_modulus = 69e3
#    poissons_ratio = 0.33
#    block = cladding
#  []
#  [clad_thermal_expansion]
#    type = ComputeThermalExpansionEigenstrain
#    temperature = temperature
#    thermal_expansion_coeff = 25.1e-6
#    stress_free_temperature = 0
#    eigenstrain_name = eigenstrain
#    block = cladding
#  []
#  [clad_stress]
#    type = ComputeLinearElasticStress
#    block = cladding
#  []
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

#  line_search = 'none'
#  nl_rel_tol = 1e-6
#  nl_abs_tol = 1e-7
#  nl_max_its = 50
#  l_tol = 1e-4
#  l_max_its = 50
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
  []
  [params_fuel]
    type = ConstantReporter
    real_vector_names = 'source'
    real_vector_values = '0' # Dummy
  []
[]

[Functions]
  [src_fuel_function]
#--mesh_approach
    type = ParameterMeshFunction
    family = MONOMIAL
    order = CONSTANT
    exodus_mesh = 'mesh_${parameter_mesh_size}.e'
    parameter_name = params_fuel/source
#--function_approach
#    type = ParsedOptimizationFunction
#    expression = q
#    param_symbol_names = 'q'
#    param_vector_name = 'params_fuel/source'
  []
[]

[VectorPostprocessors]
  [grad_src_fuel]
    type = ElementOptimizationSourceFunctionInnerProduct
    variable = temperature
    function = src_fuel_function
    block = 'fuel'
  []
[]

[Outputs]
  file_base = grad_${parameter_mesh_size} # mesh_approach
  #file_base = grad_func #function_approach
  csv = true
[]
