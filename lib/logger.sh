#!/usr/bin/env bash

# =============================================================================
# Comprehensive Structured Color-Coded Logger for Bash
# =============================================================================
#
# Features:
# - Multiple log levels (TRACE, DEBUG, INFO, WARN, ERROR, FATAL)
# - Color-coded output with customizable colors
# - Structured logging with timestamps and context
# - File logging with rotation support
# - JSON output format option
# - Log filtering by level
# - Context/metadata support
# - Performance optimized
# =============================================================================

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

# Default configuration
declare -g LOGGER_LEVEL="${LOGGER_LEVEL:-INFO}"
declare -g LOGGER_OUTPUT="${LOGGER_OUTPUT:-console}" # console, file, both, json
declare -g LOGGER_FILE="${LOGGER_FILE:-}"
declare -g LOGGER_DATE_FORMAT="${LOGGER_DATE_FORMAT:-%Y-%m-%d %H:%M:%S}"
declare -g LOGGER_SHOW_CALLER="${LOGGER_SHOW_CALLER:-true}"
declare -g LOGGER_SHOW_PID="${LOGGER_SHOW_PID:-false}"
declare -g LOGGER_COLOR_ENABLED="${LOGGER_COLOR_ENABLED:-true}"
declare -g LOGGER_PREFIX="${LOGGER_PREFIX:-}"
declare -g LOGGER_MAX_FILE_SIZE="${LOGGER_MAX_FILE_SIZE:-10485760}" # 10MB
declare -g LOGGER_MAX_FILES="${LOGGER_MAX_FILES:-5}"
declare -g LOGGER_CONTEXT=""

# Log levels (check if already declared to avoid re-sourcing issues)
if [[ -z "${LOG_LEVEL_TRACE:-}" ]]; then
	declare -gr LOG_LEVEL_TRACE=0
	declare -gr LOG_LEVEL_DEBUG=1
	declare -gr LOG_LEVEL_INFO=2
	declare -gr LOG_LEVEL_WARN=3
	declare -gr LOG_LEVEL_ERROR=4
	declare -gr LOG_LEVEL_FATAL=5
	declare -gr LOG_LEVEL_OFF=6
fi

# Level names (check if already declared)
if [[ -z "${LOG_LEVEL_NAMES[*]+x}" ]]; then
	declare -gA LOG_LEVEL_NAMES=(
		[0]="TRACE"
		[1]="DEBUG"
		[2]="INFO"
		[3]="WARN"
		[4]="ERROR"
		[5]="FATAL"
	)
fi

# Level name to number mapping (check if already declared)
if [[ -z "${LOG_LEVEL_MAP[*]+x}" ]]; then
	declare -gA LOG_LEVEL_MAP=(
		["TRACE"]=0
		["DEBUG"]=1
		["INFO"]=2
		["WARN"]=3
		["ERROR"]=4
		["FATAL"]=5
		["OFF"]=6
	)
fi

# -----------------------------------------------------------------------------
# Color Definitions
# -----------------------------------------------------------------------------

# Color codes (check if already declared)
if [[ -z "${COLOR_RESET:-}" ]]; then
	declare -gr COLOR_RESET='\033[0m'
	declare -gr COLOR_BOLD='\033[1m'
	declare -gr COLOR_DIM='\033[2m'
	declare -gr COLOR_UNDERLINE='\033[4m'
	declare -gr COLOR_BLINK='\033[5m'
	declare -gr COLOR_REVERSE='\033[7m'
	declare -gr COLOR_HIDDEN='\033[8m'

	# Foreground colors
	declare -gr COLOR_BLACK='\033[30m'
	declare -gr COLOR_RED='\033[31m'
	declare -gr COLOR_GREEN='\033[32m'
	declare -gr COLOR_YELLOW='\033[33m'
	declare -gr COLOR_BLUE='\033[34m'
	declare -gr COLOR_MAGENTA='\033[35m'
	declare -gr COLOR_CYAN='\033[36m'
	declare -gr COLOR_WHITE='\033[37m'

	# Bright foreground colors
	declare -gr COLOR_BRIGHT_BLACK='\033[90m'
	declare -gr COLOR_BRIGHT_RED='\033[91m'
	declare -gr COLOR_BRIGHT_GREEN='\033[92m'
	declare -gr COLOR_BRIGHT_YELLOW='\033[93m'
	declare -gr COLOR_BRIGHT_BLUE='\033[94m'
	declare -gr COLOR_BRIGHT_MAGENTA='\033[95m'
	declare -gr COLOR_BRIGHT_CYAN='\033[96m'
	declare -gr COLOR_BRIGHT_WHITE='\033[97m'

	# Background colors
	declare -gr COLOR_BG_BLACK='\033[40m'
	declare -gr COLOR_BG_RED='\033[41m'
	declare -gr COLOR_BG_GREEN='\033[42m'
	declare -gr COLOR_BG_YELLOW='\033[43m'
	declare -gr COLOR_BG_BLUE='\033[44m'
	declare -gr COLOR_BG_MAGENTA='\033[45m'
	declare -gr COLOR_BG_CYAN='\033[46m'
	declare -gr COLOR_BG_WHITE='\033[47m'
