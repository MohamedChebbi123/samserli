# RealEstate App - Unified Design System

This document describes the unified design system implemented across the RealEstate Flutter application.

## 🎨 Color Palette

### Primary Colors
- **Primary**: `#2E7FD8` - Main brand color (buttons, highlights, active states)
- **Primary Light**: `#5BA3E8` - Lighter variant for gradients
- **Primary Dark**: `#1E5FB8` - Darker variant for hover states

### Secondary Colors
- **Secondary**: `#00A699` - Accent color for complementary elements

### Background Colors
- **Background**: `#F7F7F7` - Main app background
- **Surface**: `#FFFFFF` - Cards, containers, elevated surfaces
- **Card Background**: `#FFFFFF` - Specific card backgrounds

### Text Colors
- **Text Primary**: `#222222` - Main text, headings
- **Text Secondary**: `#717171` - Secondary text, labels
- **Text Light**: `#9E9E9E` - Disabled text, placeholders
- **Text Dark**: `#1A1A1A` - Extra emphasis text

### Status Colors
- **Success**: `#10B981` - Success messages, positive actions
- **Warning**: `#FFA726` - Warnings, caution messages
- **Error**: `#EF4444` - Errors, destructive actions
- **Info**: `#3B82F6` - Informational messages

### Border Colors
- **Border**: `#E0E0E0` - Standard borders
- **Border Light**: `#F0F0F0` - Subtle borders

## 📏 Spacing System

### Padding & Margin
- **XS**: `4px` - Minimal spacing
- **SM**: `8px` - Small spacing
- **MD**: `16px` - Medium spacing (default)
- **LG**: `24px` - Large spacing
- **XL**: `32px` - Extra large spacing
- **XXL**: `48px` - Maximum spacing

### Border Radius
- **XS**: `4px` - Minimal rounding
- **SM**: `8px` - Small buttons, chips
- **MD**: `12px` - Cards, containers (default)
- **LG**: `16px` - Large cards
- **XL**: `20px` - Modal sheets
- **Full**: `999px` - Circular elements

### Icon Sizes
- **XS**: `16px` - Small icons
- **SM**: `20px` - Standard icons
- **MD**: `24px` - Medium icons (default)
- **LG**: `32px` - Large icons
- **XL**: `48px` - Extra large icons

### Button Heights
- **SM**: `36px` - Small buttons
- **MD**: `44px` - Medium buttons (default)
- **LG**: `52px` - Large buttons

### Card Elevation
- **None**: `0` - Flat elements
- **SM**: `2` - Subtle depth
- **MD**: `4` - Standard cards
- **LG**: `8` - Emphasized cards

## 🔤 Typography

### Display Styles
- **Display Large**: 32px, Bold (700), -0.5 letter spacing
- **Display Medium**: 28px, SemiBold (600), -0.5 letter spacing

### Headline Styles
- **Headline Large**: 24px, SemiBold (600)
- **Headline Medium**: 20px, SemiBold (600)
- **Headline Small**: 18px, SemiBold (600)

### Title Styles
- **Title Large**: 18px, SemiBold (600)
- **Title Medium**: 16px, SemiBold (600)
- **Title Small**: 14px, SemiBold (600)

### Body Styles
- **Body Large**: 16px, Regular (400)
- **Body Medium**: 14px, Regular (400)
- **Body Small**: 12px, Regular (400)

### Label Styles
- **Label Large**: 14px, Medium (500)
- **Label Medium**: 12px, Medium (500)
- **Label Small**: 10px, Medium (500)

### Button Styles
- **Button**: 16px, SemiBold (600)
- **Button Small**: 14px, SemiBold (600)

## 🧩 Component Guidelines

### Buttons
- **Primary Button**: Primary color background, white text, 12px border radius
- **Secondary Button**: White background, primary color border, primary text
- **Text Button**: No background, primary color text
- **Disabled State**: Gray background, reduced opacity

### Cards
- **Standard Card**: White background, 12px border radius, 2-4 elevation
- **Interactive Card**: Add hover/press states with slight scale or shadow change
- **Spacing**: 16px padding inside cards

