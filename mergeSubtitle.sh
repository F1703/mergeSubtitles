#!/bin/bash

url="https://subtitletools.com/merge-subtitles-online"
api="https://subtitletools.com/api/v1/file-group/result"
urlDonwload="https://subtitletools.com/download-file-job" 
cookie="/tmp/cookiesss.txt" 
mi_data="/tmp/mi_data.txt"

rm $cookie 2>/dev/null

modoDeUso() { 
    echo "Modo de uso: $0 -b baseFile.srt -m mergeFile.srt -s outputFile.srt ";
    echo "OPCIONES:" ;
    echo "-b, base  file ej: archivo1.srt " 
    echo "-m, merge file ej: archivo2.srt " 
    echo "-s, [opcional] output file ej: archivo3.srt "
    echo "-h, help"
    exit 0
}

while getopts "b:m:s:h" z; do
    case "${z}" in
        b)
            b=${OPTARG}
        ;;
        m)
            m=${OPTARG}
        ;;
        s)
            s=${OPTARG}
        ;;
        h|*)
            modoDeUso
        ;;
    esac
done
shift $((OPTIND-1))
 

if [ -z "${b}" ] || [ -z "${m}" ]; then
    modoDeUso
fi

file3=${s}
if [ -z "${s}" ]; then
    file3="sub.srt"
fi

file1=${b} 
file2=${m}

# generar numero aleatorio 
boundary=""
for ((i=1; i<=28; i++)); do
    boundary="${boundary}$((RANDOM % 10))"
done
  
_token=$(curl -s -X GET $url -c $cookie | grep _token  | grep -oP 'value="(.*?)"' | sed 's/value=//g' | sed 's/"//g')

if [ $(echo -n $_token | wc -c ) -lt 1  ]; then echo -e "[-] Token no encontrado\nSaliendo..\n"; exit; fi 

cat <<EOF > $mi_data
-----------------------------$boundary
Content-Disposition: form-data; name="_token"

$_token
-----------------------------$boundary
Content-Disposition: form-data; name="subtitles"; filename="$file1"
Content-Type: application/x-subrip

$(cat $file1)
-----------------------------$boundary
Content-Disposition: form-data; name="second-subtitle"; filename="$file2"
Content-Type: application/x-subrip

$(cat $file2)
-----------------------------$boundary
Content-Disposition: form-data; name="mode"

nearestCue
-----------------------------$boundary
Content-Disposition: form-data; name="nearestCueThreshold"

1000
-----------------------------$boundary
Content-Disposition: form-data; name="nearestCueTopBottom"

0
-----------------------------$boundary
Content-Disposition: form-data; name="nearestCueRemoveLineBreaksFromBase"

0
-----------------------------$boundary
Content-Disposition: form-data; name="nearestCueRemoveLineBreaksFromMerge"

0
-----------------------------$boundary
Content-Disposition: form-data; name="simpleTopBottom"

0
-----------------------------$boundary
Content-Disposition: form-data; name="glueVideoLength"

00:00:00
-----------------------------$boundary
Content-Disposition: form-data; name="shouldColorMergeSubtitle"

0
-----------------------------$boundary
Content-Disposition: form-data; name="shouldColorMergeSubtitle"

1
-----------------------------$boundary
Content-Disposition: form-data; name="mergeSubtitleColor"

#ffff54
-----------------------------$boundary
Content-Disposition: form-data; name="shouldColorBaseSubtitle"

0
-----------------------------$boundary
Content-Disposition: form-data; name="baseSubtitleColor"

#ffff54
-----------------------------$boundary--
EOF

id_code=$(curl -s -b $cookie -c $cookie  -X POST  $url   \
    -H "User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:120.0) Gecko/20100101 Firefox/120.0" \
    -H 'Origin: https://subtitletools.com' -H 'Connection: keep-alive' \
    -H 'Upgrade-Insecure-Requests: 1' -H 'Sec-Fetch-Dest: document' -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: same-origin' \
    -H 'Referer: https://subtitletools.com/merge-subtitles-online' \
    -H "Content-Type: multipart/form-data; boundary=---------------------------$boundary" \
    -H 'Sec-Fetch-User: ?1' -H 'TE: trailers' \
    --data-binary "@$mi_data"  | grep -oP 'href="(.*?)"' | sed 's/href="//g' | sed 's/"//g' | awk '{print $NF}' FS='/')

if [ $(echo -n $id_code | wc -c ) -lt 1  ]; then echo -e "[-] Token no encontrado\nSaliendo..\n"; exit; fi 

code=$(curl -s -X GET "$url/$id_code" -b $cookie -c $cookie | grep wire:key | grep -oP '="(.*?)"' | head -1 | tr -d '="') 
if [ $(echo -n $code | wc -c ) -lt 1  ]; then echo -e "[-] Token no encontrado\nSaliendo..\n"; exit; fi 

_token=$(curl -s -X GET "$url/$id_code" -b $cookie -c $cookie | grep _token  | grep -oP 'value="(.*?)"' | sed 's/value=//g' | sed 's/"//g' | head -1) 
if [ $(echo -n $_token | wc -c ) -lt 1  ]; then echo -e "[-] Token no encontrado\nSaliendo..\n"; exit; fi 

curl  -s -X POST "$urlDonwload/$id_code/$code"  -b $cookie -c $cookie -F "_token=$_token" -F "_method=post"   > ${file3}
 
 