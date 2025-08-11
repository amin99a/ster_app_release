import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class ImageUploadService extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image != null ? File(image.path) : null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  // Take photo with camera
  Future<File?> takePhotoWithCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image != null ? File(image.path) : null;
    } catch (e) {
      print('Error taking photo with camera: $e');
      return null;
    }
  }

  // Pick multiple images
  Future<List<File>> pickMultipleImages({int maxImages = 10}) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      final files = <File>[];
      for (final image in images.take(maxImages)) {
        files.add(File(image.path));
      }
      return files;
    } catch (e) {
      print('Error picking multiple images: $e');
      return [];
    }
  }

  // Upload user avatar
  Future<String?> uploadUserAvatar(String userId, File imageFile) async {
    try {
      _isUploading = true;
      _uploadProgress = 0.0;
      notifyListeners();

      // Read image bytes
      final bytes = await imageFile.readAsBytes();
      
      // Upload to Supabase
      final url = await SupabaseService.uploadUserAvatar(userId, Uint8List.fromList(bytes));
      
      _uploadProgress = 1.0;
      notifyListeners();
      
      return url;
    } catch (e) {
      print('Error uploading user avatar: $e');
      return null;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  // Upload car image
  Future<String?> uploadCarImage(String carId, File imageFile) async {
    try {
      _isUploading = true;
      _uploadProgress = 0.0;
      notifyListeners();

      // Read image bytes
      final bytes = await imageFile.readAsBytes();
      
      // Upload to Supabase
      final url = await SupabaseService.uploadCarImage(carId, Uint8List.fromList(bytes));
      
      _uploadProgress = 1.0;
      notifyListeners();
      
      return url;
    } catch (e) {
      print('Error uploading car image: $e');
      return null;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  // Upload multiple car images
  Future<List<String>> uploadCarImages(String carId, List<File> imageFiles) async {
    try {
      _isUploading = true;
      _uploadProgress = 0.0;
      notifyListeners();

      final urls = <String>[];
      final totalImages = imageFiles.length;
      
      for (int i = 0; i < imageFiles.length; i++) {
        final imageFile = imageFiles[i];
        final bytes = await imageFile.readAsBytes();
        
        final url = await SupabaseService.uploadCarImage(carId, Uint8List.fromList(bytes));
        if (url != null) {
          urls.add(url);
        }
        
        _uploadProgress = (i + 1) / totalImages;
        notifyListeners();
      }
      
      return urls;
    } catch (e) {
      print('Error uploading car images: $e');
      return [];
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  // Upload image with custom path
  Future<String?> uploadImageWithCustomPath(
    String bucketName,
    String path,
    File imageFile,
  ) async {
    try {
      _isUploading = true;
      _uploadProgress = 0.0;
      notifyListeners();

      // Read image bytes
      final bytes = await imageFile.readAsBytes();
      
      // Upload to Supabase storage
      await Supabase.instance.client.storage
          .from(bucketName)
          .uploadBinary(path, Uint8List.fromList(bytes));

      // Get public URL
      final url = Supabase.instance.client.storage
          .from(bucketName)
          .getPublicUrl(path);
      
      _uploadProgress = 1.0;
      notifyListeners();
      
      return url;
    } catch (e) {
      print('Error uploading image with custom path: $e');
      return null;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  // Compress image
  Future<Uint8List> compressImage(File imageFile, {int quality = 85}) async {
    try {
      final bytes = await imageFile.readAsBytes();
      
      // For now, return original bytes
      // In a real app, you'd use a compression library like flutter_image_compress
      return Uint8List.fromList(bytes);
    } catch (e) {
      print('Error compressing image: $e');
      return Uint8List(0);
    }
  }

  // Get image dimensions
  Future<Map<String, int>> getImageDimensions(File imageFile) async {
    try {
      // For now, return default dimensions
      // In a real app, you'd use a library to get actual dimensions
      return {'width': 1920, 'height': 1080};
    } catch (e) {
      print('Error getting image dimensions: $e');
      return {'width': 0, 'height': 0};
    }
  }

  // Validate image file
  bool validateImageFile(File imageFile) {
    try {
      // Check if file exists
      if (!imageFile.existsSync()) return false;
      
      // Check file size (max 10MB)
      final fileSize = imageFile.lengthSync();
      if (fileSize > 10 * 1024 * 1024) return false;
      
      // Check file extension
      final extension = imageFile.path.split('.').last.toLowerCase();
      final validExtensions = ['jpg', 'jpeg', 'png', 'webp'];
      if (!validExtensions.contains(extension)) return false;
      
      return true;
    } catch (e) {
      print('Error validating image file: $e');
      return false;
    }
  }

  // Delete image from storage
  Future<bool> deleteImage(String bucketName, String path) async {
    try {
      await Supabase.instance.client.storage
          .from(bucketName)
          .remove([path]);
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  // Get storage bucket info
  Future<Map<String, dynamic>?> getBucketInfo(String bucketName) async {
    try {
      final response = await Supabase.instance.client.storage
          .from(bucketName)
          .list();
      return {'files': response.length};
    } catch (e) {
      print('Error getting bucket info: $e');
      return null;
    }
  }

  // Create storage bucket (admin only)
  Future<bool> createBucket(String bucketName) async {
    try {
      // This would require admin privileges
      // For now, return false
      return false;
    } catch (e) {
      print('Error creating bucket: $e');
      return false;
    }
  }

  // Update upload progress
  void updateProgress(double progress) {
    _uploadProgress = progress;
    notifyListeners();
  }

  // Reset upload state
  void resetUploadState() {
    _isUploading = false;
    _uploadProgress = 0.0;
    notifyListeners();
  }

  // Upload profile image
  Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
    try {
      _isUploading = true;
      _uploadProgress = 0.0;
      notifyListeners();

      // Generate unique filename
      final fileExtension = imageFile.path.split('.').last;
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final filePath = 'users/$fileName';

      // Upload to Supabase Storage
      final response = await Supabase.instance.client.storage
          .from('images')
          .upload(filePath, imageFile);

      _uploadProgress = 1.0;
      notifyListeners();

      // Get public URL
      final url = Supabase.instance.client.storage
          .from('images')
          .getPublicUrl(filePath);

      resetUploadState();

      return {
        'success': true,
        'url': url,
        'path': filePath,
      };
    } catch (e) {
      resetUploadState();
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Get upload status message
  String get uploadStatusMessage {
    if (!_isUploading) return 'Ready';
    if (_uploadProgress == 0.0) return 'Preparing upload...';
    if (_uploadProgress < 1.0) return 'Uploading... ${(_uploadProgress * 100).toInt()}%';
    return 'Upload complete!';
  }
} 