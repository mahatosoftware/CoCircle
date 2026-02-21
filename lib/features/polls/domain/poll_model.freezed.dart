// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'poll_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PollOption {

 String get text; int get voteCount;
/// Create a copy of PollOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PollOptionCopyWith<PollOption> get copyWith => _$PollOptionCopyWithImpl<PollOption>(this as PollOption, _$identity);

  /// Serializes this PollOption to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PollOption&&(identical(other.text, text) || other.text == text)&&(identical(other.voteCount, voteCount) || other.voteCount == voteCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,voteCount);

@override
String toString() {
  return 'PollOption(text: $text, voteCount: $voteCount)';
}


}

/// @nodoc
abstract mixin class $PollOptionCopyWith<$Res>  {
  factory $PollOptionCopyWith(PollOption value, $Res Function(PollOption) _then) = _$PollOptionCopyWithImpl;
@useResult
$Res call({
 String text, int voteCount
});




}
/// @nodoc
class _$PollOptionCopyWithImpl<$Res>
    implements $PollOptionCopyWith<$Res> {
  _$PollOptionCopyWithImpl(this._self, this._then);

  final PollOption _self;
  final $Res Function(PollOption) _then;

/// Create a copy of PollOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? voteCount = null,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,voteCount: null == voteCount ? _self.voteCount : voteCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PollOption].
extension PollOptionPatterns on PollOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PollOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PollOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PollOption value)  $default,){
final _that = this;
switch (_that) {
case _PollOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PollOption value)?  $default,){
final _that = this;
switch (_that) {
case _PollOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  int voteCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PollOption() when $default != null:
return $default(_that.text,_that.voteCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  int voteCount)  $default,) {final _that = this;
switch (_that) {
case _PollOption():
return $default(_that.text,_that.voteCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  int voteCount)?  $default,) {final _that = this;
switch (_that) {
case _PollOption() when $default != null:
return $default(_that.text,_that.voteCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PollOption implements PollOption {
  const _PollOption({required this.text, this.voteCount = 0});
  factory _PollOption.fromJson(Map<String, dynamic> json) => _$PollOptionFromJson(json);

@override final  String text;
@override@JsonKey() final  int voteCount;

/// Create a copy of PollOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PollOptionCopyWith<_PollOption> get copyWith => __$PollOptionCopyWithImpl<_PollOption>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PollOptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PollOption&&(identical(other.text, text) || other.text == text)&&(identical(other.voteCount, voteCount) || other.voteCount == voteCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,voteCount);

@override
String toString() {
  return 'PollOption(text: $text, voteCount: $voteCount)';
}


}

/// @nodoc
abstract mixin class _$PollOptionCopyWith<$Res> implements $PollOptionCopyWith<$Res> {
  factory _$PollOptionCopyWith(_PollOption value, $Res Function(_PollOption) _then) = __$PollOptionCopyWithImpl;
@override @useResult
$Res call({
 String text, int voteCount
});




}
/// @nodoc
class __$PollOptionCopyWithImpl<$Res>
    implements _$PollOptionCopyWith<$Res> {
  __$PollOptionCopyWithImpl(this._self, this._then);

  final _PollOption _self;
  final $Res Function(_PollOption) _then;

/// Create a copy of PollOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? voteCount = null,}) {
  return _then(_PollOption(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,voteCount: null == voteCount ? _self.voteCount : voteCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$PollModel {

 String get id; String get tripId; String get creatorId; String get question; List<PollOption> get options; Map<String, List<int>> get votes;// userId -> list of optionIndices
 bool get allowMultipleSelections;@TimestampConverter() DateTime get createdAt; bool get isActive;@TimestampConverter() DateTime? get closedAt;
/// Create a copy of PollModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PollModelCopyWith<PollModel> get copyWith => _$PollModelCopyWithImpl<PollModel>(this as PollModel, _$identity);

  /// Serializes this PollModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PollModel&&(identical(other.id, id) || other.id == id)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.question, question) || other.question == question)&&const DeepCollectionEquality().equals(other.options, options)&&const DeepCollectionEquality().equals(other.votes, votes)&&(identical(other.allowMultipleSelections, allowMultipleSelections) || other.allowMultipleSelections == allowMultipleSelections)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.closedAt, closedAt) || other.closedAt == closedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tripId,creatorId,question,const DeepCollectionEquality().hash(options),const DeepCollectionEquality().hash(votes),allowMultipleSelections,createdAt,isActive,closedAt);

@override
String toString() {
  return 'PollModel(id: $id, tripId: $tripId, creatorId: $creatorId, question: $question, options: $options, votes: $votes, allowMultipleSelections: $allowMultipleSelections, createdAt: $createdAt, isActive: $isActive, closedAt: $closedAt)';
}


}

/// @nodoc
abstract mixin class $PollModelCopyWith<$Res>  {
  factory $PollModelCopyWith(PollModel value, $Res Function(PollModel) _then) = _$PollModelCopyWithImpl;
@useResult
$Res call({
 String id, String tripId, String creatorId, String question, List<PollOption> options, Map<String, List<int>> votes, bool allowMultipleSelections,@TimestampConverter() DateTime createdAt, bool isActive,@TimestampConverter() DateTime? closedAt
});




}
/// @nodoc
class _$PollModelCopyWithImpl<$Res>
    implements $PollModelCopyWith<$Res> {
  _$PollModelCopyWithImpl(this._self, this._then);

  final PollModel _self;
  final $Res Function(PollModel) _then;

/// Create a copy of PollModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tripId = null,Object? creatorId = null,Object? question = null,Object? options = null,Object? votes = null,Object? allowMultipleSelections = null,Object? createdAt = null,Object? isActive = null,Object? closedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tripId: null == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as List<PollOption>,votes: null == votes ? _self.votes : votes // ignore: cast_nullable_to_non_nullable
as Map<String, List<int>>,allowMultipleSelections: null == allowMultipleSelections ? _self.allowMultipleSelections : allowMultipleSelections // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,closedAt: freezed == closedAt ? _self.closedAt : closedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PollModel].
extension PollModelPatterns on PollModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PollModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PollModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PollModel value)  $default,){
final _that = this;
switch (_that) {
case _PollModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PollModel value)?  $default,){
final _that = this;
switch (_that) {
case _PollModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String tripId,  String creatorId,  String question,  List<PollOption> options,  Map<String, List<int>> votes,  bool allowMultipleSelections, @TimestampConverter()  DateTime createdAt,  bool isActive, @TimestampConverter()  DateTime? closedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PollModel() when $default != null:
return $default(_that.id,_that.tripId,_that.creatorId,_that.question,_that.options,_that.votes,_that.allowMultipleSelections,_that.createdAt,_that.isActive,_that.closedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String tripId,  String creatorId,  String question,  List<PollOption> options,  Map<String, List<int>> votes,  bool allowMultipleSelections, @TimestampConverter()  DateTime createdAt,  bool isActive, @TimestampConverter()  DateTime? closedAt)  $default,) {final _that = this;
switch (_that) {
case _PollModel():
return $default(_that.id,_that.tripId,_that.creatorId,_that.question,_that.options,_that.votes,_that.allowMultipleSelections,_that.createdAt,_that.isActive,_that.closedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String tripId,  String creatorId,  String question,  List<PollOption> options,  Map<String, List<int>> votes,  bool allowMultipleSelections, @TimestampConverter()  DateTime createdAt,  bool isActive, @TimestampConverter()  DateTime? closedAt)?  $default,) {final _that = this;
switch (_that) {
case _PollModel() when $default != null:
return $default(_that.id,_that.tripId,_that.creatorId,_that.question,_that.options,_that.votes,_that.allowMultipleSelections,_that.createdAt,_that.isActive,_that.closedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PollModel implements PollModel {
  const _PollModel({required this.id, required this.tripId, required this.creatorId, required this.question, required final  List<PollOption> options, final  Map<String, List<int>> votes = const {}, this.allowMultipleSelections = false, @TimestampConverter() required this.createdAt, this.isActive = true, @TimestampConverter() this.closedAt}): _options = options,_votes = votes;
  factory _PollModel.fromJson(Map<String, dynamic> json) => _$PollModelFromJson(json);

@override final  String id;
@override final  String tripId;
@override final  String creatorId;
@override final  String question;
 final  List<PollOption> _options;
@override List<PollOption> get options {
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_options);
}

 final  Map<String, List<int>> _votes;
@override@JsonKey() Map<String, List<int>> get votes {
  if (_votes is EqualUnmodifiableMapView) return _votes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_votes);
}

// userId -> list of optionIndices
@override@JsonKey() final  bool allowMultipleSelections;
@override@TimestampConverter() final  DateTime createdAt;
@override@JsonKey() final  bool isActive;
@override@TimestampConverter() final  DateTime? closedAt;

/// Create a copy of PollModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PollModelCopyWith<_PollModel> get copyWith => __$PollModelCopyWithImpl<_PollModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PollModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PollModel&&(identical(other.id, id) || other.id == id)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.question, question) || other.question == question)&&const DeepCollectionEquality().equals(other._options, _options)&&const DeepCollectionEquality().equals(other._votes, _votes)&&(identical(other.allowMultipleSelections, allowMultipleSelections) || other.allowMultipleSelections == allowMultipleSelections)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.closedAt, closedAt) || other.closedAt == closedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tripId,creatorId,question,const DeepCollectionEquality().hash(_options),const DeepCollectionEquality().hash(_votes),allowMultipleSelections,createdAt,isActive,closedAt);

@override
String toString() {
  return 'PollModel(id: $id, tripId: $tripId, creatorId: $creatorId, question: $question, options: $options, votes: $votes, allowMultipleSelections: $allowMultipleSelections, createdAt: $createdAt, isActive: $isActive, closedAt: $closedAt)';
}


}

/// @nodoc
abstract mixin class _$PollModelCopyWith<$Res> implements $PollModelCopyWith<$Res> {
  factory _$PollModelCopyWith(_PollModel value, $Res Function(_PollModel) _then) = __$PollModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String tripId, String creatorId, String question, List<PollOption> options, Map<String, List<int>> votes, bool allowMultipleSelections,@TimestampConverter() DateTime createdAt, bool isActive,@TimestampConverter() DateTime? closedAt
});




}
/// @nodoc
class __$PollModelCopyWithImpl<$Res>
    implements _$PollModelCopyWith<$Res> {
  __$PollModelCopyWithImpl(this._self, this._then);

  final _PollModel _self;
  final $Res Function(_PollModel) _then;

/// Create a copy of PollModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tripId = null,Object? creatorId = null,Object? question = null,Object? options = null,Object? votes = null,Object? allowMultipleSelections = null,Object? createdAt = null,Object? isActive = null,Object? closedAt = freezed,}) {
  return _then(_PollModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tripId: null == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,options: null == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<PollOption>,votes: null == votes ? _self._votes : votes // ignore: cast_nullable_to_non_nullable
as Map<String, List<int>>,allowMultipleSelections: null == allowMultipleSelections ? _self.allowMultipleSelections : allowMultipleSelections // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,closedAt: freezed == closedAt ? _self.closedAt : closedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
