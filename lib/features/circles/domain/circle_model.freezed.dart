// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'circle_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CircleModel {

 String get id; String get name; String get description; String get code;// 7-char alphanumeric
 String get currency; String? get imageUrl; List<String> get memberIds; List<String> get pendingMemberIds; List<String> get adminIds; String get createdBy; DateTime get createdAt; bool get isPendingDelete;
/// Create a copy of CircleModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CircleModelCopyWith<CircleModel> get copyWith => _$CircleModelCopyWithImpl<CircleModel>(this as CircleModel, _$identity);

  /// Serializes this CircleModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CircleModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.code, code) || other.code == code)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other.memberIds, memberIds)&&const DeepCollectionEquality().equals(other.pendingMemberIds, pendingMemberIds)&&const DeepCollectionEquality().equals(other.adminIds, adminIds)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isPendingDelete, isPendingDelete) || other.isPendingDelete == isPendingDelete));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,code,currency,imageUrl,const DeepCollectionEquality().hash(memberIds),const DeepCollectionEquality().hash(pendingMemberIds),const DeepCollectionEquality().hash(adminIds),createdBy,createdAt,isPendingDelete);

@override
String toString() {
  return 'CircleModel(id: $id, name: $name, description: $description, code: $code, currency: $currency, imageUrl: $imageUrl, memberIds: $memberIds, pendingMemberIds: $pendingMemberIds, adminIds: $adminIds, createdBy: $createdBy, createdAt: $createdAt, isPendingDelete: $isPendingDelete)';
}


}

/// @nodoc
abstract mixin class $CircleModelCopyWith<$Res>  {
  factory $CircleModelCopyWith(CircleModel value, $Res Function(CircleModel) _then) = _$CircleModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, String code, String currency, String? imageUrl, List<String> memberIds, List<String> pendingMemberIds, List<String> adminIds, String createdBy, DateTime createdAt, bool isPendingDelete
});




}
/// @nodoc
class _$CircleModelCopyWithImpl<$Res>
    implements $CircleModelCopyWith<$Res> {
  _$CircleModelCopyWithImpl(this._self, this._then);

  final CircleModel _self;
  final $Res Function(CircleModel) _then;

/// Create a copy of CircleModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? code = null,Object? currency = null,Object? imageUrl = freezed,Object? memberIds = null,Object? pendingMemberIds = null,Object? adminIds = null,Object? createdBy = null,Object? createdAt = null,Object? isPendingDelete = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,memberIds: null == memberIds ? _self.memberIds : memberIds // ignore: cast_nullable_to_non_nullable
as List<String>,pendingMemberIds: null == pendingMemberIds ? _self.pendingMemberIds : pendingMemberIds // ignore: cast_nullable_to_non_nullable
as List<String>,adminIds: null == adminIds ? _self.adminIds : adminIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isPendingDelete: null == isPendingDelete ? _self.isPendingDelete : isPendingDelete // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CircleModel].
extension CircleModelPatterns on CircleModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CircleModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CircleModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CircleModel value)  $default,){
final _that = this;
switch (_that) {
case _CircleModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CircleModel value)?  $default,){
final _that = this;
switch (_that) {
case _CircleModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String code,  String currency,  String? imageUrl,  List<String> memberIds,  List<String> pendingMemberIds,  List<String> adminIds,  String createdBy,  DateTime createdAt,  bool isPendingDelete)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CircleModel() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.code,_that.currency,_that.imageUrl,_that.memberIds,_that.pendingMemberIds,_that.adminIds,_that.createdBy,_that.createdAt,_that.isPendingDelete);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String code,  String currency,  String? imageUrl,  List<String> memberIds,  List<String> pendingMemberIds,  List<String> adminIds,  String createdBy,  DateTime createdAt,  bool isPendingDelete)  $default,) {final _that = this;
switch (_that) {
case _CircleModel():
return $default(_that.id,_that.name,_that.description,_that.code,_that.currency,_that.imageUrl,_that.memberIds,_that.pendingMemberIds,_that.adminIds,_that.createdBy,_that.createdAt,_that.isPendingDelete);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  String code,  String currency,  String? imageUrl,  List<String> memberIds,  List<String> pendingMemberIds,  List<String> adminIds,  String createdBy,  DateTime createdAt,  bool isPendingDelete)?  $default,) {final _that = this;
switch (_that) {
case _CircleModel() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.code,_that.currency,_that.imageUrl,_that.memberIds,_that.pendingMemberIds,_that.adminIds,_that.createdBy,_that.createdAt,_that.isPendingDelete);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CircleModel implements CircleModel {
  const _CircleModel({required this.id, required this.name, required this.description, required this.code, required this.currency, this.imageUrl, required final  List<String> memberIds, final  List<String> pendingMemberIds = const [], required final  List<String> adminIds, required this.createdBy, required this.createdAt, this.isPendingDelete = false}): _memberIds = memberIds,_pendingMemberIds = pendingMemberIds,_adminIds = adminIds;
  factory _CircleModel.fromJson(Map<String, dynamic> json) => _$CircleModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String description;
@override final  String code;
// 7-char alphanumeric
@override final  String currency;
@override final  String? imageUrl;
 final  List<String> _memberIds;
@override List<String> get memberIds {
  if (_memberIds is EqualUnmodifiableListView) return _memberIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_memberIds);
}

 final  List<String> _pendingMemberIds;
@override@JsonKey() List<String> get pendingMemberIds {
  if (_pendingMemberIds is EqualUnmodifiableListView) return _pendingMemberIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pendingMemberIds);
}

 final  List<String> _adminIds;
