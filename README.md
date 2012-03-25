# Titanium mobile用Cakefile

Titaniumでcoffeescriptを使ってて、かつTitanium Studioを使わない人向け。コマンドラインからシミュレータビルド、実機ビルド、AppStore向けビルドまでサポート。

## インストール

いくつかのライブラリを必要とするので、npmでインストール

	npm install -g underscore async xmlbuilder xml2js 

Cakefile, config.coffee, strings.coffeeをそれぞれTitaniumのプロジェクトディレクトリ直下にコピー。

### config.coffeeを修正

使用するTitanium SDKバージョンを指定

	  # プラットフォーム別SDKバージョン
	  titanium_version:
	    iphone:  "1.8.2"
	    android: "1.8.2"

実機でテストする場合は、証明書の設定が必要。

	  # 使用する証明書の署名
	  # KeyChainに入れた証明書の"iPhone (Developer|Distribution):"以下を記述
	  distribution_name:
	    development: "Tomoaki Shibata"
	    production:  "Tomoaki Shibata"


AppStore向けにビルドする場合は、Provisioning Profileも指定する。

	    # Provisioning設定
	    # 実機テスト用。developmentには開発用provisioning、
	    # productionにはAppStore用provisioningのProfile Identifierを設定する。
	    provisioning:
	      development: "4470ACE7-00F6-41E6-8C8E-EA686C23C956"
	      production:  "31700C07-D603-4783-9645-90E6A477121"


## 使い方

### ヘルプ

	cake

### iOS向けビルド

	cake build:iPhone

### iOS シミュレータで実行

	cake run:iphone

### ipa作成 (itunes起動)

	cake install:iPhone

### AppStore向けビルド(Archives起動)

	cake distribute:iPhone

### iPhone向けbuildディレクトリクリア

	cake clean:iPhone

## strings.coffee

ローカライズXML作成用。ビルド時に読み込んでi18nディレクトリ内に自動的にstrings.xmlに変換される。

### 書き方

	module.exports =
	  APP_TITLE:
	    en: "Application Title"
	    ja: "アプリケーションタイトル"

アプリ内から利用するときは、`L('APP_TITLE')`として呼び出す。
