output_name = 'mesh_1x1x1'
[Mesh]
  [gmg]
    #fuel and liner
    type = GeneratedMeshGenerator
    dim = 3
    nx = 1
    ny = 1
    nz = 1
    xmin = 0.0094615
    xmax = 0.0920115
    ymin = 0.003175
    ymax = 0.022225
    zmin = 0.000489
    zmax = 0.000755
  []
  second_order = false
  parallel_type = REPLICATED
[]

[Problem]
  solve = false
[]

[AuxVariables]
  [source_node]
    order = FIRST
    family = LAGRANGE
  []
  [source_elem]
    order = CONSTANT
    family = MONOMIAL
  []
  [volume]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[AuxKernels]
  [source_node]
    type = FunctionAux
    variable = source_node
    function = source
  []
  [source_elem]
    type = FunctionAux
    variable = source_elem
    function = source
  []
  [volume_aux]
    type = VolumeAux
    variable = volume
  []
[]

[Functions]
  [source]
    type = ParsedFunction
    expression = 'x*y*80e12'
  []
[]

[BCs]
[]

[VectorPostprocessors]
  [source_node]
    type = NodalValueSampler
    sort_by = id
    variable = source_node
  []
  [source_elem]
    type = ElementValueSampler
    sort_by = id
    variable = source_elem
  []
[]

[Executioner]
  type = Steady
[]

[Outputs]
  csv = true
  exodus = true
  file_base = ${output_name}
[]
