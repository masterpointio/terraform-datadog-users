[![Banner][banner-image]](https://masterpoint.io/)

# terraform-datadog-users

[![Release][release-badge]][latest-release]

💡 Learn more about Masterpoint [below](#who-we-are-𐦂𖨆𐀪𖠋).

## Purpose and Functionality

This Terraform module is designed to create and manage Datadog user accounts.

The users are associated with one of the three [out-of-the-box roles](https://docs.datadoghq.com/account_management/rbac/permissions/):

- Datadog Admin
- Datadog Standard
- Datadog Read Only

## Usage

```hcl
module "datadog_users" {
  source  = "masterpointio/datadog/users"
  version = "X.X.X"

  users = [
    {
      roles    = ["standard"],
      email    = "jane.smith@example.com",
      name     = "Jane Smith",
      role     = "Editor",
      username = "janesmith"
    }
  ]
}
```

Check out [examples/complete](examples/complete) for the full example.

To ensure the secure handling of DataDog sensitive data for datadog/datadog provider, the module's example is designed to work with the [SOPS (Secrets OPerationS)](https://github.com/mozilla/sops) provider. SOPS is a tool for encrypting and decrypting files containing sensitive data, often used in conjunction with Terraform to manage secrets. The example also utilizes [terraform-secrets-helper](https://github.com/masterpointio/terraform-secrets-helper/tree/main) module - a helper that provides a standard way of managing secrets from different sources, incuding SOPS files.

❗ We recommend to use AWS KMS, GCP KMS, Azure Key Vault for SOPS files encryption. Don't use the secrets from the example in your real configuration!

Here are some basic SOPS operations that help you to work with the example:

- Pass `age` key to SOPS provider configuration:

```sh
cd ./example/complete
export SOPS_AGE_KEY_FILE=key.txt
```

- Encryption/decryption via SOPS editior

```sh
sops example.yaml
```

<!-- prettier-ignore-start -->
<!-- markdownlint-disable MD013 -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_datadog"></a> [datadog](#requirement\_datadog) | >= 3.14 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_datadog"></a> [datadog](#provider\_datadog) | >= 3.14 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [datadog_user.users](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/user) | resource |
| [datadog_role.admin](https://registry.terraform.io/providers/datadog/datadog/latest/docs/data-sources/role) | data source |
| [datadog_role.read_only](https://registry.terraform.io/providers/datadog/datadog/latest/docs/data-sources/role) | data source |
| [datadog_role.standard](https://registry.terraform.io/providers/datadog/datadog/latest/docs/data-sources/role) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_users"></a> [users](#input\_users) | n/a | <pre>list(object({<br/>    disabled             = optional(bool, false)<br/>    email                = string<br/>    name                 = string<br/>    roles                = set(string)<br/>    send_user_invitation = optional(bool, true)<br/>    username             = string<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_datadog_users"></a> [datadog\_users](#output\_datadog\_users) | A map of all Datadog user resources keyed by username. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable MD013 -->
<!-- prettier-ignore-end -->

## Built By

Powered by the [Masterpoint team](https://masterpoint.io/who-we-are/) and driven forward by contributions from the community ❤️

[![Contributors][contributors-image]][contributors-url]

## Contribution Guidelines

Contributions are welcome and appreciated!

Found an issue or want to request a feature? [Open an issue][issues-url]

Want to fix a bug you found or add some functionality? Fork, clone, commit, push, and PR — we'll check it out.

## Who We Are 𐦂𖨆𐀪𖠋

Established in 2016, Masterpoint is a team of experienced software and platform engineers specializing in Infrastructure as Code (IaC). We provide expert guidance to organizations of all sizes, helping them leverage the latest IaC practices to accelerate their engineering teams.

### Our Mission

Our mission is to simplify cloud infrastructure so developers can innovate faster, safer, and with greater confidence. By open-sourcing tools and modules that we use internally, we aim to contribute back to the community, promoting consistency, quality, and security.

### Our Commitments

- 🌟 **Open Source**: We live and breathe open source, contributing to and maintaining hundreds of projects across multiple organizations.
- 🌎 **1% for the Planet**: Demonstrating our commitment to environmental sustainability, we are proud members of [1% for the Planet](https://www.onepercentfortheplanet.org), pledging to donate 1% of our annual sales to environmental nonprofits.
- 🇺🇦 **1% Towards Ukraine**: With team members and friends affected by the ongoing [Russo-Ukrainian war](https://en.wikipedia.org/wiki/Russo-Ukrainian_War), we donate 1% of our annual revenue to invasion relief efforts, supporting organizations providing aid to those in need. [Here's how you can help Ukraine with just a few clicks](https://masterpoint.io/updates/supporting-ukraine/).

## Connect With Us

We're active members of the community and are always publishing content, giving talks, and sharing our hard earned expertise. Here are a few ways you can see what we're up to:

[![LinkedIn][linkedin-badge]][linkedin-url] [![Newsletter][newsletter-badge]][newsletter-url] [![Blog][blog-badge]][blog-url] [![YouTube][youtube-badge]][youtube-url]

... and be sure to connect with our founder, [Matt Gowie](https://www.linkedin.com/in/gowiem/).

## License

[Apache License, Version 2.0][license-url].

[![Open Source Initiative][osi-image]][license-url]

Copyright © 2016-2025 [Masterpoint Consulting LLC](https://masterpoint.io/)

<!-- MARKDOWN LINKS & IMAGES -->

[banner-image]: https://masterpoint-public.s3.us-west-2.amazonaws.com/v2/standard-long-fullcolor.png
[license-url]: https://opensource.org/license/apache-2-0
[osi-image]: https://i0.wp.com/opensource.org/wp-content/uploads/2023/03/cropped-OSI-horizontal-large.png?fit=250%2C229&ssl=1
[linkedin-badge]: https://img.shields.io/badge/LinkedIn-Follow-0A66C2?style=for-the-badge&logoColor=white
[linkedin-url]: https://www.linkedin.com/company/masterpoint-consulting
[blog-badge]: https://img.shields.io/badge/Blog-IaC_Insights-55C1B4?style=for-the-badge&logoColor=white
[blog-url]: https://masterpoint.io/updates/
[newsletter-badge]: https://img.shields.io/badge/Newsletter-Subscribe-ECE295?style=for-the-badge&logoColor=222222
[newsletter-url]: https://newsletter.masterpoint.io/
[youtube-badge]: https://img.shields.io/badge/YouTube-Subscribe-D191BF?style=for-the-badge&logo=youtube&logoColor=white
[youtube-url]: https://www.youtube.com/channel/UCeeDaO2NREVlPy9Plqx-9JQ
[release-badge]: https://img.shields.io/github/v/release/masterpointio/terraform-datadog-users?color=0E383A&label=Release&style=for-the-badge&logo=github&logoColor=white
[latest-release]: https://github.com/masterpointio/terraform-datadog-users/releases/latest
[contributors-image]: https://contrib.rocks/image?repo=masterpointio/terraform-datadog-users
[contributors-url]: https://github.com/masterpointio/terraform-datadog-users/graphs/contributors
[issues-url]: https://github.com/masterpointio/terraform-datadog-users/issues
