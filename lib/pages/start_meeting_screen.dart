///
/// Created by Auro (aurosmruti@smarttersstudio.com) on 5/3/21 at 2:45 PM
///

import 'dart:async';
import 'dart:io';

// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_zoom_plugin/zoom_view.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_zoom_plugin/zoom_options.dart';

import 'package:flutter/material.dart';
// import 'package:zoom_lutter/config/keys.dart';

class StartMeetingWidget extends StatelessWidget {
  late ZoomOptions zoomOptions;
  late ZoomMeetingOptions meetingOptions;

  late Timer timer;

  StartMeetingWidget({Key? key, meetingId}) : super(key: key) {
    this.zoomOptions = new ZoomOptions(
      domain: "zoom.us",
      appKey: "ZoomConfig.apiKey",
      appSecret: "ZoomConfig.apiSecret",
    );
    this.meetingOptions = new ZoomMeetingOptions(
        userId: '<zoom_user_id>',
        displayName: 'Example display Name',
        meetingId: meetingId,
        zoomAccessToken: "<User zak>",
        zoomToken: "<user_token>",
        disableDialIn: "true",
        disableDrive: "true",
        disableInvite: "true",
        disableShare: "true",
        noAudio: "false",
        noDisconnectAudio: "false");
  }

  bool _isMeetingEnded(String status) {
    var result = false;

    if (Platform.isAndroid)
      result = status == "MEETING_STATUS_DISCONNECTING" ||
          status == "MEETING_STATUS_FAILED";
    else
      result = status == "MEETING_STATUS_IDLE";

    return result;
  }

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    return Scaffold(
      appBar: AppBar(
        title: Text('Loading meeting '),
      ),
      body: Padding(
          padding: EdgeInsets.all(16.0),
          child: ZoomView(onViewCreated: (controller) {
            print("Created the view");

            controller.initZoom(this.zoomOptions).then((results) {
              print("initialised");
              print(results);

              if (results[0] == 0) {
                controller.zoomStatusEvents.listen((status) {
                  print("Meeting Status Stream: " +
                      status[0] +
                      " - " +
                      status[1]);
                  if (_isMeetingEnded(status[0])) {
                    Navigator.pop(context);
                    timer.cancel();
                  }
                });

                print("listen on event channel");

                controller
                    .startMeeting(this.meetingOptions)
                    .then((joinMeetingResult) {
                  timer = Timer.periodic(new Duration(seconds: 2), (timer) {
                    controller
                        .meetingStatus(this.meetingOptions.meetingId)
                        .then((status) {
                      print("Meeting Status Polling: " +
                          status[0] +
                          " - " +
                          status[1]);
                    });
                  });
                });
              }
            }).catchError((error) {
              print("Error");
              print(error);
            });
          })),
    );
  }
}