fi

# Level colors (customizable, check if already declared)
if [[ -z "${LOG_LEVEL_COLORS[*]+x}" ]]; then
	declare -gA LOG_LEVEL_COLORS=(
		[0]="${COLOR_DIM}${COLOR_CYAN}"                  # TRACE - dim cyan
		[1]="${COLOR_CYAN}"                              # DEBUG - cyan
		[2]="${COLOR_GREEN}"                             # INFO - green
		[3]="${COLOR_YELLOW}"                            # WARN - yellow
		[4]="${COLOR_RED}"                               # ERROR - red
		[5]="${COLOR_BOLD}${COLOR_BG_RED}${COLOR_WHITE}" # FATAL - bold white on red
	)
fi

# -----------------------------------------------------------------------------
# Utility Functions
# -----------------------------------------------------------------------------

# Check if terminal supports colors
__logger_supports_colors() {
	[[ "${LOGGER_COLOR_ENABLED}" == "true" ]] &&
		[[ -t 1 ]] &&
		[[ "${TERM}" != "dumb" ]] &&
		command -v tput &>/dev/null &&
		[[ $(tput colors 2>/dev/null || echo 0) -ge 8 ]]
}

# Get current log level as number
__logger_get_level() {
	local level="${1:-${LOGGER_LEVEL}}"
	echo "${LOG_LEVEL_MAP[${level^^}]:-2}"
}

# Check if message should be logged
__logger_should_log() {
	local msg_level="$1"
	local current_level
	current_level=$(__logger_get_level)
	[[ ${msg_level} -ge ${current_level} ]]
}

# Get caller information
__logger_get_caller() {
	local frame="${1:-2}"
	local file line func

	# Get caller info from bash call stack
	if [[ "${BASH_SOURCE[${frame}]+x}" ]]; then
		file="${BASH_SOURCE[${frame}]}"
		file="${file##*/}" # basename
		line="${BASH_LINENO[$((frame - 1))]}"
		func="${FUNCNAME[${frame}]:-main}"
		echo "${file}:${line}:${func}()"
	else
		echo "unknown"
	fi
}

# Format timestamp
__logger_timestamp() {
	date +"${LOGGER_DATE_FORMAT}"
}

# Rotate log file if needed
__logger_rotate_file() {
	local file="$1"
	[[ -z "${file}" ]] && return 0

	# Check file size
	if [[ -f "${file}" ]]; then
		local size
		size=$(stat -f%z "${file}" 2>/dev/null || stat -c%s "${file}" 2>/dev/null || echo 0)

		if [[ ${size} -ge ${LOGGER_MAX_FILE_SIZE} ]]; then
			# Rotate files
			local i
			for ((i = ${LOGGER_MAX_FILES} - 1; i >= 1; i--)); do
				[[ -f "${file}.${i}" ]] && mv "${file}.${i}" "${file}.$((i + 1))"
			done
			[[ -f "${file}" ]] && mv "${file}" "${file}.1"
		fi
	fi
}

# -----------------------------------------------------------------------------
# Core Logging Function
# -----------------------------------------------------------------------------

