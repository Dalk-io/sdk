// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named

part of 'sdk_base.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

class _$_MessageTearOff {
  const _$_MessageTearOff();

  __Message _(String id, String senderId, String text, DateTime createdAt, MessageStatus status, List<UserMessageStatus> statusDetails) {
    return __Message(
      id,
      senderId,
      text,
      createdAt,
      status,
      statusDetails,
    );
  }
}

// ignore: unused_element
const _$Message = _$_MessageTearOff();

mixin _$_Message {
  String get id;

  String get senderId;

  String get text;

  DateTime get createdAt;

  MessageStatus get status;

  List<UserMessageStatus> get statusDetails;

  _$MessageCopyWith<_Message> get copyWith;
}

abstract class _$MessageCopyWith<$Res> {
  factory _$MessageCopyWith(_Message value, $Res Function(_Message) then) = __$MessageCopyWithImpl<$Res>;

  $Res call({String id, String senderId, String text, DateTime createdAt, MessageStatus status, List<UserMessageStatus> statusDetails});
}

class __$MessageCopyWithImpl<$Res> implements _$MessageCopyWith<$Res> {
  __$MessageCopyWithImpl(this._value, this._then);

  final _Message _value;

  // ignore: unused_field
  final $Res Function(_Message) _then;

  @override
  $Res call({
    Object id = freezed,
    Object senderId = freezed,
    Object text = freezed,
    Object createdAt = freezed,
    Object status = freezed,
    Object statusDetails = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed ? _value.id : id as String,
      senderId: senderId == freezed ? _value.senderId : senderId as String,
      text: text == freezed ? _value.text : text as String,
      createdAt: createdAt == freezed ? _value.createdAt : createdAt as DateTime,
      status: status == freezed ? _value.status : status as MessageStatus,
      statusDetails: statusDetails == freezed ? _value.statusDetails : statusDetails as List<UserMessageStatus>,
    ));
  }
}

abstract class _$_MessageCopyWith<$Res> implements _$MessageCopyWith<$Res> {
  factory _$_MessageCopyWith(__Message value, $Res Function(__Message) then) = __$_MessageCopyWithImpl<$Res>;

  @override
  $Res call({String id, String senderId, String text, DateTime createdAt, MessageStatus status, List<UserMessageStatus> statusDetails});
}

class __$_MessageCopyWithImpl<$Res> extends __$MessageCopyWithImpl<$Res> implements _$_MessageCopyWith<$Res> {
  __$_MessageCopyWithImpl(__Message _value, $Res Function(__Message) _then) : super(_value, (v) => _then(v as __Message));

  @override
  __Message get _value => super._value as __Message;

  @override
  $Res call({
    Object id = freezed,
    Object senderId = freezed,
    Object text = freezed,
    Object createdAt = freezed,
    Object status = freezed,
    Object statusDetails = freezed,
  }) {
    return _then(__Message(
      id == freezed ? _value.id : id as String,
      senderId == freezed ? _value.senderId : senderId as String,
      text == freezed ? _value.text : text as String,
      createdAt == freezed ? _value.createdAt : createdAt as DateTime,
      status == freezed ? _value.status : status as MessageStatus,
      statusDetails == freezed ? _value.statusDetails : statusDetails as List<UserMessageStatus>,
    ));
  }
}

class _$__Message implements __Message {
  const _$__Message(this.id, this.senderId, this.text, this.createdAt, this.status, this.statusDetails)
      : assert(id != null),
        assert(senderId != null),
        assert(text != null),
        assert(createdAt != null),
        assert(status != null),
        assert(statusDetails != null);

  @override
  final String id;
  @override
  final String senderId;
  @override
  final String text;
  @override
  final DateTime createdAt;
  @override
  final MessageStatus status;
  @override
  final List<UserMessageStatus> statusDetails;

  @override
  String toString() {
    return '_Message._(id: $id, senderId: $senderId, text: $text, createdAt: $createdAt, status: $status, statusDetails: $statusDetails)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is __Message &&
            (identical(other.id, id) || const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.senderId, senderId) || const DeepCollectionEquality().equals(other.senderId, senderId)) &&
            (identical(other.text, text) || const DeepCollectionEquality().equals(other.text, text)) &&
            (identical(other.createdAt, createdAt) || const DeepCollectionEquality().equals(other.createdAt, createdAt)) &&
            (identical(other.status, status) || const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.statusDetails, statusDetails) || const DeepCollectionEquality().equals(other.statusDetails, statusDetails)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(senderId) ^
      const DeepCollectionEquality().hash(text) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(statusDetails);

  @override
  _$_MessageCopyWith<__Message> get copyWith => __$_MessageCopyWithImpl<__Message>(this, _$identity);
}

abstract class __Message implements _Message {
  const factory __Message(String id, String senderId, String text, DateTime createdAt, MessageStatus status, List<UserMessageStatus> statusDetails) =
      _$__Message;

  @override
  String get id;

  @override
  String get senderId;

  @override
  String get text;

  @override
  DateTime get createdAt;

  @override
  MessageStatus get status;

  @override
  List<UserMessageStatus> get statusDetails;

  @override
  _$_MessageCopyWith<__Message> get copyWith;
}
