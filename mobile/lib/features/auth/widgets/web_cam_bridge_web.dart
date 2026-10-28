// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:js' as js;

html.EventListener? _listener;

void startRealWebcamScan() {
  try {
    js.context.callMethod('startRealCameraScan');
  } catch (e) {
    // ignore
  }
}

void stopRealWebcamScan() {
  try {
    js.context.callMethod('stopRealCameraScan');
  } catch (e) {
    // ignore
  }
}

void triggerCardPhotoUpload() {
  try {
    js.context.callMethod('triggerHtmlCardUpload');
  } catch (e) {
    // ignore
  }
}

void listenForCardScan(void Function(String code) onScan) {
  stopListeningForCardScan();
  _listener = (html.Event event) {
    if (event is html.CustomEvent && event.detail != null) {
      onScan(event.detail.toString());
    }
  };
  html.window.addEventListener('card_scanned_event', _listener);
}

void stopListeningForCardScan() {
  if (_listener != null) {
    html.window.removeEventListener('card_scanned_event', _listener);
    _listener = null;
  }
}
