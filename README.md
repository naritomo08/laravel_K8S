# laravelK8S

Laravel9以上のサイトをK8Sで立ち上げる手順になります。

## 参考URL

[M1 MacBook上へのローカルk8s環境（minikube、kind）セットアップ手順](https://qiita.com/kyontra/items/b1696df6ea072fa48c34)
[gcloudコマンドでGKEを立ち上げてみた。](https://qiita.com/naritomo08/items/d1a3122264b248915360)

## 事前準備

参考URLを参照し、M1 Macにて、ローカル環境またはGKE環境ができていること。

＊kindについては後に示す手順で立ち上げること。

## 環境構築手順

### 本リポジトリをクローンする。

```bash
$ git clone https://github.com/naritomo08/laravel_K8S.git laravelk8s
laravel9の場合
$ git clone https://github.com/naritomo08/laravelapp3.git backend
laravel10の場合
$ git clone https://github.com/naritomo08/laravelapp4.git backend
つぶやきサイトの場合
$ git clone https://github.com/naritomo08/laravel9tubu.git backend
```

後にファイル編集などをして、git通知が煩わしいときは
作成したフォルダで以下のコマンドを入れる。

```bash
 rm -rf .git
```

### (ローカルでkindを使用する場合)kindの立ち上げ

```bash
cd laravelk8s
kind create cluster --config kind.yaml --name kindcluster
```

停止する場合
```bash
cd laravelk8s
kind delete cluster --name kindcluster
```

### phpレジストリ作成のシェルスクリプトを実行する。

```bash
$ chmod u+x build_env.sh && ./build_env.sh
```

### docker hubへイメージプッシュする。

docker hubアカウントを作成する。

以下のコマンドを入力する。
```bash
docker login
docker tag laravel:0.1 <docker hubユーザー名>/laravel:0.1
docker push <docker hubユーザー名>/laravel:0.1
```
*パブリックレジストリに入るため扱いに注意すること。

### K8S稼働シェルスクリプトを実行する。

```bash
$ vi laravel-php.yml
以下の部分を書き換える
image: <docker hubユーザー名>/laravel:0.1
$ vi k8s_run.sh
→動かすK8S環境に応じ稼働させるサービスファイルを指定すること。
$ chmod u+x k8s_run.sh && ./k8s_run.sh
kubectl get all
→　エラーが発生していないこと。
```

### コンテナコマンド実施

```bash
kubectl get po -o wide
laravel-cache/laravel-dbのIPを控える。
kubectl get all
→laravel-phpのポッド名を確認する。(複数作った場合は全てに対して実施する。)
kubectl exec -it <ポッド名> sh

vi .env

以下の場所を前の手順で控えたIPに書き換える

DB_HOST=<laravel-dbのIPアドレス>
REDIS_HOST=<laravel-cacheのIPアドレス>

.env反映

php artisan cache:clear
php artisan config:cache

DBへのマイグレート

php artisan migrate
php artisan config:cache

exit
```

### 各種サイト確認する。

*つぶやきサイトでは画像アップが実施できません。

## サイトURL

### laravelサイト（kind)

```bash
http://127.0.0.1:10081
```

### laravelサイト（minikube)

```bash
kubectl get laravel-np
→PORT(S)の右側のポート番号を確認する。
http://127.0.0.1:<ポート番号>
```

### laravelサイト（GKE)

```bash
kubectl get laravel-lb
→External-IPの値を確認する。(数分待つ。)
http:/<External-IP>
＊SSL化していないので、利用に注意！
```

## K8S稼働サイトを削除する方法

以下のコマンドを実行する。

```bash
$ kubectl delete -f ./manifest
```
