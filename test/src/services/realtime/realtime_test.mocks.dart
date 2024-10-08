// Mocks generated by Mockito 5.4.4 from annotations
// in realtime/test/src/services/realtime/realtime_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:mockito/mockito.dart' as _i1;
import 'package:realtime/src/interfaces/params/params.dart' as _i3;
import 'package:realtime/src/interfaces/socket_client.dart' as _i2;
import 'package:realtime/src/types/types.dart' as _i4;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [SocketClient].
///
/// See the documentation for Mockito's code generation for more information.
class MockSocketClient extends _i1.Mock implements _i2.SocketClient {
  MockSocketClient() {
    _i1.throwOnMissingStub(this);
  }

  @override
  void connect(_i3.SocketConnectParams? connectionParams) => super.noSuchMethod(
        Invocation.method(
          #connect,
          [connectionParams],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void emit(
    String? event, [
    dynamic data,
  ]) =>
      super.noSuchMethod(
        Invocation.method(
          #emit,
          [
            event,
            data,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onEvent(
    String? event,
    _i4.EventHandler? handlerCallback,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #onEvent,
          [
            event,
            handlerCallback,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void offEvent(
    String? event, [
    _i4.EventHandler? handlerCallback,
  ]) =>
      super.noSuchMethod(
        Invocation.method(
          #offEvent,
          [
            event,
            handlerCallback,
          ],
        ),
        returnValueForMissingStub: null,
      );
}
