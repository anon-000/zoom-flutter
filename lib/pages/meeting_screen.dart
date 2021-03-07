///
/// Created by Auro (aurosmruti@smarttersstudio.com) on 5/3/21 at 2:36 PM
///

import 'dart:async';
import 'dart:io';

import 'package:flutter_zoom_plugin/zoom_view.dart';
import 'package:flutter_zoom_plugin/zoom_options.dart';

import 'package:flutter/material.dart';
import 'package:zoom_lutter/config/keys.dart';

class MeetingWidget extends StatefulWidget {
  ZoomOptions zoomOptions;
  ZoomMeetingOptions meetingOptions;

  MeetingWidget({Key key, meetingId, meetingPassword}) : super(key: key) {
    this.zoomOptions = new ZoomOptions(
      domain: "zoom.us",
      appKey: ZoomConfig.apiKey,
      appSecret: ZoomConfig.apiSecret,
    );
    this.meetingOptions = new ZoomMeetingOptions(
      userId: 'flutter client',
      meetingId: meetingId,
      meetingPassword: meetingPassword,
      disableDialIn: "true",
      disableDrive: "true",
      disableInvite: "true",
      disableShare: "true",
      noAudio: "false",
      noDisconnectAudio: "false",
    );
  }

  @override
  _MeetingWidgetState createState() => _MeetingWidgetState();
}

class _MeetingWidgetState extends State<MeetingWidget> {
  Timer timer;

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
  void dispose() {

    super.dispose();
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
          child: ZoomView(
            onViewCreated: (controller) {
              print("Created the view");

              controller.initZoom(this.widget.zoomOptions).then((results) {
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
                      timer?.cancel();
                    }
                  });

                  print("listen on event channel");

                  controller
                      .joinMeeting(this.widget.meetingOptions)
                      .then((joinMeetingResult) {
                    timer = Timer.periodic(new Duration(seconds: 2), (timer) {
                      controller
                          .meetingStatus(this.widget.meetingOptions.meetingId)
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
            },
            zoomOptions: widget.zoomOptions,
            meetingOptions: widget.meetingOptions,
          )),
    );
  }
}
