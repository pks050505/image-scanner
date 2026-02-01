part of 'scan_bloc.dart';

abstract class ScanState extends Equatable {
  const ScanState();

  @override
  List<Object> get props => [];
}

class ScanInitial extends ScanState {}

final class ScanImagePicked extends ScanState {
  final File image;
  const ScanImagePicked(this.image);
}

final class ScanUploading extends ScanState {
  final File image;
  const ScanUploading(this.image);
}

final class ScanUploadSuccess extends ScanState {
  final String requestId;
  final List<DishEntity> dishes; // initially empty, later update
  const ScanUploadSuccess(this.requestId, {this.dishes = const []});
}

final class ScanUploadFailure extends ScanState {
  final String error;
  const ScanUploadFailure(this.error);
}

final class ScanResultsLoaded extends ScanState {
  final List<DishEntity> dishes;
  const ScanResultsLoaded(this.dishes);
}
