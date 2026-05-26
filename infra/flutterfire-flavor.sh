#!/bin/bash
# Script to generate Firebase configuration files for different environments/flavors
# Feel free to reuse and adapt this script for your own projects

if [[ $# -eq 0 ]]; then
  echo "Error: No environment specified. Use 'staging' or 'production'."
  exit 1
fi

case $1 in
  dev)
    flutterfire config \
      --project=nunu-staging \
      --out=lib/firebase_options_dev.dart \
      --ios-bundle-id=com.nunu.dev \
      --ios-out=ios/flavors/dev/GoogleService-Info.plist \
      --macos-bundle-id=monster.nunu.dev \
      --macos-out=macos/flavors/dev/GoogleService-Info.plist \
      --android-package-name=monster.nunu.wqeeer.dev \
      --android-out=android/app/src/dev/google-services.json 
    ;;
  staging)
    flutterfire config \
      --project=nunu-staging \
      --out=lib/firebase_options_staging.dart \
      --ios-bundle-id=monster.nunu.staging \
      --ios-out=ios/flavors/staging/GoogleService-Info.plist \
      --android-package-name=monster.nunu.wqeeer.staging \
      --android-out=android/app/src/staging/google-services.json
    ;;
  production)
    flutterfire config \
      --project=nunu-2801b \
      --out=lib/firebase_options.dart \
      --ios-bundle-id=monster.nunu.production \
      --ios-out=ios/flavors/production/GoogleService-Info.plist \
      --android-package-name=monster.nunu.wqeeer \
      --android-out=android/app/src/production/google-services.json
    ;;
  *)
    echo "Error: Invalid environment specified. Use 'staging' or 'production'."
    exit 1
    ;;
esac