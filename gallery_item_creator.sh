#!/bin/bash
# run chmod u+x gallery_item_creator.sh in terminal then run ./gallery_item_creator.sh

fileDir="2019_bursa/DSC_0743EDW.webp"

output=$(cat <<EOF
<div class="f-carousel__slide" data-fancybox="gallery"
    data-caption=""
    data-thumb-src="../../../assets/image/${fileDir/.webp/}S.webp"
    data-src="../../../assets/image/$fileDir">
    <img data-lazy-src="../../../assets/image/$fileDir" alt="Image" />
</div>
EOF
)

echo "$output"