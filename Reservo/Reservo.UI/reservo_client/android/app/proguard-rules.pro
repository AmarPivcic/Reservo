# Keep Stripe push provisioning classes so R8 doesn't strip them
-keep class com.stripe.android.pushProvisioning.** { *; }
-keep class com.reactnativestripesdk.pushprovisioning.** { *; }
-keep interface com.stripe.android.pushProvisioning.EphemeralKeyUpdateListener { *; }

# Suppress warnings for missing classes (optional, but recommended)
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider
-dontwarn com.stripe.android.pushProvisioning.EphemeralKeyUpdateListener
