import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/scan_bloc.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu Scanner')),
      body: BlocConsumer<ScanBloc, ScanState>(
        listener: (context, state) {
          if (state is ScanUploadFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
          }
        },
        builder: (context, state) {
          final bloc = context.read<ScanBloc>();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (state is ScanImagePicked || state is ScanUploading)
                  Image.file(
                    (state as dynamic).image,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                else
                  const PlaceholderImage(),

                const SizedBox(height: 20),

                if (state is ScanUploading || state is ScanUploadSuccess)
                  const CircularProgressIndicator()
                else ...[
                  ElevatedButton.icon(
                    onPressed: () => bloc.add(PickImageFromCamera()),
                    icon: const Icon(Icons.camera),
                    label: const Text('Camera se Scan'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () => bloc.add(PickImageFromGallery()),
                    icon: const Icon(Icons.photo),
                    label: const Text('Gallery se Upload'),
                  ),
                ],

                const SizedBox(height: 30),

                // Results
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (state is ScanResultsLoaded) {
                        return ListView.builder(
                          itemCount: state.dishes.length,
                          itemBuilder: (ctx, i) {
                            final dish = state.dishes[i];
                            return Card(
                              child: ListTile(
                                title: Text(dish.name),
                                subtitle: Text(
                                  '${dish.isVeg ? 'Veg' : 'Non-Veg'}\n'
                                  'Ingredients: ${dish.ingredients.join(', ')}',
                                ),
                              ),
                            );
                          },
                        );
                      } else if (state is ScanUploadSuccess) {
                        return const Center(
                          child: Text('Processing... Results aa rahe hain'),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Simple placeholder widget
class PlaceholderImage extends StatelessWidget {
  const PlaceholderImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.camera_alt, size: 80, color: Colors.grey),
      ),
    );
  }
}