__logger_log() {
	local level="$1"
	shift
	local message="$*"

	# Check if should log
	__logger_should_log "${level}" || return 0

	# Get level name and color
	local level_name="${LOG_LEVEL_NAMES[${level}]}"
	local level_color="${LOG_LEVEL_COLORS[${level}]}"

	# Build log components
	local timestamp
	timestamp=$(__logger_timestamp)

	local caller_info=""
	if [[ "${LOGGER_SHOW_CALLER}" == "true" ]]; then
		caller_info=$(__logger_get_caller 3)
	fi

	local pid_info=""
	if [[ "${LOGGER_SHOW_PID}" == "true" ]]; then
		pid_info="[$$]"
	fi

	local context_info=""
	if [[ -n "${LOGGER_CONTEXT}" ]]; then
		context_info="[${LOGGER_CONTEXT}]"
	fi

	local prefix_info=""
	if [[ -n "${LOGGER_PREFIX}" ]]; then
		prefix_info="${LOGGER_PREFIX}: "
	fi

	# Output based on format
	case "${LOGGER_OUTPUT}" in
	json)
		__logger_output_json "${level}" "${level_name}" "${timestamp}" \
			"${caller_info}" "${pid_info}" "${context_info}" \
			"${prefix_info}" "${message}"
		;;
	file)
		__logger_output_file "${level_name}" "${timestamp}" \
			"${caller_info}" "${pid_info}" "${context_info}" \
			"${prefix_info}" "${message}"
		;;
	both)
		__logger_output_console "${level}" "${level_name}" "${level_color}" \
			"${timestamp}" "${caller_info}" "${pid_info}" \
			"${context_info}" "${prefix_info}" "${message}"
		__logger_output_file "${level_name}" "${timestamp}" \
			"${caller_info}" "${pid_info}" "${context_info}" \
			"${prefix_info}" "${message}"
		;;
	console | *)
		__logger_output_console "${level}" "${level_name}" "${level_color}" \
			"${timestamp}" "${caller_info}" "${pid_info}" \
			"${context_info}" "${prefix_info}" "${message}"
		;;
	esac
}

# Output to console
__logger_output_console() {
	local level="$1"
	local level_name="$2"
	local level_color="$3"
	local timestamp="$4"
	local caller_info="$5"
	local pid_info="$6"
	local context_info="$7"
	local prefix_info="$8"
	local message="$9"

	local output=""

	# Add color if supported
	if __logger_supports_colors; then
		output+="${level_color}"
	fi

	# Build output string
	output+="[${timestamp}]"
	output+=" [${level_name}]"
	[[ -n "${pid_info}" ]] && output+=" ${pid_info}"
	[[ -n "${context_info}" ]] && output+=" ${context_info}"
	[[ -n "${caller_info}" ]] && output+=" ${caller_info}"

	# Reset color for message
	if __logger_supports_colors; then
		output+="${COLOR_RESET}"
	fi

	output+=" ${prefix_info}${message}"

	# Output to appropriate stream
	if [[ ${level} -ge ${LOG_LEVEL_ERROR} ]]; then
		echo -e "${output}" >&2
	else
		echo -e "${output}"
	fi
}

# Output to file
__logger_output_file() {
	local level_name="$1"
	local timestamp="$2"
	local caller_info="$3"
	local pid_info="$4"
	local context_info="$5"
	local prefix_info="$6"
	local message="$7"

	[[ -z "${LOGGER_FILE}" ]] && return 0

	# Rotate if needed
	__logger_rotate_file "${LOGGER_FILE}"

	# Build output string (no colors in file)
	local output="[${timestamp}] [${level_name}]"
	[[ -n "${pid_info}" ]] && output+=" ${pid_info}"
	[[ -n "${context_info}" ]] && output+=" ${context_info}"
	[[ -n "${caller_info}" ]] && output+=" ${caller_info}"
	output+=" ${prefix_info}${message}"

	# Write to file
	echo "${output}" >>"${LOGGER_FILE}"
}

