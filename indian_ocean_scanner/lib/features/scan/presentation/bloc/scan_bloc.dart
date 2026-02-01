import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:indian_ocean_scanner/features/scan/data/repositories/scan_repository.dart';
import 'package:indian_ocean_scanner/features/scan/domain/entities/dish_entity.dart';
import 'package:image_picker/image_picker.dart';
part 'scan_event.dart';
part 'scan_state.dart';

class ScanBloc extends Bloc<ScanEvent, ScanState> {
  final ScanRepository repository;
  final ImagePicker picker = ImagePicker();

  ScanBloc({required this.repository}) : super(ScanInitial()) {
    on<PickImageFromCamera>(_onPickFromCamera);
    on<PickImageFromGallery>(_onPickFromGallery);
    on<UploadImage>(_onUploadImage);
    on<ResultsReceived>(_onResultsReceived);
  }

  Future<void> _onPickFromCamera(
    PickImageFromCamera event,
    Emitter<ScanState> emit,
  ) async {
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      emit(ScanImagePicked(File(picked.path)));
    }
  }

  Future<void> _onPickFromGallery(
    PickImageFromGallery event,
    Emitter<ScanState> emit,
  ) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      emit(ScanImagePicked(File(picked.path)));
    }
  }

  Future<void> _onUploadImage(
    UploadImage event,
    Emitter<ScanState> emit,
  ) async {
    emit(ScanUploading(event.image));

    try {
      final requestId = await repository.uploadImage(event.image);
      emit(ScanUploadSuccess(requestId));

      // Listen results (real-time)
      repository.listenToScanResults(requestId).listen((data) {
        if (data?['status'] == 'completed') {
          add(ResultsReceived(data!['dishes'] as List<DishEntity>));
        }
      });
    } catch (e) {
      emit(ScanUploadFailure(e.toString()));
    }
  }

  void _onResultsReceived(ResultsReceived event, Emitter<ScanState> emit) {
    if (state is ScanUploadSuccess) {
      final current = state as ScanUploadSuccess;
      emit(ScanResultsLoaded(event.dishes));
    } else {
      emit(ScanResultsLoaded(event.dishes));
    }
  }
}
