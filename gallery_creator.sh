#!/bin/bash
# run chmod u+x gallery_creator.sh in terminal then run ./gallery_creator.sh

endpoints=(
  "2019_beysehir/DSC_1095EDW.webp"
  "2019_beysehir/DSC_1097ED2W.webp"
  "2019_beysehir/DSC_1122EDW.webp"
  "2019_beysehir/P2081871ED2W.webp"
  "2019_beysehir/P2081864EDW.webp"
  "2019_beysehir/P2081957EDW.webp"
  "2019_beysehir/P2082189EDW.webp"
  "2019_beysehir/P2082201EDW.webp"
)

base_path="../../../assets/image"

echo '<div class="swiper" data-my-swiper>'
echo '    <div class="swiper-wrapper pswp-gallery" data-gallery>'

for endpoint in "${endpoints[@]}"; do
  echo '        <div class="swiper-slide">'
  echo "            <a href=\"$base_path/$endpoint\" target=\"_blank\">"
  echo "                <img src=\"$base_path/$endpoint\" alt=\"Image\" loading=\"lazy\" />"
  echo '            </a>'
  echo '            <div class="swiper-lazy-preloader swiper-lazy-preloader-white"></div>'
  echo '        </div>'
done

echo '    </div>'
echo '    <div class="swiper-button-next"></div>'
echo '    <div class="swiper-button-prev"></div>'
echo '    <div class="swiper-pagination"></div>'
echo '</div>'