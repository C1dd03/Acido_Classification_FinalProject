# Software Requirements Specification (SRS)
## Analytics Dashboard Module
### Jersey Identification System

---

**Document Version:** 1.0  
**Date:** December 5, 2025  
**Project:** IT120 Jersey Identification System  

---

## 1. Introduction

### 1.1 Purpose
This document specifies the software requirements for the Analytics Dashboard module of the Jersey Identification System. The dashboard provides users with statistical insights and performance metrics for jersey detection activities.

### 1.2 Scope
The Analytics Dashboard is a component of the Jersey Identification mobile application that:
- Displays aggregated detection statistics
- Visualizes detection trends over time
- Analyzes per-class (team) performance
- Identifies problematic classifications

### 1.3 Definitions and Acronyms
| Term | Definition |
|------|------------|
| Detection | A single jersey classification attempt |
| Ground Truth | The actual/correct jersey class selected by the user |
| Prediction | The jersey class predicted by the ML model |
| Verification | User confirmation that a detection result is correct |
| Accuracy | Percentage of correct predictions |
| Confusion Matrix | A table showing prediction vs actual class distributions |

---

## 2. Overall Description

### 2.1 Product Perspective
The Analytics Dashboard is one of three main modules in the Jersey Identification app:
1. **Detect** - Camera-based jersey detection
2. **History** - Detection record management
3. **Analytics** - Statistical analysis and visualization (this module)

### 2.2 User Classes and Characteristics
| User Type | Description |
|-----------|-------------|
| End User | Uses the app to identify NBA jerseys and review detection performance |
| Developer | Uses analytics to evaluate and improve the ML model |

### 2.3 Operating Environment
- **Platform:** Flutter (cross-platform mobile)
- **Minimum OS:** Android 5.0+ / iOS 12.0+
- **Dependencies:** fl_chart package for data visualization

---

## 3. Functional Requirements

### 3.1 Summary Statistics Display

#### FR-3.1.1 Total Detections Counter
- **Description:** Display the total number of detection records
- **Input:** Selected filter (All/Verified/Not Verified)
- **Output:** Integer count displayed in a stat card
- **Priority:** High

#### FR-3.1.2 Overall Accuracy Display
- **Description:** Display the overall prediction accuracy as a percentage
- **Input:** Selected filter
- **Output:** Percentage value (e.g., "85.5%") or "--" if no data
- **Priority:** High

#### FR-3.1.3 Verification Rate Display
- **Description:** Display the percentage of detections that have been verified by users
- **Input:** Selected filter
- **Output:** Percentage value with green color indicator
- **Priority:** Medium

#### FR-3.1.4 Error Rate Display
- **Description:** Display the percentage of incorrect predictions
- **Input:** Selected filter
- **Output:** Percentage value with orange color indicator
- **Priority:** Medium

---

### 3.2 Data Filtering

#### FR-3.2.1 Verification Status Filter
- **Description:** Allow users to filter analytics by verification status
- **Options:**
  - All - Include all records
  - Verified - Only user-confirmed records
  - Not Verified - Only unconfirmed records
- **UI Element:** Dropdown selector with icons
- **Priority:** High

#### FR-3.2.2 Error Mode Toggle
- **Description:** Toggle between normal view and error-focused view
- **Input:** Switch toggle
- **Behavior:**
  - OFF: Show detections and accuracy metrics
  - ON: Show errors and error rate metrics
- **Priority:** Medium

---

### 3.3 Daily Activity Chart

#### FR-3.3.1 Bar Chart Visualization
- **Description:** Display detection/error counts as vertical bars for the last 7 days
- **Data Points:** One bar per day
- **Bar Color:** Blue (detections) or Red (errors mode)
- **Priority:** High

#### FR-3.3.2 Secondary Metric Indicator
- **Description:** Display accuracy/error rate as a secondary thin bar
- **Data Points:** Scaled to match primary Y-axis
- **Bar Color:** Green (accuracy) or Orange (error rate)
- **Priority:** Medium

#### FR-3.3.3 Chart Tooltips
- **Description:** Show detailed information when user taps on a bar
- **Content:**
  - Date
  - Detection/Error count
  - Accuracy/Error rate percentage
- **Priority:** Medium

#### FR-3.3.4 Axis Labels
- **Description:** Display appropriate axis labels
- **Left Axis:** Detection/Error count
- **Right Axis:** Percentage scale (0-100%)
- **Bottom Axis:** Date labels (M/D format)
- **Priority:** Medium

---

### 3.4 Per-Class Performance Analysis

#### FR-3.4.1 Class Performance List
- **Description:** Display a scrollable list of all jersey classes with performance metrics
- **Data per item:**
  - Team color indicator
  - Team name
  - Detection count
  - Accuracy percentage
- **Priority:** High

#### FR-3.4.2 Hardest Classes List (Error Mode)
- **Description:** Rank classes by difficulty (lowest accuracy first)
- **Data per item:**
  - Rank badge (1, 2, 3...)
  - Team color indicator
  - Team name
  - Error count / Sample count
  - Accuracy percentage
- **Visual Indicator:** Red highlight for top 3 and accuracy < 70%
- **Priority:** Medium

---

### 3.5 Navigation

#### FR-3.5.1 Tab Navigation
- **Description:** Dashboard accessible via bottom navigation bar
- **Tab Position:** Third tab (index 2)
- **Tab Icon:** Insights icon
- **Priority:** High

