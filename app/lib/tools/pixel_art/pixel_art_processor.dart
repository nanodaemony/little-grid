import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'pixel_art_filters.dart';

class PixelArtProcessor {
  static final PixelArtProcessor instance = PixelArtProcessor._();
  PixelArtProcessor._();

  /// 主处理入口 - 处理全图（用于保存）
  Future<ui.Image> processImage({
    required ui.Image original,
    required int pixelSize,
    required int colorCount,
    required PixelFilterType filterType,
  }) async {
    final filter = PixelArtFilters.get(filterType);

    // 1. 将 ui.Image 转换为 image 包的 Image
    final image = await _convertUiImageToImage(original);

    // 2. 应用滤镜处理
    img.Image processed;
    if (filterType == PixelFilterType.pixelSketch) {
      processed = _applyPixelSketch(image, pixelSize);
    } else {
      processed = _applyPixelFilter(
        image,
        pixelSize,
        colorCount,
        filter,
      );
    }

    // 3. 转换回 ui.Image
    return _convertImageToUiImage(processed);
  }

  /// 处理预览图（缩小版本，更快）
  Future<ui.Image> processPreview({
    required ui.Image original,
    required int pixelSize,
    required int colorCount,
    required PixelFilterType filterType,
  }) async {
    // 先缩放到最大边长512px
    final scaled = await _scaleDownImage(original, maxSize: 512);
    return processImage(
      original: scaled,
      pixelSize: pixelSize,
      colorCount: colorCount,
      filterType: filterType,
    );
  }

  /// 像素滤镜处理
  img.Image _applyPixelFilter(
    img.Image image,
    int pixelSize,
    int colorCount,
    PixelFilter filter,
  ) {
    // 步骤1: 降采样
    final downscaled = _downscale(image, pixelSize);

    // 步骤2: 颜色量化
    img.Image quantized;
    if (filter.palette != null) {
      quantized = _applyFixedPalette(downscaled, filter.palette!);
    } else {
      quantized = _quantizeColors(downscaled, colorCount, filter.isGrayscale);
    }

    // 步骤3: 放大回原尺寸（最近邻插值）
    return _upscale(quantized, image.width, image.height);
  }

  /// 像素素描滤镜
  img.Image _applyPixelSketch(img.Image image, int pixelSize) {
    // 1. 转灰度
    final grayscale = img.grayscale(image);

    // 2. 降采样
    final downscaled = _downscale(grayscale, pixelSize);

    // 3. 边缘检测（Sobel算子）
    final edges = _detectEdges(downscaled);

    // 4. 二值化 - 反转颜色，线条为黑色
    final binary = _binarize(edges, threshold: 30, invert: true);

    // 5. 放大回原尺寸
    return _upscale(binary, image.width, image.height);
  }

  /// 降采样（按像素块大小）
  img.Image _downscale(img.Image image, int pixelSize) {
    final newWidth = (image.width / pixelSize).floor();
    final newHeight = (image.height / pixelSize).floor();
    return img.copyResize(image, width: newWidth, height: newHeight);
  }

  /// 放大（最近邻插值，保持像素感）
  img.Image _upscale(img.Image image, int targetWidth, int targetHeight) {
    return img.copyResize(
      image,
      width: targetWidth,
      height: targetHeight,
      interpolation: img.Interpolation.nearest,
    );
  }

