#
# Plate fuel example problem.
#

[Mesh]
  coord_type = XYZ
  [read_plate_mesh]
    type = FileMeshGenerator
    file = plateFuel_main_out.e
    use_for_exodus_restart = true
  []
[]

[Problem]
  solve = false
  kernel_coverage_check = false
[]

[AuxVariables]
  [source]
    order = CONSTANT
    family = MONOMIAL
    initial_from_file_var = source_exact
  []
[]
[AuxKernels]
  [source]
    type = FunctionAux
    variable = source
    function = src_func
    # block = 'fuel liner'
  []
[]

#----- PARAMETER MESH INPUT
#----- create these csv and exodus files by running parameter_mesh_mm_steady.i
[Functions]
  [src_func]
    type = ParameterMeshFunction
    family = MONOMIAL
    order = CONSTANT
    exodus_mesh = plateFuel_main_out.e
    parameter_name = src_vec/source
  []
[]
[VectorPostprocessors]
  [src_vec]
    type = CSVReader
    csv_file = plateFuel_main_out_forward_adjoint0_params_fuel_0001.csv
    outputs = none
  []
[]
#-------------------------------------------------------------

[Executioner]
  type = Steady
  solve_type = 'Newton'
[]

##--------- Outputs ------------------#
[VectorPostprocessors]
  [source_center_mid]
    type = LineValueSampler
    start_point = '9.46 12.7 0.622'
    end_point = '92.02 12.7 0.622'
    num_points = 1000
    sort_by = id
    variable = 'source'
  []
  [source_diag_mid]
    type = LineValueSampler
    start_point = '9.46 3.17 0.622'
    end_point = '92.02 22.23 0.622'
    num_points = 1000
    sort_by = id
    variable = 'source'
  []
[]

[Outputs]
  csv = true
[]
