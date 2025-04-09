// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef FLUTTER_DISPLAY_LIST_GEOMETRY_DL_PATH_H_
#define FLUTTER_DISPLAY_LIST_GEOMETRY_DL_PATH_H_

#include <functional>

#include "flutter/display_list/geometry/dl_geometry_types.h"
#include "flutter/impeller/geometry/path.h"
#include "flutter/impeller/geometry/path_builder.h"
#include "flutter/impeller/geometry/path_source.h"
#include "flutter/third_party/skia/include/core/SkPath.h"

namespace flutter {

using DlPathFillType = impeller::FillType;
using DlPathBuilder = impeller::PathBuilder;
using DlPathReceiver = impeller::PathReceiver;

class DlPath : public impeller::PathSource {
 public:
  static constexpr uint32_t kMaxVolatileUses = 2;

  static DlPath MakeRect(const DlRect& rect);
  static DlPath MakeRectLTRB(DlScalar left,
                             DlScalar top,
                             DlScalar right,
                             DlScalar bottom);
  static DlPath MakeRectXYWH(DlScalar x,
                             DlScalar y,
                             DlScalar width,
                             DlScalar height);

  static DlPath MakeOval(const DlRect& bounds);
  static DlPath MakeOvalLTRB(DlScalar left,
                             DlScalar top,
                             DlScalar right,
                             DlScalar bottom);

  static DlPath MakeCircle(const DlPoint& center, DlScalar radius);

  static DlPath MakeRoundRect(const DlRoundRect& rrect);
  static DlPath MakeRoundRectXY(const DlRect& rect,
                                DlScalar x_radius,
                                DlScalar y_radius,
                                bool counter_clock_wise = false);

  static DlPath MakeLine(const DlPoint& a, const DlPoint& b);
  static DlPath MakePoly(const DlPoint pts[],
                         int count,
                         bool close,
                         DlPathFillType fill_type = DlPathFillType::kNonZero);

  static DlPath MakeArc(const DlRect& bounds,
                        DlDegrees start,
                        DlDegrees end,
                        bool use_center);

  DlPath() : data_(std::make_shared<Data>(SkPath())) {}
  explicit DlPath(const SkPath& path) : data_(std::make_shared<Data>(path)) {}
  explicit DlPath(const impeller::Path& path)
      : data_(std::make_shared<Data>(path)) {}
  explicit DlPath(DlPathBuilder& builder,
                  DlPathFillType fill_type = DlPathFillType::kNonZero)
      : data_(std::make_shared<Data>(builder.TakePath(fill_type))) {}

  DlPath(const DlPath& path) = default;
  DlPath(DlPath&& path) = default;
  DlPath& operator=(const DlPath&) = default;

  ~DlPath() override = default;

  const SkPath& GetSkPath() const;
  const impeller::Path& GetPath() const;

  void Dispatch(DlPathReceiver& receiver) const override;

  /// Intent to render an SkPath multiple times will make the path
  /// non-volatile to enable caching in Skia. Calling this method
  /// before every rendering call that uses the SkPath will count
  /// down the uses and eventually reset the volatile flag.
  ///
  /// @see |kMaxVolatileUses|
  void WillRenderSkPath() const;

  [[nodiscard]] DlPath WithOffset(const DlPoint& offset) const;
  [[nodiscard]] DlPath WithFillType(DlPathFillType type) const;

  bool IsRect(DlRect* rect = nullptr, bool* is_closed = nullptr) const;
  bool IsOval(DlRect* bounds = nullptr) const;
  bool IsLine(DlPoint* start = nullptr, DlPoint* end = nullptr) const;
  bool IsRoundRect(DlRoundRect* rrect = nullptr) const;

  bool Contains(const DlPoint& point) const;

  DlRect GetBounds() const override;
  DlPathFillType GetFillType() const override;

  bool operator==(const DlPath& other) const;
  bool operator!=(const DlPath& other) const { return !(*this == other); }

  bool IsConverted() const;
  bool IsVolatile() const;
  bool IsConvex() const override;

  DlPath operator+(const DlPath& other) const;

 private:
  struct Data {
    explicit Data(const SkPath& path) : sk_path(path), sk_path_original(true) {
      FML_DCHECK(!SkPathFillType_IsInverse(path.getFillType()));
    }
    explicit Data(const impeller::Path& path)
        : path(path), sk_path_original(false) {}

    std::optional<SkPath> sk_path;
    std::optional<impeller::Path> path;
    uint32_t render_count = 0u;
    const bool sk_path_original;
  };

  std::shared_ptr<Data> data_;

  static void DispatchFromSkiaPath(const SkPath& path,
                                   DlPathReceiver& receiver);

  static void DispatchFromImpellerPath(const impeller::Path& path,
                                       DlPathReceiver& receiver);

  static SkPath ConvertToSkiaPath(const impeller::Path& path);

  static impeller::Path ConvertToImpellerPath(const SkPath& path);
};

}  // namespace flutter

#endif  // FLUTTER_DISPLAY_LIST_GEOMETRY_DL_PATH_H_
