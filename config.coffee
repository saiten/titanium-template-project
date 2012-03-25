#
# ビルド設定
#
module.exports =
  # プラットフォーム別SDKバージョン
  titanium_version:
    iphone:  "1.8.2"
    android: "1.8.2"

  # iOS固有設定
  ios:
    # ターゲットOS
    target_version: "5.1"

    # 使用する証明書の署名
    # KeyChainに入れた証明書の"iPhone (Developer|Distribution):"以下を記述
    distribution_name:
      development: ""
      production:  ""

    # Provisioning設定
    # 実機テスト用。developmentには開発用provisioning、
    # productionにはAppStore用provisioningのProfile Identifierを設定する。
    provisioning:
      development: ""
      production:  ""

  # android固有設定
  android:
    # android SDKのパス
    sdk_path: "android_sdk_path"

