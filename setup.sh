app_name="$1"
module_name="$2"

if [[ -n "$app_name" ]] && [[ -n "$module_name" ]]; then
  mv lib/me_app "lib/${app_name}"
  mv lib/me_app.ex "lib/${app_name}.ex"
  mv lib/me_app_web "lib/${app_name}_web"
  mv lib/me_app_web.ex "lib/${app_name}_web.ex"

  find ./ -type f -not -path "./.git/*" -not -name "setup.sh" -exec \
    sed -i -e "s/me_app/${app_name}/g" {} \;

  find ./ -type f -not -path "./.git/*" -not -name "setup.sh" -exec \
    sed -i -e "s/MeApp/${module_name}/g" {} \;
fi

ASSET_DIRECTORY="assets/css"

# Install fontawesome

FONT_AWESOME_FILENAME="fontawesome-free-6.1.1-web"

curl -flo "${ASSET_DIRECTORY}/${FONT_AWESOME_FILENAME}.zip" \
  https://use.fontawesome.com/releases/v6.1.1/${FONT_AWESOME_FILENAME}.zip

unzip -d $ASSET_DIRECTORY $ASSET_DIRECTORY/$FONT_AWESOME_FILENAME.zip
mv $ASSET_DIRECTORY/$FONT_AWESOME_FILENAME $ASSET_DIRECTORY/fontawesome
rm -rf $ASSET_DIRECTORY/$FONT_AWESOME_FILENAME.zip
cd $ASSET_DIRECTORY/fontawesome
rm -rf \
  LICENSE.txt \
  js \
  less \
  metadata \
  scss \
  sprites \
  svgs
cd -
cd $ASSET_DIRECTORY/fontawesome/css
rm -rf \
  all.min.css \
  brands.css \
  brands.min.css \
  fontawesome.css \
  fontawesome.min.css \
  regular.css \
  regular.min.css \
  solid.css \
  solid.min.css \
  svg-with-js.css \
  svg-with-js.min.css \
  v4-font-face.css \
  v4-font-face.min.css \
  v4-shims.css \
  v4-shims.min.css \
  v5-font-face.css \
  v5-font-face.min.css
cd -

# Install bulma

curl -fLo "${ASSET_DIRECTORY}/bulma.zip" \
  https://github.com/jgthms/bulma/releases/download/0.9.4/bulma-0.9.4.zip

unzip -d $ASSET_DIRECTORY $ASSET_DIRECTORY/bulma.zip
mv $ASSET_DIRECTORY/bulma/css/bulma.css $ASSET_DIRECTORY
rm -rf \
  $ASSET_DIRECTORY/bulma.zip \
  $ASSET_DIRECTORY/bulma

mix do deps.get, compile
