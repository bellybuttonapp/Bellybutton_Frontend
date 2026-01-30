# 🎯 BellyButton App - Easy QA Tutorial

<div align="center">

**Your Complete Guide to Testing the BellyButton App**

[Getting Started](#-getting-started) • [Features](#-features-overview) • [Test Cases](#-test-cases) • [FAQ](#-faq)

</div>

---

## 📋 Quick Start

### What You'll Need

| Requirement | Details |
|-------------|---------|
| 📱 **Test Device** | Android 5.0+ or iOS 12.0+ |
| 📲 **Test Build** | APK (Android) or TestFlight (iOS) |
| 📞 **Phone Number** | For OTP verification |
| 🌐 **Internet** | WiFi or Mobile Data |

### Installation

<details>
<summary><b>Android Installation</b></summary>

1. Download the APK from Firebase App Distribution
2. Open the downloaded file
3. If prompted, allow "Install from unknown sources"
4. Tap **Install**
5. Open the app

</details>

<details>
<summary><b>iOS Installation</b></summary>

1. Install TestFlight from App Store
2. Open the TestFlight invitation link
3. Tap **Accept** on the invitation
4. Tap **Install** for BellyButton
5. Open the app

</details>

---

## 🎬 Getting Started

### First Launch Flow

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   📱 Open App                                               │
│      ↓                                                      │
│   📖 Onboarding Slides (swipe through 3-4 screens)         │
│      ↓                                                      │
│   📞 Enter Phone Number                                     │
│      ↓                                                      │
│   🔢 Enter OTP (6 digits from SMS)                         │
│      ↓                                                      │
│   📜 Accept Terms & Conditions (first time only)           │
│      ↓                                                      │
│   👤 Setup Profile (name, photo - first time only)         │
│      ↓                                                      │
│   🏠 Dashboard (You're in!)                                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🗂️ Features Overview

### App Structure

```
BellyButton App
│
├── 🏠 Dashboard
│   ├── 📅 Upcoming Events (future events)
│   └── 📜 Past Events (completed events)
│
├── ➕ Create Event
│   ├── Event Name & Description
│   ├── Date & Time Picker
│   └── Timezone Selection
│
├── 📸 Event Gallery
│   ├── View Photos
│   ├── Upload Photos
│   ├── Slideshow Preview
│   ├── Multi-Capture Camera
│   └── Share Gallery
│
├── 📅 Calendar Sync
│   ├── Sync Event to Device Calendar
│   ├── Update Calendar Events
│   └── Remove Calendar Events
│
├── 👥 Invitations
│   ├── Send Invites (to your events)
│   └── Received Invites (from others)
│
├── 🔔 Notifications
│   └── All app notifications
│
└── 👤 Profile
    ├── Edit Profile
    ├── Settings
    └── Logout
```

---

## 🧪 Test Cases

### Module 1: Authentication

#### 📞 Phone Login

<table>
<tr>
<th>Test</th>
<th>Steps</th>
<th>Expected</th>
<th>Status</th>
</tr>
<tr>
<td><b>AUTH-001</b><br/>Valid Login</td>
<td>
1. Open app<br/>
2. Select your country<br/>
3. Enter valid phone number<br/>
4. Check "I agree to T&C"<br/>
5. Tap Continue
</td>
<td>
✅ OTP screen opens<br/>
✅ SMS received within 30 sec
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
<tr>
<td><b>AUTH-002</b><br/>Invalid Phone</td>
<td>
1. Enter short/invalid number<br/>
2. Tap Continue
</td>
<td>
✅ Error message shown<br/>
✅ Cannot proceed
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
<tr>
<td><b>AUTH-003</b><br/>T&C Required</td>
<td>
1. Enter valid phone<br/>
2. Don't check T&C box<br/>
3. Try to continue
</td>
<td>
✅ Button disabled OR<br/>
✅ Error shown
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
</table>

#### 🔢 OTP Verification

<table>
<tr>
<th>Test</th>
<th>Steps</th>
<th>Expected</th>
<th>Status</th>
</tr>
<tr>
<td><b>OTP-001</b><br/>Valid OTP</td>
<td>
1. Enter correct 6-digit OTP<br/>
2. Wait for auto-submit or tap verify
</td>
<td>
✅ Login successful<br/>
✅ Goes to Dashboard/Profile
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
<tr>
<td><b>OTP-002</b><br/>Wrong OTP</td>
<td>
1. Enter incorrect OTP<br/>
2. Try to verify
</td>
<td>
✅ "Invalid OTP" error<br/>
✅ Can retry
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
<tr>
<td><b>OTP-003</b><br/>Resend OTP</td>
<td>
1. Wait 30 seconds<br/>
2. Tap "Resend OTP"
</td>
<td>
✅ New OTP sent<br/>
✅ Timer resets to 30s
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
<tr>
<td><b>OTP-004</b><br/>SMS Auto-fill (Android)</td>
<td>
1. Wait for SMS<br/>
2. Observe auto-fill
</td>
<td>
✅ OTP auto-fills<br/>
✅ Auto-submits or ready to submit
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
</table>

---

### Module 2: Dashboard

#### 🏠 Main Screen

<table>
<tr>
<th>Test</th>
<th>Steps</th>
<th>Expected</th>
<th>Status</th>
</tr>
<tr>
<td><b>DASH-001</b><br/>View Upcoming</td>
<td>
1. Login to app<br/>
2. Check Upcoming tab
</td>
<td>
✅ Future events listed<br/>
✅ Sorted by date (nearest first)
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
<tr>
<td><b>DASH-002</b><br/>View Past</td>
<td>
1. Tap "Past" tab
</td>
<td>
✅ Past events shown<br/>
✅ Sorted by date (recent first)
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
<tr>
<td><b>DASH-003</b><br/>Empty State</td>
<td>
1. New user with no events<br/>
2. Check both tabs
</td>
<td>
✅ "No events" message<br/>
✅ Create event prompt shown
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
<tr>
<td><b>DASH-004</b><br/>Pull to Refresh</td>
<td>
1. Pull down on event list
</td>
<td>
✅ Refresh indicator shown<br/>
✅ Data reloads
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
</table>

---

### Module 3: Event Creation

#### ➕ Create Event

<table>
<tr>
<th>Test</th>
<th>Steps</th>
<th>Expected</th>
<th>Status</th>
</tr>
<tr>
<td><b>EVT-001</b><br/>Create Valid Event</td>
<td>
1. Tap + button<br/>
2. Enter event name<br/>
3. Add description<br/>
4. Select future date<br/>
5. Set start & end time<br/>
6. Tap Create
</td>
<td>
✅ Event created<br/>
✅ Appears in Upcoming
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
<tr>
<td><b>EVT-002</b><br/>Past Date Error</td>
<td>
1. Try to select yesterday's date
</td>
<td>
✅ Date not selectable OR<br/>
✅ Error when creating
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
<tr>
<td><b>EVT-003</b><br/>Missing Name</td>
<td>
1. Leave name empty<br/>
2. Fill other fields<br/>
3. Tap Create
</td>
<td>
✅ Validation error<br/>
✅ "Name required" message
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
</table>

---

### Module 4: Event Gallery

#### 📸 Photos

<table>
<tr>
<th>Test</th>
<th>Steps</th>
<th>Expected</th>
<th>Status</th>
</tr>
<tr>
<td><b>GAL-001</b><br/>View Gallery</td>
<td>
1. Tap on any event card
</td>
<td>
✅ Gallery opens<br/>
✅ Photos in grid layout
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
<tr>
<td><b>GAL-002</b><br/>Photo Preview</td>
<td>
1. Tap on any photo
</td>
<td>
✅ Full-screen preview<br/>
✅ Can pinch to zoom
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
<tr>
<td><b>GAL-003</b><br/>Swipe Navigation</td>
<td>
1. Open photo preview<br/>
2. Swipe left/right
</td>
<td>
✅ Navigate between photos<br/>
✅ Smooth animation
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
</table>

#### 📤 Upload Photos

<table>
<tr>
<th>Test</th>
<th>Steps</th>
<th>Expected</th>
<th>Status</th>
</tr>
<tr>
<td><b>UPL-001</b><br/>Single Upload</td>
<td>
1. Open event gallery<br/>
2. Tap upload button<br/>
3. Select 1 photo<br/>
4. Confirm upload
</td>
<td>
✅ Photo uploads<br/>
✅ Appears in gallery
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
<tr>
<td><b>UPL-002</b><br/>Multiple Upload</td>
<td>
1. Tap upload button<br/>
2. Select 5 photos<br/>
3. Confirm upload
</td>
<td>
✅ Progress shown<br/>
✅ All photos appear
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
<tr>
<td><b>UPL-003</b><br/>Permission Denied</td>
<td>
1. Tap upload<br/>
2. Deny gallery permission
</td>
<td>
✅ Permission error shown<br/>
✅ Option to open settings
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
</table>

#### 🎬 Slideshow Preview

<table>
<tr>
<th>Test</th>
<th>Steps</th>
<th>Expected</th>
<th>Status</th>
</tr>
<tr>
<td><b>SLIDE-001</b><br/>Auto-play Slideshow</td>
<td>
1. Open event gallery with photos<br/>
2. Tap slideshow icon<br/>
3. Observe auto-play
</td>
<td>
✅ Slideshow opens<br/>
✅ Photos auto-advance<br/>
✅ Progress bar shows
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
<tr>
<td><b>SLIDE-002</b><br/>Manual Navigation</td>
<td>
1. Open slideshow<br/>
2. Tap pause<br/>
3. Use arrows to navigate
</td>
<td>
✅ Playback pauses<br/>
✅ Arrows navigate photos<br/>
✅ Can resume playback
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
<tr>
<td><b>SLIDE-003</b><br/>Face Filter Carousel</td>
<td>
1. Open slideshow<br/>
2. View face carousel overlay<br/>
3. Tap on a member face
</td>
<td>
✅ Face carousel visible<br/>
✅ Member photos show<br/>
✅ Filter applied when tapped
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
</table>

#### 📷 Multi-Capture Camera

<table>
<tr>
<th>Test</th>
<th>Steps</th>
<th>Expected</th>
<th>Status</th>
</tr>
<tr>
<td><b>CAM-001</b><br/>Capture Multiple Photos</td>
<td>
1. Open camera from gallery<br/>
2. Take 3+ photos<br/>
3. Review captured photos
</td>
<td>
✅ Camera opens<br/>
✅ Counter shows photo count<br/>
✅ Thumbnails appear at bottom
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
<tr>
<td><b>CAM-002</b><br/>Camera Controls</td>
<td>
1. Toggle flash button<br/>
2. Switch front/back camera<br/>
3. Observe changes
</td>
<td>
✅ Flash toggles (Off/Auto/On)<br/>
✅ Camera switches smoothly<br/>
✅ Preview updates
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
<tr>
<td><b>CAM-003</b><br/>Delete & Confirm</td>
<td>
1. Take some photos<br/>
2. Tap on thumbnail<br/>
3. Delete a photo<br/>
4. Tap Done
</td>
<td>
✅ Preview opens on tap<br/>
✅ Photo deleted<br/>
✅ Remaining photos upload
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
</table>

---

### Module 5: Calendar Sync

#### 📅 Device Calendar Integration

<table>
<tr>
<th>Test</th>
<th>Steps</th>
<th>Expected</th>
<th>Status</th>
</tr>
<tr>
<td><b>CAL-001</b><br/>Sync New Event</td>
<td>
1. Create a new event<br/>
2. Check device calendar app
</td>
<td>
✅ Event appears in calendar<br/>
✅ Correct date/time<br/>
✅ Event details match
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
<tr>
<td><b>CAL-002</b><br/>Accept Invitation Sync</td>
<td>
1. Accept an event invitation<br/>
2. Check device calendar
</td>
<td>
✅ Invited event in calendar<br/>
✅ Marked as participant
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
<tr>
<td><b>CAL-003</b><br/>Calendar Permission</td>
<td>
1. Deny calendar permission<br/>
2. Try to create event
</td>
<td>
✅ Permission prompt shown<br/>
✅ App works without sync<br/>
✅ Option to enable in settings
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
<tr>
<td><b>CAL-004</b><br/>Event Update Sync</td>
<td>
1. Edit event date/time<br/>
2. Check device calendar
</td>
<td>
✅ Calendar event updated<br/>
✅ Changes reflected
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
</table>

---

### Module 6: Invitations

#### 📨 Send Invitations

<table>
<tr>
<th>Test</th>
<th>Steps</th>
<th>Expected</th>
<th>Status</th>
</tr>
<tr>
<td><b>INV-001</b><br/>Invite Contact</td>
<td>
1. Open your event<br/>
2. Tap Invite<br/>
3. Select contact<br/>
4. Send invite
</td>
<td>
✅ Invite sent<br/>
✅ Success message
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
<tr>
<td><b>INV-002</b><br/>Invite by Phone</td>
<td>
1. Tap Invite<br/>
2. Enter phone number<br/>
3. Add to list<br/>
4. Send invite
</td>
<td>
✅ Invite sent to number<br/>
✅ User receives notification
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
</table>

#### 📬 Receive Invitations

<table>
<tr>
<th>Test</th>
<th>Steps</th>
<th>Expected</th>
<th>Status</th>
</tr>
<tr>
<td><b>INV-003</b><br/>Accept Invite</td>
<td>
1. Open Invitations<br/>
2. Find pending invite<br/>
3. Tap Accept
</td>
<td>
✅ Event added to your list<br/>
✅ Can view gallery
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
<tr>
<td><b>INV-004</b><br/>Reject Invite</td>
<td>
1. Open Invitations<br/>
2. Find pending invite<br/>
3. Tap Reject/Decline
</td>
<td>
✅ Invite removed<br/>
✅ Not added to events
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
</table>

---

### Module 6: Notifications

#### 🔔 Notification Center

<table>
<tr>
<th>Test</th>
<th>Steps</th>
<th>Expected</th>
<th>Status</th>
</tr>
<tr>
<td><b>NOT-001</b><br/>View All</td>
<td>
1. Tap bell icon
</td>
<td>
✅ Notification list opens<br/>
✅ Shows all notifications
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
<tr>
<td><b>NOT-002</b><br/>Unread Badge</td>
<td>
1. Have unread notifications<br/>
2. Check bell icon
</td>
<td>
✅ Badge shows count<br/>
✅ Count is accurate
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
<tr>
<td><b>NOT-003</b><br/>Push Notification</td>
<td>
1. Close app<br/>
2. Have someone invite you<br/>
3. Check phone notifications
</td>
<td>
✅ Push notification appears<br/>
✅ Tapping opens app
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
</table>

---

### Module 7: Sharing & Deep Links

#### 🔗 Share Event

<table>
<tr>
<th>Test</th>
<th>Steps</th>
<th>Expected</th>
<th>Status</th>
</tr>
<tr>
<td><b>SHARE-001</b><br/>Generate Link</td>
<td>
1. Open your event<br/>
2. Tap Share button
</td>
<td>
✅ Share sheet opens<br/>
✅ Link is generated
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
<tr>
<td><b>SHARE-002</b><br/>Open Link (Logged In)</td>
<td>
1. Copy event link<br/>
2. Open in browser<br/>
3. App should open
</td>
<td>
✅ App opens<br/>
✅ Goes to event gallery
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
<tr>
<td><b>SHARE-003</b><br/>Public Gallery</td>
<td>
1. Share link to non-user<br/>
2. They open in browser
</td>
<td>
✅ Gallery visible in browser<br/>
✅ No login required
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
</table>

---

### Module 8: Profile

#### 👤 Profile Management

<table>
<tr>
<th>Test</th>
<th>Steps</th>
<th>Expected</th>
<th>Status</th>
</tr>
<tr>
<td><b>PROF-001</b><br/>View Profile</td>
<td>
1. Tap profile icon
</td>
<td>
✅ Profile screen opens<br/>
✅ Shows your info
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
<tr>
<td><b>PROF-002</b><br/>Edit Profile</td>
<td>
1. Open profile<br/>
2. Change name<br/>
3. Save
</td>
<td>
✅ Changes saved<br/>
✅ Name updated everywhere
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
<tr>
<td><b>PROF-003</b><br/>Logout</td>
<td>
1. Open profile<br/>
2. Tap Logout<br/>
3. Confirm
</td>
<td>
✅ Logged out<br/>
✅ Returns to login screen
</td>
<td>☐ Pass ☐ Fail</td>
</tr>
</table>

---

## 🔄 End-to-End Scenarios

### Scenario A: New User Journey

```
📱 Step 1: Install & Open App
   └── See onboarding slides

📞 Step 2: Phone Login
   └── Enter number → Get OTP → Verify

👤 Step 3: Setup Profile
   └── Add name, photo → Save

➕ Step 4: Create First Event
   └── Add details → Create

👥 Step 5: Invite Friends
   └── Select contacts → Send invites

📸 Step 6: Upload Photos
   └── Select photos → Upload

🔗 Step 7: Share Event
   └── Generate link → Share via WhatsApp
```

**✅ Test Status**: ☐ All steps completed successfully

---

### Scenario B: Invited User Journey

```
📬 Step 1: Receive Invitation
   └── Get push notification

📱 Step 2: Open App
   └── See pending invitation

✅ Step 3: Accept Invitation
   └── Tap Accept

📅 Step 4: View Event
   └── Event appears in your list

📸 Step 5: View Photos
   └── Open gallery, browse photos

📤 Step 6: Upload Your Photos
   └── Add your own photos
```

**✅ Test Status**: ☐ All steps completed successfully

---

### Scenario C: Photo Sync Between Users

```
👤 User A (Creator)          👤 User B (Invited)
      │                            │
      ├── Creates event            │
      │                            │
      ├── Invites User B ─────────►│
      │                            │
      │                            ├── Accepts invitation
      │                            │
      ├── Uploads 5 photos         │
      │                            │
      │◄─────────────────────────── │ Sees 5 photos
      │                            │
      │                            ├── Uploads 3 photos
      │                            │
      ├── Sees all 8 photos ◄──────│
      │                            │
```

**✅ Test Status**: ☐ Photos sync correctly for both users

---

## ⚠️ Error Handling Tests

### Network Errors

| Scenario | How to Test | Expected |
|----------|-------------|----------|
| **No Internet** | Turn on Airplane Mode, try any action | "No internet" message |
| **Slow Connection** | Use network throttling | Loading indicators shown |
| **Server Timeout** | Wait 30+ seconds | Timeout error with retry |

### Permission Errors

| Scenario | How to Test | Expected |
|----------|-------------|----------|
| **Camera Denied** | Deny camera permission | Error + Settings option |
| **Gallery Denied** | Deny storage permission | Error + Settings option |
| **Calendar Denied** | Deny calendar permission | Event created, no sync + Settings option |
| **Notifications Denied** | Deny notification permission | Works but no push |

### Session Errors

| Scenario | How to Test | Expected |
|----------|-------------|----------|
| **Token Expired** | Wait for session timeout | Redirected to login |
| **Account Deleted** | Try to login after deletion | Appropriate error |

---

## 📱 Device Testing Matrix

### Android Devices

| Device | OS | Screen | Priority | Tested |
|--------|----|---------|---------:|:------:|
| Samsung Galaxy S21 | Android 13 | 6.2" | High | ☐ |
| Google Pixel 6 | Android 14 | 6.4" | High | ☐ |
| Samsung Galaxy A52 | Android 12 | 6.5" | Medium | ☐ |
| OnePlus 9 | Android 13 | 6.55" | Medium | ☐ |
| Any device | Android 5-6 | Any | Low | ☐ |

### iOS Devices

| Device | OS | Screen | Priority | Tested |
|--------|----|---------|---------:|:------:|
| iPhone 14 Pro | iOS 17 | 6.1" | High | ☐ |
| iPhone 13 | iOS 16 | 6.1" | High | ☐ |
| iPhone SE (2nd) | iOS 15 | 4.7" | Medium | ☐ |
| iPhone 11 | iOS 15 | 6.1" | Medium | ☐ |
| iPad | iOS 15+ | Various | Low | ☐ |

---

## 🐛 Bug Report Template

When you find a bug, copy this template:

```
## 🐛 Bug Report

**Title**: [Short description]

**Environment**:
- App Version: 1.0.2+6
- Device: [e.g., iPhone 14 Pro]
- OS: [e.g., iOS 17.2]
- Environment: [Dev/QA/Prod]

**Steps to Reproduce**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected**: [What should happen]

**Actual**: [What actually happened]

**Screenshot/Video**: [Attach file]

**Severity**:
- [ ] 🔴 Critical (crash/data loss)
- [ ] 🟠 High (feature broken)
- [ ] 🟡 Medium (workaround exists)
- [ ] 🟢 Low (cosmetic issue)
```

---

## ✅ Daily Smoke Test Checklist

Run this every day before testing:

```
☐ App launches without crash
☐ Can login with valid phone/OTP
☐ Dashboard loads with events
☐ Can create a new event
☐ Event syncs to device calendar
☐ Can open event gallery
☐ Can upload a photo
☐ Slideshow preview works
☐ Multi-capture camera works
☐ Push notifications work
☐ Can logout successfully
```

**Time**: ~7 minutes

---

## 📊 Test Summary Report

| Module | Total Tests | Passed | Failed | Blocked |
|--------|:-----------:|:------:|:------:|:-------:|
| Authentication | 7 | ☐ | ☐ | ☐ |
| Dashboard | 4 | ☐ | ☐ | ☐ |
| Event Creation | 3 | ☐ | ☐ | ☐ |
| Event Gallery | 3 | ☐ | ☐ | ☐ |
| Photo Upload | 3 | ☐ | ☐ | ☐ |
| Slideshow Preview | 3 | ☐ | ☐ | ☐ |
| Multi-Capture Camera | 3 | ☐ | ☐ | ☐ |
| Calendar Sync | 4 | ☐ | ☐ | ☐ |
| Invitations | 4 | ☐ | ☐ | ☐ |
| Notifications | 3 | ☐ | ☐ | ☐ |
| Sharing | 3 | ☐ | ☐ | ☐ |
| Profile | 3 | ☐ | ☐ | ☐ |
| **TOTAL** | **43** | **☐** | **☐** | **☐** |

---

## ❓ FAQ

<details>
<summary><b>Q: How do I get the test build?</b></summary>

**Android**: Request APK from development team or check Firebase App Distribution.

**iOS**: Accept TestFlight invitation sent to your email.

</details>

<details>
<summary><b>Q: What phone number should I use for testing?</b></summary>

Use your real phone number to receive OTP. For shared test accounts, contact the development team.

</details>

<details>
<summary><b>Q: The OTP is not arriving, what should I do?</b></summary>

1. Wait 30 seconds and tap "Resend"
2. Check if your number is correct
3. Check SMS spam folder
4. Try again after 5 minutes

</details>

<details>
<summary><b>Q: How do I test push notifications?</b></summary>

1. Login on Device A
2. Login on Device B with different account
3. From Device A, invite Device B's user
4. Device B should receive push notification

</details>

<details>
<summary><b>Q: App is crashing, what info do I need?</b></summary>

1. Device model and OS version
2. Exact steps to reproduce
3. Screen recording if possible
4. App version number

</details>

---

## 📞 Support Contacts

| Role | Contact |
|------|---------|
| **Lead Developer** | Aravinth Kannan |
| **Email** | flutterdev.aravinth@gmail.com |

---

<div align="center">

**Happy Testing! 🎉**

*BellyButton QA Easy Tutorial v1.0.2+6*
*Updated: January 2026*

</div>
