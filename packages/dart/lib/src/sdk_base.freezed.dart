// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named

part of 'sdk_base.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

class _$_MessageTearOff {
  const _$_MessageTearOff();

  __Message _(
      String id,
      String senderId,
      @nullable String text,
      DateTime createdAt,
      @nullable DateTime updatedAt,
      MessageStatus status,
      List<UserMessageStatus> statusDetails,
      Map<String, dynamic> metadata) {
    return __Message(
      id,
      senderId,
      text,
      createdAt,
      updatedAt,
      status,
      statusDetails,
      metadata,
    );
  }
}

// ignore: unused_element
const _$Message = _$_MessageTearOff();

mixin _$_Message {
  String get id;
  String get senderId;
  @nullable
  String get text;
  DateTime get createdAt;
  @nullable
  DateTime get updatedAt;
  MessageStatus get status;
  List<UserMessageStatus> get statusDetails;
  Map<String, dynamic> get metadata;

  _$MessageCopyWith<_Message> get copyWith;
}

abstract class _$MessageCopyWith<$Res> {
  factory _$MessageCopyWith(_Message value, $Res Function(_Message) then) =
      __$MessageCopyWithImpl<$Res>;
  $Res call(
      {String id,
      String senderId,
      @nullable String text,
      DateTime createdAt,
      @nullable DateTime updatedAt,
      MessageStatus status,
      List<UserMessageStatus> statusDetails,
      Map<String, dynamic> metadata});
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
    Object updatedAt = freezed,
    Object status = freezed,
    Object statusDetails = freezed,
    Object metadata = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed ? _value.id : id as String,
      senderId: senderId == freezed ? _value.senderId : senderId as String,
      text: text == freezed ? _value.text : text as String,
      createdAt:
          createdAt == freezed ? _value.createdAt : createdAt as DateTime,
      updatedAt:
          updatedAt == freezed ? _value.updatedAt : updatedAt as DateTime,
      status: status == freezed ? _value.status : status as MessageStatus,
      statusDetails: statusDetails == freezed
          ? _value.statusDetails
          : statusDetails as List<UserMessageStatus>,
      metadata: metadata == freezed
          ? _value.metadata
          : metadata as Map<String, dynamic>,
    ));
  }
}

abstract class _$_MessageCopyWith<$Res> implements _$MessageCopyWith<$Res> {
  factory _$_MessageCopyWith(__Message value, $Res Function(__Message) then) =
      __$_MessageCopyWithImpl<$Res>;
  @override
  $Res call(
      {String id,
      String senderId,
      @nullable String text,
      DateTime createdAt,
      @nullable DateTime updatedAt,
      MessageStatus status,
      List<UserMessageStatus> statusDetails,
      Map<String, dynamic> metadata});
}

class __$_MessageCopyWithImpl<$Res> extends __$MessageCopyWithImpl<$Res>
    implements _$_MessageCopyWith<$Res> {
  __$_MessageCopyWithImpl(__Message _value, $Res Function(__Message) _then)
      : super(_value, (v) => _then(v as __Message));

  @override
  __Message get _value => super._value as __Message;

  @override
  $Res call({
    Object id = freezed,
    Object senderId = freezed,
    Object text = freezed,
    Object createdAt = freezed,
    Object updatedAt = freezed,
    Object status = freezed,
    Object statusDetails = freezed,
    Object metadata = freezed,
  }) {
    return _then(__Message(
      id == freezed ? _value.id : id as String,
      senderId == freezed ? _value.senderId : senderId as String,
      text == freezed ? _value.text : text as String,
      createdAt == freezed ? _value.createdAt : createdAt as DateTime,
      updatedAt == freezed ? _value.updatedAt : updatedAt as DateTime,
      status == freezed ? _value.status : status as MessageStatus,
      statusDetails == freezed
          ? _value.statusDetails
          : statusDetails as List<UserMessageStatus>,
      metadata == freezed ? _value.metadata : metadata as Map<String, dynamic>,
    ));
  }
}

class _$__Message implements __Message {
  const _$__Message(this.id, this.senderId, @nullable this.text, this.createdAt,
      @nullable this.updatedAt, this.status, this.statusDetails, this.metadata)
      : assert(id != null),
        assert(senderId != null),
        assert(createdAt != null),
        assert(status != null),
        assert(statusDetails != null),
        assert(metadata != null);

  @override
  final String id;
  @override
  final String senderId;
  @override
  @nullable
  final String text;
  @override
  final DateTime createdAt;
  @override
  @nullable
  final DateTime updatedAt;
  @override
  final MessageStatus status;
  @override
  final List<UserMessageStatus> statusDetails;
  @override
  final Map<String, dynamic> metadata;

  @override
  String toString() {
    return '_Message._(id: $id, senderId: $senderId, text: $text, createdAt: $createdAt, updatedAt: $updatedAt, status: $status, statusDetails: $statusDetails, metadata: $metadata)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is __Message &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.senderId, senderId) ||
                const DeepCollectionEquality()
                    .equals(other.senderId, senderId)) &&
            (identical(other.text, text) ||
                const DeepCollectionEquality().equals(other.text, text)) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality()
                    .equals(other.createdAt, createdAt)) &&
            (identical(other.updatedAt, updatedAt) ||
                const DeepCollectionEquality()
                    .equals(other.updatedAt, updatedAt)) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.statusDetails, statusDetails) ||
                const DeepCollectionEquality()
                    .equals(other.statusDetails, statusDetails)) &&
            (identical(other.metadata, metadata) ||
                const DeepCollectionEquality()
                    .equals(other.metadata, metadata)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(senderId) ^
      const DeepCollectionEquality().hash(text) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(updatedAt) ^
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(statusDetails) ^
      const DeepCollectionEquality().hash(metadata);

  @override
  _$_MessageCopyWith<__Message> get copyWith =>
      __$_MessageCopyWithImpl<__Message>(this, _$identity);
}

abstract class __Message implements _Message {
  const factory __Message(
      String id,
      String senderId,
      @nullable String text,
      DateTime createdAt,
      @nullable DateTime updatedAt,
      MessageStatus status,
      List<UserMessageStatus> statusDetails,
      Map<String, dynamic> metadata) = _$__Message;

  @override
  String get id;
  @override
  String get senderId;
  @override
  @nullable
  String get text;
  @override
  DateTime get createdAt;
  @override
  @nullable
  DateTime get updatedAt;
  @override
  MessageStatus get status;
  @override
  List<UserMessageStatus> get statusDetails;
  @override
  Map<String, dynamic> get metadata;
  @override
  _$_MessageCopyWith<__Message> get copyWith;
}