# Output as JSON
__logger_output_json() {
	local level="$1"
	local level_name="$2"
	local timestamp="$3"
	local caller_info="$4"
	local pid_info="$5"
	local context_info="$6"
	local prefix_info="$7"
	local message="$8"

	# Build JSON object (basic escaping)
	local json='{'
	json+='"timestamp":"'"${timestamp}"'"'
	json+=',"level":"'"${level_name}"'"'
	json+=',"level_num":'"${level}"

	[[ -n "${pid_info}" ]] && json+=',"pid":'"${pid_info//[\[\]]/}"
	[[ -n "${context_info}" ]] && json+=',"context":"'"${context_info//[\[\]]/}"'"'
	[[ -n "${caller_info}" ]] && json+=',"caller":"'"${caller_info}"'"'

	# Escape message for JSON
	message="${message//\\/\\\\}"
	message="${message//\"/\\\"}"
	message="${message//$'\n'/\\n}"
	message="${message//$'\r'/\\r}"
	message="${message//$'\t'/\\t}"

	json+=',"message":"'"${prefix_info}${message}"'"'
	json+='}'

	echo "${json}"
}

# -----------------------------------------------------------------------------
# Public API Functions
# -----------------------------------------------------------------------------

# Log functions for each level
log_trace() {
	__logger_log ${LOG_LEVEL_TRACE} "$@"
}

log_debug() {
	__logger_log ${LOG_LEVEL_DEBUG} "$@"
}

log_info() {
	__logger_log ${LOG_LEVEL_INFO} "$@"
}

log_warn() {
	__logger_log ${LOG_LEVEL_WARN} "$@"
}

log_error() {
	__logger_log ${LOG_LEVEL_ERROR} "$@"
}

log_fatal() {
	__logger_log ${LOG_LEVEL_FATAL} "$@"
}

# Aliases for convenience
log() { log_info "$@"; }
trace() { log_trace "$@"; }
debug() { log_debug "$@"; }
info() { log_info "$@"; }
warn() { log_warn "$@"; }
error() { log_error "$@"; }
fatal() { log_fatal "$@"; }

# -----------------------------------------------------------------------------
# Configuration Functions
# -----------------------------------------------------------------------------

# Set log level
logger_set_level() {
	local level="${1^^}"
	if [[ -n "${LOG_LEVEL_MAP[${level}]}" ]]; then
		LOGGER_LEVEL="${level}"
	else
		error "Invalid log level: $1"
		return 1
	fi
}

# Set output mode
logger_set_output() {
	local output="${1,,}"
	case "${output}" in
	console | file | both | json)
		LOGGER_OUTPUT="${output}"
		;;
	*)
		error "Invalid output mode: $1"
		return 1
		;;
	esac
}

# Set log file
logger_set_file() {
	LOGGER_FILE="$1"
	# Create directory if needed
	local dir
	dir=$(dirname "${LOGGER_FILE}")
	[[ -d "${dir}" ]] || mkdir -p "${dir}"
}

# Set context
logger_set_context() {
	LOGGER_CONTEXT="$1"
}

# Clear context
logger_clear_context() {
	LOGGER_CONTEXT=""
}

# Set prefix
logger_set_prefix() {
	LOGGER_PREFIX="$1"
}

# Enable/disable colors
logger_set_colors() {
	LOGGER_COLOR_ENABLED="$1"
}

# Enable/disable caller info
logger_set_caller() {
	LOGGER_SHOW_CALLER="$1"
}

# Enable/disable PID
logger_set_pid() {
	LOGGER_SHOW_PID="$1"
}

# Set custom color for level
logger_set_level_color() {
	local level="${1^^}"
	local color="$2"

	if [[ -n "${LOG_LEVEL_MAP[${level}]}" ]]; then
		LOG_LEVEL_COLORS[${LOG_LEVEL_MAP[${level}]}]="${color}"
	else
		error "Invalid log level: $1"
		return 1
	fi
}

# -----------------------------------------------------------------------------
# Utility Functions
# -----------------------------------------------------------------------------

# Log with custom formatting
log_formatted() {
	local level="$1"
	local format="$2"
	shift 2
	local message
	# shellcheck disable=SC2059
	message=$(printf "${format}" "$@")
	__logger_log "${level}" "${message}"
}

