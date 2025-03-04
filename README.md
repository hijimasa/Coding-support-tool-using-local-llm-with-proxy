# Cline_for_local_llm_with_proxy

このリポジトリはollamaを使ってローカルLLMサーバーを立ち上げて、Clineを動作させるまでの手順を示したリポジトリです。

## ローカルLLMサーバー導入手順

1. 本リポジトリをサーバー機にクローンする
   ```
   git clone https://github.com/hijimasa/Cline_for_local_llm_with_proxy.git
   ```

2. Dockerイメージをビルドする
   ```
   cd Cline_for_local_llm_with_proxy
   bash ./build_docker.sh
   ```

3. コンテナを立ち上げる
   ```
   bash ./launch_container.sh
   ```

## Cline設定手順

## 参考URL
- https://note.com/cppp_cpchan/n/n92c7795f5939#825209eb-6a46-4197-90b7-15ad73c7ae8e