  /// 简单颜色量化 - 均匀量化
  img.Image _quantizeColors(img.Image image, int colorCount, bool isGrayscale) {
    if (isGrayscale) {
      // 灰度量化
      final grayLevels = colorCount;
      final step = 255 ~/ (grayLevels - 1);
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          final gray = img.getLuminance(pixel);
          final quantizedGray = (gray / step).round() * step;
          image.setPixelRgba(x, y, quantizedGray, quantizedGray, quantizedGray, 255);
        }
      }
    } else {
      // RGB 均匀量化 - 使用中位切分简化版
      final bitsPerChannel = _calculateBitsPerChannel(colorCount);
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          final r = _quantizeChannel(pixel.r.toInt(), bitsPerChannel);
          final g = _quantizeChannel(pixel.g.toInt(), bitsPerChannel);
          final b = _quantizeChannel(pixel.b.toInt(), bitsPerChannel);
          image.setPixelRgba(x, y, r, g, b, 255);
        }
      }
    }
    return image;
  }

  int _calculateBitsPerChannel(int colorCount) {
    if (colorCount <= 8) return 1;
    if (colorCount <= 64) return 2;
    if (colorCount <= 512) return 3;
    return 4;
  }

  int _quantizeChannel(int value, int bits) {
    final levels = (1 << bits) - 1;
    final step = 255 ~/ levels;
    return (value / step).round() * step;
  }

  /// 应用固定调色板
  img.Image _applyFixedPalette(img.Image image, List<Color> palette) {
    // 将 Color 转换为 RGB 列表
    final paletteColors = palette.map((c) {
      return [c.red, c.green, c.blue];
    }).toList();

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();

        // 找到最近的调色板颜色
        var minDist = double.maxFinite;
        var nearestColor = paletteColors[0];

        for (final color in paletteColors) {
          final dist = _colorDistance(r, g, b, color[0], color[1], color[2]);
          if (dist < minDist) {
            minDist = dist;
            nearestColor = color;
          }
        }

        image.setPixelRgba(x, y, nearestColor[0], nearestColor[1], nearestColor[2], 255);
      }
    }
    return image;
  }

  double _colorDistance(int r1, int g1, int b1, int r2, int g2, int b2) {
    // 使用欧氏距离
    final dr = r1 - r2;
    final dg = g1 - g2;
    final db = b1 - b2;
    return (dr * dr + dg * dg + db * db).toDouble();
  }

  /// 边缘检测
  img.Image _detectEdges(img.Image image) {
    final result = img.Image(width: image.width, height: image.height);

    // Sobel 算子
    const sobelX = [[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]];
    const sobelY = [[-1, -2, -1], [0, 0, 0], [1, 2, 1]];

    for (int y = 1; y < image.height - 1; y++) {
      for (int x = 1; x < image.width - 1; x++) {
        double gx = 0;
        double gy = 0;

        // 应用卷积
        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            final pixel = image.getPixel(x + kx, y + ky);
            final gray = img.getLuminance(pixel);
            gx += gray * sobelX[ky + 1][kx + 1];
            gy += gray * sobelY[ky + 1][kx + 1];
          }
        }

        // 计算梯度幅值
        final magnitude = math.sqrt(gx * gx + gy * gy).toInt();
        final clamped = magnitude.clamp(0, 255);
        result.setPixelRgba(x, y, clamped, clamped, clamped, 255);
      }
    }

    return result;
  }

  /// 二值化
  img.Image _binarize(img.Image image, {required int threshold, bool invert = false}) {
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final gray = img.getLuminance(pixel);
        var value = gray > threshold ? 255 : 0;
        if (invert) value = 255 - value;
        image.setPixelRgba(x, y, value, value, value, 255);
      }
    }
    return image;
  }

  /// ui.Image 转换为 image包的Image
  Future<img.Image> _convertUiImageToImage(ui.Image uiImage) async {
    final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();
    return img.decodeImage(bytes)!;
  }

  /// image包的Image 转换为 ui.Image
  Future<ui.Image> _convertImageToUiImage(img.Image image) async {
    final bytes = img.encodePng(image);
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  /// 缩小图片
  Future<ui.Image> _scaleDownImage(ui.Image image, {required int maxSize}) async {
    if (image.width <= maxSize && image.height <= maxSize) {
      return image;
    }

    // 计算缩放比例
    double scale;
    if (image.width > image.height) {
      scale = maxSize / image.width;
    } else {
      scale = maxSize / image.height;
    }

    final newWidth = (image.width * scale).round();
    final newHeight = (image.height * scale).round();

    // 转换为 image 包进行缩放
    final imgImage = await _convertUiImageToImage(image);
    final scaled = img.copyResize(imgImage, width: newWidth, height: newHeight);
    return _convertImageToUiImage(scaled);
  }
}
