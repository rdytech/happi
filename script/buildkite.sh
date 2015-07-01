#!/bin/bash
set -e

REVISION=https://github.com/$BUILDBOX_PROJECT_SLUG/commit/$BUILDBOX_COMMIT

echo '--- setting ruby version'
rbenv local 2.1.5

echo '--- bundling'
bundle install -j $(nproc) --without development production --quiet

echo '--- running specs'
if bundle exec rspec; then
  echo "[Successful] $BUILDBOX_PROJECT_SLUG - Build - $BUILDBOX_BUILD_URL - Commit - $REVISION" | hipchat_room_message -t $HIPCHAT_TOKEN -r $HIPCHAT_ROOM -f "Buildbox" -c "green"
else
  echo "[Failed] Build $BUILDBOX_PROJECT_SLUG - Build - $BUILDBOX_BUILD_URL - Commit - $REVISION" | hipchat_room_message -t $HIPCHAT_TOKEN -r $HIPCHAT_ROOM -f "Buildbox" -c "red"
  exit 1;
fi

