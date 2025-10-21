// Theme colors
export const colors = {
  // Primary colors
  primary: '#1da1f2',
  primaryDark: '#1a91da',
  primaryLight: '#71c9f8',
  
  // Secondary colors
  secondary: '#14171a',
  secondaryLight: '#657786',
  secondaryDark: '#000000',
  
  // Accent colors
  accent: '#1da1f2',
  accentSecondary: '#17bf63',
  
  // Status colors
  success: '#17bf63',
  warning: '#ffad1f',
  error: '#e0245e',
  info: '#1da1f2',
  
  // Neutral colors
  white: '#ffffff',
  black: '#000000',
  
  // Grays
  gray50: '#f7f9fa',
  gray100: '#e1e8ed',
  gray200: '#aab8c2',
  gray300: '#657786',
  gray400: '#536471',
  gray500: '#657786',
  gray600: '#536471',
  gray700: '#3d4852',
  gray800: '#253341',
  gray900: '#14171a',
  
  // Background colors
  background: '#ffffff',
  backgroundSecondary: '#f7f9fa',
  backgroundDark: '#15202b',
  backgroundDarkSecondary: '#192734',
  
  // Text colors
  text: '#14171a',
  textSecondary: '#657786',
  textLight: '#ffffff',
  textMuted: '#aab8c2',
  
  // Border colors
  border: '#e1e8ed',
  borderDark: '#38444d',
  borderLight: '#f0f3f4',
  
  // Interactive colors
  link: '#1da1f2',
  linkHover: '#1a91da',
  
  // Social colors
  twitter: '#1da1f2',
  facebook: '#1877f2',
  instagram: '#e4405f',
  linkedin: '#0077b5',
  youtube: '#ff0000',
  
  // Overlay
  overlay: 'rgba(0, 0, 0, 0.4)',
  overlayLight: 'rgba(0, 0, 0, 0.2)',
  overlayDark: 'rgba(0, 0, 0, 0.6)',
};

// Typography
export const typography = {
  // Font families
  fontFamily: {
    regular: 'System',
    medium: 'System',
    bold: 'System',
    light: 'System',
  },
  
  // Font sizes
  fontSize: {
    xs: 12,
    sm: 14,
    base: 16,
    lg: 18,
    xl: 20,
    '2xl': 24,
    '3xl': 30,
    '4xl': 36,
    '5xl': 48,
    '6xl': 60,
  },
  
  // Font weights
  fontWeight: {
    light: '300',
    normal: '400',
    medium: '500',
    semibold: '600',
    bold: '700',
    extrabold: '800',
  },
  
  // Line heights
  lineHeight: {
    tight: 1.25,
    normal: 1.5,
    relaxed: 1.75,
  },
  
  // Letter spacing
  letterSpacing: {
    tight: -0.5,
    normal: 0,
    wide: 0.5,
  },
};

// Spacing
export const spacing = {
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 20,
  '2xl': 24,
  '3xl': 32,
  '4xl': 40,
  '5xl': 48,
  '6xl': 64,
  '7xl': 80,
  '8xl': 96,
};

// Border radius
export const borderRadius = {
  none: 0,
  sm: 4,
  md: 8,
  lg: 12,
  xl: 16,
  '2xl': 20,
  '3xl': 24,
  full: 9999,
};

// Shadows
export const shadows = {
  none: {
    shadowColor: 'transparent',
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0,
    shadowRadius: 0,
    elevation: 0,
  },
  sm: {
    shadowColor: colors.black,
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  md: {
    shadowColor: colors.black,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 4,
  },
  lg: {
    shadowColor: colors.black,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 8,
  },
  xl: {
    shadowColor: colors.black,
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.1,
    shadowRadius: 16,
    elevation: 16,
  },
};

// Breakpoints
export const breakpoints = {
  sm: 640,
  md: 768,
  lg: 1024,
  xl: 1280,
  '2xl': 1536,
};

// Z-index
export const zIndex = {
  hide: -1,
  auto: 'auto',
  base: 0,
  docked: 10,
  dropdown: 1000,
  sticky: 1100,
  banner: 1200,
  overlay: 1300,
  modal: 1400,
  popover: 1500,
  skipLink: 1600,
  toast: 1700,
  tooltip: 1800,
};

// Animation durations
export const duration = {
  instant: 0,
  fast: 150,
  normal: 300,
  slow: 500,
  slower: 750,
  slowest: 1000,
};

// Common component styles
export const commonStyles = {
  // Container styles
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  
  // Center content
  center: {
    justifyContent: 'center' as const,
    alignItems: 'center' as const,
  },
  
  // Flex styles
  flexRow: {
    flexDirection: 'row' as const,
  },
  
  flexColumn: {
    flexDirection: 'column' as const,
  },
  
  flex1: {
    flex: 1,
  },
  
  // Text styles
  textCenter: {
    textAlign: 'center' as const,
  },
  
  textLeft: {
    textAlign: 'left' as const,
  },
  
  textRight: {
    textAlign: 'right' as const,
  },
  
  // Button styles
  buttonBase: {
    justifyContent: 'center' as const,
    alignItems: 'center' as const,
    borderRadius: borderRadius.md,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.md,
  },
  
  // Input styles
  inputBase: {
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: borderRadius.md,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.md,
    fontSize: typography.fontSize.base,
    color: colors.text,
    backgroundColor: colors.white,
  },
  
  // Card styles
  cardBase: {
    backgroundColor: colors.white,
    borderRadius: borderRadius.lg,
    padding: spacing.lg,
    ...shadows.md,
  },
  
  // Header styles
  headerBase: {
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: colors.border,
    backgroundColor: colors.white,
  },
};

// Dark theme
export const darkTheme = {
  ...colors,
  background: colors.backgroundDark,
  backgroundSecondary: colors.backgroundDarkSecondary,
  text: colors.textLight,
  textSecondary: colors.gray300,
  border: colors.borderDark,
  
  // Override card style for dark theme
  cardBase: {
    ...commonStyles.cardBase,
    backgroundColor: colors.backgroundDarkSecondary,
  },
  
  // Override input style for dark theme
  inputBase: {
    ...commonStyles.inputBase,
    backgroundColor: colors.backgroundDarkSecondary,
    borderColor: colors.borderDark,
    color: colors.textLight,
  },
  
  // Override header style for dark theme
  headerBase: {
    ...commonStyles.headerBase,
    backgroundColor: colors.backgroundDark,
    borderBottomColor: colors.borderDark,
  },
};

export default {
  colors,
  typography,
  spacing,
  borderRadius,
  shadows,
  breakpoints,
  zIndex,
  duration,
  commonStyles,
  darkTheme,
};
