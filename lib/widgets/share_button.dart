import 'package:flutter/material.dart';
import '../services/share_service.dart';

class ShareButton extends StatelessWidget {
  final ShareType type;
  final Map<String, dynamic> data;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  const ShareButton({
    super.key,
    required this.type,
    required this.data,
    this.size = 40,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleShare(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? const Color(0xFF353935),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.share,
          color: iconColor ?? Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }

  Future<void> _handleShare() async {
    try {
      switch (type) {
        case ShareType.hostProfile:
          await ShareService.shareHostProfile(
            hostId: data['hostId'],
            hostName: data['hostName'],
            hostLocation: data['hostLocation'],
            hostImage: data['hostImage'],
          );
          break;
          
        case ShareType.carListing:
          await ShareService.shareCarListing(
            carId: data['carId'],
            carName: data['carName'],
            carBrand: data['carBrand'],
            carModel: data['carModel'],
            price: data['price'],
            hostName: data['hostName'],
            carImage: data['carImage'],
          );
          break;
          
        case ShareType.bookingConfirmation:
          await ShareService.shareBookingConfirmation(
            bookingId: data['bookingId'],
            carName: data['carName'],
            hostName: data['hostName'],
            startDate: data['startDate'],
            endDate: data['endDate'],
            totalPrice: data['totalPrice'],
          );
          break;
          
        case ShareType.favoriteList:
          await ShareService.shareFavoriteList(
            listName: data['listName'],
            cars: data['cars'],
            listDescription: data['listDescription'],
          );
          break;
          
        case ShareType.app:
          await ShareService.shareApp();
          break;
      }
    } catch (e) {
      debugPrint('Error sharing: $e');
    }
  }
}

enum ShareType {
  hostProfile,
  carListing,
  bookingConfirmation,
  favoriteList,
  app,
}