### Input Fields
- **Standard Input**: White background, gray border, 8px border radius
- **Focused Input**: Primary color border (2px width)
- **Error Input**: Error color border, error message below
- **Padding**: 16px horizontal, 16px vertical

### Icons
- **Interactive Icons**: Primary color when active, secondary text color when inactive
- **Icon Buttons**: 8-12px padding, circular or rounded background
- **Badge/Notification**: Primary color background, white text, circular

### Loading States
- **Spinner**: Primary color, 3px stroke width for standard size
- **Progress Indicators**: Primary color fill

### Navigation Bar
- **Background**: White with subtle shadow
- **Active Item**: Primary color icon and text
- **Inactive Item**: Secondary text color
- **Badge**: Primary color background for notifications

## 📱 Screen Layouts

### Common AppBar Structure
```dart
AppBar(
  backgroundColor: Colors.white,
  elevation: 0,
  iconTheme: IconThemeData(color: AppColors.textPrimary),
  title: Text(
    'Title',
    style: AppTextStyles.headlineSmall,
  ),
)
```

### Common Screen Background
```dart
Scaffold(
  backgroundColor: AppColors.background, // #F7F7F7
  // ...
)
```

### Card Structure
```dart
Container(
  decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadow,
        blurRadius: 10,
        offset: Offset(0, 2),
      ),
    ],
  ),
  padding: EdgeInsets.all(AppSpacing.md),
  // ...
)
```

## 🎯 Usage

Import the constants in your Dart files:

```dart
import 'package:frontend/constants/app_colors.dart';
import 'package:frontend/constants/app_spacing.dart';
import 'package:frontend/constants/app_text_styles.dart';
```

Example usage:

```dart
Container(
  color: AppColors.primary,
  padding: EdgeInsets.all(AppSpacing.md),
  child: Text(
    'Hello',
    style: AppTextStyles.headlineMedium,
  ),
)
```

## ✅ Design Consistency Checklist

- [ ] All screens use `AppColors.background` (#F7F7F7) as scaffold background
- [ ] Primary actions use `AppColors.primary` (#FF385C)
- [ ] Text uses consistent styles from `AppTextStyles`
- [ ] Spacing follows the spacing system (`AppSpacing`)
- [ ] Cards have consistent elevation and border radius
- [ ] Loading indicators use primary color
- [ ] Icon buttons have consistent styling
- [ ] Error states use error color
- [ ] Success states use success color

## 🌙 Dark Mode

The app now supports dark mode with the following features:

### Color Palette - Dark Mode
- **Background**: `#121212` - Main dark background
- **Surface**: `#1E1E1E` - Cards and elevated surfaces
- **Text Primary**: `#FFFFFF` - Main text color
- **Text Secondary**: `#B0B0B0` - Secondary text
- **Primary Color**: `#2E7FD8` - Remains consistent across themes

### Implementation
- **Theme Service**: Manages theme state with persistent storage
- **Toggle Location**: Profile page with switch control
- **Storage**: Uses `flutter_secure_storage` to remember preference
- **Automatic**: Theme persists across app restarts

### Usage
Users can toggle between light and dark mode from the Profile page. The preference is automatically saved and restored when the app is reopened.

### Theme-Aware Widgets
When creating new widgets, use theme colors instead of hardcoded colors:
```dart
// ✅ Good - Theme aware
color: Theme.of(context).cardColor
color: Theme.of(context).textTheme.bodyLarge?.color

// ❌ Bad - Hardcoded
color: Colors.white
color: Color(0xFF222222)
```

## 🔄 Recent Updates

All pages have been updated to use the unified design system:
- ✅ Splash Screen
- ✅ Login & Registration
- ✅ Profile & Edit Profile (with Dark Mode Toggle)
- ✅ Houses List
- ✅ House Details
- ✅ Favorites
- ✅ Your Properties
- ✅ Edit Property
- ✅ Map View
- ✅ Messages Inbox
- ✅ Message User
- ✅ Navigation Bar

**New Features**:
- 🌙 Dark Mode support with persistent storage
- 🎨 Unified color system for both themes
- 💾 Theme preference saved automatically

---

**Last Updated**: December 3, 2025
**Design System Version**: 2.0.0
