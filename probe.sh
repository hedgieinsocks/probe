#!/bin/bash

SCRIPT_NAME="$(basename "$0")"

CURL_FOOTER="IP: %{remote_ip}\nURL: %{url_effective}\nRedirects: %{num_redirects}\nTime: %{time_total}\n⤷ DNS: %{time_namelookup}\n⤷ Connect: %{time_connect}\n⤷ Redirect: %{time_redirect}\n⤷ TTFB: %{time_starttransfer}\n"
CURL_OPTIONS=("--connect-timeout" "10" "--silent" "--insecure" "--location" "--write-out" "${CURL_FOOTER}")

URL_REGEXP='^(https?:\/\/)?[a-z0-9.-]+\.[a-z0-9-]{2,}(\/([a-z0-9.\/-]+)?)?$'
IP_REGEXP='^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'

export GREP_COLORS='mt=1;33'


function print_help {
  cat << EOF
usage: ${SCRIPT_NAME} URL [-i <IP>] [-g|-s] [-h]
  -g      send GET request instead of HEAD
  -i IP   resolve from specified IP
  -s      get SSL info
  -h      show this message
EOF
  exit
}


function err {
  echo "error: ${SCRIPT_NAME}: $*" >&2
  exit 1
}


function parse_input {
  while [[ -n "$1" ]]; do
    case "$1" in
      -h)
        print_help
        ;;
      -s)
        [[ -n "${GET_FLAG}" ]] && err "you cannot combine options -s and -g"
        SSL_FLAG=1
        shift
        ;;
      -g)
        [[ -n "${SSL_FLAG}" ]] && err "you cannot combine options -s and -g"
        GET_FLAG=1
        shift
        ;;
      -i)
        shift
        [[ -z "$1" ]] && err "missing argument: IP"
        [[ ! "$1" =~ ${IP_REGEXP} ]] && err "invalid argument: IP: $1"
        IP="$1"
        shift
        ;;
      *)
        [[ ! "$1" =~ ${URL_REGEXP} ]] && err "invalid argument: URL: $1"
        [[ -n "${URL}" ]] && err "extra argument: URL: $1"
        URL="$1"
        shift
        ;;
    esac
  done
  [[ -z "${URL}" ]] && err "missing argument: URL"
}


function probe_ssl {
  local domain
  domain="$(grep -oE '[a-z0-9.-]+\.[a-z0-9-]{2,}' <<< "${URL}")"
  :| openssl s_client -servername "${domain}" -connect "${IP:-${domain}}:443" 2>/dev/null \
    | openssl x509 -noout -issuer -subject -dates \
    | grep --color=always -E "^issuer=|^subject=|^notBefore=|^notAfter=|"
}


function probe_url {
  [[ -z "${GET_FLAG}" ]] && CURL_OPTIONS+=("--head")
  [[ -n "${IP}" ]] && CURL_OPTIONS+=("--resolve *:80:${IP}" "--resolve *:443:${IP}")
  curl "${URL}" "${CURL_OPTIONS[@]}" \
    | grep --color=always -E "^IP:|^URL:|^Redirects:|^Time:|"
}


function main {
  parse_input "$@"
  if [[ -n "${SSL_FLAG}" ]]; then
    probe_ssl
  else
    probe_url
  fi
}

main "$@"
