# BellyButton App - QA Testing Guide

> **Version**: 1.0.0+2
> **Last Updated**: January 2026
> **For**: QA Testing Team

---

## Table of Contents

1. [App Overview](#1-app-overview)
2. [Test Environments](#2-test-environments)
3. [User Roles & Permissions](#3-user-roles--permissions)
4. [Feature Testing Guide](#4-feature-testing-guide)
5. [Test Scenarios](#5-test-scenarios)
6. [API Testing](#6-api-testing)
7. [Edge Cases & Error Handling](#7-edge-cases--error-handling)
8. [Performance Testing](#8-performance-testing)
9. [Device Compatibility](#9-device-compatibility)
10. [Bug Reporting Template](#10-bug-reporting-template)

---

## 1. App Overview

### What is BellyButton?

BellyButton is an **event management and photo-sharing app** that allows users to:

- Create events with date, time, and timezone
- Invite friends/family via phone numbers
- Share photos within event galleries
- Receive push notifications for event updates
- Access shared galleries via links

### Core User Journey

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│   Download   │───►│   Sign Up    │───►│   Create     │
│     App      │    │  (Phone OTP) │    │    Event     │
└──────────────┘    └──────────────┘    └──────────────┘
                                               │
                                               ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│    Share     │◄───│   Upload     │◄───│   Invite     │
│   Gallery    │    │   Photos     │    │    Users     │
└──────────────┘    └──────────────┘    └──────────────┘
```

---

## 2. Test Environments

### Environment URLs

| Environment | Base URL | Purpose |
|-------------|----------|---------|
| **Development** | `mobapidev.bellybutton.global` | Daily development testing |
| **Testing/QA** | `mobapitest.bellybutton.global` | QA team testing |
| **Production** | `mobapi.bellybutton.global` | Live app |

### Test Builds

| Platform | Build Type | Location |
|----------|------------|----------|
| Android | APK | Firebase App Distribution / TestFlight |
| iOS | TestFlight | Apple TestFlight |

### Test Accounts

> **Note**: Request test accounts from the development team

| Role | Phone Number | Purpose |
|------|--------------|---------|
| Event Creator | [Request from dev] | Creating and managing events |
| Invited User | [Request from dev] | Testing invitation flows |
| New User | Any new number | Testing signup flow |

---

## 3. User Roles & Permissions

### Role Types

| Role | Description | Capabilities |
|------|-------------|--------------|
| **Event Creator** | User who creates the event | Full control - edit, delete, invite, upload, share |
| **Event Admin** | Promoted by creator | Can invite users, upload photos |
| **Invited User (view-sync)** | Standard invited user | Can view & upload photos |
| **Invited User (view-only)** | Limited access user | Can only view photos |
| **Public Viewer** | Via shared link | View-only, no account needed |

### Permission Matrix

| Action | Creator | Admin | View-Sync | View-Only | Public |
|--------|---------|-------|-----------|-----------|--------|
| View event details | ✅ | ✅ | ✅ | ✅ | ✅ |
| View photos | ✅ | ✅ | ✅ | ✅ | ✅ |
| Upload photos | ✅ | ✅ | ✅ | ❌ | ❌ |
| Invite users | ✅ | ✅ | ❌ | ❌ | ❌ |
| Edit event | ✅ | ❌ | ❌ | ❌ | ❌ |
| Delete event | ✅ | ❌ | ❌ | ❌ | ❌ |
| Share event link | ✅ | ✅ | ✅ | ✅ | ❌ |

---

## 4. Feature Testing Guide

### 4.1 Authentication Module

#### Phone Login Screen

**Location**: First screen after onboarding

**UI Elements to Test**:
- [ ] Country picker dropdown (shows country flag + code)
- [ ] Phone number input field
- [ ] Terms & Conditions checkbox
- [ ] "Continue" button
- [ ] Terms & Conditions link (opens T&C page)

**Test Cases**:

| Test ID | Test Case | Steps | Expected Result |
|---------|-----------|-------|-----------------|
| AUTH-001 | Valid phone login | 1. Select country 2. Enter valid phone 3. Check T&C 4. Tap Continue | OTP screen opens, SMS received |
| AUTH-002 | Invalid phone number | Enter invalid/short phone number | Error message shown |
| AUTH-003 | T&C not checked | Try to continue without checking T&C | Button disabled or error shown |
| AUTH-004 | Country auto-detection | Open app fresh | Country auto-selected based on SIM/locale |
| AUTH-005 | Change country | Tap country picker, select different country | Country code updates, phone format changes |

---

#### OTP Verification Screen

**Location**: After phone number submission

**UI Elements to Test**:
- [ ] 6-digit OTP input boxes
- [ ] Resend OTP button (with timer)
- [ ] Back button
- [ ] Auto-fill from SMS (Android)

**Test Cases**:

| Test ID | Test Case | Steps | Expected Result |
|---------|-----------|-------|-----------------|
| OTP-001 | Valid OTP | Enter correct 6-digit OTP | Login successful, navigate to Dashboard/Profile Setup |
| OTP-002 | Invalid OTP | Enter wrong OTP | Error message: "Invalid OTP" |
| OTP-003 | Expired OTP | Wait 5+ minutes, enter OTP | Error message: "OTP expired" |
| OTP-004 | Resend OTP | Wait for timer (30s), tap Resend | New OTP sent, timer resets |
| OTP-005 | SMS Auto-fill | Receive SMS on Android | OTP auto-fills in input boxes |
| OTP-006 | Max attempts | Enter wrong OTP 5 times | Account locked / cooldown message |

---

#### Profile Setup Screen

**Location**: After first-time login

**UI Elements to Test**:
- [ ] Profile photo picker (camera/gallery)
- [ ] Name input field
- [ ] Email input field
- [ ] Bio/About field
- [ ] Save/Continue button

**Test Cases**:

| Test ID | Test Case | Steps | Expected Result |
|---------|-----------|-------|-----------------|
| PROF-001 | Complete profile | Fill all fields, add photo, save | Profile saved, navigate to Dashboard |
| PROF-002 | Skip photo | Complete without adding photo | Profile saved with default avatar |
| PROF-003 | Invalid email | Enter invalid email format | Validation error shown |
| PROF-004 | Empty name | Try to save without name | Error: "Name is required" |
| PROF-005 | Photo crop | Select photo, crop | Cropped image shown as preview |
| PROF-006 | Camera permission | Tap camera, deny permission | Permission denied message, option to settings |

---

### 4.2 Dashboard Module

#### Main Dashboard

**Location**: Home screen after login

**UI Elements to Test**:
- [ ] Tab bar (Upcoming / Past events)
- [ ] Event cards list
- [ ] Create event FAB (floating action button)
- [ ] Notification bell icon (with badge)
- [ ] Profile icon
- [ ] Pull-to-refresh

**Test Cases**:

| Test ID | Test Case | Steps | Expected Result |
|---------|-----------|-------|-----------------|
| DASH-001 | View upcoming events | Open Dashboard, Upcoming tab | List of future events shown |
| DASH-002 | View past events | Tap Past tab | List of completed events shown |
| DASH-003 | Empty state | New user with no events | "No events" placeholder shown |
| DASH-004 | Pull to refresh | Pull down on event list | Events refreshed from server |
| DASH-005 | Notification badge | Have unread notifications | Badge shows count on bell icon |
| DASH-006 | Event card tap | Tap on any event card | Opens event gallery |

---

### 4.3 Event Creation

#### Create Event Screen

**Location**: Tap "+" FAB on Dashboard

**UI Elements to Test**:
- [ ] Event name input
- [ ] Event description input
- [ ] Date picker
- [ ] Start time picker
- [ ] End time picker
- [ ] Timezone selector
- [ ] Create button

**Test Cases**:

| Test ID | Test Case | Steps | Expected Result |
|---------|-----------|-------|-----------------|
| EVT-001 | Create valid event | Fill all fields, tap Create | Event created, shown in Upcoming |
| EVT-002 | Past date | Select date in the past | Error: "Cannot create past event" |
| EVT-003 | End before start | Set end time before start time | Error: "End time must be after start" |
| EVT-004 | Empty name | Try to create without name | Validation error |
| EVT-005 | Timezone selection | Change timezone | Time displayed in selected timezone |
| EVT-006 | Long description | Enter 500+ characters | Text truncated or scrollable |

---

### 4.4 Event Gallery

#### Gallery Screen

**Location**: Tap on any event card

**UI Elements to Test**:
- [ ] Photo grid (staggered layout)
- [ ] Upload button/FAB
- [ ] Share button
- [ ] Event details header
- [ ] Photo count
- [ ] Member list button

**Test Cases**:

| Test ID | Test Case | Steps | Expected Result |
|---------|-----------|-------|-----------------|
| GAL-001 | View photos | Open event gallery | Photos displayed in grid |
| GAL-002 | Photo preview | Tap on any photo | Full-screen preview opens |
| GAL-003 | Zoom photo | Pinch zoom in preview | Photo zooms in/out |
| GAL-004 | Swipe photos | Swipe left/right in preview | Navigate between photos |
| GAL-005 | Empty gallery | Event with no photos | "No photos" placeholder |
| GAL-006 | Loading state | Open gallery with many photos | Shimmer/skeleton loading shown |

---

### 4.5 Photo Upload

#### Upload Flow

**Test Cases**:

| Test ID | Test Case | Steps | Expected Result |
|---------|-----------|-------|-----------------|
| UPL-001 | Single photo | Select 1 photo, upload | Photo appears in gallery |
| UPL-002 | Multiple photos | Select 5 photos, upload | All photos uploaded, progress shown |
| UPL-003 | Large photo | Upload 10MB+ image | Photo compressed/uploaded successfully |
| UPL-004 | Upload progress | Upload multiple photos | Progress indicator shown |
| UPL-005 | Cancel upload | Start upload, cancel | Upload cancelled, partial uploads removed |
| UPL-006 | No permission | Deny gallery permission | Permission error, settings option |
| UPL-007 | Network fail | Upload with no internet | Error message, retry option |

---

### 4.6 Invitations

#### Invite Users Screen

**Location**: From event menu → Invite

**UI Elements to Test**:
- [ ] Contact list/search
- [ ] Phone number input
- [ ] Selected users chips
- [ ] Send invite button
- [ ] Permission toggle (view-sync / view-only)

**Test Cases**:

| Test ID | Test Case | Steps | Expected Result |
|---------|-----------|-------|-----------------|
| INV-001 | Invite by contact | Select contact from list | User added to invite list |
| INV-002 | Invite by phone | Enter phone number manually | User added to invite list |
| INV-003 | Send invitations | Add users, tap Send | Invites sent, success message |
| INV-004 | Duplicate invite | Invite already invited user | Error: "User already invited" |
| INV-005 | Invalid phone | Enter invalid phone format | Validation error |
| INV-006 | Remove from list | Tap X on selected user chip | User removed from list |

---

#### Received Invitations Screen

**Location**: Dashboard → Invitations tab/button

**Test Cases**:

| Test ID | Test Case | Steps | Expected Result |
|---------|-----------|-------|-----------------|
| INV-007 | View invitations | Open invitations screen | List of pending invitations |
| INV-008 | Accept invitation | Tap Accept on invitation | Event added to your events, status changes |
| INV-009 | Reject invitation | Tap Reject on invitation | Invitation removed from list |
| INV-010 | Event conflict | Accept event overlapping another | Warning shown about conflict |
| INV-011 | Empty state | No pending invitations | "No invitations" message |

---

### 4.7 Notifications

#### Notifications Screen

**Location**: Tap bell icon on Dashboard

**UI Elements to Test**:
- [ ] Notification list
- [ ] Read/unread indicators
- [ ] Notification timestamp
- [ ] Pull-to-refresh
- [ ] Empty state

**Test Cases**:

| Test ID | Test Case | Steps | Expected Result |
|---------|-----------|-------|-----------------|
| NOT-001 | View notifications | Open notifications | List of all notifications |
| NOT-002 | Unread indicator | Have unread notifications | Unread shown with dot/highlight |
| NOT-003 | Mark as read | Tap on notification | Notification marked as read |
| NOT-004 | Navigate from notification | Tap event notification | Opens relevant event/screen |
| NOT-005 | Push notification | Receive push while app closed | System notification appears |
| NOT-006 | In-app notification | Receive push while app open | In-app banner/popup shown |

---

### 4.8 Deep Links & Sharing

#### Share Event

**Test Cases**:

| Test ID | Test Case | Steps | Expected Result |
|---------|-----------|-------|-----------------|
| SHARE-001 | Generate share link | Tap Share in event | Share sheet opens with link |
| SHARE-002 | Copy link | Tap Copy in share sheet | Link copied to clipboard |
| SHARE-003 | Share via WhatsApp | Share to WhatsApp | Message with link sent |
| SHARE-004 | Open shared link (logged in) | Click link while logged in | Opens event gallery |
| SHARE-005 | Open shared link (logged out) | Click link while logged out | Opens login, then event |
| SHARE-006 | Invalid link | Open expired/invalid link | Error message shown |

---

### 4.9 Profile Management

#### Profile Screen

**Location**: Tap profile icon on Dashboard

**Test Cases**:

| Test ID | Test Case | Steps | Expected Result |
|---------|-----------|-------|-----------------|
| PRFL-001 | View profile | Open profile screen | User details displayed |
| PRFL-002 | Edit name | Change name, save | Name updated |
| PRFL-003 | Edit photo | Change profile photo | Photo updated everywhere |
| PRFL-004 | Logout | Tap Logout | Logged out, back to login screen |
| PRFL-005 | Delete account | Delete account flow | Account deleted, data removed |

---

## 5. Test Scenarios

### 5.1 End-to-End Scenarios

#### Scenario 1: New User Complete Flow

```
1. Install app fresh
2. Complete onboarding slides
3. Enter phone number
4. Verify OTP
5. Complete profile setup
6. Create first event
7. Invite a friend
8. Upload photos
9. Share event link
```

**Expected**: All steps complete without errors

---

#### Scenario 2: Invited User Flow

```
1. User A creates event and invites User B
2. User B receives notification
3. User B opens app, sees invitation
4. User B accepts invitation
5. Event appears in User B's list
6. User B opens event, views photos
7. User B uploads own photos
8. User A sees User B's photos
```

**Expected**: Photos sync between both users

---

#### Scenario 3: Public Gallery Access

```
1. User A creates event with photos
2. User A generates share link
3. User A sends link to non-app user
4. Non-app user opens link in browser
5. Public gallery loads with photos
```

**Expected**: Photos visible without login

---

#### Scenario 4: Offline → Online Sync

```
1. User opens app with internet
2. User loads events/photos
3. User goes offline (airplane mode)
4. User browses cached content
5. User tries to upload photo (should queue/fail gracefully)
6. User goes back online
7. Check if queued actions complete
```

**Expected**: Graceful offline handling, sync on reconnect

---

### 5.2 Negative Test Scenarios

| Scenario | Test | Expected |
|----------|------|----------|
| No Internet | Try any API action | "No internet connection" error |
| Session Expired | Use app after token expires | Redirected to login |
| Server Down | Try any action when server is down | Timeout error with retry option |
| Invalid Data | Send malformed data | Validation errors shown |
| Concurrent Edit | Two users edit same event | Last save wins / conflict resolution |

---

## 6. API Testing

### Key Endpoints to Test

#### Authentication APIs

```
POST /userresource/auth/send-otp
- Valid phone → 200 OK, OTP sent
- Invalid phone → 400 Bad Request
- Rate limited → 429 Too Many Requests

POST /userresource/auth/verify-otp
- Valid OTP → 200 OK, token returned
- Invalid OTP → 401 Unauthorized
- Expired OTP → 401 Unauthorized
```

#### Event APIs

```
POST /eventresource/create/event
- Valid data → 201 Created
- Missing fields → 400 Bad Request
- Unauthorized → 401 Unauthorized

GET /eventresource/list/my/events
- Authorized → 200 OK, events array
- Unauthorized → 401 Unauthorized
```

#### Photo APIs

```
POST /userresource/event/upload
- Valid image → 200 OK
- Too large → 413 Payload Too Large
- Invalid format → 400 Bad Request
```

### API Response Codes

| Code | Meaning | Action |
|------|---------|--------|
| 200 | Success | Display data |
| 201 | Created | Show success message |
| 400 | Bad Request | Show validation error |
| 401 | Unauthorized | Redirect to login |
| 403 | Forbidden | Show permission error |
| 404 | Not Found | Show "not found" message |
| 429 | Rate Limited | Show "try again later" |
| 500 | Server Error | Show generic error |

---

## 7. Edge Cases & Error Handling

### Network Edge Cases

| Case | Test Steps | Expected Behavior |
|------|------------|-------------------|
| Slow network | Throttle to 2G speed | Loading indicators, no timeout |
| Network switch | Switch WiFi ↔ Mobile | Seamless transition |
| Airplane mode | Enable during action | Graceful error message |
| Server timeout | Mock 30s+ response | Timeout message, retry option |

### Data Edge Cases

| Case | Test Steps | Expected Behavior |
|------|------------|-------------------|
| Empty lists | New user, no events | Empty state placeholder |
| Very long text | 1000+ char event name | Text truncated with "..." |
| Special characters | Use emoji, unicode in names | Displayed correctly |
| Large numbers | 100+ photos, 50+ members | Pagination or lazy loading |

### UI Edge Cases

| Case | Test Steps | Expected Behavior |
|------|------------|-------------------|
| Small screen | Test on 4" phone | UI adapts, no overflow |
| Large screen | Test on tablet | UI scales appropriately |
| Dark mode | Enable system dark mode | App respects dark theme |
| Font scaling | Set large system font | Text readable, no cutoff |
| Rotation | Rotate device | UI handles orientation |

---

## 8. Performance Testing

### Load Time Benchmarks

| Screen | Target Load Time | Acceptable |
|--------|------------------|------------|
| Splash screen | < 2 seconds | < 3 seconds |
| Dashboard | < 3 seconds | < 5 seconds |
| Event gallery (50 photos) | < 4 seconds | < 6 seconds |
| Photo upload (5 photos) | < 10 seconds | < 15 seconds |

### Memory & Battery

| Test | How to Test | Acceptable |
|------|-------------|------------|
| Memory usage | Monitor in dev tools | < 200MB |
| Battery drain | Use for 30 min | < 10% drain |
| Background activity | Check battery settings | Minimal background |

### Stress Testing

| Test | Steps | Expected |
|------|-------|----------|
| Rapid navigation | Quickly tap between screens | No crashes, smooth |
| Multiple uploads | Upload 20 photos at once | Queue handled, progress shown |
| Long session | Use app for 1+ hour | No memory leaks |

---

## 9. Device Compatibility

### Minimum Requirements

| Platform | Minimum Version |
|----------|-----------------|
| Android | API 21 (Android 5.0 Lollipop) |
| iOS | iOS 12.0 |

### Recommended Test Devices

#### Android

| Device | OS Version | Screen Size | Priority |
|--------|------------|-------------|----------|
| Samsung Galaxy S21 | Android 13 | 6.2" | High |
| Google Pixel 6 | Android 14 | 6.4" | High |
| Samsung Galaxy A52 | Android 12 | 6.5" | Medium |
| OnePlus 9 | Android 13 | 6.55" | Medium |
| Xiaomi Redmi Note 10 | Android 11 | 6.43" | Medium |
| Old device (any) | Android 5-6 | Various | Low |

#### iOS

| Device | OS Version | Screen Size | Priority |
|--------|------------|-------------|----------|
| iPhone 14 Pro | iOS 17 | 6.1" | High |
| iPhone 13 | iOS 16 | 6.1" | High |
| iPhone SE (2nd gen) | iOS 15 | 4.7" | Medium |
| iPhone 11 | iOS 15 | 6.1" | Medium |
| iPad (any) | iOS 15+ | Various | Low |

### Compatibility Checklist

- [ ] App installs successfully
- [ ] All screens render correctly
- [ ] Touch interactions work
- [ ] Camera/gallery permissions work
- [ ] Push notifications work
- [ ] Deep links open correctly
- [ ] No crashes during normal use

---

## 10. Bug Reporting Template

### Bug Report Format

```markdown
## Bug Title
[Short, descriptive title]

## Environment
- **App Version**: 1.0.0
- **Device**: iPhone 14 Pro
- **OS Version**: iOS 17.2
- **Environment**: Testing/QA

## Steps to Reproduce
1. [First step]
2. [Second step]
3. [Third step]

## Expected Result
[What should happen]

## Actual Result
[What actually happened]

## Screenshots/Videos
[Attach evidence]

## Severity
- [ ] Critical (App crash, data loss)
- [ ] High (Feature broken, no workaround)
- [ ] Medium (Feature broken, workaround exists)
- [ ] Low (Minor UI issue, cosmetic)

## Additional Notes
[Any other relevant information]
```

### Example Bug Report

```markdown
## Bug Title
OTP screen crashes when entering 7th digit

## Environment
- **App Version**: 1.0.0+2
- **Device**: Samsung Galaxy S21
- **OS Version**: Android 13
- **Environment**: Testing

## Steps to Reproduce
1. Open app and enter phone number
2. Receive OTP via SMS
3. In OTP screen, enter 6 digits
4. Quickly tap another digit (7th)

## Expected Result
App should ignore extra digit or show error

## Actual Result
App crashes and returns to home screen

## Screenshots/Videos
[crash_video.mp4]

## Severity
- [x] Critical (App crash, data loss)

## Additional Notes
Happens consistently on Android devices.
iOS handles this gracefully.
```

---

## Quick Reference Checklists

### Daily Smoke Test (5 minutes)

- [ ] App launches successfully
- [ ] Login works with valid credentials
- [ ] Dashboard loads with events
- [ ] Can create new event
- [ ] Can view event gallery
- [ ] Push notifications received

### Pre-Release Checklist

- [ ] All P0/P1 bugs fixed
- [ ] All test scenarios pass
- [ ] Performance benchmarks met
- [ ] No crashes in crash reporting
- [ ] Tested on min supported devices
- [ ] Deep links working
- [ ] Push notifications working
- [ ] Offline mode graceful

### Regression Checklist

- [ ] Authentication flow
- [ ] Event CRUD operations
- [ ] Photo upload/view
- [ ] Invitation flow
- [ ] Notification system
- [ ] Profile management
- [ ] Share functionality
- [ ] Deep linking

---

## Contact & Support

| Role | Contact |
|------|---------|
| **Developer** | Aravinth Kannan |
| **Email** | flutterdev.aravinth@gmail.com |
| **Bug Reports** | [Project Issue Tracker] |

---

*QA Testing Guide for BellyButton App v1.0.0*
*Last Updated: January 2026*
