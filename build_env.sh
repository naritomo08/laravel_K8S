#!/bin/sh

# .envファイルコピー
cp .env.example backend/.env

# イメージファイルビルド
docker build --tag laravel:0.1 . 