---

## 4. Non-Functional Requirements

### 4.1 Performance

#### NFR-4.1.1 Load Time
- **Requirement:** Dashboard shall load within 500ms
- **Measurement:** Time from tab selection to full render

#### NFR-4.1.2 Data Refresh
- **Requirement:** Statistics shall update automatically when new records are added
- **Trigger:** Widget rebuild on state change

---

### 4.2 Usability

#### NFR-4.2.1 Scrollable Content
- **Requirement:** All content shall be accessible via vertical scrolling
- **Rationale:** Support devices with smaller screens

#### NFR-4.2.2 Visual Hierarchy
- **Requirement:** Important metrics shall be prominently displayed
- **Implementation:** Stat cards at top, charts in middle, lists at bottom

#### NFR-4.2.3 Color Coding
- **Requirement:** Use consistent colors for status indication
- **Colors:**
  - Green: Positive/Verified/Correct
  - Orange: Warning/Error rate
  - Red: Negative/Errors
  - Blue: Primary/Neutral

---

### 4.3 Reliability

#### NFR-4.3.1 Empty State Handling
- **Requirement:** Display appropriate message when no data is available
- **Message:** "No data for the last 7 days" (chart), "--" (stats)

#### NFR-4.3.2 Data Integrity
- **Requirement:** Statistics shall accurately reflect stored records
- **Validation:** Cross-reference with History page counts

---

### 4.4 Maintainability

#### NFR-4.4.1 Modular Design
- **Requirement:** Dashboard components shall be implemented as separate widgets
- **Components:**
  - `_StatCard` - Reusable stat display
  - `_DailyStatsChart` - Chart visualization
  - `_LegendItem` - Chart legend item

---

## 5. Data Requirements

### 5.1 Input Data

| Data Element | Type | Source |
|--------------|------|--------|
| Detection Records | List<DetectionRecord> | DetectionStorageService |
| Class Names | List<String> | AppColors.classNames |
| Class Colors | List<Color> | AppColors.classColors |

### 5.2 Computed Metrics

| Metric | Formula | Method |
|--------|---------|--------|
| Total Detections | COUNT(records) | `getTotalDetections()` |
| Accuracy | correct / total | `getAccuracy()` |
| Verification Rate | verified / total | `getVerificationRate()` |
| Error Rate | incorrect / total | `getErrorRate()` |
| Daily Stats | GROUP BY date | `getDailyStats()` |
| Per-Class Counts | GROUP BY class | `getDetectionsPerClass()` |
| Class Accuracy | correct[class] / total[class] | `getAccuracyForClass()` |

---

## 6. Interface Requirements

### 6.1 User Interface

```
┌─────────────────────────────────────┐
│           Analytics (AppBar)         │
├─────────────────────────────────────┤
│  Dashboard                           │
│  ┌─────────────┐ ┌─────────────┐    │
│  │ Filter: All ▼│ │ Errors: OFF │    │
│  └─────────────┘ └─────────────┘    │
│                                      │
│  ┌───────────┐ ┌───────────┐        │
│  │  Total    │ │  Accuracy │        │
│  │   125     │ │   85.5%   │        │
│  └───────────┘ └───────────┘        │
│                                      │
│  ┌───────────┐ ┌───────────┐        │
│  │ Verified  │ │ Error Rate│        │
│  │   72.0%   │ │   14.5%   │        │
│  └───────────┘ └───────────┘        │
│                                      │
│  ┌─────────────────────────────┐    │
│  │     Daily Activity Chart     │    │
│  │  ▓▓▓                        │    │
│  │  ▓▓▓ ▓▓▓     ▓▓▓            │    │
│  │  ▓▓▓ ▓▓▓ ▓▓▓ ▓▓▓ ▓▓▓ ▓▓▓   │    │
│  │  Mon Tue Wed Thu Fri Sat    │    │
│  └─────────────────────────────┘    │
│                                      │
│  Per-Class Performance               │
│  ┌─────────────────────────────┐    │
│  │ ▌ Boston Celtics    85.0%   │    │
│  │ ▌ Brooklyn Nets     92.3%   │    │
│  │ ▌ Chicago Bulls     78.5%   │    │
│  │ ...                         │    │
│  └─────────────────────────────┘    │
│                                      │
├─────────────────────────────────────┤
│  [Detect]  [History]  [Analytics]   │
└─────────────────────────────────────┘
```

### 6.2 Software Interfaces

| Interface | Description |
|-----------|-------------|
| DetectionStorageService | Provides detection records and computed statistics |
| AppColors/AppTheme | Provides consistent styling constants |
| fl_chart | Third-party charting library for visualizations |

---

## 7. Appendix

### 7.1 Supported Jersey Classes

| Index | Team Name | Color Code |
|-------|-----------|------------|
| 0 | Boston Celtics | #007A33 |
| 1 | Brooklyn Nets | #000000 |
| 2 | Chicago Bulls | #CE1141 |
| 3 | Dallas Mavericks | #00538C |
| 4 | Denver Nuggets | #FEC524 |
| 5 | Golden State Warriors | #1D428A |
| 6 | Los Angeles Lakers | #552583 |
| 7 | Miami Heat | #98002E |
| 8 | Milwaukee Bucks | #00471B |
| 9 | Phoenix Suns | #1D1160 |

---

**End of Document**
