# Changelog

## [5.0.0](https://github.com/CloudNationHQ/terraform-azure-acr/compare/v4.2.0...v5.0.0) (2025-08-27)


### ⚠ BREAKING CHANGES

* this change causes recreates

### Features

* small refactor and changed data structure ([#95](https://github.com/CloudNationHQ/terraform-azure-acr/issues/95)) ([d33f851](https://github.com/CloudNationHQ/terraform-azure-acr/commit/d33f8515cff2d1376ed95bf8f09c32413f43536f))

### Upgrade from v4.2.0 to v5.0.0:

- Update module reference to: `version = "~> 5.0"`
- The property and variable resource_group is renamed to resource_group_name

## [4.2.0](https://github.com/CloudNationHQ/terraform-azure-acr/compare/v4.1.0...v4.2.0) (2025-02-25)


### Features

* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#85](https://github.com/CloudNationHQ/terraform-azure-acr/issues/85)) ([96eb65b](https://github.com/CloudNationHQ/terraform-azure-acr/commit/96eb65b90bea28db1f1f32908b7d80065a1b2b05))


### Bug Fixes

* make agent setting fully optional in registry tasks ([#86](https://github.com/CloudNationHQ/terraform-azure-acr/issues/86)) ([a032561](https://github.com/CloudNationHQ/terraform-azure-acr/commit/a03256177c79f31141ee65e27e308993f4a80cb2))

## [4.1.0](https://github.com/CloudNationHQ/terraform-azure-acr/compare/v4.0.0...v4.1.0) (2025-01-20)


### Features

* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#80](https://github.com/CloudNationHQ/terraform-azure-acr/issues/80)) ([2ccdee4](https://github.com/CloudNationHQ/terraform-azure-acr/commit/2ccdee4f5d9489e720d70aad92e38f2c2d1f5d3f))
* **deps:** bump golang.org/x/crypto from 0.29.0 to 0.31.0 in /tests ([#82](https://github.com/CloudNationHQ/terraform-azure-acr/issues/82)) ([4c77a19](https://github.com/CloudNationHQ/terraform-azure-acr/commit/4c77a19deab46e3f702a125e9289361b64c5aada))
* **deps:** bump golang.org/x/net from 0.31.0 to 0.33.0 in /tests ([#83](https://github.com/CloudNationHQ/terraform-azure-acr/issues/83)) ([0b01ad9](https://github.com/CloudNationHQ/terraform-azure-acr/commit/0b01ad9419bc6f5c5fc21d17f8902088577bd5c3))

## [4.0.0](https://github.com/CloudNationHQ/terraform-azure-acr/compare/v3.2.2...v4.0.0) (2024-12-12)


### ⚠ BREAKING CHANGES

* some keys regarding registry tokens and secrets have changed, which will cause a replacement.

### Features

* small refactor ([#77](https://github.com/CloudNationHQ/terraform-azure-acr/issues/77)) ([c582f2c](https://github.com/CloudNationHQ/terraform-azure-acr/commit/c582f2ca527852e6b6f3fa9b9add18891755e55c))

### Upgrade from v3.2.2 to v4.0.0:

- Update module reference to: `version = "~> 4.0"`

## [3.2.2](https://github.com/CloudNationHQ/terraform-azure-acr/compare/v3.2.1...v3.2.2) (2024-11-21)


### Bug Fixes

* agent setting block is now fully optional ([#74](https://github.com/CloudNationHQ/terraform-azure-acr/issues/74)) ([e3aee76](https://github.com/CloudNationHQ/terraform-azure-acr/commit/e3aee76a4477b2169f26bd42fedaea3a01840643))

## [3.2.1](https://github.com/CloudNationHQ/terraform-azure-acr/compare/v3.2.0...v3.2.1) (2024-11-13)


### Bug Fixes

* fix submodule documentation generation ([#72](https://github.com/CloudNationHQ/terraform-azure-acr/issues/72)) ([37eddce](https://github.com/CloudNationHQ/terraform-azure-acr/commit/37eddced492540efa769ae6696f8e3e9f21dbec6))

## [3.2.0](https://github.com/CloudNationHQ/terraform-azure-acr/compare/v3.1.0...v3.2.0) (2024-11-11)


### Features

* enhance testing with sequential, parallel modes and flags for exceptions and skip-destroy ([#70](https://github.com/CloudNationHQ/terraform-azure-acr/issues/70)) ([4887664](https://github.com/CloudNationHQ/terraform-azure-acr/commit/48876641542a2ac0eb2fcd3343931e3b6cf0d79c))

## [3.1.0](https://github.com/CloudNationHQ/terraform-azure-acr/compare/v3.0.1...v3.1.0) (2024-10-11)


### Features

* auto generated docs and refine makefile ([#68](https://github.com/CloudNationHQ/terraform-azure-acr/issues/68)) ([170da12](https://github.com/CloudNationHQ/terraform-azure-acr/commit/170da1211ab51a666f5a5ae1559bdfa475fdf171))
* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#67](https://github.com/CloudNationHQ/terraform-azure-acr/issues/67)) ([bd69966](https://github.com/CloudNationHQ/terraform-azure-acr/commit/bd6996642446559de35d85cf705740d7ceb43e15))

## [3.0.1](https://github.com/CloudNationHQ/terraform-azure-acr/compare/v3.0.0...v3.0.1) (2024-09-26)


### Bug Fixes

* fix defaults retention policy in days ([#65](https://github.com/CloudNationHQ/terraform-azure-acr/issues/65)) ([18a276b](https://github.com/CloudNationHQ/terraform-azure-acr/commit/18a276b09f05070743567b659a1878f44204e9da))

## [3.0.0](https://github.com/CloudNationHQ/terraform-azure-acr/compare/v2.0.0...v3.0.0) (2024-09-24)


### ⚠ BREAKING CHANGES

* Version 4 of the azurerm provider includes breaking changes.

### Features

* upgrade azurerm provider to v4 ([#63](https://github.com/CloudNationHQ/terraform-azure-acr/issues/63)) ([c06c825](https://github.com/CloudNationHQ/terraform-azure-acr/commit/c06c825e7b11b8614c78d8d34b35956a0ffbac36))

### Upgrade from v2.0.0 to v3.0.0:

- Update module reference to: `version = "~> 3.0"`
- Rename properties in registry object:
  - trust_policy  -> trust_policy_enabled
  - retention_policy -> retention_policy_in_days
  - encryption.enabled -> removed

## [2.0.0](https://github.com/CloudNationHQ/terraform-azure-acr/compare/v1.7.0...v2.0.0) (2024-09-04)


### ⚠ BREAKING CHANGES

* data structure has changed due to renaming of properties.

### Features

* aligned several properties ([#60](https://github.com/CloudNationHQ/terraform-azure-acr/issues/60)) ([12cc189](https://github.com/CloudNationHQ/terraform-azure-acr/commit/12cc18929519d0e72b83340459841c05dd7e18b0))

### Upgrade from v1.7.0 to v2.0.0:

- Update module reference to: `version = "~> 2.0"`
- Rename or remove properties in registry object:
  - resourcegroup -> resource_group
  - trust_policy.enabled -> trust_policy
  - retention_policy.enabled -> retention_policy
  - replications -> georeplications
  - encryption.enable -> encryption
- Rename variable (optional):
  - resourcegroup -> resource_group
- Rename output variable:
  - subscriptionId -> subscription_id'
  - acr -> registry
- Change defaults:
  - identity is now fully optional 
  - enabled property under trust_policy now defaults to false

## [1.7.0](https://github.com/CloudNationHQ/terraform-azure-acr/compare/v1.6.0...v1.7.0) (2024-08-28)


### Features

* update documentation ([#57](https://github.com/CloudNationHQ/terraform-azure-acr/issues/57)) ([99577dc](https://github.com/CloudNationHQ/terraform-azure-acr/commit/99577dca625029a78e73594bc031166a3be017e7))

## [1.6.0](https://github.com/CloudNationHQ/terraform-azure-acr/compare/v1.5.0...v1.6.0) (2024-08-22)


### Features

* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#55](https://github.com/CloudNationHQ/terraform-azure-acr/issues/55)) ([38227f2](https://github.com/CloudNationHQ/terraform-azure-acr/commit/38227f27ff124ca39724fc3424bd16e0eaa699c2))
* update contribution docs ([#53](https://github.com/CloudNationHQ/terraform-azure-acr/issues/53)) ([f7a2f8a](https://github.com/CloudNationHQ/terraform-azure-acr/commit/f7a2f8a4e07ba9c9803a66315cb8565979053c46))

## [1.5.0](https://github.com/CloudNationHQ/terraform-azure-acr/compare/v1.4.0...v1.5.0) (2024-07-03)


### Features

* update random provider version ([#51](https://github.com/CloudNationHQ/terraform-azure-acr/issues/51)) ([8c5edfd](https://github.com/CloudNationHQ/terraform-azure-acr/commit/8c5edfdca04744d40c89c9e18c5d01195ac2ebe5))

## [1.4.0](https://github.com/CloudNationHQ/terraform-azure-acr/compare/v1.3.0...v1.4.0) (2024-07-02)


### Features

* add issue template ([#48](https://github.com/CloudNationHQ/terraform-azure-acr/issues/48)) ([dc844a0](https://github.com/CloudNationHQ/terraform-azure-acr/commit/dc844a0e4b4fb115c7daa6fe3133a049fb750b2b))
* **deps:** bump github.com/Azure/azure-sdk-for-go/sdk/azidentity ([#45](https://github.com/CloudNationHQ/terraform-azure-acr/issues/45)) ([e691991](https://github.com/CloudNationHQ/terraform-azure-acr/commit/e691991f26661c2a488e4ecb2d80e8dd35b7fadf))
* **deps:** bump github.com/Azure/azure-sdk-for-go/sdk/azidentity ([#46](https://github.com/CloudNationHQ/terraform-azure-acr/issues/46)) ([0d5b9ea](https://github.com/CloudNationHQ/terraform-azure-acr/commit/0d5b9eabca0b665745a39832cdb74afbcdef3b80))
* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#49](https://github.com/CloudNationHQ/terraform-azure-acr/issues/49)) ([d5c4c99](https://github.com/CloudNationHQ/terraform-azure-acr/commit/d5c4c999fa2cbb601e7f0ed1c605db6da205226f))
* **deps:** bump github.com/hashicorp/go-getter in /tests ([#47](https://github.com/CloudNationHQ/terraform-azure-acr/issues/47)) ([bcde716](https://github.com/CloudNationHQ/terraform-azure-acr/commit/bcde716f480840be8aa3704910c7e53c568cac89))

## [1.3.0](https://github.com/CloudNationHQ/terraform-azure-acr/compare/v1.2.0...v1.3.0) (2024-06-07)


### Features

* add pull request template ([703b00d](https://github.com/CloudNationHQ/terraform-azure-acr/commit/703b00d28c4b62d0deda2cdd4af88adbe0e86bbc))

## [1.2.0](https://github.com/CloudNationHQ/terraform-azure-acr/compare/v1.1.0...v1.2.0) (2024-05-29)


### Features

* update documentation ([#38](https://github.com/CloudNationHQ/terraform-azure-acr/issues/38)) ([6523d3f](https://github.com/CloudNationHQ/terraform-azure-acr/commit/6523d3f995569e94e5a1fd406a3787d167a1e872))

## [1.1.0](https://github.com/CloudNationHQ/terraform-azure-acr/compare/v1.0.0...v1.1.0) (2024-05-29)


### Features

* add tasks submodule with support for all available triggers and extended functionality ([#36](https://github.com/CloudNationHQ/terraform-azure-acr/issues/36)) ([8046673](https://github.com/CloudNationHQ/terraform-azure-acr/commit/8046673bdf3db9324a3abb2f427f255510d57961))
* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#35](https://github.com/CloudNationHQ/terraform-azure-acr/issues/35)) ([f12c8f1](https://github.com/CloudNationHQ/terraform-azure-acr/commit/f12c8f1a533e8da4ff8a146568f4c2070d49830c))

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
