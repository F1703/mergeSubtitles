#!/bin/bash

url="https://subtitletools.com/merge-subtitles-online"
api="https://subtitletools.com/api/v1/file-group/result"
urlDonwload="https://subtitletools.com/download-file-job"

cookie="/tmp/cookie.txt" 

# name=_token
# name=subtitles
# name=second-subtitle
# name=mode value=nearestCue
# name=baseSubtitleColor value=#ffff54
# name=mergeSubtitleColor  value=#ffff54
# name=shouldColorBaseSubtitle value=1
# name=shouldColorMergeSubtitle value=0
# name=glueOffset value=1000
# name=simpleTopBottom value=0
# name=nearestCueTopBottom value=0
# name=nearestCueThreshold value=0

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

_token=$(curl -s -X GET $url -c $cookie | grep _token  | grep -oP 'value="(.*?)"' | sed 's/value=//g' | sed 's/"//g')
 
id_code=$(curl -s -X POST  $url -b $cookie -c $cookie  \
    -F "_token=$_token" \
    -F "subtitles=@$file1" \
    -F "second-subtitle=@$file2" \
    -F "mode=nearestCue" \
    -F "baseSubtitleColor=#ffff54"  \
    -F "mergeSubtitleColor=#ffff54"  \
    -F "shouldColorBaseSubtitle=1"  \
    -F "shouldColorMergeSubtitle=0"  \
    -F "glueOffset=1000"  \
    -F "simpleTopBottom=0"  \
    -F "nearestCueTopBottom=0"  \
    -F "nearestCueThreshold=1000"  \
    -H "User-Agent:Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:105.0) Gecko/20100101 Firefox/105.0" \
    | grep -oP 'href="(.*?)"' | sed 's/href="//g' | sed 's/"//g' | awk '{print $NF}' FS='/') 

sleep 2
code=$(curl -s -X GET "$api/$id_code" | grep -oP 'id":(.*?),' | sed 's/id"://g' | sed 's/,//g'  ) 
 
_token=$(curl -s -X GET "$url/$id_code" -b $cookie -c $cookie | grep csrf-token  | grep -oP 'content="(.*?)"' | sed 's/content="//g' | sed 's/"//g')

curl -s -X POST "$urlDonwload/$id_code/$code"  -b $cookie -c $cookie -F "_token=$_token" > ${file3}
 