@override List<String> get adminIds {
  if (_adminIds is EqualUnmodifiableListView) return _adminIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_adminIds);
}

@override final  String createdBy;
@override final  DateTime createdAt;
@override@JsonKey() final  bool isPendingDelete;

/// Create a copy of CircleModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CircleModelCopyWith<_CircleModel> get copyWith => __$CircleModelCopyWithImpl<_CircleModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CircleModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CircleModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.code, code) || other.code == code)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other._memberIds, _memberIds)&&const DeepCollectionEquality().equals(other._pendingMemberIds, _pendingMemberIds)&&const DeepCollectionEquality().equals(other._adminIds, _adminIds)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isPendingDelete, isPendingDelete) || other.isPendingDelete == isPendingDelete));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,code,currency,imageUrl,const DeepCollectionEquality().hash(_memberIds),const DeepCollectionEquality().hash(_pendingMemberIds),const DeepCollectionEquality().hash(_adminIds),createdBy,createdAt,isPendingDelete);

@override
String toString() {
  return 'CircleModel(id: $id, name: $name, description: $description, code: $code, currency: $currency, imageUrl: $imageUrl, memberIds: $memberIds, pendingMemberIds: $pendingMemberIds, adminIds: $adminIds, createdBy: $createdBy, createdAt: $createdAt, isPendingDelete: $isPendingDelete)';
}


}

/// @nodoc
abstract mixin class _$CircleModelCopyWith<$Res> implements $CircleModelCopyWith<$Res> {
  factory _$CircleModelCopyWith(_CircleModel value, $Res Function(_CircleModel) _then) = __$CircleModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, String code, String currency, String? imageUrl, List<String> memberIds, List<String> pendingMemberIds, List<String> adminIds, String createdBy, DateTime createdAt, bool isPendingDelete
});




}
/// @nodoc
class __$CircleModelCopyWithImpl<$Res>
    implements _$CircleModelCopyWith<$Res> {
  __$CircleModelCopyWithImpl(this._self, this._then);

  final _CircleModel _self;
  final $Res Function(_CircleModel) _then;

/// Create a copy of CircleModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? code = null,Object? currency = null,Object? imageUrl = freezed,Object? memberIds = null,Object? pendingMemberIds = null,Object? adminIds = null,Object? createdBy = null,Object? createdAt = null,Object? isPendingDelete = null,}) {
  return _then(_CircleModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,memberIds: null == memberIds ? _self._memberIds : memberIds // ignore: cast_nullable_to_non_nullable
as List<String>,pendingMemberIds: null == pendingMemberIds ? _self._pendingMemberIds : pendingMemberIds // ignore: cast_nullable_to_non_nullable
as List<String>,adminIds: null == adminIds ? _self._adminIds : adminIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isPendingDelete: null == isPendingDelete ? _self.isPendingDelete : isPendingDelete // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
