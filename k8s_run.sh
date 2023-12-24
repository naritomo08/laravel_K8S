#!/bin/sh

# db起動
kubectl apply -f ./manifest/laravel-db.yml

# cache起動
kubectl apply -f ./manifest/laravel-cache.yml

# Laravel起動
kubectl apply -f ./manifest/laravel-php.yml

# サービス起動(kind対応)
kubectl apply -f ./manifest/laravel-np-kind.yml

# サービス起動(minikube対応)
#kubectl apply -f ./manifest/laravel-np.yml

# サービス起動(GKE対応)
#kubectl apply -f ./manifest/laravel-lb.yml
