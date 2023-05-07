# 🌐 Probe - Handy curl/openssl wraper for checking website/SSL availability

## Usage

```sh
➜  ~ ./probe.sh -h
usage: probe.sh URL [-i <IP>] [-g|-s] [-h]
  -g      send GET request instead of HEAD
  -i IP   resolve from specified IP
  -s      get SSL info
  -h      show this message

➜  ~ ./probe.sh hedgie.tech
HTTP/1.1 200 OK
keep-alive: timeout=5, max=100
content-type: text/html
date: Sat, 06 May 2023 20:54:58 GMT
server: LiteSpeed
x-turbo-charged-by: LiteSpeed

IP: 198.54.121.233
URL: http://hedgie.tech/
Redirects: 0
Time: 0.631332
⤷ DNS: 0.002077
⤷ Connect: 0.445792
⤷ Redirect: 0.000000
⤷ TTFB: 0.631234

➜  ~ ./probe.sh hedgie.tech -s
issuer=C = US, O = Let's Encrypt, CN = R3
subject=CN = hedgie.tech
notBefore=Apr 15 14:23:50 2023 GMT
notAfter=Jul 14 14:23:49 2023 GMT
```