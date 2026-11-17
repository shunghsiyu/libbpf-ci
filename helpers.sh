# shellcheck shell=bash

# $1 - start or end
# $2 - fold identifier, no spaces
# $3 - fold section description
foldable() {
  local YELLOW='\033[1;33m'
  local NOCOLOR='\033[0m'
  if [ $1 = "start" ]; then
    line="::group::$2"
    if [ ! -z "${3:-}" ]; then
      line="$line - ${YELLOW}$3${NOCOLOR}"
    fi
  else
    line="::endgroup::"
  fi
  echo -e "$line"
}

__print() {
  local TITLE=""
  if [[ -n $2 ]]; then
      TITLE=" title=$2"
  fi
  echo "::$1${TITLE}::$3"
}

# $1 - title
# $2 - message
print_error() {
  __print error $1 $2
}

# $1 - title
# $2 - message
print_notice() {
  __print notice $1 $2
}

# Run a command, retrying with exponential backoff if it fails. Meant for
# network operations against hosts that are intermittently unreachable
# (e.g. git.kernel.org refusing connections or returning HTTP 502).
# $1 - maximum number of attempts
# $2 - delay in seconds before the first retry, doubled after each retry
# $@ - command to run
retry() {
  local attempts=$1
  local delay=$2
  shift 2

  local i rc
  for (( i = 1; ; i++ )); do
    "$@" && return 0
    rc=$?
    if (( i >= attempts )); then
      echo "::error::'$*' failed after ${attempts} attempts (exit code ${rc})"
      return "$rc"
    fi
    echo "::warning::'$*' failed (exit code ${rc}), attempt ${i}/${attempts}; retrying in ${delay}s"
    sleep "$delay"
    delay=$(( delay * 2 ))
  done
}

# No arguments
llvm_default_version() {
  echo "17"
}

# No arguments
llvm_latest_version() {
  echo "19"
}

kernel_build_make_jobs() {
  smp=$(( $(nproc) - 1 ))
  MAX_MAKE_JOBS=${MAX_MAKE_JOBS:-$smp}
  echo $(( smp > MAX_MAKE_JOBS ? MAX_MAKE_JOBS : smp ))
}

distrib_codename() {
    DISTRIB_CODENAME="noble"
    test -f /etc/lsb-release && . /etc/lsb-release
    echo "${DISTRIB_CODENAME}"
}

# Convert a platform (as returned by uname -m) to the kernel
# arch (as expected by ARCH= env).
platform_to_kernel_arch() {
  case $1 in
    s390x)
      echo "s390"
      ;;
    aarch64)
      echo "arm64"
      ;;
    riscv64)
      echo "riscv"
      ;;
    x86_64)
      echo "x86"
      ;;
    *)
      echo "$1"
      ;;
  esac
}

# Convert a platform (as returned by uname -m) to its debian equivalent.
platform_to_deb_arch() {
  case $1 in
    aarch64)
      echo "arm64"
      ;;
    x86_64)
      echo "amd64"
      ;;
    *)
      echo "$1"
      ;;
  esac
}
