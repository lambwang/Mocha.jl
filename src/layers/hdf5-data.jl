using HDF5

type HDF5DataLayerState <: LayerState
  layer :: HDF5DataLayer
  blobs :: Vector{Blob}

  sources        :: Vector{String}
  curr_source    :: Int
  curr_hdf5_file :: HDF5File
  curr_index     :: Int

  HDF5DataLayerState(layer) = begin
    state = new(layer)

    sources = open(layer.source, "r") do s
      filter(l -> !isspace(l), readlines(s))
    end
    @assert(length(sources) > 0)
    state.sources = sources

    state.curr_source = 1
    state.curr_hdf5_file = h5open(sources[1], "r")

    state.blobs = Array(Blob, length(layer.tops))
    for i = 1:length(state.blobs)
      dims = size(state.curr_hdf5_file[layer.tops[i]])
      if layer.batch_size > 0
        dims = tuple(layer.batch_size, dims[2:end]...)
      end

      idx = [1:x for x in dims]
      dset = state.current_hdf5_file[layer.tops[i]]
      state.blobs[i] = Blob(layer.tops[i], dset[idx...])
    end
    state.curr_index = 1

    return state
  end
end

function setup(layer::HDF5DataLayer)
  state = HDF5DataLayerState(layer)
  return state
end

function forward(state::HDF5DataLayerState)
  if (state.layer.batch_size == 0)
    if (state.curr_index != 1) # file already consumed, open next file
      close(state.curr_hdf5_file)
      state.curr_source = state.curr_source % length(state.sources) + 1
      state.curr_hdf5_file = h5open(state.sources[state.curr_source], "r")
    end
    for i = 1:length(state.blobs)
      idx = map(dim -> 1:dim, size(state.blobs[i].data))
      state.blobs[i].data = state.curr_hdf5_file[state.layer.tops[i]][idx...]
    end
  else
    throw(MethodError("Not implemented yet"))
  end
end
