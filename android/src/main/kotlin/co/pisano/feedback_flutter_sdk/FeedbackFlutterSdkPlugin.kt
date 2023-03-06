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
import android.util.Log
import co.pisano.feedback.data.helper.ViewMode
import co.pisano.feedback.data.model.Title

/** FeedbackFlutterSdkPlugin */
class FeedbackFlutterSdkPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var actionCallback: ((PisanoActions) -> Unit)? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "feedback_flutter_sdk")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            "init" -> {
                val manager = PisanoSDKManager.Builder(context)
                    .setApplicationId(call.argument<String>("applicationId"))
                    .setAccessKey(call.argument<String>("accessKey"))
                    .setApiUrl(call.argument<String>("apiUrl"))
                    .setFeedbackUrl(call.argument<String>("feedbackUrl"))
                    .setEventUrl(call.argument<String?>("eventUrl"))
                    .setCloseStatusCallback(object : ActionListener {
                        override fun action(action: PisanoActions) {
                            actionCallback?.invoke(action)
                        }
                    })
                    .build()
                PisanoSDK.init(manager)
            }
            "show" -> {
                val viewMode: ViewMode = ViewMode.parse(call.argument<Int>("viewMode") ?: 0) ?: ViewMode.DEFAULT
                var title: Title? = null
                val payload = call.argument<HashMap<String, String>>("payload")
                val customer = call.argument<HashMap<String, Any>>("customer")

                val titleArg = call.argument<String?>("title")
                if (!titleArg.isNullOrBlank()) {
                    title = Title(text = titleArg, textSize = call.argument<Int?>("titleFontSize")?.toFloat())
                }

                val customerModel = PisanoCustomer(
                    name = customer?.get("name") as? String,
                    externalId = customer?.get("externalId") as? String,
                    email = customer?.get("email") as? String,
                    phoneNumber = customer?.get("phoneNumber") as? String,
                    customAttributes = customer?.get("customAttrs") as? java.util.HashMap<String, Any>
                )

                PisanoSDK.show(
                    viewMode = viewMode,
                    title = title,
                    flowId = call.argument<String?>("flowId"),
                    language = call.argument<String?>("language"),
                    payload = payload,
                    pisanoCustomer = customerModel
                )

                actionCallback = {
                    if (it != PisanoActions.OPENED) {
                        result.success(it.ordinal + 1)
                    }
                }
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

                actionCallback = {
                    if (it != PisanoActions.OPENED) {
                        result.success(it.ordinal + 1)
                    }
                }
            }
            "clear" -> {
                PisanoSDK.clearAction()
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
