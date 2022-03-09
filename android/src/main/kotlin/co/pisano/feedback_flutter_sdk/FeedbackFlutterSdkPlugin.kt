package co.pisano.feedback_flutter_sdk

import android.content.Context
import androidx.annotation.NonNull
import co.pisano.feedback.data.helper.ActionListener
import co.pisano.feedback.data.helper.PisanoActions
import co.pisano.feedback.data.model.PisanoCustomer
import co.pisano.feedback.managers.PisanoSDK
import co.pisano.feedback.managers.PisanoSDKManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FeedbackFlutterSdkPlugin */
class FeedbackFlutterSdkPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "feedback_flutter_sdk")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            "init" -> {
                val props = call.argument<HashMap<String, Any>>("props")
                val manager = PisanoSDKManager.Builder(context)
                    .setApplicationId(props?.get("applicationId") as? String)
                    .setAccessKey(props?.get("accessKey") as? String)
                    .setApiUrl(props?.get("apiUrl") as? String)
                    .setFeedbackUrl(props?.get("feedbackUrl") as? String)
                    .setEventUrl(props?.get("eventUrl") as? String)
                    .setCloseStatusCallback(object : ActionListener {
                        override fun action(action: PisanoActions) {

                        }
                    })
                    .build()
                PisanoSDK.init(manager)
            }
            "show" -> {
                val props = call.argument<HashMap<String, Any>>("props")
                val payload = call.argument<HashMap<String, String>>("payload")
                val customer = call.argument<HashMap<String, Any>>("customer")

                val customAttributes = java.util.HashMap<String, Any>()
                customer?.keys?.forEach { key ->
                    customAttributes[key] = customer?.get(key) as Any
                }

                val customerModel = PisanoCustomer(
                    name = customer?.get("name") as? String,
                    externalId = customer?.get("externalId") as? String,
                    email = customer?.get("email") as? String,
                    phoneNumber = customer?.get("phoneNumber") as? String,
                    customAttributes = customAttributes
                )

                PisanoSDK.show(
                    flowId = props?.get("flowId") as? String,
                    language = props?.get("language") as? String,
                    payload = payload,
                    pisanoCustomer = customerModel
                )
            }
            "track" -> {
                val props = call.argument<HashMap<String, Any>>("props")
                val payload = call.argument<HashMap<String, String>>("payload")
                val customer = call.argument<HashMap<String, Any>>("customer")

                val customAttributes = java.util.HashMap<String, Any>()
                customer?.keys?.forEach { key ->
                    customAttributes[key] = customer?.get(key) as Any
                }

                val customerModel = PisanoCustomer(
                    name = customer?.get("name") as? String,
                    externalId = customer?.get("externalId") as? String,
                    email = customer?.get("email") as? String,
                    phoneNumber = customer?.get("phoneNumber") as? String,
                    customAttributes = customAttributes
                )

                PisanoSDK.track(
                    event = (props?.get("event") as? String) ?: "",
                    payload = payload,
                    pisanoCustomer = customerModel
                )
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
