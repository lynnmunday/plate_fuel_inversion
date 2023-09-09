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
    file = plate_steady_in.e
  []
  # [plate]
  #   type = PlateMeshGenerator
  #   fuel_dimensions = '82.550e-3 19.050e-3 0.216e-3'
  #   liner_thickness = 0.025e-3
  #   cladding_thicknesses = '9.4615e-3 9.4615e-3 3.175e-3 3.175e-3 0.489e-3 0.489e-3'
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
  #   coord = '0.101473 0 0'
  #   new_boundary = 'right_bottom_back'
  # []
  # [add_nodesets3]
  #   type = ExtraNodesetGenerator
  #   input = add_nodesets2
  #   coord = '0.101473 0.0254 0'
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
  [l2ar]
    order = CONSTANT
    family = MONOMIAL
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
  [l2ar]
    type = ParsedAux
    variable = l2ar
    use_xyzt = true
    constant_names = 'x_offset y_offset'
    constant_expressions = '9.4615e-3 3.175e-3'
    expression = 'x0 := x-x_offset;
             y0 := y-y_offset;
             (4.669e-10*x0^5 - 8.657e-8*x0^4 + 5.877e-6*x0^3 - 0.0001962*x0^2 + 0.004373*x0 + 0.9446) * (5.047e-7*y0^6 - 2.974e-05*y0^5 + 0.0006881*y0^4 - 0.007883*y0^3 + 0.04726*y0^2 - 0.1458*y0 + 1.152)'
  []
[]

[Functions]
  [power_density]
    type = ConstantFunction
    value = 40000e6 # first timestep from POWER_DENSITY.csv
  []
  [L2AR]
    type = ParsedFunction
    expression = 1.0
    # fissprof_l2ar is the distribution from the L2AR tab: L2AR_ABAQUS at cell R64
    # symbol_names = 'x_offset y_offset'
    # symbol_values = '9.4615e-3 3.175e-3'
    # expression = 'x0 := x-x_offset;
    #          y0 := y-y_offset;
    #          (4.669e-10*x0^5 - 8.657e-8*x0^4 + 5.877e-6*x0^3 - 0.0001962*x0^2 + 0.004373*x0 + 0.9446) * (5.047e-7*y0^6 - 2.974e-05*y0^5 + 0.0006881*y0^4 - 0.007883*y0^3 + 0.04726*y0^2 - 0.1458*y0 + 1.152)'
  []
  [power_history]
    type = CompositeFunction
    functions = 'power_density L2AR'
  []
[]

[Variables]
  [temperature]
    initial_condition = 400
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
    block = fuel
    function = power_history
    variable = temperature
    extra_vector_tags = 'ref heatSource_tag'
  []
[]

[Modules/TensorMechanics/Master]
  [all]
    strain = SMALL
    temperature = temperature
    generate_output = 'stress_xx stress_yy stress_zz vonmises_stress'
    eigenstrain_names = 'eigenstrain'
    extra_vector_tags = 'ref'
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
    T_infinity = 325 # film temperature
    heat_transfer_coefficient = 40000
    extra_vector_tags = 'flux_tag'
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
  # fuel properties
  [fuel_thermal]
    type = HeatConductionMaterial
    block = 'fuel liner'
    thermal_conductivity = 17.6
  []
  [fuel_elasticity]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 90e9
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
  # cladding properties
  [clad_thermal]
    type = HeatConductionMaterial
    block = cladding
    thermal_conductivity = 175
  []
  [clad_elasticity]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 69e9
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

  # petsc_options_iname = '-ksp_gmres_restart -pc_type -pc_hypre_type -pc_hypre_boomeramg_max_iter'
  # petsc_options_value = '201                hypre    boomeramg      4'
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

[Outputs]
  perf_graph = true
  csv = true
  exodus = true
[]
