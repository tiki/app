import 'package:app/src/slices/api_company/api_company_service.dart';
import 'package:app/src/slices/api_google/api_google_service.dart';
import 'package:app/src/slices/api_message/api_message_service.dart';
import 'package:app/src/slices/api_message/model/api_message_fetched_model.dart';
import 'package:app/src/slices/api_sender/api_sender_service.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:googleapis/gmail/v1.dart';

class ApiBackgroundService {
  final ApiCompanyService companyService;
  final ApiGoogleService googleService;
  final ApiSenderService senderService;
  final ApiMessageService messageService;

  ApiBackgroundService(
      {required this.googleService,
      required this.companyService,
      required this.senderService,
      required this.messageService});

  void registerAndroidHeadlessTask(HeadlessTask task) async {
    String taskId = task.taskId;
    bool isTimeout = task.timeout;
    if (isTimeout) {
      print(
          "[BackgroundFetch] Headless task timed-out: $taskId"); // TODO send to Sentry
      BackgroundFetch.finish(taskId);
      return;
    }
    await fetchGoogleEmails(); // TODO add a scheduler for multiples tasks
    BackgroundFetch.finish(taskId);
  }

  Future<void> initBackgroundFetch() async {
    BackgroundFetch.registerHeadlessTask(registerAndroidHeadlessTask);
    await BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 1440,
            stopOnTerminate: false,
            enableHeadless: true,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresStorageNotLow: false,
            requiresDeviceIdle: false,
            requiredNetworkType: NetworkType.NONE), (String taskId) async {
      print("[BackgroundFetch] Event received $taskId");
      await fetchGoogleEmails(); // TODO add a scheduler for multiples tasks
      BackgroundFetch.finish(taskId);
    }, (String taskId) async {
      print(
          "[BackgroundFetch] TASK TIMEOUT taskId: $taskId"); // TODO send to Sentry and record last fetched message
      BackgroundFetch.finish(taskId);
    });
  }

  Future<void> fetchGoogleEmails() async {
    var messagesMeta = await googleService.fetchGmailMessagesMetadata();
    List<Message> messages = [];
    for (var messageMeta in messagesMeta) {
      var message =
          await googleService.fetchAndProcessGmailMessage(messageMeta);
      if (message != null) messages.add(message);
    }
    for (var message in messages) {
      var fetchedModel = googleService.processEmailListMessage(message);
      var companyId = saveCompany(fetchedModel.domain);
      fetchedModel.senderData['company_id'] = companyId;
      var senderId = saveSender(fetchedModel);
      fetchedModel.senderData['sender_id'] = senderId;
      saveMessage(fetchedModel);
    }
  }

  saveCompany(String domain) async {
    var companyId = await companyService.createOrUpdate(domain);
    return companyId;
  }

  saveSender(ApiMessageFetchedModel fetchedModel) async {
    return await senderService.createOrUpdate(fetchedModel);
  }

  saveMessage(ApiMessageFetchedModel fetchedModel) async {
    return await messageService.save(fetchedModel);
  }
}
