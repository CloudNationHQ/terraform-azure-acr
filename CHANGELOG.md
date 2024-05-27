# Changelog

## [1.0.0](https://github.com/CloudNationHQ/terraform-azure-acr/compare/v0.6.0...v1.0.0) (2024-05-27)


### ⚠ BREAKING CHANGES

* The data structure for registry agent pools and tasks has changed. This change is not backwards compatible

### Features

* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#30](https://github.com/CloudNationHQ/terraform-azure-acr/issues/30)) ([736c889](https://github.com/CloudNationHQ/terraform-azure-acr/commit/736c88915c70fe1eeee436e77dc33a160ee572c7))
* **deps:** bump github.com/hashicorp/go-getter in /tests ([#29](https://github.com/CloudNationHQ/terraform-azure-acr/issues/29)) ([1949c21](https://github.com/CloudNationHQ/terraform-azure-acr/commit/1949c21ac0f4a392af53d865ea7698d264050c13))
* **deps:** bump golang.org/x/net from 0.19.0 to 0.23.0 in /tests ([#28](https://github.com/CloudNationHQ/terraform-azure-acr/issues/28)) ([9dde8e4](https://github.com/CloudNationHQ/terraform-azure-acr/commit/9dde8e496db1b4aeed6bf9df333ee965368a84c5))
* refactor registry agent pools ([#33](https://github.com/CloudNationHQ/terraform-azure-acr/issues/33)) ([c8bd072](https://github.com/CloudNationHQ/terraform-azure-acr/commit/c8bd0725234e834f8950e88fc320bddfefcea879))

## [0.6.0](https://github.com/CloudNationHQ/terraform-azure-acr/compare/v0.5.0...v0.6.0) (2024-03-22)


### Features

* add support for network rules ([#23](https://github.com/CloudNationHQ/terraform-azure-acr/issues/23)) ([546798c](https://github.com/CloudNationHQ/terraform-azure-acr/commit/546798c0e21538eda4046d02b26f59bb4aa36291))

## [0.5.0](https://github.com/CloudNationHQ/terraform-azure-acr/compare/v0.4.0...v0.5.0) (2024-03-15)


### Features

* **deps:** bump github.com/Azure/azure-sdk-for-go/sdk/azidentity ([#15](https://github.com/CloudNationHQ/terraform-azure-acr/issues/15)) ([a729d59](https://github.com/CloudNationHQ/terraform-azure-acr/commit/a729d59b17cb827903df48b7165d3b9830f41c23))
* **deps:** bump github.com/stretchr/testify in /tests ([#17](https://github.com/CloudNationHQ/terraform-azure-acr/issues/17)) ([0fdfa6c](https://github.com/CloudNationHQ/terraform-azure-acr/commit/0fdfa6c62122b78e0923109734de2c9328199dd8))
* **deps:** bump google.golang.org/protobuf in /tests ([#19](https://github.com/CloudNationHQ/terraform-azure-acr/issues/19)) ([cbd4423](https://github.com/CloudNationHQ/terraform-azure-acr/commit/cbd44236e79de5af80a57dcc7324c3bfa42f0f58))
* improved alignment for several properties and added some missing ones ([#21](https://github.com/CloudNationHQ/terraform-azure-acr/issues/21)) ([f5545f7](https://github.com/CloudNationHQ/terraform-azure-acr/commit/f5545f70cdf97ca5d29c0ec5b6633990667234d5))
* remove sku conditions on several properties because the rest api already does that and added conditional expressions to allow some global properties ([#22](https://github.com/CloudNationHQ/terraform-azure-acr/issues/22)) ([fe49738](https://github.com/CloudNationHQ/terraform-azure-acr/commit/fe49738cbfd9a3bf65db835fda1c700b5624b13a))
* small refactor private endpoints ([#20](https://github.com/CloudNationHQ/terraform-azure-acr/issues/20)) ([a49b5db](https://github.com/CloudNationHQ/terraform-azure-acr/commit/a49b5db900162d2144be5e3bf2c3ee649c92aa08))

## [0.4.0](https://github.com/CloudNationHQ/terraform-azure-acr/compare/v0.3.0...v0.4.0) (2024-01-19)


### Features

* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#10](https://github.com/CloudNationHQ/terraform-azure-acr/issues/10)) ([b2a4e84](https://github.com/CloudNationHQ/terraform-azure-acr/commit/b2a4e840526a9618ce3d53a042667960dc6a4a48))
* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#13](https://github.com/CloudNationHQ/terraform-azure-acr/issues/13)) ([00b1cd9](https://github.com/CloudNationHQ/terraform-azure-acr/commit/00b1cd9a240b71ec393105b3880440fcb56eb01d))
* **deps:** bump golang.org/x/crypto from 0.14.0 to 0.17.0 in /tests ([#12](https://github.com/CloudNationHQ/terraform-azure-acr/issues/12)) ([eccc9b5](https://github.com/CloudNationHQ/terraform-azure-acr/commit/eccc9b513db916e1ce8794aea899a8fd05c2acb6))
* small refactor workflows ([#14](https://github.com/CloudNationHQ/terraform-azure-acr/issues/14)) ([ad183ab](https://github.com/CloudNationHQ/terraform-azure-acr/commit/ad183ab7c218f939d54cd8872de31c4643aefbfb))

## [0.3.0](https://github.com/CloudNationHQ/terraform-azure-acr/compare/v0.2.0...v0.3.0) (2023-11-23)


### Features

* **deps:** bump github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/containerregistry/armcontainerregistry ([#7](https://github.com/CloudNationHQ/terraform-azure-acr/issues/7)) ([88289d3](https://github.com/CloudNationHQ/terraform-azure-acr/commit/88289d3d56db52cbae80b004fb3e5a5c589f25c7))
* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#5](https://github.com/CloudNationHQ/terraform-azure-acr/issues/5)) ([52c5db3](https://github.com/CloudNationHQ/terraform-azure-acr/commit/52c5db34258ed1402171ddb10f0ae5454f54378d))
* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#8](https://github.com/CloudNationHQ/terraform-azure-acr/issues/8)) ([86ef359](https://github.com/CloudNationHQ/terraform-azure-acr/commit/86ef359b8c96b5967d302eba26fd95a92e842b9d))

## [0.2.0](https://github.com/CloudNationHQ/terraform-azure-acr/compare/v0.1.0...v0.2.0) (2023-11-04)


### Features

* fix module source references in examples ([#3](https://github.com/CloudNationHQ/terraform-azure-acr/issues/3)) ([0865129](https://github.com/CloudNationHQ/terraform-azure-acr/commit/08651296876812f949486298ba73843078e7e110))

## 0.1.0 (2023-11-02)


### Features

* add initial resources ([#1](https://github.com/CloudNationHQ/terraform-azure-acr/issues/1)) ([19b665d](https://github.com/CloudNationHQ/terraform-azure-acr/commit/19b665d2118a7e0f84544981e54cd09abb699e3f))
