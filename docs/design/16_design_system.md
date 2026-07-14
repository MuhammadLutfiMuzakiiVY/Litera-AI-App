# Design System

## 1. Design Principles

- Calm and focused for learning.
- Minimal but not empty.
- Professional for teachers.
- Friendly enough for students.
- Native feel on Android and iOS.
- Accessible by default.

## 2. Foundations

### Color Tokens

Palette avoids a single-hue UI by combining educational blue, fresh green, warm amber, and neutral gray.

| Token | Light | Dark | Usage |
| --- | --- | --- | --- |
| primary | `#2563EB` | `#7AA2FF` | Main actions, active nav. |
| secondary | `#0F766E` | `#5EEAD4` | Mastery, progress, success accents. |
| tertiary | `#F59E0B` | `#FBBF24` | Attention, recommendations, highlights. |
| error | `#DC2626` | `#FCA5A5` | Error states. |
| surface | `#FFFFFF` | `#111827` | App surfaces. |
| surfaceVariant | `#F3F4F6` | `#1F2937` | Section backgrounds. |
| outline | `#D1D5DB` | `#4B5563` | Dividers, borders. |
| textPrimary | `#111827` | `#F9FAFB` | Main text. |
| textSecondary | `#4B5563` | `#D1D5DB` | Supporting text. |

### Typography

Use Material 3 type scale with platform-appropriate font fallback:

- Android: Roboto.
- iOS: SF Pro via system font.
- Fallback: system sans-serif.

| Role | Size | Weight |
| --- | --- | --- |
| Display small | 36 | 600 |
| Headline medium | 28 | 600 |
| Title large | 22 | 600 |
| Title medium | 16 | 600 |
| Body large | 16 | 400 |
| Body medium | 14 | 400 |
| Label large | 14 | 600 |
| Label small | 11 | 500 |

Rules:

- Do not scale font size with viewport width.
- Letter spacing remains 0 unless Material defaults require otherwise.
- Learning content uses comfortable line height.

### Spacing

Base spacing: 4 dp grid.

| Token | Value |
| --- | --- |
| space-1 | 4 |
| space-2 | 8 |
| space-3 | 12 |
| space-4 | 16 |
| space-5 | 20 |
| space-6 | 24 |
| space-8 | 32 |

### Shape

- Buttons: 8 dp radius.
- Cards: 8 dp radius maximum.
- Inputs: 8 dp radius.
- Chips: 8 dp radius unless using native segmented control.
- Dialogs: platform default with restrained shape.

## 3. Components

### Atoms

- AppText.
- AppButton with loading state.
- AppIconButton with tooltip.
- AppTextField with validation.
- AppChip.
- AppProgressBar.
- AppBadge.
- AppSkeleton.

### Molecules

- AuthForm.
- OtpInput.
- QuestionOptionTile.
- ModuleProgressTile.
- MasteryIndicator.
- RiskBadge.
- RetryPanel.
- EmptyStatePanel.
- OfflineBanner.

### Organisms

- StudentDashboardSummary.
- LearningPathList.
- AdaptiveQuizQuestion.
- TeacherClassroomSummary.
- StudentRiskList.
- ConceptMasteryHeatmap.
- InterventionRecommendationPanel.

## 4. States

Every interactive component supports:

- Enabled.
- Disabled.
- Loading.
- Pressed.
- Focused.
- Error.
- Success where relevant.

Every data screen supports:

- Loading skeleton.
- Empty state.
- Error state.
- Offline cached state.
- Retry action.

## 5. Motion

- Use Material motion for route transitions on Android.
- Use Cupertino page transition on iOS.
- Duration: 150-250 ms for common transitions.
- Avoid heavy animation on low-end devices.
- Respect reduced motion accessibility setting.

## 6. Icons

Use Material Symbols or Flutter built-in Material/Cupertino icons consistently:

- Home: dashboard.
- Path: route/map.
- Module: menu_book.
- Quiz: quiz.
- History: history.
- Settings: settings.
- Notification: notifications.
- Retry: refresh.
- Download/offline: download/cloud_off.

Icon-only buttons require tooltips and semantic labels.

## 7. Content Style

- Use Bahasa Indonesia by default.
- Keep instructions short and action-oriented.
- Avoid blaming the student for incorrect answers.
- Explain AI recommendations in teacher-friendly language.
- Avoid visible text that explains app features as marketing; focus on the task.

## 8. Dark Mode

- Dark mode must preserve contrast.
- Charts and heatmaps use accessible color ramps.
- Do not rely on red/green only for risk/mastery.
- Image backgrounds should not reduce text readability.

## 9. Accessibility Checklist

- Contrast AA.
- 48x48 dp tap targets.
- Semantic labels.
- Logical focus order.
- Text scale support.
- Screen reader compatible error messages.
- No critical information conveyed by color only.

## 10. Design QA

Before implementation is accepted:

- Test small Android viewport.
- Test iPhone SE-like viewport.
- Test tablet width for teacher dashboard.
- Test light/dark mode.
- Test text scale 200%.
- Test offline banner and long error messages.
