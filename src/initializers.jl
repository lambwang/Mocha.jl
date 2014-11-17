# An Initializer is used to initialize network parameters
export Initializer
export ConstantInitializer
export XavierInitializer

abstract Initializer # The root type of all initializer

type NullInitializer <: Initializer end
function init(::NullInitializer, blob::Blob)
  # do nothing
end

type ConstantInitializer <: Initializer
  value
end

function init(initializer::ConstantInitializer, blob::Blob)
  fill!(blob, initializer.value)
end

################################################################################
# An initializer  based on the paper [Bengio and Glorot 2010]: Understanding
# the difficulty of training deep feedforward neuralnetworks, but does not
# use the fan_out value.
#
# It fills the incoming matrix by randomly sampling uniform data from
# [-scale, scale] where scale = sqrt(3 / fan_in) where fan_in is the number
# of input nodes. You should make sure the input blob has shape (a, b, c, num)
# where a * b * c = fan_in.
################################################################################
type XavierInitializer <: Initializer
end
function init(initializer::XavierInitializer, blob::Blob)
  fan_in = get_width(blob)*get_height(blob)*get_chann(blob)
  scale = sqrt(3.0) / fan_in
  init_val = rand(eltype(blob), size(blob)) * 2scale - scale
  copy!(blob, init_val)
end


type GaussianInitializer <: Initializer
  mean :: FloatingPoint
  std  :: FloatingPoint
end
GaussianInitializer(;mean=0.0, std=1.0) = GaussianInitializer(mean, std)
function init(initializer::GaussianInitializer, blob::Blob)
  init_val = randn(size(blob)) * initializer.std + initializer.mean
  copy!(blob, init_val)
end
