#!/bin/sh

set -eu

#base_url="https://pbs.twimg.com/media/"
base_url="http://10.1.1.1/files/miminashi/test/"

rm ./tmp/notsulemio_test_result.txt
rm ./tmp/sulemio_test_result.txt

# SULEMIO
ls -1 train_data/sulemio/test |
  xargs -IXXX curl -s http://localhost:5080/?image_url="${base_url}"XXX |
  jq -r .class_name > ./tmp/sulemio_test_result.txt

all_count="$(wc -l ./tmp/sulemio_test_result.txt | awk '{print $1}')"
sulemio_count="$(grep -c -x SULEMIO ./tmp/sulemio_test_result.txt)"
printf 'sulemio: %s/%s' "${sulemio_count}" "${all_count}, "
echo "${sulemio_count} ${all_count}" | awk '{print $1 / $2}'

# NOTSULEMIO
ls -1 train_data/notsulemio/test |
  xargs -IXXX curl -s http://localhost:5080/?image_url="${base_url}"XXX |
  jq -r .class_name > ./tmp/notsulemio_test_result.txt

all_count="$(wc -l ./tmp/notsulemio_test_result.txt | awk '{print $1}')"
notsulemio_count="$(grep -c -x NOTSULEMIO ./tmp/notsulemio_test_result.txt)"
printf 'notsulemio: %s/%s' "${notsulemio_count}" "${all_count}, "
echo "${notsulemio_count} ${all_count}" | awk '{print $1 / $2}'
