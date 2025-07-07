#!/bin/bash
set -e

echo '--- setting up ruby'
rbenv install -s 2.1.5
rbenv local 2.1.5
rbenv rehash

echo '--- bundling'
bundle install -j $(nproc) --with=development

echo '--- running specs'
bundle exec rspec
