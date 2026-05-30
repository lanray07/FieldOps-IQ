# GitHub Actions Secrets

The `Xcode App Store Build` workflow accepts the following repository secrets.
Primary names are preferred, and aliases are supported to match existing uploads.

## Required secrets

| Purpose | Preferred secret | Supported aliases |
| --- | --- | --- |
| Apple Developer team ID | `APPLE_TEAM_ID` | `DEVELOPMENT_TEAM` |

The workflow can sign in either automatic or manual mode.

## Automatic signing secrets

These are enough for Xcode to manage signing on the macOS runner. They are also
used to upload the exported IPA to App Store Connect.

| Purpose | Preferred secret | Supported aliases |
| --- | --- | --- |
| API key ID | `APP_STORE_CONNECT_API_KEY_ID` | `APP_STORE_CONNECT_KEY_ID`, `ASC_KEY_ID` |
| API issuer ID | `APP_STORE_CONNECT_API_ISSUER_ID` | `APP_STORE_CONNECT_ISSUER_ID`, `ASC_ISSUER_ID` |
| API private key `.p8` contents | `APP_STORE_CONNECT_API_PRIVATE_KEY` | `APP_STORE_CONNECT_PRIVATE_KEY`, `ASC_PRIVATE_KEY` |

The private key can be stored with normal newlines or escaped `\n` line breaks.

## Manual signing secrets

If these are present, the workflow imports the certificate and provisioning
profile and signs manually instead of asking Xcode to manage signing.

| Purpose | Preferred secret | Supported aliases |
| --- | --- | --- |
| Distribution certificate as base64 `.p12` | `BUILD_CERTIFICATE_BASE64` | `IOS_CERTIFICATE_BASE64`, `P12_BASE64` |
| Distribution certificate password | `P12_PASSWORD` | `CERTIFICATE_PASSWORD`, `IOS_CERTIFICATE_PASSWORD` |
| App Store provisioning profile as base64 `.mobileprovision` | `BUILD_PROVISION_PROFILE_BASE64` | `IOS_PROVISION_PROFILE_BASE64`, `MOBILEPROVISION_BASE64` |
| Temporary keychain password | `KEYCHAIN_PASSWORD` | Optional; generated if missing |
