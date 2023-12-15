import 'dart:async';
import 'dart:typed_data';

import 'package:projects/AllEnum.dart';

import 'NetCommonPackages.dart';
import 'NetPackagesDataTypes.dart';
import 'PhotoHeaders.dart';

class FileManager {
  bool useHeaderlessPhotoFormat = true;

  List<FilePartPackage> _fileParts = [];
  List<FilePartPackage> _lastFileParts = [];

  static const int _partAwaitMs = (3 * 12 + 9) * 1000;
  Map<int, Timer> _partTimers = Map();

  late Timer _autoClean;

  Map<int, ImageProperty> _imageProperties = Map();

  FileManager() {
    _autoClean = Timer.periodic(const Duration(hours: 24), autoClean);
  }

  void autoClean(Timer timer) {
    var dt = DateTime.now().add(const Duration(days: -1));

    for (int i = 0; i < _fileParts.length; ++i) {
      var part = _fileParts[i];

      if (part.getCreationTime().millisecondsSinceEpoch <
          dt.millisecondsSinceEpoch) {
        _fileParts.removeAt(i);
        i -= 1;
      }
    }

    for (int i = 0; i < _lastFileParts.length; ++i) {
      var part = _lastFileParts[i];

      if (part.getCreationTime().millisecondsSinceEpoch <
          dt.millisecondsSinceEpoch) {
        _lastFileParts.removeAt(i);
        i -= 1;
      }
    }
  }

  static bool isFileType(PackageType type) {
    return type == PackageType.PHOTO ||
        type == PackageType.SEISMIC_WAVE ||
        type == PackageType.ADPCM_SEISMIC_WAVE ||
        type == PackageType.MESSAGE;
  }

  void addFilePart(FilePartPackage filePart) {
    if (filePart.getType() == PackageType.MESSAGE) {
      Timer.run(() => messageReceived(filePart));

      return;
    }
    print('Part received: part pos: ${filePart.getCurrentPosition()}\tpart size: ${filePart.getPartSize()}\tfull size: ${filePart.getFileSize()}');


    fromSameFile(FilePartPackage part) {
      return filePart.getCreationTime() == part.getCreationTime() &&
          filePart.getSender() == part.getSender() &&
          filePart.getType() == part.getType();
    }

    var lastPartIt = _lastFileParts.indexWhere(fromSameFile);

    if (lastPartIt == -1) {
      if (filePart.getCurrentPosition() == 0) {
        print("First part received");

        var fp = FilePartPackage();
        fp.copyWith(filePart);
        _lastFileParts.insert(0, fp);

        if (filePart.getType() == PackageType.PHOTO &&
            useHeaderlessPhotoFormat) {
          var header = getPhotoImageHeader(filePart.getPartner());

          if (header.isNotEmpty) {
            Uint8List newBuffer =
                Uint8List(header.length + filePart.getPartSize());
            newBuffer.setAll(0, header);
            newBuffer.setAll(header.length, filePart.getPartData());

            filePart.setPartData(newBuffer);
          }
        }

        Timer.run(() {
          fileDownloadStarted(filePart.getSender(), filePart);
          filePartReceived(filePart);
        });

        //savePart(filePart);

        startPartTimer(filePart.getSender());
      } else {
        print("Async part recieved");
        _fileParts.insert(0, filePart);
      }

      return;
    }

    var lastPart = _lastFileParts[lastPartIt];
    _lastFileParts.removeAt(lastPartIt);

    if (filePart.isNextAfter(lastPart)) {
      print("Next file part received");

      Timer.run(() {
        filePartReceived(filePart);
      });
      //savePart(filePart);

      if (filePart.isLastPart()) {
        print("File downloaded");

        Timer.run(() {
          print('HERE');
          fileDownloaded(lastPart.getSender());
        });

        stopPartTimer(lastPart.getSender());
      } else {
        startPartTimer(lastPart.getSender());

        _lastFileParts.insert(0, filePart);
      }

      return;
    }

    _fileParts.add(filePart);

    List<FilePartPackage> parts =
        _fileParts.where((e) => fromSameFile(e)).toList();

    parts.sort((lhs, rhs) =>
        lhs.getCurrentPosition().compareTo(rhs.getCurrentPosition()));

    while (parts.isNotEmpty) {
      var part = parts.first;

      if (lastPart.getCurrentPosition() == part.getCurrentPosition()) {
        print("Duplicate part skipped");

        if (lastPart != part) {
          lastPart = part;
        }

        _fileParts.remove(part);
        parts.removeAt(0);
        continue;
      }

      if (!part.isNextAfter(lastPart)) break;

      print("Restoring async parts order");
      Timer.run(() {
        filePartReceived(part);
      });
      //savePart(part);

      _fileParts.remove(part);
      parts.removeAt(0);

      lastPart = part;
    }

    if (lastPart.isLastPart()) {
      print("File downloaded");
      Timer.run(() {
        print('HERE2');
        fileDownloaded(lastPart.getSender());
      });
      stopPartTimer(lastPart.getSender());
    } else {
      startPartTimer(lastPart.getSender());
      _lastFileParts.insert(0, lastPart);
    }
  }

