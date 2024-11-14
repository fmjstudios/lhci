# ==== Variables ====
# require setting a version
variable "VERSION" {
  default = null
}

# use 'latest' if no other TAGS are passed in
variable "TAGS" {
  default = "latest"
}

# targets to build (currently unused)
variable "TARGETS" {
  default = "dev,prod"
}

# determine (custom) image registries
variable "REGISTRIES" {
  default = "ghcr.io"
}

# lock the image repository
variable "REPOSITORY" {
  default = "fmjstudios/lhci"
}

# build for multiple Node.js versions - can be a comma-separated list of values like 18,20,22 etc.
variable "NODE_VERSIONS" {
  default = "20"
}

# ==== Custom Functions ====
# common labels to add to ALL images
function "labels" {
  params = []
  result = {
    "org.opencontainers.image.base.name"     = "fmjstudios/lhci:latest"
    "org.opencontainers.image.created"       = "${timestamp()}"
    "org.opencontainers.image.description"   = "A server for the storage and review of Google Lighthouse report data"
    "org.opencontainers.image.documentation" = "https://github.com/fmjstudios/lhci/wiki"
    "org.opencontainers.image.licenses"      = "MIT"
    "org.opencontainers.image.url"           = "https://hub.docker.com/r/fmjstudios/lhci"
    "org.opencontainers.image.source"        = "https://github.com/fmjstudios/lhci"
    "org.opencontainers.image.title"         = "lhci"
    "org.opencontainers.image.vendor"        = "FMJ Studios"
    "org.opencontainers.image.authors"       = "info@fmj.studio"
    "org.opencontainers.image.version"       = VERSION == null ? "dev-${timestamp()}" : VERSION
  }
}

function "get_target" {
  params = []
  result = flatten(split(",", TARGETS))
}

function "get_node_version" {
  params = []
  result = flatten(split(",", NODE_VERSIONS))
}

# determine in which we're going to append for the image
function "get_tags" {
  params = []
  result = VERSION == null ? flatten(split(",", TAGS)) : concat(flatten(split(",", TAGS)), [VERSION])
}

# determine in which we're going to append for the image
function "get_registry" {
  params = []
  result = flatten(split(",", REGISTRIES))
}

# create the fully qualified tags
function "tags" {
  params = []
  result = flatten(concat(
    [for tag in get_tags() : "${REPOSITORY}:${tag}"],
    [for registry in get_registry() : [for tag in get_tags() : "${registry}/${REPOSITORY}:${tag}"]]
  ))
}

# ==== Bake Targets ====
group "default" {
  targets = ["lhci"]
}

# The 'lhci' Alpine application image
target "lhci" {
  name = "lhci-node${node}"
  dockerfile = "Dockerfile" # symlink
  matrix = {
    node = get_node_version()
  }
  args = {
    NODE_VERSION = node
  }
  platforms = [
    "linux/amd64",
    "linux/arm64",
    # see: https://github.com/nodejs/docker-node/issues/1829
    # "linux/arm/v7",
    # "linux/arm/v6",
    # "linux/s390x",
    # "linux/ppc64le"
  ]
  tags = tags()
  labels = labels()
  output = ["type=docker"]
}
