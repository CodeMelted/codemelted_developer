/*
===============================================================================
MIT License

© 2024 Mark Shaffer. All Rights Reserved.

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
===============================================================================
*/

// TODO: Tab Theme definition to follow style of other widgets.
//       1. Remove items from CTabItem. They should be in theme.
//       2. Allow for customization of icon placement in relation to title.
//       3. Ensure at least title or icon are specified.
//       4. Take some of the scaffold items from the uiTabView and add to the
//          theme.

// TODO: Text Field Theme definition to follow style of other uiComboBox.
//       This represents the standard I would like to shoot for.

import 'package:flutter/material.dart';

/// Provides an alternative to the flutter DialogTheme class. This is due
/// to the fact it really does not theme much when utilizing the built-in
/// [AlertDialog] of Flutter wrapped in the codemelted_dlg_xxx functions.
class CDialogTheme extends ThemeExtension<CDialogTheme> {
  /// Background color for the entire dialog panel.
  final Color? backgroundColor;

  /// The title foreground color for the text and close icon.
  final Color? titleColor;

  /// The foreground color of the content color for all dialog types minus
  /// custom dialogs. There the developer sets the color of the content.
  final Color? contentColor;

  /// The foreground color of the Text buttons for the dialog.
  final Color? actionsColor;

  @override
  CDialogTheme copyWith({
    Color? backgroundColor,
    Color? titleColor,
    Color? contentColor,
    Color? actionsColor,
  }) {
    return CDialogTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      titleColor: titleColor ?? this.titleColor,
      contentColor: contentColor ?? this.contentColor,
      actionsColor: actionsColor ?? this.actionsColor,
    );
  }

  @override
  CDialogTheme lerp(CDialogTheme? other, double t) {
    if (other is! CDialogTheme) {
      return this;
    }
    return CDialogTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      titleColor: Color.lerp(titleColor, other.titleColor, t),
      contentColor: Color.lerp(contentColor, other.contentColor, t),
      actionsColor: Color.lerp(actionsColor, other.actionsColor, t),
    );
  }

  /// Constructor for the theme. Sets up generic colors if none are specified.
  const CDialogTheme({
    this.backgroundColor = const Color.fromARGB(255, 2, 48, 32),
    this.titleColor = Colors.amber,
    this.contentColor = Colors.white,
    this.actionsColor = Colors.lightBlueAccent,
  });
}

/// Provides an extension on the ThemeData object to access the [CDialogTheme]
/// object as part of the ThemeData object.
extension ThemeDataExtension on ThemeData {
  /// Accesses the [CDialogTheme] for the codemelted_dlg_xxx methods.
  CDialogTheme get cDialogTheme => extension<CDialogTheme>()!;
}
