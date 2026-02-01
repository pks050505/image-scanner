part of 'scan_bloc.dart';

abstract class ScanEvent extends Equatable {
  const ScanEvent();

  @override
  List<Object> get props => [];
}

class PickImageFromCamera extends ScanEvent {}

class PickImageFromGallery extends ScanEvent {}

class UploadImage extends ScanEvent {
  final File image;
  UploadImage(this.image);
}

class ResultsReceived extends ScanEvent {
  final List<DishEntity> dishes;
  ResultsReceived(this.dishes);
}
