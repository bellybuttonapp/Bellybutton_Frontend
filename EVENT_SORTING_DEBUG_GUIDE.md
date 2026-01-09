# Event Sorting Debug Guide

## How to Verify Your Event Sorting is Working Correctly

### Your Event Details:
- **Start Time**: 2:55 PM (14:55)
- **End Time**: 3:30 PM (15:30)
- **Created**: Today (January 3, 2026)

---

## Expected Behavior

### Current Time: ~2:51 PM (14:51)

Your event **should appear in UPCOMING EVENTS** because:
```
Current Time: 2:51 PM (14:51)
Event End Time: 3:30 PM (15:30)
3:30 PM > 2:51 PM ✅ TRUE
→ Shows in UPCOMING
```

### At 3:31 PM (After Event Ends)

Your event **should move to PAST EVENTS** because:
```
Current Time: 3:31 PM (15:31)
Event End Time: 3:30 PM (15:30)
3:30 PM < 3:31 PM ✅ TRUE
→ Shows in PAST
```

---

## How to Check If It's Working

### Method 1: Check Console Logs

Your controllers have debug logging built-in. Look for these logs:

1. **Open your terminal/console**
2. **Look for debug output** like this:

```
🔍 Event: [Your Event Title]
   eventDate: 2026-01-03 00:00:00.000
   startTime: 14:55:00
   endTime: 15:30:00
   fullEventEndDateTime: 2026-01-03 15:30:00.000
   now: 2026-01-03 14:51:xx.xxx
   isAfter now: true
```

**What to check:**
- ✅ `fullEventEndDateTime` = `2026-01-03 15:30:00` (3:30 PM today)
- ✅ `now` = Current time (should be ~14:51 right now)
- ✅ `isAfter now` = `true` (means it shows in UPCOMING)

### Method 2: Visual Check in App

1. **Go to Upcoming Events tab**
   - Your event should be there
   - Should show: "2:55 PM - 3:30 PM"

2. **Go to Past Events tab**
   - Your event should NOT be there (yet)

3. **Wait until 3:31 PM**
   - Pull to refresh Upcoming Events → Event disappears
   - Pull to refresh Past Events → Event appears

---

## Troubleshooting

### Problem 1: Event Shows in Wrong Tab

**If event shows in PAST instead of UPCOMING:**

**Possible Causes:**
1. **Timezone issue** - Backend might be using different timezone
2. **Date parsing issue** - Date might be yesterday instead of today

**Check console logs for:**
```
eventDate: 2026-01-03   ← Should be today
fullEventEndDateTime: 2026-01-03 15:30:00  ← Should be 3:30 PM today
now: 2026-01-03 14:51:xx  ← Current time
```

**Fix:** Check your event creation - make sure you're selecting today's date.

---

### Problem 2: Event Doesn't Appear at All

**Possible Causes:**
1. **API didn't save the event**
2. **Event fetch failed**

**Check console logs for:**
```
📦 All Events Response: X items  ← Should include your event
```

**Fix:** Try creating the event again or check API response.

---

### Problem 3: Event Still in UPCOMING After 3:30 PM

**Possible Causes:**
1. **Page not refreshed**
2. **Caching issue**

**Fix:** Pull down to refresh the list.

---

## Quick Test Script

To test the sorting logic manually:

### Current Time Check
```dart
final now = DateTime.now();
print("Current time: $now");
```

### Your Event
```dart
final eventDate = DateTime(2026, 1, 3);
final startTime = "14:55:00";
final endTime = "15:30:00";

// Parse end time
final parts = endTime.split(':');
final hour = int.parse(parts[0]);
final minute = int.parse(parts[1]);

final fullEventEndDateTime = DateTime(
  eventDate.year,
  eventDate.month,
  eventDate.day,
  hour,
  minute,
  0,
);

print("Event end time: $fullEventEndDateTime");
print("Is upcoming: ${fullEventEndDateTime.isAfter(now)}");
```

**Expected Output (at 2:51 PM):**
```
Current time: 2026-01-03 14:51:xx.xxx
Event end time: 2026-01-03 15:30:00.000
Is upcoming: true
```

**Expected Output (at 3:31 PM):**
```
Current time: 2026-01-03 15:31:xx.xxx
Event end time: 2026-01-03 15:30:00.000
Is upcoming: false
```

---

## Screenshots to Check

### Right Now (2:51 PM) - UPCOMING TAB
Should show:
```
┌─────────────────────────────────┐
│  [Your Event Title]             │
│  📅 Jan 3, 2026                 │
│  🕐 2:55 PM - 3:30 PM           │
│  ▶ Event starts in 4 minutes    │
└─────────────────────────────────┘
```

### Right Now (2:51 PM) - PAST TAB
Should show:
```
┌─────────────────────────────────┐
│  No past events found           │
│  (or other past events,         │
│   but NOT your current event)   │
└─────────────────────────────────┘
```

### At 3:31 PM - UPCOMING TAB
Should show:
```
┌─────────────────────────────────┐
│  No upcoming events found       │
│  (or other future events,       │
│   but NOT your current event)   │
└─────────────────────────────────┘
```

### At 3:31 PM - PAST TAB
Should show:
```
┌─────────────────────────────────┐
│  [Your Event Title]             │
│  📅 Jan 3, 2026                 │
│  🕐 2:55 PM - 3:30 PM           │
│  ✓ Ended 1 minute ago           │
└─────────────────────────────────┘
```

---

## What to Report Back

Please check and let me know:

1. **Where is the event showing right now?**
   - [ ] Upcoming Events
   - [ ] Past Events
   - [ ] Not showing at all

2. **What do the console logs say?**
   - Copy the lines with `🔍 Event:` for your event
   - Include the `fullEventEndDateTime` and `isAfter now` values

3. **What time is it when you checked?**
   - Before 3:30 PM or after?

4. **Did you pull to refresh?**
   - Yes / No

---

## Expected Timeline

```
2:51 PM ← Current time
2:55 PM → Event starts
3:00 PM → Event ongoing (still UPCOMING)
3:30 PM → Event ends
3:31 PM → Event becomes PAST (after refresh)
```

**Key Point:** The event moves from UPCOMING to PAST at **3:30 PM** (the end time), not at 2:55 PM (the start time).

---

## Summary

✅ **Working correctly if:**
- Event shows in UPCOMING right now (before 3:30 PM)
- Console shows `isAfter now: true`
- Event moves to PAST after 3:30 PM (with refresh)

❌ **Not working if:**
- Event shows in PAST right now (before 3:30 PM)
- Console shows `isAfter now: false`
- Event doesn't appear at all

Let me know what you find!