  void startPartTimer(int sender) {
    var timer = _partTimers[sender];
    timer?.cancel();

    timer = Timer(const Duration(milliseconds: _partAwaitMs), () {
        Timer.run(() { fileDownloaded(sender); });
        stopPartTimer(sender);
      });

    _partTimers[sender] = timer;
    }

  void stopPartTimer(int sender) {
    var timer = _partTimers[sender];
    timer?.cancel();
    _partTimers.remove(sender);
  }

  void setCameraImageProperty(int cameraId, PhotoImageSize size, PhotoImageCompression compression) {
    var ip = ImageProperty();
    ip.size = size;
    ip.compression = compression;

    _imageProperties[cameraId] = ip;
  }

  late void Function(int sender, FilePartPackage filePartPackage) fileDownloadStarted;
  late void Function(FilePartPackage filePart) filePartReceived;
  late void Function(int sender) fileDownloaded;
  late void Function(FilePartPackage message) messageReceived;

  Uint8List getPhotoImageHeader(int cameraId) {
    var item = _imageProperties[cameraId];
    if (item == null) {
      return Uint8List(0);
    }

    switch (item.size) {
      case PhotoImageSize.IMAGE_160X120:
        switch (item.compression) {
          case PhotoImageCompression.MINIMUM:
            return jpg_header_160x120_comp0;
          case PhotoImageCompression.LOW:
            return jpg_header_160x120_comp80;
          case PhotoImageCompression.MEDIUM:
            return jpg_header_160x120_comp130;
          case PhotoImageCompression.HIGH:
            return jpg_header_160x120_comp180;
          case PhotoImageCompression.MAXIMUM:
            return jpg_header_160x120_comp255;
        }
      case PhotoImageSize.IMAGE_SIZE_TRAP:
      case PhotoImageSize.IMAGE_320X240:
        switch (item.compression) {
          case PhotoImageCompression.MINIMUM:
            return jpg_header_320x240_comp0;
          case PhotoImageCompression.LOW:
            return jpg_header_320x240_comp80;
          case PhotoImageCompression.MEDIUM:
            return jpg_header_320x240_comp130;
          case PhotoImageCompression.HIGH:
            return jpg_header_320x240_comp180;
          case PhotoImageCompression.MAXIMUM:
            return jpg_header_320x240_comp255;
        }

      case PhotoImageSize.IMAGE_640X480:
      default:
        return Uint8List(0);
    }
  }
}

class ImageProperty {
  PhotoImageSize size = PhotoImageSize.IMAGE_320X240;
  PhotoImageCompression compression = PhotoImageCompression.HIGH;
}
