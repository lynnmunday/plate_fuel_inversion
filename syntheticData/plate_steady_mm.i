#
# Plate fuel example problem.
#
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
    file = plate_steady_mm_in.e
  []
  # [plate]
  #   type = PlateMeshGenerator
  #   fuel_dimensions = '82.550 19.050 0.216'
  #   liner_thickness = 0.025
  #   cladding_thicknesses = '9.4615 9.4615 3.175 3.175 0.489 0.489'
  #   number_fuel_elements = '25 15 3'
  #   number_cladding_elements = '4 4 3 3 4 4'
  #   ### For a more refined mesh (40 processors):
  #   # number_fuel_elements = '108 30 5'
  #   # number_cladding_elements = '15 15 5 5 8 8'
  #   ###
  #   number_liner_elements = 1
  # []
  # [translate_to_origin]
  #   type = TransformGenerator
  #   input = plate
  #   transform = translate_min_origin
  # []
  # [add_nodesets1]
  #   type = ExtraNodesetGenerator
  #   input = translate_to_origin
  #   coord = '0 0 0'
  #   new_boundary = 'left_bottom_back'
  # []
  # [add_nodesets2]
  #   type = ExtraNodesetGenerator
  #   input = add_nodesets1
  #   coord = '101.473 0 0'
  #   new_boundary = 'right_bottom_back'
  # []
  # [add_nodesets3]
  #   type = ExtraNodesetGenerator
  #   input = add_nodesets2
  #   coord = '101.473 25.4 0'
  #   new_boundary = 'right_top_back'
  # []

[]

[Problem]
  type = ReferenceResidualProblem
  reference_vector = ref
  extra_tag_vectors = 'ref flux_tag heatSource_tag'
  group_variables = 'disp_x disp_y disp_z'
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
  [source]
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
  [source]
    type = FunctionAux
    variable = source
    function = src_func
    block = 'fuel liner'
  []
[]

[Functions]
  [src_func]
    type = ParsedFunction
    expression = 'x*y*80e3'
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
    function = src_func
    variable = temperature
    extra_vector_tags = 'ref heatSource_tag'
    block = 'fuel liner'
  []
[]

[Modules/TensorMechanics/Master]
  [all]
    strain = SMALL
    temperature = temperature
    generate_output = 'stress_xx stress_yy stress_zz vonmises_stress'
    eigenstrain_names = 'eigenstrain'
    extra_vector_tags = 'ref'
    use_automatic_differentiation = true
  []
[]

[BCs]
  [conv_BC_front]
    type = ADConvectiveHeatFluxBC
    variable = temperature
    boundary = front
    T_infinity = 355
    heat_transfer_coefficient = 90000
    extra_vector_tags = 'flux_tag'
  []
  [conv_BC_back]
    type = ADConvectiveHeatFluxBC
    variable = temperature
    boundary = back
    T_infinity = 325
    heat_transfer_coefficient = 40000
    extra_vector_tags = 'flux_tag'
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

#--------- Output synthetic measurement data
[AuxVariables]
  [weighted_disp_z]
    family = LAGRANGE
    order = FIRST
  []
  [weight]
    family = LAGRANGE
    order = FIRST
    initial_condition = 1e3
  []
[]
[AuxKernels]
  [weighted_disp_z]
    type = ParsedAux
    expression = disp_z*1e3
    variable = weighted_disp_z
    coupled_variables = disp_z
  []
[]

[VectorPostprocessors]
  [disp_all]
    type = NodalValueSampler
    sort_by = id
    boundary = front
    variable = 'disp_x disp_y disp_z temperature weighted_disp_z weight'
  []
  [disp_top]
    type = LineValueSampler
    start_point = '0.0 12.7 0.7'
    end_point = '101 12.7 0.7'
    num_points = 20
    sort_by = id
    variable = 'disp_x disp_y disp_z temperature weighted_disp_z weight'
  []
[]

[Outputs]
  file_base = results_func
  csv = true
  exodus = true
[]
