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
    private var isResultReturned = false

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "feedback_flutter_sdk")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        isResultReturned = false

        try {
            when (call.method) {
                "getPlatformVersion" -> {
                    result.success("Android ${android.os.Build.VERSION.RELEASE}")
                }

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
                    result.success(null)
                }

                "show" -> {
                    val viewMode: ViewMode = ViewMode.parse(call.argument<Int>("viewMode") ?: 0) ?: ViewMode.DEFAULT
                    val payload = call.argument<HashMap<String, String>>("payload")
                    val customer = call.argument<HashMap<String, Any>>("customer")

                    val titleArg = call.argument<String?>("title")
                    val title = if (!titleArg.isNullOrBlank()) {
                        Title(text = titleArg, textSize = call.argument<Int?>("titleFontSize")?.toFloat())
                    } else {
                        null
                    }

                    val customerModel = buildPisanoCustomer(customer)

                    PisanoSDK.show(
                        viewMode = viewMode,
                        title = title,
                        flowId = call.argument<String?>("flowId"),
                        language = call.argument<String?>("language"),
                        payload = payload,
                        pisanoCustomer = customerModel
                    )

                    actionCallback = { action ->
                        if (!isResultReturned && action != PisanoActions.OPENED) {
                            result.success(action.ordinal + 1)
                            isResultReturned = true
                            actionCallback = null
                        }
                    }
                }

                "track" -> {
                    val props = call.argument<HashMap<String, Any>>("props")
                    val payload = call.argument<HashMap<String, String>>("payload")
                    val customer = call.argument<HashMap<String, Any>>("customer")
                    val explicitEvent = call.argument<String>("event")

                    val eventName = explicitEvent ?: (props?.get("event") as? String)
                    if (eventName.isNullOrBlank()) {
                        result.error("INVALID_ARGUMENT", "event cannot be empty", null)
                        return
                    }

                    val customerModel = buildPisanoCustomer(customer)

                    PisanoSDK.track(
                        event = eventName,
                        payload = payload,
                        pisanoCustomer = customerModel
                    )

                    actionCallback = { action ->
                        if (!isResultReturned && action != PisanoActions.OPENED) {
                            result.success(action.ordinal + 1)
                            isResultReturned = true
                            actionCallback = null
                        }
                    }
                }

                "clear" -> {
                    PisanoSDK.clearAction()
                    result.success(null)
                }

                else -> {
                    result.notImplemented()
                }
            }
        } catch (e: Exception) {
            Log.e("FeedbackFlutterSdk", "An error occured: ${e.message}", e)
            result.error("ERROR", "An error occured during the process: ${e.message}", null)
        }
    }


    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun buildPisanoCustomer(customer: HashMap<String, Any>?): PisanoCustomer {
        val customAttributes = customer?.get("customAttrs") as? HashMap<String, Any>

        return PisanoCustomer(
            name = customer?.get("name") as? String,
            externalId = customer?.get("externalId") as? String,
            email = customer?.get("email") as? String,
            phoneNumber = customer?.get("phoneNumber") as? String,
            customAttributes = customAttributes
        )
    }
}
