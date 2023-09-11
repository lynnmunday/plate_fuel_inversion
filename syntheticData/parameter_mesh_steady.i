[Mesh]
  [gmg]
    #fuel and liner
    type = GeneratedMeshGenerator
    dim = 3
    nx=10
    ny=3
    nz=1
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
  solve=false
[]

[AuxVariables]
  [source]
    order = FIRST
    family = LAGRANGE
  []
[]

[AuxKernels]
  [source]
    type = ParsedAux
    variable = source
    expression = 'x*y*80e12' #80000e6 #'x*y*40e12'
    use_xyzt = true
  []
[]

[BCs]
[]

[VectorPostprocessors]
  [source_vec]
    type = NodalValueSampler
    sort_by = id
    variable = source
  []
[]

[Executioner]
  type = Steady
[]

[Outputs]
  csv = true
  exodus = true
[]
