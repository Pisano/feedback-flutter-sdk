package co.pisano.feedback_flutter_sdk

import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import co.pisano.feedback.data.helper.CloseStatus
import co.pisano.feedback.data.helper.PisanoCloseReason
import co.pisano.feedback.data.helper.PisanoEvent
import co.pisano.feedback.data.helper.PisanoEventType
import co.pisano.feedback.data.helper.PisanoSubscription
import co.pisano.feedback.data.helper.ViewMode
import co.pisano.feedback.data.model.PisanoCustomer
import co.pisano.feedback.data.model.Title
import co.pisano.feedback.managers.PisanoSDK
import co.pisano.feedback.managers.PisanoSDKManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class FeedbackFlutterSdkPlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var context: Context

    private var eventSubscription: PisanoSubscription? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "feedback_flutter_sdk")
        channel.setMethodCallHandler(this)
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "feedback_flutter_sdk/events")
        eventChannel.setStreamHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        try {
            when (call.method) {
                "getPlatformVersion" -> {
                    result.success("Android ${android.os.Build.VERSION.RELEASE}")
                }

                "init" -> {
                    // The builder throws on an empty applicationId / accessKey /
                    // code; that is a failed boot, not a crash.
                    val manager = try {
                        PisanoSDKManager.Builder(context)
                            .setApplicationId(call.argument<String>("applicationId"))
                            .setAccessKey(call.argument<String>("accessKey"))
                            .setCode(call.argument<String>("code"))
                            .setApiUrl(call.argument<String>("apiUrl"))
                            .setFeedbackUrl(call.argument<String>("feedbackUrl"))
                            .setEventUrl(call.argument<String?>("eventUrl"))
                            .setDebug(call.argument<Boolean>("debugLogging") ?: false)
                            .build()
                    } catch (e: Exception) {
                        Log.e(TAG, "init: invalid configuration: ${e.message}")
                        result.success(false)
                        return
                    }
                    PisanoSDK.init(manager) { succeeded -> result.success(succeeded) }
                }

                "show" -> {
                    // One result per call. The native SDK opens one survey at a
                    // time: a show() while one is open or about to open ends with NONE.
                    val viewMode: ViewMode = ViewMode.parse(call.argument<Int>("viewMode") ?: 0) ?: ViewMode.DEFAULT
                    val titleArg = call.argument<String?>("title")
                    val title = if (!titleArg.isNullOrBlank()) {
                        Title(text = titleArg, textSize = call.argument<Int?>("titleFontSize")?.toFloat())
                    } else {
                        null
                    }

                    PisanoSDK.show(
                        viewMode = viewMode,
                        title = title,
                        code = call.argument<String?>("code"),
                        language = call.argument<String?>("language"),
                        payload = call.argument<HashMap<String, String>>("payload"),
                        pisanoCustomer = buildPisanoCustomer(call.argument<Map<String, Any?>>("customer")),
                        dismissOnDrag = call.argument<Boolean>("dismissOnDrag") ?: false,
                    ) { status -> result.success(resultName(status)) }
                }

                "healthCheck" -> {
                    PisanoSDK.healthCheck(
                        language = call.argument<String?>("language"),
                        payload = call.argument<HashMap<String, String>>("payload"),
                        pisanoCustomer = buildPisanoCustomer(call.argument<Map<String, Any?>>("customer")),
                        code = call.argument<String?>("code"),
                    ) { canShow -> result.success(canShow) }
                }

                "track" -> {
                    val eventName = call.argument<String>("event")
                    if (eventName.isNullOrBlank()) {
                        result.error("INVALID_ARGUMENT", "event cannot be empty", null)
                        return
                    }

                    PisanoSDK.track(
                        event = eventName,
                        payload = call.argument<HashMap<String, String>>("payload"),
                        pisanoCustomer = buildPisanoCustomer(call.argument<Map<String, Any?>>("customer")),
                        languageCode = call.argument<String?>("language"),
                    ) { sent -> result.success(sent) }
                }

                "setAutomaticStoreReview" -> {
                    PisanoSDK.automaticStoreReview = call.argument<Boolean>("enabled") ?: true
                    result.success(null)
                }

                "setRequestTimeout" -> {
                    call.argument<Number>("seconds")?.let { PisanoSDK.requestTimeout = it.toLong() }
                    result.success(null)
                }

                "clear" -> {
                    // Closes an open survey and ends a pending show() with NONE.
                    PisanoSDK.clear()
                    result.success(null)
                }

                else -> {
                    result.notImplemented()
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "An error occured: ${e.message}", e)
            if (call.method == "show") {
                result.success(resultName(CloseStatus.NONE))
            } else {
                result.error("ERROR", "An error occured during the process: ${e.message}", null)
            }
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        eventSubscription?.cancel()
        eventSubscription = PisanoSDK.subscribe { event -> events.success(eventMap(event)) }
    }

    override fun onCancel(arguments: Any?) {
        eventSubscription?.cancel()
        eventSubscription = null
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        eventSubscription?.cancel()
        eventSubscription = null
    }

    companion object {
        private const val TAG = "FeedbackFlutterSdk"

        /** `CloseStatus` -> the Dart `FeedbackCallback` name. By name, never by ordinal. */
        fun resultName(status: CloseStatus): String =
            when (status) {
                CloseStatus.NONE -> "none"
                CloseStatus.CLOSED -> "closed"
                CloseStatus.SEND_FEEDBACK -> "sendFeedback"
                CloseStatus.DISPLAY_ONCE -> "displayOnce"
                CloseStatus.PREVENT_MULTIPLE_FEEDBACK -> "preventMultipleFeedback"
                CloseStatus.CHANNEL_QUOTA_EXCEEDED -> "channelQuotaExceeded"
                CloseStatus.CHANNEL_PASSIVE -> "channelPassive"
                CloseStatus.DISPLAY_RATE_LIMITED -> "displayRateLimited"
            }

        /** `PisanoEvent` -> the map `PisanoEvent.fromMap` reads in Dart. */
        fun eventMap(event: PisanoEvent): Map<String, Any?> =
            mapOf(
                "type" to when (event.type) {
                    PisanoEventType.OPENED -> "opened"
                    PisanoEventType.FEEDBACK_SUBMITTED -> "feedbackSubmitted"
                    PisanoEventType.REDIRECTED_TO_STORE -> "redirectedToStore"
                    PisanoEventType.CLOSED -> "closed"
                },
                "code" to event.code,
                "hasChat" to event.hasChat,
                "closeReason" to when (event.closeReason) {
                    PisanoCloseReason.CLOSE_BUTTON -> "closeButton"
                    PisanoCloseReason.BACK -> "back"
                    PisanoCloseReason.DRAG -> "drag"
                    PisanoCloseReason.OUTSIDE -> "outside"
                    PisanoCloseReason.AFTER_SUBMIT -> "afterSubmit"
                    PisanoCloseReason.CLEAR -> "clear"
                    PisanoCloseReason.LOAD_FAILED -> "loadFailed"
                    PisanoCloseReason.HOST_DISMISSED -> "hostDismissed"
                    null -> null
                },
                "handledBySDK" to event.handledBySDK,
            )

        /**
         * The customer map (keys already mapped onto the PisanoCustomer field
         * names in Dart, `normalizeCustomer`) as the native customer; null when no
         * field is set.
         */
        fun buildPisanoCustomer(customer: Map<String, Any?>?): PisanoCustomer? {
            if (customer == null) return null
            fun string(key: String) = (customer[key] as? String)?.takeIf { it.isNotEmpty() }

            @Suppress("UNCHECKED_CAST")
            val customAttributes = (customer["customAttributes"] as? Map<String, Any>)?.let { HashMap(it) }
            val pisanoCustomer = PisanoCustomer(
                name = string("name"),
                externalId = string("externalId"),
                email = string("email"),
                phoneNumber = string("phoneNumber"),
                customAttributes = customAttributes,
            )
            return pisanoCustomer.takeUnless { it == PisanoCustomer() }
        }
    }
}