# Log with timing
log_timed() {
	local start
	start=$(date +%s%N)
	"$@"
	local exit_code=$?
	local end
	end=$(date +%s%N)
	local duration=$(((end - start) / 1000000))

	if [[ ${exit_code} -eq 0 ]]; then
		log_info "Command completed in ${duration}ms: $*"
	else
		log_error "Command failed (exit ${exit_code}) after ${duration}ms: $*"
	fi

	return ${exit_code}
}

# Log separator line
log_separator() {
	local char="${1:--}"
	local width="${2:-80}"
	local sep
	sep=$(printf "%${width}s" | tr ' ' "${char:0:1}")
	log_info "${sep}"
}

# Log header
log_header() {
	local message="$1"
	local width="${2:-80}"
	log_separator "=" "${width}"
	log_info "${message}"
	log_separator "=" "${width}"
}

# Log section
log_section() {
	local message="$1"
	log_separator "-" 60
	log_info "${message}"
	log_separator "-" 60
}

# -----------------------------------------------------------------------------
# Structured Logging Support
# -----------------------------------------------------------------------------

# Log with key-value pairs
log_kv() {
	local level="$1"
	local message="$2"
	shift 2

	local kv_string=""
	while [[ $# -gt 0 ]]; do
		kv_string+=" $1=$2"
		shift 2
	done

	__logger_log "${level}" "${message}${kv_string}"
}

# Convenience functions for structured logging
log_trace_kv() { log_kv ${LOG_LEVEL_TRACE} "$@"; }
log_debug_kv() { log_kv ${LOG_LEVEL_DEBUG} "$@"; }
log_info_kv() { log_kv ${LOG_LEVEL_INFO} "$@"; }
log_warn_kv() { log_kv ${LOG_LEVEL_WARN} "$@"; }
log_error_kv() { log_kv ${LOG_LEVEL_ERROR} "$@"; }
log_fatal_kv() { log_kv ${LOG_LEVEL_FATAL} "$@"; }

# -----------------------------------------------------------------------------
# Progress and Status Functions
# -----------------------------------------------------------------------------

# Log progress
log_progress() {
	local current="$1"
	local total="$2"
	local message="${3:-Progress}"
	local percent=$(((current * 100) / total))
	log_info "${message}: ${current}/${total} (${percent}%)"
}

# Log status with icon
log_status() {
	local status="$1"
	local message="$2"

	case "${status,,}" in
	success | ok | done)
		log_info "✓ ${message}"
		;;
	error | fail | failed)
		log_error "✗ ${message}"
		;;
	warning | warn)
		log_warn "⚠ ${message}"
		;;
	info)
		log_info "ℹ ${message}"
		;;
	working | progress)
		log_info "⟳ ${message}"
		;;
	*)
		log_info "${message}"
		;;
	esac
}

# -----------------------------------------------------------------------------
# Initialization
# -----------------------------------------------------------------------------

# Auto-configure based on environment
__logger_init() {
	# Check if running in CI/CD environment
	if [[ -n "${CI:-}" ]] || [[ -n "${GITHUB_ACTIONS:-}" ]] || [[ -n "${JENKINS_HOME:-}" ]]; then
		LOGGER_COLOR_ENABLED="false"
		LOGGER_SHOW_CALLER="true"
	fi

	# Check if output is being piped
	if [[ ! -t 1 ]]; then
		LOGGER_COLOR_ENABLED="false"
	fi

	# Set default log file if requested via env
	if [[ -n "${LOG_FILE:-}" ]]; then
		logger_set_file "${LOG_FILE}"
		LOGGER_OUTPUT="both"
	fi
}

# Initialize logger
__logger_init

# -----------------------------------------------------------------------------
# Export public functions
# -----------------------------------------------------------------------------

export -f log_trace log_debug log_info log_warn log_error log_fatal
export -f log trace debug info warn error fatal
export -f logger_set_level logger_set_output logger_set_file
export -f logger_set_context logger_clear_context logger_set_prefix
export -f logger_set_colors logger_set_caller logger_set_pid
export -f logger_set_level_color
export -f log_formatted log_timed log_separator log_header log_section
export -f log_kv log_trace_kv log_debug_kv log_info_kv log_warn_kv log_error_kv log_fatal_kv
export -f log_progress log_status
