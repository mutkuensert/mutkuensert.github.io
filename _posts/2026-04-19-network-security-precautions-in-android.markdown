---
layout: post
title:  "Network security precautions in Android"
date:   2026-04-19 20:00:00 +0300
categories: android
excerpt: ""
---

## Cleartext Traffic
Even though the base urls in project configurations usually starts with https, it is better to opt out of cleartext traffic as a precaution. Thus any attempt for a http connection will throw an exception that indicates cleartext traffic is not permitted. Cleartext traffic is [permitted by default](https://developer.android.com/privacy-and-security/security-config#CleartextTraffic) up to Android 8.1 (api 27).

Create a file under xml (network_security_config.xml):

To disable cleartext traffic for all connections
```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="false" />
</network-security-config>
```

To disable cleartext traffic for a specific domain name:
```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="false">
        <domain includeSubdomains="true">domain.com</domain>
    </domain-config>
</network-security-config>
```

Add it in application in AndroidManifest.xml
```xml
<application
    ...
    ...
    android:networkSecurityConfig="@xml/network_security_config">
```

- https://mas.owasp.org/MASWE/MASVS-NETWORK/MASWE-0050/
- https://mas.owasp.org/MASTG/knowledge/android/MASVS-NETWORK/MASTG-KNOW-0014/

</br>

## Certificate Transparency
Certificate transparency is a system that requires certificate authorities to submit all certificates to a public log so that domain owners can identify any certificates issued without their approval. That means, if we enforce certificate transparency for our connections, it reduces some risks like MITM attacks because domain owners that use certificate transparency can take immediate action for revoking mis-issued certificates. Still, certificate transparency doesn’t directly prevent connections with revoked certificates though.

We can enforce certificate transparency for the certificates in tls handshakes on Android 16. Unfortunately CT enforcement is not supported on Android 15 (api level 35) and lower. It's disabled on Android 16 (api level 36) by default and enabled on Android 17 (api level 37) by default.

To enable CT enforcement
```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config>
        <certificateTransparency enabled="true" />
    </base-config>
</network-security-config>
```

</br>

## OCSP - Online Certificate Status Protocol
You might encounter OCSP while doing research about network security. OCSP simply involves asking a certificate's status to the certificate authority during tls handshakes. But asking something like "Is this certificate belongs to this website?" does not coincide with privacy and ocsp responder might have performance or even a connection problem at the moment. Let's Encrypt [ended OCSP support](https://letsencrypt.org/2024/12/05/ending-ocsp) in 2025 which includes ending support for stapling features as well and it seems that internet will use Certificate Revokation List again or/and short lived certificates.

OCSP stapling is a way for servers to send their certificates along with the ocsp response together to the client so that users keep their privacy and potential connection or performance issues while requesting to ocsp responders are prevented. The ocsp response is also signed by certificate authority so that clients can verify it the same way they verify certificates.

</br>

## CRL - Certificate Revocation List
Certificate revocation list is a list of digital certificates that have been revoked by the certificate authority. Apple says that they check revoked certificates using CRL for network calls at system level:

*From [support.apple.com](https://support.apple.com/guide/security/tls-security-sec100a75d12/1/web/1), visited on April 19, 2026*
> On devices with iOS 11 or later and macOS 10.13 or later, Apple devices are periodically updated with a current list of revoked and constrained certificates. The list is aggregated from certificate revocation lists (CRLs), which are published by each of the built-in root certificate authorities trusted by Apple, as well as by their subordinate CA issuers. The list may also include other constraints at Apple’s discretion. This information is consulted whenever a network API function is used to make a secure connection.

</br>

Android doesn't directly call it CRL check but they say that they use a combination of a blocklist and certificate transparency

*From [developer.android.com](https://developer.android.com/privacy-and-security/security-ssl#certificate-validation), visited on April 19, 2026*
> To mitigate this risk, Android handles certificate revocation system-wide, through a combination of a blocklist and certificate transparency, without relying on on-line certificate verification. In addition, Android will validate OCSP responses stapled to the TLS handshake.

</br>

## Updating GMS security provider
Android [recommends](https://developer.android.com/privacy-and-security/security-gms-provider) ensuring security provider updates against SSL exploits.

To use ProviderInstaller and others
```kotlin
implementation("com.google.android.gms:play-services-base:18.10.0")
```

</br>

An example of an interceptor to block requests if the security provider is not up-to-date:

*SecurityInterceptor.kt*
```kotlin
import android.content.Context
import com.google.android.gms.common.GoogleApiAvailability
import com.google.android.gms.common.GooglePlayServicesNotAvailableException
import com.google.android.gms.common.GooglePlayServicesRepairableException
import com.google.android.gms.security.ProviderInstaller
import core.data.network.ProviderInstallerException
import core.data.network.SecurityProviderStateManager
import okhttp3.Interceptor
import okhttp3.Response
import okio.IOException
import timber.log.Timber

class SecurityProviderInterceptor(
    private val context: Context,
    private val securityProviderStateManager: SecurityProviderStateManager
) : Interceptor {
    override fun intercept(chain: Interceptor.Chain): Response {
        if (securityProviderStateManager.isChecked) return chain.proceed(chain.request())
        checkSecurityProvider()
        return chain.proceed(chain.request())
    }

    private fun checkSecurityProvider() {
        try {
            ProviderInstaller.installIfNeeded(context)
            securityProviderStateManager.isChecked = true
        } catch (e: GooglePlayServicesRepairableException) {
            GoogleApiAvailability.getInstance()
                .showErrorNotification(context, e.connectionStatusCode)

            Timber.e(e)
            throw IOException("Google Play services is out of date or disabled")

        } catch (e: GooglePlayServicesNotAvailableException) {
            Timber.e(e)
            throw IOException("Non-recoverable Google Play services error")
        }
    }
}

```

A simple class to hold the value at runtime. (Must be singleton)

*SecurityProviderStateManager.kt*
```kotlin
class SecurityProviderStateManager {
    var isChecked = false
}
```

[More info on OWASP](https://mas.owasp.org/MASTG/best-practices/MASTG-BEST-0020/)

</br>

## Certificate Pinning

Certificate pinning restricts the certificates for client's network configuration to a specified list of public keys so that any other certificate won't be accepted for tls handshakes. The downside of this method is clients have to be updated with the new public key when the certificate is renewed, otherwise connections will be blocked because tls handshake won't be successful. [While Android doesn't recommend certificate pinning, they say that multiple backup pins should be used to prevent connectivity issues if certificate pinning is used.](https://developer.android.com/privacy-and-security/security-ssl#Pinning)

Other links for certificate pinning:
- https://developer.android.com/privacy-and-security/security-config#CertificatePinning
- https://square.github.io/okhttp/3.x/okhttp/okhttp3/CertificatePinner.html

</br>

## References
- https://developer.android.com/privacy-and-security/security-ssl
- https://developer.android.com/privacy-and-security/security-config
- https://developer.android.com/privacy-and-security/certificate-transparency-policy
- https://developer.android.com/privacy-and-security/security-config#CertificateTransparencySummary
- https://auth0.com/blog/the-tls-handshake-explained/
- https://mas.owasp.org/MASWE/MASVS-NETWORK/MASWE-0050/
- https://cheatsheetseries.owasp.org/cheatsheets/HTTP_Strict_Transport_Security_Cheat_Sheet.html
- https://commandlinefanatic.com/cgi-bin/showarticle.cgi?article=art080
- https://mas.owasp.org/MASTG/knowledge/android/MASVS-NETWORK/MASTG-KNOW-0014/
- https://scotthelme.co.uk/revocation-is-broken/
- https://github.com/appmattus/certificatetransparency
- https://letsencrypt.org/2024/12/05/ending-ocsp#must-staple
- https://community.letsencrypt.org/t/whats-the-future-of-ocsp-stapling-is-crl-reintroducing-the-downtime-problem/236707/3
- https://scotthelme.co.uk/designing-a-new-security-header-expect-staple
- https://www.feistyduck.com/newsletter/issue_121_the_slow_death_of_ocsp
- https://www.feistyduck.com/newsletter/issue_123_mozilla_fixes_certificate_revocation_checking
- https://www.ssl.com/sample-valid-revoked-and-expired-ssl-tls-certificates/
- https://knowledge.digicert.com/general-information/ocsp-crl-revoked-ssl-certificates
- https://developer.android.com/privacy-and-security/security-gms-provider
- https://android.googlesource.com/platform/external/conscrypt/+/refs/heads/main/common/src/main/java/org/conscrypt/TrustManagerImpl.java
- https://android.googlesource.com/platform/frameworks/base/+/refs/heads/main/services/core/java/com/android/server/CertBlocklister.java
- https://android.googlesource.com/platform/external/conscrypt/+/refs/heads/main/platform/src/main/java/org/conscrypt/CertBlocklistImpl.java
- https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Strict-Transport-Security
- https://www.imperialviolet.org/2014/04/19/revchecking.html
- https://support.apple.com/guide/security/tls-security-sec100a75d12/1/web/1
- https://www.reddit.com/r/androiddev/comments/w1tk4a/server_tls_certificate_revocationvalidity_check/
- https://mas.owasp.org/MASTG/best-practices/MASTG-BEST-0020/