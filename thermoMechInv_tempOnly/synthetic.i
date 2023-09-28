# Plate fuel example problem.

parameter_mesh_size='4x2x1'
#parameter_mesh_size='1x1x1'

[GlobalParams]
  order = FIRST
  family = LAGRANGE
  displacements = 'disp_x disp_y disp_z'
  volumetric_locking_correction = false
[]

[Mesh]
  coord_type = XYZ
  [read_plate_mesh]
    type = FileMeshGenerator
    file = plate_mm.e
  []
[]

#[Problem]
#  type = ReferenceResidualProblem
#  reference_vector = ref
#[]

#---------- create these csv and exodus files by running parameter_mesh_steady.i
[Functions]
  [src_func]
    type = ParameterMeshFunction
    family = MONOMIAL
    order = CONSTANT
    exodus_mesh = mesh_${parameter_mesh_size}.e
    parameter_name = src_vec/source_elem
  []
[]
[VectorPostprocessors]
  [src_vec]
    type = CSVReader
    csv_file = mesh_${parameter_mesh_size}_source_elem_0001.csv
  []
[]
#-------------------------------------------------------------

[Variables]
  [temperature]
#    initial_condition = 400
  []
  [disp_x]
  []
  [disp_y]
  []
  [disp_z]
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
    function = src_func # for synthetic
    variable = temperature
  []
[]

[Modules/TensorMechanics/Master]
  [all]
    strain = SMALL
    temperature = temperature
    generate_output = 'stress_xx stress_yy stress_zz vonmises_stress'
    eigenstrain_names = 'eigenstrain'
  []
[]

[BCs]
  [conv_BC_front]
    type = ConvectiveHeatFluxBC
    variable = temperature
    boundary = front
    T_infinity = 0 #355
    heat_transfer_coefficient = 90000
  []
  [conv_BC_back]
    type = ConvectiveHeatFluxBC
    variable = temperature
    boundary = back
    T_infinity = 0 #325
    heat_transfer_coefficient = 40000
  []
  [disp_x]
    type = DirichletBC
    variable = disp_x
    boundary = 'left_bottom_back'
    value = 0.0
  []
  [disp_y]
    type = DirichletBC
    variable = disp_y
    boundary = 'left_bottom_back right_bottom_back'
    value = 0.0
  []
  [disp_z]
    type = DirichletBC
    variable = disp_z
    boundary = 'left_bottom_back right_bottom_back right_top_back'
    value = 0.0
  []
[]

[Materials]
  [fuel_thermal]
    type = HeatConductionMaterial
    block = 'fuel liner'
    thermal_conductivity = 17.6e3
  []
  [fuel_elasticity]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 90e3
    poissons_ratio = 0.35
    block = 'fuel liner'
  []
  [fuel_thermal_expansion]
    type = ComputeThermalExpansionEigenstrain
    temperature = temperature
    thermal_expansion_coeff = 15e-6 #U10MoThermalExpansionEigenstrain - Burkes  T=300
    stress_free_temperature = 294
    eigenstrain_name = eigenstrain
    block = 'fuel liner'
  []
  [fuel_stress]
    type = ComputeLinearElasticStress
    block = 'fuel liner'
  []
  [clad_thermal]
    type = HeatConductionMaterial
    block = cladding
    thermal_conductivity = 175e3
  []
  [clad_elasticity]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 69e3
    poissons_ratio = 0.33
    block = cladding
  []
  [clad_thermal_expansion]
    type = ComputeThermalExpansionEigenstrain
    temperature = temperature
    thermal_expansion_coeff = 25.1e-6 #Al6061ThermalExpansionEigenstrain T=300
    stress_free_temperature = 295
    eigenstrain_name = eigenstrain
    block = cladding
  []
  [clad_stress]
    type = ComputeLinearElasticStress
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

#  line_search = 'none'
#  nl_rel_tol = 1e-6
#  nl_abs_tol = 1e-7
#  nl_max_its = 50
#  l_tol = 1e-4
#  l_max_its = 50
[]

#[Postprocessors]
#  [average_fuel_T]
#    type = ElementAverageValue
#    block = fuel
#    variable = temperature
#    execute_on = 'initial timestep_end'
#  []
#[]

#--------- Output synthetic measurement data
[VectorPostprocessors]
  [all]
    type = NodalValueSampler
    sort_by = id
    boundary = front
    variable = 'disp_x disp_y disp_z temperature'
  []

#  [top]
#    type = LineValueSampler
#    start_point = '0.0 12.7 0.7'
#    end_point = '101 12.7 0.7'
#    num_points = 20
#    sort_by = id
#    variable = 'disp_x disp_y disp_z temperature'
#  []
[]

[Outputs]
  file_base = synthetic_${parameter_mesh_size}
  csv = true
  #exodus = true
[]
