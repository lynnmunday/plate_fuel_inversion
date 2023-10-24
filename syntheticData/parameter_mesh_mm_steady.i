output_name = 'mesh_1x1x1'
[Mesh]
  [gmg]
    #fuel and liner
    type = GeneratedMeshGenerator
    dim = 3
    nx = 20
    ny = 3
    nz = 1
    xmin = 9.46   #9.4615
    xmax = 92.02  #92.0115
    ymin = 3.17   #3.175
    ymax = 22.23  #22.225
    zmin = 0.48   #0.489
    zmax = 0.76   #0.755
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
    expression = 'x*y*80e3'
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
